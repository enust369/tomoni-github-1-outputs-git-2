create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  person_name text not null check (char_length(person_name) between 1 and 20),
  owner_gender text not null check (owner_gender in ('女性', '男性')),
  title text check (title is null or char_length(title) between 1 and 60),
  activity text not null,
  duration text,
  prefecture text,
  city text,
  place text not null check (char_length(place) between 1 and 100),
  scheduled_at timestamptz not null,
  capacity smallint not null check (capacity between 1 and 5),
  audience text not null check (audience in ('same_gender', 'anyone')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.listings add column if not exists status text not null default 'open';
alter table public.listings add column if not exists duration text;
alter table public.listings add column if not exists prefecture text;
alter table public.listings add column if not exists city text;
alter table public.listings alter column title drop not null;

do $$
begin
  if exists (select 1 from pg_constraint where conname = 'listings_title_check' and conrelid = 'public.listings'::regclass) then
    alter table public.listings drop constraint listings_title_check;
  end if;
  alter table public.listings
  add constraint listings_title_check
  check (title is null or char_length(title) between 1 and 60);
exception
  when duplicate_object then null;
end;
$$;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'listings_status_check' and conrelid = 'public.listings'::regclass) then
    alter table public.listings
    add constraint listings_status_check
    check (status in ('open', 'ended'));
  end if;
end;
$$;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 1 and 20),
  age text not null check (age in ('20代', '30代', '40代', '50代以上')),
  gender text not null check (gender in ('女性', '男性')),
  area text not null check (char_length(area) between 1 and 30),
  bio text not null check (char_length(bio) between 1 and 300),
  tags text[] not null default '{}',
  photo_urls text[] not null default '{}',
  personality_type text,
  personality_title text,
  personality_description text,
  personality_tags text[] not null default '{}',
  quiet_score integer,
  talk_score integer,
  comfort_score integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (cardinality(photo_urls) <= 3)
);

