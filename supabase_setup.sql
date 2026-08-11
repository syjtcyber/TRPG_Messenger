-- TRPG Messenger 0.2
-- Supabase > SQL Editor 에서 한 번 실행하세요.
-- 친구 몇 명과 비공개 테스트하는 0.2용 스키마입니다.

create table if not exists rooms (
  id text primary key,
  code text unique not null,
  name text not null,
  created_at timestamptz default now()
);

create table if not exists members (
  id text primary key,
  room_code text not null,
  role text not null check (role in ('KEEPER','EXPLORER')),
  name text not null,
  created_at timestamptz default now()
);

create table if not exists actors (
  id text primary key,
  room_code text not null,
  name text not null,
  type text not null check (type in ('KPC','NPC')),
  created_at timestamptz default now()
);

create table if not exists scenes (
  id text primary key,
  room_code text not null,
  title text not null,
  cast_ids text,
  cast_names text,
  preset text,
  keeper_memo text,
  is_current boolean default false,
  created_at timestamptz default now()
);

create table if not exists messages (
  id text primary key,
  room_code text not null,
  sender_id text not null,
  sender_role text not null,
  sender_name text not null,
  actor_id text,
  actor_name text,
  actor_type text,
  type text not null,
  content text not null,
  scene_id text,
  check_name text,
  dice text,
  target numeric,
  result numeric,
  success boolean,
  created_at timestamptz default now()
);

create table if not exists checks (
  id text primary key,
  room_code text not null,
  owner_id text not null,
  name text not null,
  dice text not null,
  target numeric not null,
  mode text not null check (mode in ('under','over')),
  created_at timestamptz default now()
);

alter table rooms enable row level security;
alter table members enable row level security;
alter table actors enable row level security;
alter table scenes enable row level security;
alter table messages enable row level security;
alter table checks enable row level security;

-- 0.2 비공개 테스트용 정책.
-- 공개 서비스 전환 시 로그인/방 권한 기반 RLS로 교체해야 합니다.
drop policy if exists "v02 rooms" on rooms;
drop policy if exists "v02 members" on members;
drop policy if exists "v02 actors" on actors;
drop policy if exists "v02 scenes" on scenes;
drop policy if exists "v02 messages" on messages;
drop policy if exists "v02 checks" on checks;

create policy "v02 rooms" on rooms for all to anon using (true) with check (true);
create policy "v02 members" on members for all to anon using (true) with check (true);
create policy "v02 actors" on actors for all to anon using (true) with check (true);
create policy "v02 scenes" on scenes for all to anon using (true) with check (true);
create policy "v02 messages" on messages for all to anon using (true) with check (true);
create policy "v02 checks" on checks for all to anon using (true) with check (true);

-- Realtime: 이미 publication에 들어가 있으면 오류가 날 수 있습니다.
-- 처음 한 번만 실행하세요.
alter publication supabase_realtime add table messages;
alter publication supabase_realtime add table scenes;
alter publication supabase_realtime add table members;
alter publication supabase_realtime add table actors;
