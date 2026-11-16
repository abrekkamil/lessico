-- Optional upgrade to supabase-setup.sql. Run it once in the Supabase SQL
-- editor; running it again does no harm.
--
-- Why: every row carries the time its card was studied. That is the right
-- thing for deciding which device's answer wins, and the wrong thing for
-- "what has changed since my last sync". A phone that studied offline at
-- 10:00 and uploads at noon is invisible to a device whose last sync already
-- reached 11:00, so those answers were never pulled.
--
-- This adds a second time, synced_at, which the database sets itself on every
-- write, so it is always later than anything already read and no device clock
-- is involved. The phone app uses it as soon as it exists and falls back to
-- the old way (with a day of overlap) until then. The desktop keeps working
-- unchanged: it never sends synced_at, and the trigger fills it in.

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

-- so the REST endpoint sees the new column straight away
notify pgrst, 'reload schema';
