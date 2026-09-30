create or replace function public.save_my_friend_gender_preference(
  p_preference text
)
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

  if p_preference not in ('same_gender', 'opposite_gender', 'anyone') then
    raise exception '会いたい相手の設定が正しくありません。';
  end if;

  update public.profiles
  set friend_gender_preference = p_preference,
      updated_at = now()
  where user_id = current_user_id;

  if not found then
    raise exception 'プロフィールが見つかりません。';
  end if;
end;
$$;

revoke all on function public.save_my_friend_gender_preference(text)
  from public, anon, authenticated;
grant execute on function public.save_my_friend_gender_preference(text)
  to authenticated;
