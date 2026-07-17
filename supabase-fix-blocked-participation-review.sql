-- TOMONI 参加申請の承認・見送り・通知におけるブロック関係の再確認
-- Supabase SQL Editorへ、このファイル全体を貼り付けて実行してください。

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

  if not public.users_not_blocked(current_user_id, p_target_user_id) then
    raise exception 'ブロック関係があるため、この参加申請は処理できません。';
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

create or replace function public.notify_listing_participation_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  listing_owner_id uuid;
begin
  select owner_id into listing_owner_id from public.listings where id = new.listing_id;

  if tg_op = 'INSERT' and new.status = 'pending' then
    if not public.users_not_blocked(new.user_id, listing_owner_id) then
      return new;
    end if;

    insert into public.notifications (recipient_id, actor_id, listing_id, type, message, event_key)
    values (listing_owner_id, new.user_id, new.listing_id, 'participation_request', coalesce(new.applicant_name, '参加申請者') || 'さんが参加申請しました', 'participation-request:' || new.listing_id || ':' || new.user_id)
    on conflict (event_key) do nothing;
  elsif tg_op = 'UPDATE' and old.status is distinct from new.status and new.status in ('approved', 'declined') then
    if not public.users_not_blocked(listing_owner_id, new.user_id) then
      return new;
    end if;

    insert into public.notifications (recipient_id, actor_id, listing_id, type, message, event_key)
    values (
      new.user_id,
      listing_owner_id,
      new.listing_id,
      case when new.status = 'approved' then 'participation_approved' else 'participation_declined' end,
      case when new.status = 'approved' then '参加申請が承認されました' else '今回は見送られました' end,
      'participation-review:' || new.listing_id || ':' || new.user_id || ':' || new.status
    )
    on conflict (event_key) do nothing;
  end if;
  return new;
end;
$$;
