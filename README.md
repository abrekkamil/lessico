# Lessico Drill on your phone

Four files that together are a complete offline study app. No server, no
account, no build step: put them on any static host and open the URL.

```
index.html            the whole app
sw.js                 service worker, so it opens with no signal
manifest.webmanifest  makes it installable to the home screen
icon.svg
```

## Putting it online

Any of these is free and takes a few minutes. **GitHub Pages** is the one to
pick if you already have an account, since you have a repository habit already.

**GitHub Pages**
1. Make a repository, public, called something like `lessico`.
2. Upload these four files to the root.
3. Settings → Pages → Source: `Deploy from a branch`, branch `main`, folder
   `/ (root)`. Save.
4. A minute later it is at `https://<your-username>.github.io/lessico/`.

**Cloudflare Pages** or **Netlify**: create a project, drag the folder onto the
deploy area, done. Both give an HTTPS URL immediately.

HTTPS matters: a service worker will not register over plain HTTP, so the
offline part only works on a real host, not on a file:// path.

## Installing it

Open the URL on the phone.

* **iPhone**: Share → Add to Home Screen. It then runs full screen with no
  browser chrome and keeps working in aeroplane mode.
* **Android**: the three-dot menu → Install app, or the prompt Chrome offers.

Everything lives in the phone's own storage after that, so a walk with no
signal is fine. Do not use private browsing: it is cleared when you close it.

## Getting your words onto it

1. Desktop app → **Phone sync** → **Export collection for phone**. That writes
   one JSON file with the words, meanings, sentences and your current progress.
2. Get the file to the phone: email it to yourself, put it in Drive or
   iCloud, or use a cable. Anything that ends with the file on the phone.
3. In the web app tap **Load a file** on the welcome screen and choose it.

Do this again only when the workbook itself changes, for example after adding
A2 words. It is roughly 600 KB for a thousand-word collection.

## Automatic sync (recommended)

Instead of carrying files, both devices can talk to one small free database
and keep themselves in step.

**Set it up once, about five minutes.** After this the phone needs no files
at all: it pulls the words down from the same database.

1. Make a free project at supabase.com. Any region; the nearest is fastest.
2. Open the **SQL editor**, paste in `supabase-setup.sql` from the desktop
   package, and run it. That creates two tables and their policies.
3. In **Project Settings → API**, copy the **Project URL** and the
   **anon public** key.
4. Desktop app → **Phone sync**: paste both, keep the suggested collection
   name, tick *Sync when the app opens and when a session ends*, then
   **Save and test** and **Sync now**.
5. Desktop → **Upload words** in the same dialog. That puts the whole
   collection in the database, so a phone can set itself up from nothing.
   Repeat it only when the workbook changes.
6. Phone → **Download from the database** on the welcome screen: paste the
   same three values, turn on the same switch, then **Download words**.

After that neither device needs anything from you. Each sync sends only the
cards that changed, so a session's worth is a few kilobytes and works fine on
mobile data. The first one is larger because it seeds the table.

**A word on the key.** The anon key is designed to sit in a public app, and
the tables have no login, so anyone holding both your project URL and your key
could read your vocabulary progress. That is why the collection name is a
random string rather than "italian": it is what actually keeps the collection
private. Do not commit the key to the public GitHub repository. Type it into
the phone directly, where it is stored only in the phone's own database.

If a sync fails, nothing is lost. The devices simply diverge until the next
one, and per-card merging sorts it out then. With no signal the app says so
plainly and tries again next time. The offline copy holds only the app's own
files and texts, never answers from the database.

**Recommended upgrade.** Run `supabase-upgrade.sql` from this repository
once, in the same SQL editor. It does two things. It adds the `reading`
table, so finished texts, their answers, the words added while reading and
grammar progress reach your other phones (see Reading below); until then reading stays on the
phone it happened on, and the Sync tab says so. And it fixes a gap in how
changes are found. Each sync only asks for what changed since the
last one, and without this the "since" is measured by when a card was
studied. Answers given offline on a walk then look older than the other
device's last sync and can be skipped. The upgrade lets the database stamp
each upload itself. The phone notices it within ten minutes; until it is
run, the phone reaches back a day on every sync to be safe. The desktop needs the same
change to its own pull (see `cloud.py`), so until then its pulls can still
miss answers made offline. Use **Full resync** on the desktop if they
disagree.

## Studying on both

Progress files are small and carry only what changed.

**Before going out**: desktop → Phone sync → **Export progress**, load it on
the phone with **Sync → Import a file**.

**When you get back**: phone → **Sync → Export my progress**, then desktop → Phone
sync → **Import progress**.

