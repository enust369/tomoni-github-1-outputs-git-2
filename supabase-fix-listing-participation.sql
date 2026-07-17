-- TOMONI 参加申請・承認RPCの募集状態、開催日時、定員検証
-- Supabase SQL Editorへ、このファイル全体を貼り付けて実行してください。

create or replace function public.request_listing_participation(target_listing_id uuid, requested_applicant_name text)
returns void
language plpgsql
security definer
set search_path = public
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

  if not found then
    raise exception '募集が見つかりません。';
  end if;

  if listing_status <> 'open' then
    raise exception '募集は終了しています。';
  end if;

  if listing_scheduled_at <= now() then
    raise exception '開催日時を過ぎています。';
  end if;

  if listing_owner_id = current_user_id then
    raise exception '自分の募集には参加できません。';
  end if;

  if not public.same_gender_users(current_user_id, listing_owner_id) then
    raise exception 'この募集は、募集者と同じ性別の方だけが参加申請できます。';
  end if;

  if public.has_block_relation(listing_owner_id) then
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

  insert into public.listing_participants (listing_id, user_id, applicant_name, status)
  values (target_listing_id, current_user_id, left(nullif(trim(requested_applicant_name), ''), 20), 'pending');
end;
$$;

revoke all on function public.request_listing_participation(uuid, text) from public, anon;
grant execute on function public.request_listing_participation(uuid, text) to authenticated;

create or replace function public.review_listing_participation(target_listing_id uuid, p_target_user_id uuid, decision text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  listing_owner_id uuid;
  listing_status text;
  listing_scheduled_at timestamptz;
  listing_capacity smallint;
  approved_count integer;
begin
  if decision not in ('approved', 'declined') then
    raise exception '承認内容が正しくありません。';
  end if;

  select owner_id, status, scheduled_at, capacity
  into listing_owner_id, listing_status, listing_scheduled_at, listing_capacity
  from public.listings
  where id = target_listing_id
  for update;

  if not found then
    raise exception '募集が見つかりません。';
  end if;

  if listing_owner_id <> current_user_id then
    raise exception 'この参加申請を確認する権限がありません。';
  end if;

  if listing_status <> 'open' then
    raise exception '募集は終了しています。';
  end if;

  if listing_scheduled_at <= now() then
    raise exception '開催日時を過ぎています。';
  end if;

  if not exists (
    select 1
    from public.listing_participants
    where listing_id = target_listing_id
      and user_id = p_target_user_id
      and status = 'pending'
  ) then
    raise exception '参加申請が見つからないか、すでに処理されています。';
  end if;

  if decision = 'approved' then
    select count(*) into approved_count
    from public.listing_participants
    where listing_id = target_listing_id and status = 'approved';
    if approved_count >= listing_capacity then
      raise exception 'この募集は満員です。';
    end if;
  end if;

  update public.listing_participants
  set status = decision
  where listing_id = target_listing_id
    and user_id = p_target_user_id
    and status = 'pending';

  if not found then
    raise exception '参加申請が見つからないか、すでに処理されています。';
  end if;
end;
$$;

revoke all on function public.review_listing_participation(uuid, uuid, text) from public, anon;
grant execute on function public.review_listing_participation(uuid, uuid, text) to authenticated;