create or replace function public.same_gender_users(p_user1 uuid, p_user2 uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_user1 is not null
    and p_user2 is not null
    and p_user1 <> p_user2
    and exists (
      select 1
      from public.profiles p1
      join public.profiles p2 on p2.user_id = p_user2
      where p1.user_id = p_user1
        and p1.gender in ('女性', '男性')
        and p1.gender = p2.gender
    );
$$;

revoke all on function public.same_gender_users(uuid, uuid) from public, anon;
grant execute on function public.same_gender_users(uuid, uuid) to authenticated;

alter table public.listings enable row level security;

drop policy if exists "listings are readable by everyone" on public.listings;
create policy "listings are readable by everyone"
on public.listings for select
using (
  auth.uid() is not null
  and (
    owner_id = auth.uid()
    or public.same_gender_users(auth.uid(), owner_id)
  )
);

drop policy if exists "signed-in users can create their own listings" on public.listings;
create policy "signed-in users can create their own listings"
on public.listings for insert to authenticated
with check (
  auth.uid() = owner_id
  and exists (
    select 1 from public.profiles
    where profiles.user_id = auth.uid()
      and profiles.gender = owner_gender
  )
);

drop policy if exists "owners can update their listings" on public.listings;
create policy "owners can update their listings"
on public.listings for update to authenticated
using (auth.uid() = owner_id)
with check (
  auth.uid() = owner_id
  and exists (
    select 1 from public.profiles
    where profiles.user_id = auth.uid()
      and profiles.gender = owner_gender
  )
);

drop policy if exists "owners can delete their listings" on public.listings;
create policy "owners can delete their listings"
on public.listings for delete to authenticated
using (auth.uid() = owner_id);

create index if not exists listings_scheduled_at_idx
on public.listings (scheduled_at desc);

create table if not exists public.listing_participants (
  listing_id uuid not null references public.listings(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (listing_id, user_id)
);

alter table public.listing_participants
add column if not exists applicant_name text,
add column if not exists status text not null default 'approved';

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'listing_participants_status_check' and conrelid = 'public.listing_participants'::regclass) then
    alter table public.listing_participants
    add constraint listing_participants_status_check
    check (status in ('pending', 'approved', 'declined'));
  end if;
end;
$$;

alter table public.listing_participants enable row level security;

drop policy if exists "users can read their own participation" on public.listing_participants;
create policy "users can read their own participation"
on public.listing_participants for select to authenticated
using (auth.uid() = user_id);

drop policy if exists "owners can read listing requests" on public.listing_participants;
create policy "owners can read listing requests"
on public.listing_participants for select to authenticated
using (
  exists (
    select 1 from public.listings
    where listings.id = listing_participants.listing_id
      and listings.owner_id = auth.uid()
  )
);

drop policy if exists "users can cancel their own participation" on public.listing_participants;
create policy "users can cancel their own participation"
on public.listing_participants for delete to authenticated
using (auth.uid() = user_id);

create or replace view public.listing_participant_counts
with (security_barrier = true)
as
select
  listing_id,
  count(*)::integer as participant_count
from public.listing_participants
where status = 'approved'
group by listing_id;

grant select on public.listing_participant_counts to anon, authenticated;
grant select on public.listings to anon, authenticated;
grant insert, update, delete on public.listings to authenticated;
grant select, delete on public.listing_participants to authenticated;

drop function if exists public.join_listing(uuid);

create or replace function public.request_listing_participation(target_listing_id uuid, requested_applicant_name text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  listing_owner_id uuid;
begin
  if current_user_id is null then
    raise exception 'ログインが必要です。';
  end if;

  select owner_id
  into listing_owner_id
  from public.listings
  where id = target_listing_id
  for update;

  if not found then
    raise exception '募集が見つかりません。';
  end if;

  if listing_owner_id = current_user_id then
    raise exception '自分の募集には参加できません。';
  end if;

  if not public.same_gender_users(current_user_id, listing_owner_id) then
    raise exception 'この募集は、募集者と同じ性別の方だけが参加申請できます。';
  end if;

  if public.has_block_relation(listing_owner_id) then
    raise exception 'ブロック関係があるため、この募集には応募できません。';
  end if;

  if exists (
    select 1 from public.listing_participants
    where listing_id = target_listing_id and user_id = current_user_id
  ) then
    return;
  end if;

  insert into public.listing_participants (listing_id, user_id, applicant_name, status)
  values (target_listing_id, current_user_id, left(nullif(trim(requested_applicant_name), ''), 20), 'pending');
end;
$$;

revoke all on function public.request_listing_participation(uuid, text) from public, anon;
grant execute on function public.request_listing_participation(uuid, text) to authenticated;

drop function if exists public.review_listing_participation(uuid, uuid, text);
create or replace function public.review_listing_participation(target_listing_id uuid, p_target_user_id uuid, decision text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  listing_capacity smallint;
  approved_count integer;
begin
  if decision not in ('approved', 'declined') then
    raise exception '承認内容が正しくありません。';
  end if;

  select capacity into listing_capacity
  from public.listings
  where id = target_listing_id and owner_id = current_user_id
  for update;

  if not found then
    raise exception 'この参加申請を確認する権限がありません。';
  end if;

  if decision = 'approved' then
    select count(*) into approved_count
    from public.listing_participants
    where listing_id = target_listing_id and status = 'approved';
    if approved_count >= listing_capacity then
      raise exception 'この募集は満員です。';
    end if;
  end if;

  update public.listing_participants
  set status = decision
  where listing_id = target_listing_id
    and user_id = p_target_user_id
    and status = 'pending';

  if not found then
    raise exception '参加申請が見つかりません。';
  end if;
end;
$$;

revoke all on function public.review_listing_participation(uuid, uuid, text) from public, anon;
grant execute on function public.review_listing_participation(uuid, uuid, text) to authenticated;

create or replace function public.cancel_listing_participation(target_listing_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'ログインが必要です。';
  end if;

  delete from public.listing_participants
  where listing_id = target_listing_id
    and user_id = current_user_id;
end;
$$;

revoke all on function public.cancel_listing_participation(uuid) from public, anon;
grant execute on function public.cancel_listing_participation(uuid) to authenticated;

create index if not exists listing_participants_user_id_idx
on public.listing_participants (user_id);

create table if not exists public.listing_messages (
  id bigint generated by default as identity primary key,
  listing_id uuid not null references public.listings(id) on delete cascade,
  sender_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now()
);

alter table public.listing_messages enable row level security;

create or replace function public.can_access_listing_chat(target_listing_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
    and (
      exists (
        select 1 from public.listings
        where listings.id = target_listing_id
          and listings.owner_id = auth.uid()
      )
      or exists (
        select 1 from public.listing_participants
        join public.listings on listings.id = listing_participants.listing_id
        where listing_participants.listing_id = target_listing_id
          and listing_participants.user_id = auth.uid()
          and listing_participants.status = 'approved'
          and public.same_gender_users(auth.uid(), listings.owner_id)
      )
    );
$$;

revoke all on function public.can_access_listing_chat(uuid) from public, anon;
grant execute on function public.can_access_listing_chat(uuid) to authenticated;

drop policy if exists "listing members can read messages" on public.listing_messages;
create policy "listing members can read messages"
on public.listing_messages for select to authenticated
using (public.can_access_listing_chat(listing_id));

drop policy if exists "listing members can send messages" on public.listing_messages;
create policy "listing members can send messages"
on public.listing_messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and public.can_access_listing_chat(listing_id)
  and not exists (
    select 1
    from public.listings l
    where l.id = public.listing_messages.listing_id
      and l.owner_id <> auth.uid()
      and public.has_block_relation(l.owner_id)
  )
  and not exists (
    select 1
    from public.listings l
    where l.id = public.listing_messages.listing_id
      and l.owner_id = auth.uid()
      and exists (
        select 1
        from public.listing_participants lp
        where lp.listing_id = l.id
          and lp.status = 'approved'
          and public.has_block_relation(lp.user_id)
      )
  )
);

grant select, insert on public.listing_messages to authenticated;
grant usage, select on sequence public.listing_messages_id_seq to authenticated;

create index if not exists listing_messages_listing_created_idx
on public.listing_messages (listing_id, created_at);

create table if not exists public.meeting_records (
  listing_id uuid not null references public.listings(id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  met_safely boolean not null default false,
  meet_again boolean not null default false,
  private_note text check (private_note is null or char_length(private_note) <= 300),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (listing_id, user_id)
);

alter table public.meeting_records enable row level security;

create or replace function public.can_manage_meeting_record(target_listing_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
    and exists (
      select 1 from public.listings
      where listings.id = target_listing_id
        and listings.scheduled_at <= now()
        and (
          listings.owner_id = auth.uid()
          or exists (
            select 1 from public.listing_participants
            where listing_participants.listing_id = target_listing_id
              and listing_participants.user_id = auth.uid()
              and listing_participants.status = 'approved'
          )
        )
    );
$$;

revoke all on function public.can_manage_meeting_record(uuid) from public, anon;
grant execute on function public.can_manage_meeting_record(uuid) to authenticated;

drop policy if exists "users can read their own meeting record" on public.meeting_records;
create policy "users can read their own meeting record"
on public.meeting_records for select to authenticated
using (
  user_id = auth.uid()
  and public.can_manage_meeting_record(listing_id)
);

drop policy if exists "users can create their own meeting record" on public.meeting_records;
create policy "users can create their own meeting record"
on public.meeting_records for insert to authenticated
with check (
  user_id = auth.uid()
  and public.can_manage_meeting_record(listing_id)
);

drop policy if exists "users can update their own meeting record" on public.meeting_records;
create policy "users can update their own meeting record"
on public.meeting_records for update to authenticated
using (
  user_id = auth.uid()
  and public.can_manage_meeting_record(listing_id)
)
with check (
  user_id = auth.uid()
  and public.can_manage_meeting_record(listing_id)
);

grant select, insert, update on public.meeting_records to authenticated;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 1 and 20),
  age text not null check (age in ('20代', '30代', '40代', '50代以上')),
  gender text not null check (gender in ('女性', '男性')),
  area text not null check (char_length(area) between 1 and 30),
  bio text not null check (char_length(bio) between 1 and 300),
  tags text[] not null default '{}',
  photo_urls text[] not null default '{}',
  personality_type text,
  personality_title text,
  personality_description text,
  personality_tags text[] not null default '{}',
  quiet_score integer,
  talk_score integer,
  comfort_score integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (cardinality(photo_urls) <= 3)
);

alter table public.profiles add column if not exists personality_type text;
alter table public.profiles add column if not exists personality_title text;
alter table public.profiles add column if not exists personality_description text;
alter table public.profiles add column if not exists personality_tags text[] not null default '{}';
alter table public.profiles add column if not exists quiet_score integer;
alter table public.profiles add column if not exists talk_score integer;
alter table public.profiles add column if not exists comfort_score integer;
alter table public.profiles add column if not exists is_verified boolean not null default false;

alter table public.profiles enable row level security;

drop policy if exists "authenticated users can read profiles" on public.profiles;
create policy "authenticated users can read profiles"
on public.profiles for select to authenticated
using (
  user_id = auth.uid()
  or public.same_gender_users(auth.uid(), user_id)
);

drop policy if exists "users can create their own profile" on public.profiles;
create policy "users can create their own profile"
on public.profiles for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "users can update their own profile" on public.profiles;
create policy "users can update their own profile"
on public.profiles for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

grant select, insert, update on public.profiles to authenticated;

create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  target_user_id uuid references auth.users(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint favorites_user_listing_unique unique (user_id, listing_id)
);

create unique index if not exists favorites_user_target_unique
on public.favorites (user_id, target_user_id)
where target_user_id is not null;

alter table public.favorites enable row level security;

drop policy if exists "users can read their own favorites" on public.favorites;
create policy "users can read their own favorites"
on public.favorites for select to authenticated
using (user_id = auth.uid());

drop policy if exists "users can create their own favorites" on public.favorites;
create policy "users can create their own favorites"
on public.favorites for insert to authenticated
with check (
  user_id = auth.uid()
  and (
    favorites.target_user_id is null
    or public.same_gender_users(auth.uid(), favorites.target_user_id)
  )
  and (
    favorites.listing_id is null
    or exists (
      select 1
      from public.listings
      where listings.id = favorites.listing_id
        and public.same_gender_users(auth.uid(), listings.owner_id)
    )
  )
);

drop policy if exists "users can delete their own favorites" on public.favorites;
create policy "users can delete their own favorites"
on public.favorites for delete to authenticated
using (user_id = auth.uid());

grant select, insert, delete on public.favorites to authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(auth.jwt() ->> 'email', '') in (
    'iriehair@yahoo.co.jp',
    'tsunehito1979@hotmail.co.jp'
  );
$$;

revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  target_user_id uuid references auth.users(id) on delete set null,
  listing_id uuid references public.listings(id) on delete set null,
  match_id uuid,
  source text not null default 'unknown',
  reason text not null check (reason in ('不適切な発言', '勧誘・営業', '誹謗中傷', 'ドタキャン', 'その他')),
  detail text check (detail is null or char_length(detail) <= 500),
  status text not null default 'received' check (status in ('received', 'reviewing', 'resolved')),
  created_at timestamptz not null default now()
);

alter table public.reports enable row level security;

drop policy if exists "users can create their own reports" on public.reports;
create policy "users can create their own reports"
on public.reports for insert to authenticated
with check (reporter_id = auth.uid());

drop policy if exists "users can read their own reports" on public.reports;
create policy "users can read their own reports"
on public.reports for select to authenticated
using (reporter_id = auth.uid() or public.is_admin());

grant select, insert on public.reports to authenticated;

create index if not exists reports_reporter_created_idx
on public.reports (reporter_id, created_at desc);

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 80),
  email text not null check (char_length(email) between 3 and 254),
  category text not null check (category in ('サービスについて', '安全について', '登録情報について', 'その他')),
  message text not null check (char_length(message) between 10 and 2000),
  user_id uuid references auth.users(id) on delete set null,
  status text not null default 'received' check (status in ('received', 'reviewing', 'resolved')),
  created_at timestamptz not null default now()
);

alter table public.contacts enable row level security;

drop policy if exists "anyone can create contacts" on public.contacts;
create policy "anyone can create contacts"
on public.contacts for insert
with check (user_id is null or user_id = auth.uid());

drop policy if exists "admins can read contacts" on public.contacts;
create policy "admins can read contacts"
on public.contacts for select to authenticated
using (public.is_admin());

grant insert on public.contacts to anon, authenticated;
grant select on public.contacts to authenticated;

create index if not exists contacts_created_idx
on public.contacts (created_at desc);

create table if not exists public.blocks (
  id uuid primary key default gen_random_uuid(),
  blocker_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  blocked_user_id uuid not null references auth.users(id) on delete cascade,
  reason text,
  created_at timestamptz not null default now(),
  constraint blocks_unique_pair unique (blocker_id, blocked_user_id),
  check (blocker_id <> blocked_user_id)
);

alter table public.blocks enable row level security;

drop policy if exists "users can create their own blocks" on public.blocks;
create policy "users can create their own blocks"
on public.blocks for insert to authenticated
with check (blocker_id = auth.uid());

drop policy if exists "users can read their own blocks" on public.blocks;
create policy "users can read their own blocks"
on public.blocks for select to authenticated
using (blocker_id = auth.uid() or public.is_admin());

drop policy if exists "users can delete their own blocks" on public.blocks;
create policy "users can delete their own blocks"
on public.blocks for delete to authenticated
using (blocker_id = auth.uid());

grant select, insert, delete on public.blocks to authenticated;

create index if not exists blocks_blocker_created_idx
on public.blocks (blocker_id, created_at desc);

create or replace function public.has_block_relation(p_target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
    and p_target_user_id is not null
    and exists (
      select 1
      from public.blocks b
      where (b.blocker_id = auth.uid() and b.blocked_user_id = p_target_user_id)
         or (b.blocker_id = p_target_user_id and b.blocked_user_id = auth.uid())
    );
$$;

revoke all on function public.has_block_relation(uuid) from public, anon;
grant execute on function public.has_block_relation(uuid) to authenticated;

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  user1_id uuid not null references auth.users(id) on delete cascade,
  user2_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  status text not null default 'active' check (status in ('active')),
  check (user1_id <> user2_id)
);

create unique index if not exists matches_unique_pair
on public.matches (least(user1_id, user2_id), greatest(user1_id, user2_id))
where status = 'active';

alter table public.matches enable row level security;

drop policy if exists "matched users can read their own matches" on public.matches;
create policy "matched users can read their own matches"
on public.matches for select to authenticated
using (
  (auth.uid() = user1_id or auth.uid() = user2_id)
  and public.same_gender_users(user1_id, user2_id)
);

grant select on public.matches to authenticated;

create or replace function public.create_match_from_favorite()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  first_user uuid;
  second_user uuid;
begin
  if new.target_user_id is null or new.target_user_id = new.user_id then
    return new;
  end if;

  if not public.same_gender_users(new.user_id, new.target_user_id) then
    return new;
  end if;

  if exists (
    select 1
    from public.favorites
    where favorites.user_id = new.target_user_id
      and favorites.target_user_id = new.user_id
  ) then
    first_user := least(new.user_id, new.target_user_id);
    second_user := greatest(new.user_id, new.target_user_id);

    insert into public.matches (user1_id, user2_id, status)
    values (first_user, second_user, 'active')
    on conflict do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists on_favorite_create_match on public.favorites;
create trigger on_favorite_create_match
after insert on public.favorites
for each row execute function public.create_match_from_favorite();

drop function if exists public.ensure_match_with_user(uuid);
create or replace function public.ensure_match_with_user(p_target_user_id uuid)
returns public.matches
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  first_user uuid;
  second_user uuid;
  match_row public.matches;
begin
  if current_user_id is null then
    raise exception 'ログインが必要です。';
  end if;

  if p_target_user_id is null or p_target_user_id = current_user_id then
    raise exception '相手ユーザーが正しくありません。';
  end if;

  if not public.same_gender_users(current_user_id, p_target_user_id) then
    raise exception '同性の相手とだけマッチできます。';
  end if;

  if not exists (
    select 1
    from public.favorites f
    where f.user_id = current_user_id
      and f.target_user_id = p_target_user_id
  ) then
    raise exception '自分の気になるが見つかりません。';
  end if;

  if not exists (
    select 1
    from public.favorites f
    where f.user_id = p_target_user_id
      and f.target_user_id = current_user_id
  ) then
    return null;
  end if;

  first_user := least(current_user_id, p_target_user_id);
  second_user := greatest(current_user_id, p_target_user_id);

  insert into public.matches (user1_id, user2_id, status)
  values (first_user, second_user, 'active')
  on conflict do nothing;

  select m.*
  into match_row
  from public.matches m
  where m.status = 'active'
    and least(m.user1_id, m.user2_id) = first_user
    and greatest(m.user1_id, m.user2_id) = second_user
  limit 1;

  return match_row;
end;
$$;

revoke all on function public.ensure_match_with_user(uuid) from public, anon;
grant execute on function public.ensure_match_with_user(uuid) to authenticated;

insert into public.matches (user1_id, user2_id, status)
select distinct
  least(f1.user_id, f1.target_user_id),
  greatest(f1.user_id, f1.target_user_id),
  'active'
from public.favorites f1
join public.favorites f2
  on f2.user_id = f1.target_user_id
 and f2.target_user_id = f1.user_id
where f1.target_user_id is not null
  and f1.user_id <> f1.target_user_id
  and public.same_gender_users(f1.user_id, f1.target_user_id)
on conflict do nothing;

create table if not exists public.match_messages (
  id bigint generated always as identity primary key,
  match_id uuid not null references public.matches(id) on delete cascade,
  sender_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now(),
  check (sender_id <> receiver_id)
);

alter table public.match_messages enable row level security;

create or replace function public.can_access_match_chat(target_match_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
    and exists (
      select 1
      from public.matches
      where matches.id = target_match_id
        and matches.status = 'active'
        and (matches.user1_id = auth.uid() or matches.user2_id = auth.uid())
        and public.same_gender_users(matches.user1_id, matches.user2_id)
    );
$$;

revoke all on function public.can_access_match_chat(uuid) from public, anon;
grant execute on function public.can_access_match_chat(uuid) to authenticated;

drop policy if exists "matched users can read match messages" on public.match_messages;
create policy "matched users can read match messages"
on public.match_messages for select to authenticated
using (public.can_access_match_chat(match_id));

drop policy if exists "matched users can send match messages" on public.match_messages;
create policy "matched users can send match messages"
on public.match_messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and public.can_access_match_chat(match_id)
  and exists (
    select 1
    from public.matches
    where matches.id = match_id
      and matches.status = 'active'
      and receiver_id in (matches.user1_id, matches.user2_id)
      and receiver_id <> auth.uid()
  )
  and not public.has_block_relation(receiver_id)
);

grant select, insert on public.match_messages to authenticated;
grant usage, select on sequence public.match_messages_id_seq to authenticated;

create index if not exists match_messages_match_created_idx
on public.match_messages (match_id, created_at);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('profile-photos', 'profile-photos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "profile photos are publicly readable" on storage.objects;
create policy "profile photos are publicly readable"
on storage.objects for select
using (bucket_id = 'profile-photos');

drop policy if exists "users can upload their own profile photos" on storage.objects;
create policy "users can upload their own profile photos"
on storage.objects for insert to authenticated
with check (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "users can update their own profile photos" on storage.objects;
create policy "users can update their own profile photos"
on storage.objects for update to authenticated
using (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "users can delete their own profile photos" on storage.objects;
create policy "users can delete their own profile photos"
on storage.objects for delete to authenticated
using (bucket_id = 'profile-photos' and (storage.foldername(name))[1] = auth.uid()::text);

create table if not exists public.notifications (
  id bigint generated by default as identity primary key,
  recipient_id uuid not null references auth.users(id) on delete cascade,
  actor_id uuid references auth.users(id) on delete set null,
  listing_id uuid references public.listings(id) on delete cascade,
  type text not null check (type in ('participation_request', 'participation_approved', 'participation_declined', 'message', 'listing_ended')),
  message text not null,
  event_key text not null unique,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.notifications enable row level security;

drop policy if exists "users can read their own notifications" on public.notifications;
create policy "users can read their own notifications"
on public.notifications for select to authenticated
using (recipient_id = auth.uid());

drop policy if exists "users can mark their own notifications read" on public.notifications;
create policy "users can mark their own notifications read"
on public.notifications for update to authenticated
using (recipient_id = auth.uid())
with check (recipient_id = auth.uid());

grant select on public.notifications to authenticated;
grant update (read_at) on public.notifications to authenticated;

create or replace function public.get_admin_summary()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  return jsonb_build_object(
    'users_count', (select count(*) from auth.users),
    'verified_users_count', (
      select count(*)
      from auth.users u
      left join public.profiles p on p.user_id = u.id
      where coalesce(p.is_verified, false) or u.email_confirmed_at is not null
    ),
    'today_listings_count', (
      select count(*)
      from public.listings
      where created_at >= current_date
    ),
    'listings_count', (select count(*) from public.listings),
    'matches_count', (select count(*) from public.matches where status = 'active'),
    'listing_messages_count', (select count(*) from public.listing_messages),
    'match_messages_count', (select count(*) from public.match_messages),
    'today_chat_messages_count', (
      (select count(*) from public.listing_messages where created_at >= current_date)
      +
      (select count(*) from public.match_messages where created_at >= current_date)
    ),
    'reports_count', (select count(*) from public.reports),
    'blocks_count', (select count(*) from public.blocks)
  );
end;
$$;

revoke all on function public.get_admin_summary() from public, anon;
grant execute on function public.get_admin_summary() to authenticated;

drop function if exists public.get_admin_users(text);
create or replace function public.get_admin_users(search_term text default '')
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  return (
    select coalesce(jsonb_agg(to_jsonb(admin_users) order by admin_users.created_at desc), '[]'::jsonb)
    from (
      select
        u.id as user_id,
        u.email,
        coalesce(p.nickname, '未設定') as nickname,
        coalesce(p.is_verified, false) or u.email_confirmed_at is not null as is_verified,
        u.last_sign_in_at,
        u.created_at,
        (select count(*) from public.listings l where l.owner_id = u.id) as listings_count,
        (select count(*) from public.matches m where m.status = 'active' and (m.user1_id = u.id or m.user2_id = u.id)) as matches_count
      from auth.users u
      left join public.profiles p on p.user_id = u.id
      where nullif(trim(search_term), '') is null
        or lower(coalesce(p.nickname, '') || ' ' || coalesce(u.email, '')) like '%' || lower(trim(search_term)) || '%'
      order by u.created_at desc
      limit 200
    ) admin_users
  );
end;
$$;

revoke all on function public.get_admin_users(text) from public, anon;
grant execute on function public.get_admin_users(text) to authenticated;

drop function if exists public.get_admin_reports();
create or replace function public.get_admin_reports()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  return (
    select coalesce(jsonb_agg(to_jsonb(admin_reports) order by admin_reports.created_at desc), '[]'::jsonb)
    from (
      select
        r.id,
        r.reason,
        r.detail,
        r.status,
        r.source,
        r.listing_id,
        r.match_id,
        r.created_at,
        r.reporter_id,
        reporter.email as reporter_email,
        coalesce(reporter_profile.nickname, '未設定') as reporter_name,
        r.target_user_id,
        target_user.email as target_email,
        coalesce(target_profile.nickname, '未設定') as target_name
      from public.reports r
      left join auth.users reporter on reporter.id = r.reporter_id
      left join public.profiles reporter_profile on reporter_profile.user_id = r.reporter_id
      left join auth.users target_user on target_user.id = r.target_user_id
      left join public.profiles target_profile on target_profile.user_id = r.target_user_id
      order by r.created_at desc
      limit 200
    ) admin_reports
  );
end;
$$;

revoke all on function public.get_admin_reports() from public, anon;
grant execute on function public.get_admin_reports() to authenticated;

drop function if exists public.get_admin_contacts();
create or replace function public.get_admin_contacts()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  return (
    select coalesce(jsonb_agg(to_jsonb(admin_contacts) order by admin_contacts.created_at desc), '[]'::jsonb)
    from (
      select
        c.id,
        c.name,
        c.email,
        c.category,
        c.message,
        c.user_id,
        c.status,
        c.created_at
      from public.contacts c
      order by c.created_at desc
      limit 200
    ) admin_contacts
  );
end;
$$;

revoke all on function public.get_admin_contacts() from public, anon;
grant execute on function public.get_admin_contacts() to authenticated;

drop function if exists public.get_admin_listings();
create or replace function public.get_admin_listings()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  return (
    select coalesce(jsonb_agg(to_jsonb(admin_listings) order by admin_listings.created_at desc), '[]'::jsonb)
    from (
      select
        l.id,
        l.title,
        l.activity,
        l.place,
        l.scheduled_at,
        l.capacity,
        l.status,
        l.created_at,
        l.owner_id,
        owner.email as owner_email,
        coalesce(p.nickname, l.person_name) as owner_name,
        (select count(*) from public.listing_participants lp where lp.listing_id = l.id and lp.status = 'approved') as participant_count
      from public.listings l
      left join auth.users owner on owner.id = l.owner_id
      left join public.profiles p on p.user_id = l.owner_id
      order by l.created_at desc
      limit 200
    ) admin_listings
  );
end;
$$;

revoke all on function public.get_admin_listings() from public, anon;
grant execute on function public.get_admin_listings() to authenticated;

drop function if exists public.get_admin_blocks();
create or replace function public.get_admin_blocks()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  return (
    select coalesce(jsonb_agg(to_jsonb(admin_blocks) order by admin_blocks.created_at desc), '[]'::jsonb)
    from (
      select
        b.id,
        b.blocker_id,
        blocker.email as blocker_email,
        coalesce(blocker_profile.nickname, '未設定') as blocker_name,
        b.blocked_user_id,
        blocked.email as blocked_email,
        coalesce(blocked_profile.nickname, '未設定') as blocked_name,
        b.reason,
        b.created_at
      from public.blocks b
      left join auth.users blocker on blocker.id = b.blocker_id
      left join public.profiles blocker_profile on blocker_profile.user_id = b.blocker_id
      left join auth.users blocked on blocked.id = b.blocked_user_id
      left join public.profiles blocked_profile on blocked_profile.user_id = b.blocked_user_id
      order by b.created_at desc
      limit 200
    ) admin_blocks
  );
end;
$$;

revoke all on function public.get_admin_blocks() from public, anon;
grant execute on function public.get_admin_blocks() to authenticated;

drop function if exists public.resolve_admin_report(uuid);
create or replace function public.resolve_admin_report(target_report_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  update public.reports
  set status = 'resolved'
  where id = target_report_id;
end;
$$;

revoke all on function public.resolve_admin_report(uuid) from public, anon;
grant execute on function public.resolve_admin_report(uuid) to authenticated;

drop function if exists public.resolve_admin_contact(uuid);
create or replace function public.resolve_admin_contact(target_contact_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  update public.contacts
  set status = 'resolved'
  where id = target_contact_id;
end;
$$;

revoke all on function public.resolve_admin_contact(uuid) from public, anon;
grant execute on function public.resolve_admin_contact(uuid) to authenticated;

drop function if exists public.admin_end_listing(uuid);
create or replace function public.admin_end_listing(target_listing_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  update public.listings
  set status = 'ended', updated_at = now()
  where id = target_listing_id;
end;
$$;

revoke all on function public.admin_end_listing(uuid) from public, anon;
grant execute on function public.admin_end_listing(uuid) to authenticated;

drop function if exists public.admin_delete_listing(uuid);
create or replace function public.admin_delete_listing(target_listing_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  delete from public.listings
  where id = target_listing_id;
end;
$$;

revoke all on function public.admin_delete_listing(uuid) from public, anon;
grant execute on function public.admin_delete_listing(uuid) to authenticated;

drop function if exists public.admin_unblock_user(uuid);
create or replace function public.admin_unblock_user(target_block_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception '管理者のみ利用できます。';
  end if;

  delete from public.blocks
  where id = target_block_id;
end;
$$;

revoke all on function public.admin_unblock_user(uuid) from public, anon;
grant execute on function public.admin_unblock_user(uuid) to authenticated;

create or replace function public.notify_listing_participation_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  listing_owner_id uuid;
begin
  select owner_id into listing_owner_id from public.listings where id = new.listing_id;

  if tg_op = 'INSERT' and new.status = 'pending' then
    insert into public.notifications (recipient_id, actor_id, listing_id, type, message, event_key)
    values (listing_owner_id, new.user_id, new.listing_id, 'participation_request', coalesce(new.applicant_name, '参加申請者') || 'さんが参加申請しました', 'participation-request:' || new.listing_id || ':' || new.user_id)
    on conflict (event_key) do nothing;
  elsif tg_op = 'UPDATE' and old.status is distinct from new.status and new.status in ('approved', 'declined') then
    insert into public.notifications (recipient_id, actor_id, listing_id, type, message, event_key)
    values (
      new.user_id,
      listing_owner_id,
      new.listing_id,
      case when new.status = 'approved' then 'participation_approved' else 'participation_declined' end,
      case when new.status = 'approved' then '参加申請が承認されました' else '今回は見送られました' end,
      'participation-review:' || new.listing_id || ':' || new.user_id || ':' || new.status
    )
    on conflict (event_key) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists notify_listing_participation_change_trigger on public.listing_participants;
create trigger notify_listing_participation_change_trigger
after insert or update of status on public.listing_participants
for each row execute function public.notify_listing_participation_change();

create or replace function public.notify_new_listing_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  listing_owner_id uuid;
  sender_name text;
begin
  select owner_id, person_name into listing_owner_id, sender_name
  from public.listings where id = new.listing_id;

  if new.sender_id <> listing_owner_id then
    select coalesce(applicant_name, '参加者') into sender_name
    from public.listing_participants
    where listing_id = new.listing_id and user_id = new.sender_id;
  end if;

  insert into public.notifications (recipient_id, actor_id, listing_id, type, message, event_key)
  select recipient_id, new.sender_id, new.listing_id, 'message', coalesce(sender_name, '相手') || 'さんから新しいメッセージがあります', 'message:' || new.id || ':' || recipient_id
  from (
    select listing_owner_id as recipient_id
    union
    select user_id from public.listing_participants
    where listing_id = new.listing_id and status = 'approved'
  ) recipients
  where recipient_id <> new.sender_id
  on conflict (event_key) do nothing;
  return new;
end;
$$;

drop trigger if exists notify_new_listing_message_trigger on public.listing_messages;
create trigger notify_new_listing_message_trigger
after insert on public.listing_messages
for each row execute function public.notify_new_listing_message();

create or replace function public.sync_listing_end_notifications()
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.notifications (recipient_id, listing_id, type, message, event_key)
  select recipient_id, listing_id, 'listing_ended', '募集「' || title || '」が終了しました', 'listing-ended:' || listing_id || ':' || recipient_id
  from (
    select listings.owner_id as recipient_id, listings.id as listing_id, listings.title
    from public.listings
    where listings.scheduled_at <= now() and listings.owner_id = auth.uid()
    union
    select listing_participants.user_id, listings.id, listings.title
    from public.listings
    join public.listing_participants on listing_participants.listing_id = listings.id and listing_participants.status = 'approved'
    where listings.scheduled_at <= now() and listing_participants.user_id = auth.uid()
  ) ended
  on conflict (event_key) do nothing;
$$;

revoke all on function public.sync_listing_end_notifications() from public, anon;
grant execute on function public.sync_listing_end_notifications() to authenticated;

alter table public.listing_participants replica identity full;
alter table public.listing_messages replica identity full;
alter table public.match_messages replica identity full;
alter table public.notifications replica identity full;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
    and not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'listing_messages'
    ) then
    alter publication supabase_realtime add table public.listing_messages;
  end if;
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
    and not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'listing_participants'
    ) then
    alter publication supabase_realtime add table public.listing_participants;
  end if;
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
    and not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'notifications'
    ) then
    alter publication supabase_realtime add table public.notifications;
  end if;
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
    and not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = 'match_messages'
    ) then
    alter publication supabase_realtime add table public.match_messages;
  end if;
end;
$$;
