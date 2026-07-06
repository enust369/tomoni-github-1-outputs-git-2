create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  person_name text not null check (char_length(person_name) between 1 and 20),
  owner_gender text not null check (owner_gender in ('女性', '男性')),
  title text not null check (char_length(title) between 1 and 60),
  activity text not null,
  place text not null check (char_length(place) between 1 and 100),
  scheduled_at timestamptz not null,
  capacity smallint not null check (capacity between 1 and 5),
  audience text not null check (audience in ('same_gender', 'anyone')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.listings enable row level security;

drop policy if exists "listings are readable by everyone" on public.listings;
create policy "listings are readable by everyone"
on public.listings for select
using (true);

drop policy if exists "signed-in users can create their own listings" on public.listings;
create policy "signed-in users can create their own listings"
on public.listings for insert to authenticated
with check (auth.uid() = owner_id);

drop policy if exists "owners can update their listings" on public.listings;
create policy "owners can update their listings"
on public.listings for update to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

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

create or replace function public.review_listing_participation(target_listing_id uuid, target_user_id uuid, decision text)
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
    and user_id = target_user_id
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
        where listing_participants.listing_id = target_listing_id
          and listing_participants.user_id = auth.uid()
          and listing_participants.status = 'approved'
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

alter table public.listing_participants replica identity full;
alter table public.listing_messages replica identity full;

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
end;
$$;
