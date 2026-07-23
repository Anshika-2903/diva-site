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
