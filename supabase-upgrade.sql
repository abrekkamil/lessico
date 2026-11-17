-- Upgrades to supabase-setup.sql (from the desktop package). Run this whole
-- file once in the Supabase SQL editor. Running it again does no harm.
--
-- 1. synced_at on cards and reviews
--
-- Every row carries the time its card was studied. That is the right thing
-- for deciding which device's answer wins, and the wrong thing for "what has
-- changed since my last sync". A phone that studied offline at 10:00 and
-- uploads at noon is invisible to a device whose last sync already reached
-- 11:00, so those answers were never pulled.
--
-- This adds a second time, synced_at, which the database sets itself on every
-- write, so it is always later than anything already read and no device clock
-- is involved. The phone app uses it as soon as it exists and falls back to
-- the old way (with a day of overlap) until then. The desktop keeps working
-- unchanged: it never sends synced_at, and the trigger fills it in.
--
-- 2. the reading table
--
-- What happens in the phone's Read tab: each finished text with its score and
-- answers, and each word added from a text. One row per item, so two phones
-- that read different texts both keep theirs. Without this table reading
-- stays on the phone it happened on; the cards still sync as before.

alter table cards   add column if not exists synced_at timestamptz not null default now();
alter table reviews add column if not exists synced_at timestamptz not null default now();

create or replace function lessico_stamp_synced_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.synced_at := clock_timestamp();
  return new;
end $$;

drop trigger if exists cards_synced_at on cards;
create trigger cards_synced_at before insert or update on cards
  for each row execute function lessico_stamp_synced_at();

drop trigger if exists reviews_synced_at on reviews;
create trigger reviews_synced_at before insert or update on reviews
  for each row execute function lessico_stamp_synced_at();

create index if not exists cards_synced   on cards   (collection, synced_at, word);
create index if not exists reviews_synced on reviews (collection, synced_at, word);

-- item is 'text:<text id>' for a finished text, 'word:<word>' for a word
-- added from a text; state holds what the phone keeps for it
create table if not exists reading (
  collection  text not null,
  item        text not null,
  updated_at  text not null,
  state       jsonb not null,
  synced_at   timestamptz not null default now(),
  primary key (collection, item)
);

drop trigger if exists reading_synced_at on reading;
create trigger reading_synced_at before insert or update on reading
  for each row execute function lessico_stamp_synced_at();

create index if not exists reading_changed on reading (collection, updated_at, item);
create index if not exists reading_synced  on reading (collection, synced_at, item);

-- the same rule as the other tables: the anon key reads and writes, and the
-- unguessable collection name is what keeps a collection private
alter table reading enable row level security;
drop policy if exists reading_all on reading;
create policy reading_all on reading for all using (true) with check (true);

-- so the REST endpoint sees the new column and table straight away
notify pgrst, 'reload schema';
