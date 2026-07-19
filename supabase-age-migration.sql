-- TOMONI 実年齢表示・生年月日非公開化マイグレーション
-- Supabase SQL Editor へ、このファイル全体を貼り付けて実行してください。

alter table public.profiles alter column age drop not null;
alter table public.profiles drop constraint if exists profiles_age_check;
update public.profiles set age = null where age is not null;

revoke select on public.profiles from authenticated;
grant select (
  user_id, nickname, gender, area, bio, tags, photo_urls,
  personality_type, personality_title, personality_description,
  personality_tags, quiet_score, talk_score, comfort_score,
  is_verified, created_at, updated_at
) on public.profiles to authenticated;

create table if not exists public.profile_birth_dates (
  user_id uuid primary key references auth.users(id) on delete cascade,
  birth_date date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profile_birth_dates
drop constraint if exists profile_birth_dates_user_id_fkey;
alter table public.profile_birth_dates
add constraint profile_birth_dates_user_id_fkey
foreign key (user_id) references auth.users(id) on delete cascade;

alter table public.profile_birth_dates enable row level security;

drop policy if exists "users can read their own birth date" on public.profile_birth_dates;
create policy "users can read their own birth date"
on public.profile_birth_dates for select to authenticated
using (user_id = auth.uid());

revoke all on public.profile_birth_dates from public, anon, authenticated;
grant select on public.profile_birth_dates to authenticated;

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
      or public.same_gender_users(auth.uid(), p.user_id)
    );
$$;

revoke all on function public.list_public_profiles() from public, anon;
grant execute on function public.list_public_profiles() to authenticated;

create or replace function public.capture_signup_birth_date()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  signup_birth_date date;
begin
  begin
    signup_birth_date := nullif(new.raw_user_meta_data ->> 'birth_date', '')::date;
  exception when others then
    signup_birth_date := null;
  end;

  if signup_birth_date is not null
    and signup_birth_date <= timezone('Asia/Tokyo', now())::date
    and extract(year from age(timezone('Asia/Tokyo', now())::date, signup_birth_date)) between 18 and 120 then
    insert into public.profile_birth_dates (user_id, birth_date)
    values (new.id, signup_birth_date)
    on conflict (user_id) do nothing;
  end if;
  return new;
end;
$$;

revoke all on function public.capture_signup_birth_date() from public, anon, authenticated;

drop trigger if exists on_auth_user_created_capture_birth_date on auth.users;
create trigger on_auth_user_created_capture_birth_date
after insert on auth.users
for each row execute function public.capture_signup_birth_date();
