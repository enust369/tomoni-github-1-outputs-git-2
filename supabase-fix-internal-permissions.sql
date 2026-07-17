-- TOMONI 内部判定関数と参加人数取得の公開範囲修正
-- Supabase SQL Editorへ、このファイル全体を貼り付けて実行してください。

create or replace function public.current_user_same_gender_with(p_target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
    and public.same_gender_users(auth.uid(), p_target_user_id);
$$;

revoke all on function public.current_user_same_gender_with(uuid) from public, anon;
grant execute on function public.current_user_same_gender_with(uuid) to authenticated;

create or replace function public.current_user_not_blocked_with(p_target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
    and public.users_not_blocked(auth.uid(), p_target_user_id);
$$;

revoke all on function public.current_user_not_blocked_with(uuid) from public, anon;
grant execute on function public.current_user_not_blocked_with(uuid) to authenticated;

drop policy if exists "listings are readable by everyone" on public.listings;
create policy "listings are readable by everyone"
on public.listings for select
using (
  auth.uid() is not null
  and (
    owner_id = auth.uid()
    or public.current_user_same_gender_with(owner_id)
  )
);

drop policy if exists "authenticated users can read profiles" on public.profiles;
create policy "authenticated users can read profiles"
on public.profiles for select to authenticated
using (
  user_id = auth.uid()
  or public.current_user_same_gender_with(user_id)
);

drop policy if exists "users can create their own favorites" on public.favorites;
create policy "users can create their own favorites"
on public.favorites for insert to authenticated
with check (
  user_id = auth.uid()
  and (
    favorites.target_user_id is null
    or (
      public.current_user_same_gender_with(favorites.target_user_id)
      and public.current_user_not_blocked_with(favorites.target_user_id)
    )
  )
  and (
    favorites.listing_id is null
    or exists (
      select 1
      from public.listings
      where listings.id = favorites.listing_id
        and public.current_user_same_gender_with(listings.owner_id)
        and public.current_user_not_blocked_with(listings.owner_id)
    )
  )
);

drop policy if exists "matched users can read their own matches" on public.matches;
create policy "matched users can read their own matches"
on public.matches for select to authenticated
using (
  (auth.uid() = user1_id or auth.uid() = user2_id)
  and public.current_user_same_gender_with(
    case when user1_id = auth.uid() then user2_id else user1_id end
  )
  and public.current_user_not_blocked_with(
    case when user1_id = auth.uid() then user2_id else user1_id end
  )
);

create or replace view public.listing_participant_counts
with (
  security_barrier = true,
  security_invoker = true
)
as
select
  listing_id,
  count(*)::integer as participant_count
from public.listing_participants
where status = 'approved'
group by listing_id;

revoke all on public.listing_participant_counts from public, anon, authenticated;

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
      or public.same_gender_users(auth.uid(), listings.owner_id)
    )
  group by listings.id;
$$;

revoke all on function public.list_visible_listing_participant_counts() from public, anon;
grant execute on function public.list_visible_listing_participant_counts() to authenticated;

revoke all on function public.same_gender_users(uuid, uuid) from public, anon, authenticated;
revoke all on function public.users_not_blocked(uuid, uuid) from public, anon, authenticated;
