-- Run this once in Supabase: Dashboard → SQL Editor → New query → paste → Run

-- Table: one row per wisher submission
create table cast_entries (
  id text primary key,
  name text not null,
  role text,
  review text,
  stars int,
  roast text,
  flower text,
  weather text,
  color text,
  song text,
  video text,
  photo_url text,
  audio_url text,
  created_at timestamptz default now()
);

-- Table: quiz leaderboard
create table scores (
  id bigint generated always as identity primary key,
  name text not null,
  score int not null,
  of int not null,
  created_at timestamptz default now()
);

-- Enable Row Level Security, then allow anyone to read/insert
-- (anon key is meant to be public — this is what makes that safe)
alter table cast_entries enable row level security;
alter table scores enable row level security;

create policy "public read cast" on cast_entries for select using (true);
create policy "public insert cast" on cast_entries for insert with check (true);

create policy "public read scores" on scores for select using (true);
create policy "public insert scores" on scores for insert with check (true);

-- Storage buckets for photos and voice notes (do this in the Storage tab, not SQL —
-- see the setup steps. These policies apply once the buckets exist.)
create policy "public read photos" on storage.objects for select using (bucket_id = 'photos');
create policy "public upload photos" on storage.objects for insert with check (bucket_id = 'photos');

create policy "public read audio" on storage.objects for select using (bucket_id = 'audio');
create policy "public upload audio" on storage.objects for insert with check (bucket_id = 'audio');

-- ============================================================
-- MIGRATION: multiple photos per wisher + video wishes
-- Run this once in the SQL Editor, after the schema above has
-- already been applied. Safe to run even with existing rows —
-- there's no real data yet, so photo_url is simply replaced.
-- ============================================================
alter table cast_entries drop column if exists photo_url;
alter table cast_entries add column if not exists photo_urls text[];
alter table cast_entries add column if not exists clip_url text;

-- Then: Storage tab → New bucket → name it exactly `videos` →
-- toggle Public bucket ON → Create. Then run:
create policy "public read videos" on storage.objects for select using (bucket_id = 'videos');
create policy "public upload videos" on storage.objects for insert with check (bucket_id = 'videos');

-- ============================================================
-- MIGRATION 2: profile pics + wish note, and the new
-- collaborative reels (stills, box numbers, dialogues,
-- riddles, trait-wall photos). Run this whole block once in
-- the SQL Editor. Safe to re-run — everything uses IF NOT EXISTS.
-- No new storage buckets are needed; images reuse `photos`.
-- ============================================================

-- profile picture + birthday wish note on each cast card
alter table cast_entries add column if not exists avatar_url text;
alter table cast_entries add column if not exists wish text;

-- Reel one: photos of her, with a caption
create table if not exists her_stills (
  id text primary key,
  name text,
  caption text,
  photo_url text,
  created_at timestamptz default now()
);

-- Reel two: box-office numbers people add
create table if not exists box_numbers (
  id text primary key,
  name text,
  num text not null,
  label text not null,
  created_at timestamptz default now()
);

-- Reel four: iconic dialogues she says a lot
create table if not exists dialogues (
  id text primary key,
  name text,
  line text not null,
  created_at timestamptz default now()
);

-- Reel five: riddles people set about her
create table if not exists riddles (
  id text primary key,
  name text,
  question text not null,
  answer text not null,
  created_at timestamptz default now()
);

-- Trait walls: a photo (and/or word) of what flower/weather/colour/song she is
create table if not exists trait_photos (
  id text primary key,
  name text,
  trait text not null,   -- 'flower' | 'weather' | 'color' | 'song'
  value text,
  photo_url text,
  created_at timestamptz default now()
);

alter table her_stills   enable row level security;
alter table box_numbers  enable row level security;
alter table dialogues    enable row level security;
alter table riddles      enable row level security;
alter table trait_photos enable row level security;

create policy "public read stills"   on her_stills   for select using (true);
create policy "public insert stills"  on her_stills   for insert with check (true);
create policy "public read numbers"   on box_numbers  for select using (true);
create policy "public insert numbers" on box_numbers  for insert with check (true);
create policy "public read dialogues"   on dialogues  for select using (true);
create policy "public insert dialogues" on dialogues  for insert with check (true);
create policy "public read riddles"   on riddles      for select using (true);
create policy "public insert riddles" on riddles      for insert with check (true);
create policy "public read traitphotos"   on trait_photos for select using (true);
create policy "public insert traitphotos" on trait_photos for insert with check (true);

-- ============================================================
-- MIGRATION 3: multiple-choice riddles (4 options, one correct)
-- ============================================================
alter table riddles add column if not exists options text[];
