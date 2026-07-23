-- TOMONI「話したいこと」と「会う時に大切にしたいこと」を登録者一覧へ反映します。
-- Supabase SQL Editorへ、このファイル全体を貼り付けて実行してください。
-- DBカラムは追加せず、既存 profiles.tags の公開許可対象だけを更新します。

create or replace function public.list_discoverable_profiles()
returns table (
  profile_key text,
  nickname text,
  age integer,
  area text,
  photo_urls text[],
  bio text,
  public_tags text[],
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
