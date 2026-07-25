-- ブロック関係にある相手の募集・プロフィールをDB側でも非表示にします。
-- 既存環境では、このファイルだけをSupabase SQL Editorで実行してください。

drop policy if exists "listings are readable by everyone" on public.listings;
create policy "listings are readable by everyone"
on public.listings for select
using (
  auth.uid() is not null
  and (
    owner_id = auth.uid()
    or (
      public.current_user_same_gender_with(owner_id)
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
    public.current_user_same_gender_with(user_id)
    and public.current_user_not_blocked_with(user_id)
  )
);

create or replace function public.list_public_profiles()
returns table (
  user_id uuid,
  nickname text,
  age integer,
  gender text,
  area text,
  photo_urls text[],
  personality_title text,
  personality_tags text[],
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
    p.is_verified
  from public.profiles p
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

create or replace function public.list_visible_listing_participant_counts()
returns table (
  listing_id uuid,
  participant_count integer
)
language sql
stable
security definer
set search_path = public
as $$
  select
    listings.id as listing_id,
    count(listing_participants.user_id)::integer as participant_count
  from public.listings
  left join public.listing_participants
    on listing_participants.listing_id = listings.id
   and listing_participants.status = 'approved'
  where auth.uid() is not null
    and (
      listings.owner_id = auth.uid()
      or (
        public.same_gender_users(auth.uid(), listings.owner_id)
        and public.users_not_blocked(auth.uid(), listings.owner_id)
      )
    )
  group by listings.id;
$$;

revoke all on function public.list_visible_listing_participant_counts() from public, anon;
grant execute on function public.list_visible_listing_participant_counts() to authenticated;
