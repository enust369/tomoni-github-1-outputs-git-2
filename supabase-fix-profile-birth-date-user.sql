-- profile_birth_datesの参照先と本人専用保存RPCを既存環境へ反映します。

alter table public.profile_birth_dates
drop constraint if exists profile_birth_dates_user_id_fkey;

alter table public.profile_birth_dates
add constraint profile_birth_dates_user_id_fkey
foreign key (user_id) references auth.users(id) on delete cascade;

create or replace function public.save_my_birth_date(p_birth_date date)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'ログインが必要です。';
  end if;
  if not exists (select 1 from auth.users where id = current_user_id) then
    raise exception 'ログインユーザーを確認できませんでした。もう一度ログインしてください。';
  end if;
  if p_birth_date is null
    or p_birth_date > timezone('Asia/Tokyo', now())::date
    or extract(year from age(timezone('Asia/Tokyo', now())::date, p_birth_date)) < 18
    or extract(year from age(timezone('Asia/Tokyo', now())::date, p_birth_date)) > 120 then
    raise exception '18歳以上の正しい生年月日を入力してください。';
  end if;

  insert into public.profile_birth_dates (user_id, birth_date, updated_at)
  values (current_user_id, p_birth_date, now())
  on conflict (user_id) do update
  set birth_date = excluded.birth_date,
      updated_at = now();
end;
$$;

revoke all on function public.save_my_birth_date(date) from public, anon;
grant execute on function public.save_my_birth_date(date) to authenticated;
