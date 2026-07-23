# THE DIVA — setup & deploy

## 1. Create the Supabase backend (~5 min)

1. Go to supabase.com → sign up (free) → **New project**. Pick any name/region, set a database password (you won't need it again).
2. Once it's ready: left sidebar → **SQL Editor** → **New query**.
3. Paste the entire contents of `supabase-schema.sql` → **Run**. This creates the two tables and their permissions.
4. Left sidebar → **Storage** → **New bucket** → name it exactly `photos` → toggle **Public bucket** ON → Create.
5. Repeat: **New bucket** → name it exactly `audio` → **Public bucket** ON → Create.
5b. Repeat again: **New bucket** → name it exactly `videos` → **Public bucket** ON → Create.
5c. Back in **SQL Editor** → **New query** → paste and run the **MIGRATION** block at the bottom of `supabase-schema.sql` (adds multi-photo + video-clip support).
6. Left sidebar → **Project Settings** → **API**. Copy two values:
   - **Project URL**
   - **anon public** key (NOT the service_role key — that one must never go in this file)

## 2. Drop your credentials into the site

Open `index.html`, find this near the top of the `<script>` block:

```js
const SUPABASE_URL = "PASTE_YOUR_SUPABASE_URL_HERE";
const SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE";
```

Paste in the two values from step 6. Save.

The anon key is safe to have visible in the page source — it's designed for this. Row Level Security (set up by the SQL script) is what actually controls access, not secrecy of the key.

## 3. Fill in her content

Still in `index.html`:
- Replace every `[BRACKETED PLACEHOLDER]` in the HTML with real content (her name, timeline, stats, chat excerpts, censor board line, riddle).
- Edit the `CONFIG` object (loading messages, riddle answer, both quizzes, closing letter).
- Swap the 8 gallery placeholders for real `<img src="...">` tags once you have photo URLs (see note below).

**On photos for the gallery (reel two):** these are curated by you, not uploaded by wishers, so just host them somewhere (a Supabase `gallery` bucket works the same way as `photos`, or even direct links) and swap the `<figure>` placeholders for `<img>` tags.

## 4. Deploy to Vercel

Easiest path, no terminal needed:
1. Push this folder to a new GitHub repo (or use Vercel's drag-and-drop deploy at vercel.com/new — it accepts a zipped folder).
2. On vercel.com → **New Project** → import the repo (or upload the folder).
3. Framework preset: **Other** / static — no build command needed, it's a single HTML file.
4. Deploy. You'll get a link like `the-diva.vercel.app` — free custom domain aliasing is available too if you want something like `happybirthdayher.vercel.app`.

## 5. Test before sending the group the link

Open the deployed link yourself, go through as a wisher, submit a test entry with a photo and a voice note, refresh, confirm it shows up. Delete your test row afterward from Supabase (Table Editor → `cast_entries` → delete row) so it's clean for real submissions.

## Notes
- Free tier limits (Supabase): 500MB database, 1GB file storage, 2GB bandwidth/month. Way more than enough for a birthday site.
- If a lot of people submit at once and something looks off, check Supabase → **Logs** for the actual error rather than guessing.
