begin;

-- TOMONI: 恋愛目的ではない友達探しで、同性・異性・どちらもを選べるようにする。
-- 既存ユーザー/既存募集は同性のみのまま維持する。

alter table public.profiles
  add column if not exists friend_gender_preference text not null default 'same_gender';

alter table public.profiles
  drop constraint if exists profiles_friend_gender_preference_check;
alter table public.profiles
  add constraint profiles_friend_gender_preference_check
  check (friend_gender_preference in ('same_gender', 'opposite_gender', 'anyone'));

alter table public.listings
  drop constraint if exists listings_audience_check;
alter table public.listings
  add constraint listings_audience_check
  check (audience in ('same_gender', 'opposite_gender', 'anyone'));

create or replace function public.gender_preference_accepts(
  p_preference text,
  p_owner_gender text,
  p_target_gender text
)
returns boolean
language sql
immutable
set search_path = public
as $$
  select p_owner_gender in ('女性', '男性')
    and p_target_gender in ('女性', '男性')
    and case coalesce(p_preference, 'same_gender')
      when 'same_gender' then p_owner_gender = p_target_gender
      when 'opposite_gender' then p_owner_gender <> p_target_gender
      when 'anyone' then true
      else false
    end;
$$;

revoke all on function public.gender_preference_accepts(text, text, text)
  from public, anon, authenticated;

create or replace function public.users_are_friend_compatible(
  p_user1 uuid,
  p_user2 uuid
)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select p_user1 is not null
    and p_user2 is not null
    and p_user1 <> p_user2
    and exists (
      select 1
      from public.profiles p1
      join public.profiles p2 on p2.user_id = p_user2
      where p1.user_id = p_user1
        and public.gender_preference_accepts(
          p1.friend_gender_preference, p1.gender, p2.gender
        )
        and public.gender_preference_accepts(
          p2.friend_gender_preference, p2.gender, p1.gender
        )
    );
$$;

revoke all on function public.users_are_friend_compatible(uuid, uuid)
  from public, anon, authenticated;

create or replace function public.current_user_friend_compatible_with(
  p_target_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select auth.uid() is not null
    and public.users_are_friend_compatible(auth.uid(), p_target_user_id);
$$;

revoke all on function public.current_user_friend_compatible_with(uuid)
  from public, anon;
grant execute on function public.current_user_friend_compatible_with(uuid)
  to authenticated;

create or replace function public.listing_allows_user(
  p_listing_id uuid,
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select p_user_id is not null
    and exists (
      select 1
      from public.listings l
      join public.profiles owner_profile on owner_profile.user_id = l.owner_id
      join public.profiles viewer_profile on viewer_profile.user_id = p_user_id
      where l.id = p_listing_id
        and l.owner_id <> p_user_id
        and public.gender_preference_accepts(
          l.audience, owner_profile.gender, viewer_profile.gender
        )
        and public.gender_preference_accepts(
          viewer_profile.friend_gender_preference,
          viewer_profile.gender,
          owner_profile.gender
        )
    );
$$;

revoke all on function public.listing_allows_user(uuid, uuid)
  from public, anon;
grant execute on function public.listing_allows_user(uuid, uuid)
  to authenticated;

create or replace function public.get_my_friend_gender_preference()
returns text
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(p.friend_gender_preference, 'same_gender')
  from public.profiles p
  where p.user_id = auth.uid();
$$;

revoke all on function public.get_my_friend_gender_preference()
  from public, anon;
grant execute on function public.get_my_friend_gender_preference()
  to authenticated;

drop policy if exists "listings are readable by everyone" on public.listings;
create policy "listings are readable by everyone"
on public.listings for select
using (
  auth.uid() is not null
  and (
    owner_id = auth.uid()
    or (
      public.listing_allows_user(id, auth.uid())
      and public.current_user_not_blocked_with(owner_id)
    )
  )
);

drop policy if exists "authenticated users can read profiles" on public.profiles;
create policy "authenticated users can read profiles"
on public.profiles for select to authenticated
using (
  user_id = auth.uid()
  or (
    public.current_user_friend_compatible_with(user_id)
    and public.current_user_not_blocked_with(user_id)
  )
);

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
    end,
    p.gender,
    p.area,
    p.photo_urls,
    p.personality_title,
    p.personality_tags,
    u.email_confirmed_at is not null,
    b.birth_date is not null,
    p.is_verified
  from public.profiles p
  join auth.users u on u.id = p.user_id
  left join public.profile_birth_dates b on b.user_id = p.user_id
  where auth.uid() is not null
    and (
      p.user_id = auth.uid()
      or (
        public.users_are_friend_compatible(auth.uid(), p.user_id)
        and public.users_not_blocked(auth.uid(), p.user_id)
      )
    );
$$;

revoke all on function public.list_public_profiles()
  from public, anon, authenticated;
grant execute on function public.list_public_profiles()
  to authenticated;

drop policy if exists "users can create their own favorites" on public.favorites;
create policy "users can create their own favorites"
on public.favorites for insert to authenticated
with check (
  user_id = auth.uid()
  and (
    favorites.target_user_id is null
    or (
      public.current_user_friend_compatible_with(favorites.target_user_id)
      and public.current_user_not_blocked_with(favorites.target_user_id)
    )
  )
  and (
    favorites.listing_id is null
    or exists (
      select 1
      from public.listings l
      where l.id = favorites.listing_id
        and public.listing_allows_user(l.id, auth.uid())
        and public.current_user_not_blocked_with(l.owner_id)
    )
  )
);

create or replace function public.list_discoverable_profiles()
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
    md5(p.user_id::text || ':tomoni-member-v1'),
    p.nickname,
    case
      when b.birth_date is null then null
      else extract(year from age(timezone('Asia/Tokyo', now())::date, b.birth_date))::integer
    end,
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
         or tag like 'tomoni:profile:talkTopic=%'
         or tag like 'tomoni:profile:meetingValue=%'
         or tag like 'tomoni:profile:currentInterest=%'
    ), '{}'::text[]),
    u.email_confirmed_at is not null,
    b.birth_date is not null,
    p.is_verified,
    exists (
      select 1
      from public.favorites f
      where f.user_id = auth.uid()
        and f.target_user_id = p.user_id
    )
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
    and public.users_are_friend_compatible(auth.uid(), p.user_id)
    and public.users_not_blocked(auth.uid(), p.user_id)
  order by p.created_at desc;