Merging is per card and the newer answer wins, so the order does not matter and
nothing is lost if you forget a step. A card you studied on the phone updates
the desktop; a card you did not touch is left alone. Reviews are merged too, so
the activity chart is the same on both.

Skipping a sync is not a disaster either. The two copies simply diverge until
the next one, and then each card takes whichever answer was later.

## Sorting and adding words

The phone has the sorting pass too: the word alone, and you answer *I know
this*, *Hint* or *New to me*. It is the quickest way to place a fresh list, and
it works on a walk.

**Add a word** on the home screen takes something you met during the day. It
starts in the sorting pass, and the desktop adopts it on the next sync,
rebuilding the gap sentence from your example. Another phone on the same
collection takes it in on its next sync too, without waiting for the desktop.
Downloading the words again keeps words made on the phone that the desktop
has not taken in yet, and keeps everything done in the Read tab.

## Words, progress and sorting on the phone

**Words** and **Progress** are tabs along the bottom. Words lists everything
with a search box and filters, showing where each word sits: which level,
which box, and when it is next due. Its box filter opens a complete list for
any of the seven flashcard boxes or six Level 2 boxes. The box counts in
Progress are tappable too. Progress also shows a streak and the last
fortnight's activity.

**How Lessico works** on the Home screen is the in-app guide. It explains the
recommended first steps, every box exercise and interval, the actual dates a
clean pass would produce today, reading unlocks, the three different reading
lists, and the difference between graded sessions and Free practice.

**Sort** on the home screen opens the waiting list rather than showing words
at random. Filter by part of speech, level or topic, tap anything you already
know, and sort the rest one by one.

Each collection is stored separately, so Italian and Turkish can both live on
the phone without disturbing each other. The language button at the top of
the home screen moves between them or starts another. Each language needs its
own collection name in sync settings. The phone remembers the database address
and key from the first language, so adding another asks only for its
collection name. Typing a name the
phone does not know while words are open asks whether it is another language
or a new name for these words, and before anything is sent the phone checks
that the collection holds the same language.

## Word details and listening

Once a word has been answered, its card shows **Details**: tap it for
everything the desktop knows about the word. That means each meaning with its
example and note, the example sentences with the word marked, the
explanations and the common phrases. Tapping a word in the **Words** tab
opens the same sheet.

When a collection includes the generated `reading_texts` index, the Words tab
also shows how many reading texts contain each word and can filter to **In
reading texts** or **Not in reading texts**. Word details list the text title,
ID, level and whether the match was an explicit lemma mapping or exact visible
wording: the first five, and the rest a tap away. This makes the uncovered
vocabulary list usable as the plan for new reading texts. A word added from a
text on the phone is not in the desktop's index yet, so it takes the same kind
of entry from the texts on the phone.

The speaker buttons say the word or sentence aloud with the phone's own
voices. That costs nothing, needs no key and works offline. Next to a word's
speaker is a turtle that says it slowly, to catch every sound and repeat it.
Tap the speaker again within a few seconds and it is slower too.

During a session the word is said by itself. When the card shows it (the word
to give the meaning of, a sentence to translate), you hear it as the card
appears. When the card shows the English and you type the word, it is said
once you have answered, and the card's own speakers then say it again at
either speed. The speaker in the session bar turns this off and on; the phone
remembers the choice, and the buttons still work while it is off. The voice
itself is chosen in **Settings** (see below). If the device has no voice
for the language, it says so and where to add one. On an iPhone, voices are
added under Settings › Accessibility › Spoken Content › Voices, and the
*Enhanced* ones sound much better. On a Windows computer, Microsoft Edge has
Turkish, Italian and most other voices built in. Chrome brings only a few of
its own, Italian among them but not Turkish, and otherwise uses the voices
added to Windows under Settings › Time & language › Speech › Add voices.

## Settings

**Settings**, at the bottom of the home screen, keeps two things for this
phone, for every language on it:

* **Words in a session**: 10, 20, 30 or 50. It sets the length of a session,
  a sorting round and a round of free practice. Up to half of a session can be
  words not studied yet.
* **Voice**: every voice the phone has for the language open now, with
  *Automatic* (the best one) at the top. Tap one to choose it and hear it.
  Voices belong to each device, so each phone keeps its own choice. The
  switch for saying words by themselves is here too.

## Free practice

**Free practice**, under the exercises on the home screen, is for playing
with words without touching their progress: no card moves, nothing becomes
due and nothing counts as a review. Pick the words by level, kind (nouns,
verbs, adjectives and so on), topic, and whether you have met them, then one
of three games:

* **Flip**: see the card, think of the answer, turn it.
* **Choose**: pick the right one of four.
* **Type**: see the English and type the word.

Flip and Choose go from the word to English, from English to the word, or
mixed. A round takes words at random, and at the end you can play the ones
you missed again. The phone remembers the last set-up.

