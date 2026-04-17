-- claude_inbox: voice notes & text captures from Michael's devices,
-- pending Claude's review in the next Claude Code session.
--
-- Entry points: dashboard mic button (anon key), Sven via Telegram (service key).
-- Exit: Claude reads via service key when Michael says "check inbox".

create table if not exists public.claude_inbox (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  source text not null default 'dashboard_voice',
  raw_text text not null,
  processed boolean not null default false,
  processed_at timestamptz,
  metadata jsonb
);

alter table public.claude_inbox enable row level security;

-- Anyone with the anon key can INSERT (needed for dashboard on any device)
drop policy if exists "anon can insert" on public.claude_inbox;
create policy "anon can insert" on public.claude_inbox
  for insert to anon
  with check (true);

-- Only service role can read/update/delete (keeps notes private)
drop policy if exists "service role full" on public.claude_inbox;
create policy "service role full" on public.claude_inbox
  for all to service_role
  using (true)
  with check (true);

-- Index to make "unprocessed, most recent" queries fast
create index if not exists idx_claude_inbox_unprocessed
  on public.claude_inbox (created_at desc)
  where not processed;

comment on table public.claude_inbox is
  'Voice notes and text captures from Michael. Pending Claude review.';
