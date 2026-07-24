-- TOMONIホームに、実データから集計した公開統計だけを返します。
-- 日付境界はTOMONIの基準地域である日本時間（Asia/Tokyo）です。

create or replace function public.get_home_stats()
returns table (
  today_listings bigint,
  today_available_listings bigint,
  week_matches bigint,
  fetched_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  with boundaries as (
    select
      date_trunc('day', timezone('Asia/Tokyo', now())) at time zone 'Asia/Tokyo' as today_start,
      date_trunc('day', timezone('Asia/Tokyo', now())) at time zone 'Asia/Tokyo' + interval '1 day' as tomorrow_start,
      date_trunc('week', timezone('Asia/Tokyo', now())) at time zone 'Asia/Tokyo' as week_start
  )
  select
    (
      select count(*)
      from public.listings l
      where l.created_at >= b.today_start
        and l.created_at < b.tomorrow_start
    ) as today_listings,
    (
      select count(*)
      from public.listings l
      where l.status = 'open'
        and l.scheduled_at >= b.today_start
        and l.scheduled_at < b.tomorrow_start
    ) as today_available_listings,
    (
      select count(*)
      from public.matches m
      where m.created_at >= b.week_start
    ) as week_matches,
    now() as fetched_at
  from boundaries b;
$$;

revoke all on function public.get_home_stats() from public, anon, authenticated;
grant execute on function public.get_home_stats() to anon, authenticated;
