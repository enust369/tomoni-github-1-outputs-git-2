-- TOMONI の公開閲覧を anon に限定して提供します。
-- 既存環境では Supabase SQL Editor でこのファイル全体を一度だけ実行してください。

-- anon は基礎テーブルを直接読めません。公開情報は下記の SECURITY DEFINER RPC だけが返します。
revoke all on public.listings, public.profiles, public.profile_birth_dates,
  public.listing_participants, public.listing_messages, public.meeting_records,
  public.favorites, public.reports, public.blocks, public.matches,
  public.match_messages, public.notifications from anon;
revoke execute on function public.get_home_stats() from anon;

-- 「DB への書き込みはログイン必須」に合わせて、お問い合わせも認証済み利用者に限定します。
drop policy if exists "anyone can create contacts" on public.contacts;
drop policy if exists "authenticated users can create contacts" on public.contacts;
create policy "authenticated users can create contacts"
on public.contacts for insert to authenticated
with check (user_id = auth.uid());
revoke insert on public.contacts from anon;
grant insert on public.contacts to authenticated;

create or replace function public.list_public_discoverable_profiles()
returns table (
  profile_key text,
  nickname text,
  age integer,
  area text,
  photo_count integer,
  bio text,
  public_tags text[],
  email_confirmed boolean,
  birth_date_registered boolean,
  is_verified boolean
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select
    md5(p.user_id::text || ':tomoni-member-v1') as profile_key,
    p.nickname,
    case
      when b.birth_date is null then null
      else extract(year from age(timezone('Asia/Tokyo', now())::date, b.birth_date))::integer
    end as age,
    p.area,
    cardinality(coalesce(p.photo_urls, '{}'::text[])) as photo_count,
    p.bio,
    coalesce((
      select array_agg(tag order by tag)
      from unnest(coalesce(p.tags, '{}'::text[])) as tag
      where tag like 'tomoni:profile:occupation=%'
         or tag like 'tomoni:profile:favoriteActivity=%'
         or tag like 'tomoni:profile:holiday=%'
         or tag like 'tomoni:profile:personalityNature=%'
         or tag like 'tomoni:profile:speechPreference=%'
         or tag like 'tomoni:profile:conversationStyle=%'
         or tag like 'tomoni:profile:shyness=%'
         or tag like 'tomoni:profile:firstMeetingMood=%'
         or tag like 'tomoni:profile:afterMeeting=%'
         or tag like 'tomoni:profile:reassurancePoint=%'
         or tag like 'tomoni:profile:talkStyle=%'
         or tag like 'tomoni:profile:firstMeeting=%'
         or tag like 'tomoni:profile:talkTopic=%'
         or tag like 'tomoni:profile:meetingValue=%'
         or tag like 'tomoni:profile:currentInterest=%'
    ), '{}'::text[]) as public_tags,
    u.email_confirmed_at is not null as email_confirmed,
    b.birth_date is not null as birth_date_registered,
    coalesce(p.is_verified, false) as is_verified
  from public.profiles p
  join auth.users u on u.id = p.user_id
  left join public.profile_birth_dates b on b.user_id = p.user_id
  where p.nickname <> ''
    and p.area <> ''
    and p.bio <> ''
    and p.gender in ('女性', '男性')
    and u.email_confirmed_at is not null
    and u.deleted_at is null
    and (u.banned_until is null or u.banned_until <= now())
  order by p.created_at desc;
$$;

revoke all on function public.list_public_discoverable_profiles() from public, anon, authenticated;
grant execute on function public.list_public_discoverable_profiles() to anon, authenticated;

-- Storage上の元URLにはユーザーUUIDを含めないため、画像本体はEdge Functionだけが参照します。
create or replace function public.get_public_profile_photo_path(
  target_profile_key text,
  target_photo_index integer
)
returns text
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select p.photo_urls[target_photo_index + 1]
  from public.profiles p
  join auth.users u on u.id = p.user_id
  where target_profile_key ~ '^[a-f0-9]{32}$'
    and target_photo_index between 0 and 2
    and md5(p.user_id::text || ':tomoni-member-v1') = target_profile_key
    and p.nickname <> ''
    and p.area <> ''
    and p.bio <> ''
    and p.gender in ('女性', '男性')
    and u.email_confirmed_at is not null
    and u.deleted_at is null
    and (u.banned_until is null or u.banned_until <= now())
    and p.photo_urls[target_photo_index + 1] is not null
  limit 1;
$$;

revoke all on function public.get_public_profile_photo_path(text, integer) from public, anon, authenticated;
grant execute on function public.get_public_profile_photo_path(text, integer) to service_role;

create or replace function public.list_public_listings()
returns table (
  id uuid,
  person_name text,
  title text,
  activity text,
  duration text,
  prefecture text,
  city text,
  place text,
  scheduled_at timestamptz,
  capacity smallint,
  audience text,
  status text,
  created_at timestamptz,
  profile_age integer,
  profile_area text,
  email_confirmed boolean,
  birth_date_registered boolean,
  is_verified boolean,
  participant_count integer
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select
    l.id,
    l.person_name,
    l.title,
    l.activity,
    l.duration,
    l.prefecture,
    l.city,
    l.place,
    l.scheduled_at,
    l.capacity,
    l.audience,
    l.status,
    l.created_at,
    case
      when b.birth_date is null then null
      else extract(year from age(timezone('Asia/Tokyo', now())::date, b.birth_date))::integer
    end as profile_age,
    p.area as profile_area,
    u.email_confirmed_at is not null as email_confirmed,
    b.birth_date is not null as birth_date_registered,
    coalesce(p.is_verified, false) as is_verified,
    (
      select count(*)::integer
      from public.listing_participants lp
      where lp.listing_id = l.id
        and lp.status = 'approved'
    ) as participant_count
  from public.listings l
  join public.profiles p on p.user_id = l.owner_id
  join auth.users u on u.id = l.owner_id
  left join public.profile_birth_dates b on b.user_id = l.owner_id
  where l.status = 'open'
    and l.scheduled_at > now()
    and p.nickname <> ''
    and p.area <> ''
    and p.bio <> ''
    and p.gender in ('女性', '男性')
    and u.email_confirmed_at is not null
    and u.deleted_at is null
    and (u.banned_until is null or u.banned_until <= now())
  order by l.created_at desc;
$$;

revoke all on function public.list_public_listings() from public, anon, authenticated;
grant execute on function public.list_public_listings() to anon, authenticated;

create or replace function public.get_public_listing(target_listing_id uuid)
returns table (
  id uuid,
  person_name text,
  title text,
  activity text,
  duration text,
  prefecture text,
  city text,
  place text,
  scheduled_at timestamptz,
  capacity smallint,
  audience text,
  status text,
  created_at timestamptz,
  profile_age integer,
  profile_area text,
  email_confirmed boolean,
  birth_date_registered boolean,
  is_verified boolean,
  participant_count integer
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select *
  from public.list_public_listings()
  where id = target_listing_id;
$$;

revoke all on function public.get_public_listing(uuid) from public, anon, authenticated;
grant execute on function public.get_public_listing(uuid) to anon, authenticated;