$$;

revoke all on function public.list_discoverable_profiles()
  from public, anon, authenticated;
grant execute on function public.list_discoverable_profiles()
  to authenticated;

create or replace function public.set_discoverable_profile_favorite(
  target_profile_key text,
  desired boolean
)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  current_user_id uuid := auth.uid();
  v_target_user_id uuid;
begin
  if current_user_id is null then
    raise exception 'ログインが必要です。';
  end if;

  select p.user_id
  into v_target_user_id
  from public.profiles p
  join auth.users u on u.id = p.user_id
  where md5(p.user_id::text || ':tomoni-member-v1') = target_profile_key
    and p.user_id <> current_user_id
    and p.nickname <> ''
    and p.area <> ''
    and p.bio <> ''
    and p.gender in ('女性', '男性')
    and u.email_confirmed_at is not null
    and u.deleted_at is null
    and (u.banned_until is null or u.banned_until <= now())
    and public.users_are_friend_compatible(current_user_id, p.user_id)
    and public.users_not_blocked(current_user_id, p.user_id)
  limit 1;

  if v_target_user_id is null then
    raise exception 'このプロフィールは現在の希望条件では選択できません。';
  end if;

  if coalesce(desired, false) then
    insert into public.favorites (user_id, target_user_id, listing_id)
    values (current_user_id, v_target_user_id, null)
    on conflict (user_id, target_user_id)
      where target_user_id is not null do nothing;
  else
    delete from public.favorites
    where user_id = current_user_id
      and favorites.target_user_id = v_target_user_id;
  end if;

  return coalesce(desired, false);
end;
$$;

revoke all on function public.set_discoverable_profile_favorite(text, boolean)
  from public, anon, authenticated;
grant execute on function public.set_discoverable_profile_favorite(text, boolean)
  to authenticated;

