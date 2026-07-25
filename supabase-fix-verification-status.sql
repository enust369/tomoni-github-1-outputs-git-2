-- メール確認・年齢情報入力・公的本人確認を別々の状態として返します。
-- Supabase SQL Editorでこのファイルだけを実行してください。

drop function if exists public.list_public_profiles();
create function public.list_public_profiles()
returns table (
  user_id uuid,
  nickname text,
  age integer,
  gender text,
  area text,
  photo_urls text[],
  personality_title text,
  personality_tags text[],
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
    p.user_id,
    p.nickname,
    case
      when b.birth_date is null then null
      else extract(year from age(timezone('Asia/Tokyo', now())::date, b.birth_date))::integer
    end as age,
    p.gender,
    p.area,
    p.photo_urls,
    p.personality_title,
    p.personality_tags,
    u.email_confirmed_at is not null as email_confirmed,
    b.birth_date is not null as birth_date_registered,
    p.is_verified
  from public.profiles p
  join auth.users u on u.id = p.user_id
  left join public.profile_birth_dates b on b.user_id = p.user_id
  where auth.uid() is not null
    and (
      p.user_id = auth.uid()
      or (
        public.same_gender_users(auth.uid(), p.user_id)
        and public.users_not_blocked(auth.uid(), p.user_id)
      )
    );
$$;

revoke all on function public.list_public_profiles() from public, anon;
grant execute on function public.list_public_profiles() to authenticated;

drop function if exists public.list_discoverable_profiles();
create function public.list_discoverable_profiles()
returns table (
  profile_key text,
  nickname text,
  age integer,
  area text,
  photo_urls text[],
  bio text,
  public_tags text[],
  email_confirmed boolean,
  birth_date_registered boolean,
  is_verified boolean,
  is_favorite boolean
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
    p.photo_urls,
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
    p.is_verified,
    exists (
      select 1
      from public.favorites f
      where f.user_id = auth.uid()
        and f.target_user_id = p.user_id
    ) as is_favorite
  from public.profiles p
  join auth.users u on u.id = p.user_id
  left join public.profile_birth_dates b on b.user_id = p.user_id
  where auth.uid() is not null
    and p.user_id <> auth.uid()
    and p.nickname <> ''
    and p.area <> ''
    and p.bio <> ''
    and p.gender in ('女性', '男性')
    and u.email_confirmed_at is not null
    and u.deleted_at is null
    and (u.banned_until is null or u.banned_until <= now())
    and public.same_gender_users(auth.uid(), p.user_id)
    and public.users_not_blocked(auth.uid(), p.user_id)
  order by p.created_at desc;
$$;

revoke all on function public.list_discoverable_profiles() from public, anon, authenticated;
grant execute on function public.list_discoverable_profiles() to authenticated;

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
    'email_confirmed_users_count', (
      select count(*) from auth.users u where u.email_confirmed_at is not null
    ),
    'birth_date_registered_users_count', (
      select count(*) from public.profile_birth_dates
    ),
    'verified_users_count', (
      select count(*) from public.profiles p where coalesce(p.is_verified, false)
    ),
    'today_listings_count', (
      select count(*) from public.listings where created_at >= current_date
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
create function public.get_admin_users(search_term text default '')
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
        u.email_confirmed_at is not null as email_confirmed,
        exists (
          select 1
          from public.profile_birth_dates b
          where b.user_id = u.id
        ) as birth_date_registered,
        coalesce(p.is_verified, false) as is_verified,
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