A word's level is the reviewed CEFR level stored in its collection. When a
manually added word has no level yet, the first reading text that uses it can
provide one.

## Reading

The **Read** tab has short texts from A1 to B2 in Italian and Turkish, from
easy to hard. They are original texts written for the app (in
`reading/it.json` and `reading/tr.json`), each with its English translation.
They start with a few sentences about one person and work up to ads, menus,
timetables, messages, a diary, short biographies and a survey with
percentages. Italian now has 140 A1 texts and Turkish has 100; both languages
have 40 A2 texts, a little longer and
with past tenses, some in short series that follow one story over two or
three texts. The same people come back from text to text, so their words do
too. A phrase the text explains as one, such as *öğleden sonra* or *fare la
spesa*, is tapped and added as one. Its sheet also lists the words inside it
that the text explains on their own (*öğle*, *sonra*), each ready to add, and
the word check after a text finds such a word inside its phrase.
The method follows exam-style reading books such as METU's *Reader at Work*:
- **Before you read**, a question gets you thinking about the topic.
- **Recycled words:** the words you met in earlier texts come back. They are
  listed so you can check you still remember them, and marked in the text.
- **Numbered paragraphs:** each can be heard aloud or shown in English.
- **Questions after the text:** true, false or not given; details; what a
  word refers to; a meaning guessed from context; the main idea. Then a quick
  check on two words from before and two new ones.

**A text opens once you have met 80% of its words.** Met means the word is
in your words and past the sorting pass: it does not have to be learnt yet.
A closed text shows a lock and how much of it you know. Tapping it shows
its words and offers a short deck first: the words not met yet (those your
list lacks are added from the text, with their sentence, and tagged
*reading*), sorted first because that is what opens the text, then those of
its words that are due. Words in a box and not due are left alone. A deck is
as long as a session, or longer when the text needs more to open. When it
ends you go straight back to the text. An open text with a few words still
due or unmet offers them before you read, without insisting. A finished text
always opens again.

Tap any word you don't know to add it to your words. It goes straight into
flashcards, with the sentence from the text as its example, and is tagged
*reading* in the Words tab. **My reading words** in the Read tab lists only
these, with a button to practise them. The desktop gives phone-made words its
own topic, so the phone keeps the reading tag itself.

With `supabase-upgrade.sql` run, reading syncs like the cards: each finished
text with its score and every answer, and each reading word, which another
phone makes into a card if it has never had it. If both phones read the same
text, the later result wins.

## Grammar

The **Grammar** tab has short A1 lessons, in order. Italian has 15: noun
gender, the articles, regular plurals, adjective agreement, subject pronouns,
*essere* and its uses, *avere*, negation with *non*, basic questions, *c'è*
and *ci sono*, and regular *-are* and *-ire* verbs. Turkish has 4: the vowels
and capital letters (I/ı, İ/i), two-way and four-way vowel harmony, and the
plural *-lar/-ler*. Each lesson explains the rule with tables, a short
dialogue and examples you can hear, then asks about twenty scored questions
and a few short writing self-checks. A lesson is learned at 80% with its
writing checks done, and comes back for review after 1, 3, 7, 14, 30 and 60
days. Answers accept either apostrophe (*c'è* or *c’è*).

Grammar and reading are linked, not gated. A text shows the grammar it uses
most under **Grammar in this text**, one tap from the lesson, and Back
returns to the text. A lesson lists the reading texts that use it, closed
ones with their lock, and a few of their sentences with the grammar marked.
Grammar progress travels with reading through the `reading` table, so every
device shows the same lessons learned and due.

Lessons live in `grammar/<language>/<topic id>.json` and are listed in
`grammar/index.json`. Each entry's `reading` field says how the topic shows up
in a text: its words or phrases (`"words": ["c'è"]`, `"phrases": ["ci sono"]`),
or the kind of word the text glosses (`"pos": ["verb"]`,
`"lemma_endings": ["are"]`), and `min`, how many a text needs to count. A new
topic needs an entry there to appear.

## What the phone does and does not do

It runs the same ladder with the same rules: flashcards in both directions,
the six boxes of level 2, the letter hints, three tries at the meanings, the
marks system and the demotion rules. The wording is generated by the same
logic, so a card behaves identically on both devices.

It does not have the morphology engines. That matters in one place: the
desktop can ask a gap for a specific tense or case because it can generate
that form, whereas the phone uses the forms already stored with each sentence.
In practice you will not notice, since gaps are stored with their answer.
Free writing is also lighter: the phone checks that your sentence contains the
word and leaves the grammar to you, where the desktop runs the full checker.

Use the phone for the walk and the desktop for the sit-down session, and they
stay in step.