create or replace function public.list_visible_listing_participant_counts()
returns table (
  listing_id uuid,
  participant_count integer
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select
    l.id,
    count(lp.user_id)::integer
  from public.listings l
  left join public.listing_participants lp
    on lp.listing_id = l.id
   and lp.status = 'approved'
  where auth.uid() is not null
    and (
      l.owner_id = auth.uid()
      or (
        public.listing_allows_user(l.id, auth.uid())
        and public.users_not_blocked(auth.uid(), l.owner_id)
      )
    )
  group by l.id;
$$;

revoke all on function public.list_visible_listing_participant_counts()
  from public, anon, authenticated;
grant execute on function public.list_visible_listing_participant_counts()
  to authenticated;

create or replace function public.request_listing_participation(
  target_listing_id uuid,
  requested_applicant_name text
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  current_user_id uuid := auth.uid();
  listing_owner_id uuid;
  listing_status text;
  listing_scheduled_at timestamptz;
  listing_capacity smallint;
  approved_count integer;
begin
  if current_user_id is null then
    raise exception 'ログインが必要です。';
  end if;

  select owner_id, status, scheduled_at, capacity
  into listing_owner_id, listing_status, listing_scheduled_at, listing_capacity
  from public.listings
  where id = target_listing_id
  for update;

  if not found then raise exception '募集が見つかりません。'; end if;
  if listing_status <> 'open' then raise exception '募集は終了しています。'; end if;
  if listing_scheduled_at <= now() then raise exception '開催日時を過ぎています。'; end if;
  if listing_owner_id = current_user_id then raise exception '自分の募集には参加できません。'; end if;

  if not public.listing_allows_user(target_listing_id, current_user_id) then
    raise exception 'この募集の参加対象と、あなたの会いたい相手の設定が一致していません。';
  end if;

  if not public.users_not_blocked(current_user_id, listing_owner_id) then
    raise exception 'ブロック関係があるため、この募集には応募できません。';
  end if;

  if exists (
    select 1 from public.listing_participants
    where listing_id = target_listing_id and user_id = current_user_id
  ) then
    raise exception 'すでに参加申請済みです。';
  end if;

  select count(*) into approved_count
  from public.listing_participants
  where listing_id = target_listing_id
    and status = 'approved';

  if approved_count >= listing_capacity then
    raise exception 'この募集は満員です。';
  end if;

  insert into public.listing_participants (
    listing_id, user_id, applicant_name, status
  )
  values (
    target_listing_id,
    current_user_id,
    left(nullif(trim(requested_applicant_name), ''), 20),
    'pending'
  );
end;
$$;

revoke all on function public.request_listing_participation(uuid, text)
  from public, anon, authenticated;
grant execute on function public.request_listing_participation(uuid, text)
  to authenticated;

create or replace function public.can_access_listing_chat(target_listing_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select auth.uid() is not null
    and (
      exists (
        select 1
        from public.listings l
        where l.id = target_listing_id
          and l.owner_id = auth.uid()
      )
      or exists (
        select 1
        from public.listing_participants lp
        join public.listings l on l.id = lp.listing_id
        where lp.listing_id = target_listing_id
          and lp.user_id = auth.uid()
          and lp.status = 'approved'
          and public.listing_allows_user(l.id, auth.uid())
          and public.users_not_blocked(auth.uid(), l.owner_id)
      )
    );
$$;

revoke all on function public.can_access_listing_chat(uuid)
  from public, anon, authenticated;
grant execute on function public.can_access_listing_chat(uuid)
  to authenticated;

drop policy if exists "matched users can read their own matches" on public.matches;
create policy "matched users can read their own matches"
on public.matches for select to authenticated
using (
  (auth.uid() = user1_id or auth.uid() = user2_id)
  and public.current_user_friend_compatible_with(
    case when user1_id = auth.uid() then user2_id else user1_id end
  )
  and public.current_user_not_blocked_with(
    case when user1_id = auth.uid() then user2_id else user1_id end
  )
);

create or replace function public.create_match_from_favorite()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  first_user uuid;
  second_user uuid;
begin
  if new.target_user_id is null or new.target_user_id = new.user_id then
    return new;
  end if;

  if not public.users_are_friend_compatible(new.user_id, new.target_user_id) then
    return new;
  end if;

  if not public.users_not_blocked(new.user_id, new.target_user_id) then
    return new;
  end if;

  if exists (
    select 1
    from public.favorites
    where user_id = new.target_user_id
      and target_user_id = new.user_id
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

create or replace function public.ensure_match_with_user(p_target_user_id uuid)
returns public.matches
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  current_user_id uuid := auth.uid();
  first_user uuid;
  second_user uuid;
  match_row public.matches;
begin
  if current_user_id is null then raise exception 'ログインが必要です。'; end if;
  if p_target_user_id is null or p_target_user_id = current_user_id then
    raise exception '相手ユーザーが正しくありません。';
  end if;

  if not public.users_are_friend_compatible(current_user_id, p_target_user_id) then
    raise exception 'お互いの会いたい相手の設定が一致していません。';
  end if;

  if not public.users_not_blocked(current_user_id, p_target_user_id) then
    raise exception 'ブロック関係があるため、この相手とはマッチできません。';
  end if;

  if not exists (
    select 1 from public.favorites
    where user_id = current_user_id
      and target_user_id = p_target_user_id
  ) then
    raise exception '自分の気になるが見つかりません。';
  end if;

  if not exists (
    select 1 from public.favorites
    where user_id = p_target_user_id
      and target_user_id = current_user_id
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

revoke all on function public.ensure_match_with_user(uuid)
  from public, anon, authenticated;
grant execute on function public.ensure_match_with_user(uuid)
  to authenticated;

create or replace function public.can_access_match_chat(target_match_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select auth.uid() is not null
    and exists (
      select 1
      from public.matches m
      where m.id = target_match_id
        and m.status = 'active'
        and (m.user1_id = auth.uid() or m.user2_id = auth.uid())
        and public.users_are_friend_compatible(m.user1_id, m.user2_id)
        and public.users_not_blocked(m.user1_id, m.user2_id)
    );
$$;

revoke all on function public.can_access_match_chat(uuid)
  from public, anon, authenticated;
grant execute on function public.can_access_match_chat(uuid)
  to authenticated;

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
  and public.users_are_friend_compatible(f1.user_id, f1.target_user_id)
  and public.users_not_blocked(f1.user_id, f1.target_user_id)
on conflict do nothing;

commit;
