-- Apply ONLY to a new, dedicated Supabase project. Do not apply to TOMONI.
begin;
create table public.spots (
 id uuid primary key default gen_random_uuid(), slug text unique not null,
 name text not null, category text not null check(category in ('sightseeing','gourmet','cycling','camp','onsen','michinoeki','stay','fishing','surfing','activity')),
 area text not null check(area in ('kochi_city','east','west','north_niyodo')), municipality text not null,
 initial_rank integer not null check(initial_rank>0), recommend_count integer not null default 0 check(recommend_count>=0),
 review_average numeric, review_count integer not null default 0, short_description text, description text, catchphrase text,
 address text, latitude numeric, longitude numeric, phone text, official_url text, google_maps_url text, opening_hours text,
 closed_days text, price_text text, parking_text text, main_image_url text, tags text[] not null default '{}',
 is_published boolean not null default false, is_demo boolean not null default false, source_url text, last_verified_at timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index spots_ranking on public.spots(category, recommend_count desc, initial_rank asc) where is_published;
create table public.anonymous_recommendations (
 spot_id uuid not null references public.spots on delete cascade,
 anonymous_id uuid not null references auth.users on delete cascade,
 created_at timestamptz not null default now(), primary key(spot_id,anonymous_id)
);
create table public.profiles(id uuid primary key references auth.users on delete cascade,nickname text,created_at timestamptz default now());
create table public.favorites(user_id uuid references auth.users on delete cascade,spot_id uuid references public.spots on delete cascade,created_at timestamptz default now(),primary key(user_id,spot_id));
create table public.reviews(id uuid primary key default gen_random_uuid(),user_id uuid references auth.users on delete cascade,spot_id uuid references public.spots on delete cascade,rating integer check(rating between 1 and 5),body text,status text not null default 'pending' check(status in ('pending','approved','rejected')),created_at timestamptz default now());
create table public.courses(id uuid primary key default gen_random_uuid(),slug text unique not null,name text not null,area text,theme text,duration text,transport text,audience text,season text,notes text,main_image_url text,initial_rank integer not null default 1,is_published boolean not null default false,created_at timestamptz default now());
create table public.course_spots(course_id uuid references public.courses on delete cascade,spot_id uuid references public.spots on delete cascade,position integer not null,stay_minutes integer,travel_minutes integer,day_number integer default 1,primary key(course_id,position));
create table public.spot_images(id uuid primary key default gen_random_uuid(),spot_id uuid references public.spots on delete cascade,url text not null,alt text,credit text,license text,is_approved boolean default false);
create table public.spot_suggestions(id uuid primary key default gen_random_uuid(),submitted_by uuid references auth.users on delete set null,name text not null,category text not null,area text not null,municipality text not null,reason text not null,details jsonb not null default '{}',status text not null default 'pending' check(status in ('pending','approved','rejected')),approved_spot_id uuid references public.spots,created_at timestamptz default now());
create table public.spot_correction_requests(id uuid primary key default gen_random_uuid(),submitted_by uuid references auth.users on delete set null,spot_id uuid not null references public.spots,target text not null,reason text not null,details jsonb not null default '{}',status text not null default 'pending' check(status in ('pending','approved','rejected')),created_at timestamptz default now());
create table public.events(id uuid primary key default gen_random_uuid(),slug text unique not null,name text not null,category text not null,area text,start_date date not null,end_date date not null,description text,spot_id uuid references public.spots,official_url text,is_published boolean default false,is_demo boolean default false,created_at timestamptz default now(),check(end_date>=start_date));
-- Private rolling request budget. No IP is stored or used as an identity.
create table public.request_budgets(identity uuid not null references auth.users on delete cascade,operation text not null,window_start timestamptz not null default now(),attempts integer not null default 0,primary key(identity,operation));
create function public.enforce_budget(op text, maximum integer) returns void language plpgsql security definer set search_path='' as $$
declare u uuid:=auth.uid(); b public.request_budgets;
begin
 if u is null then raise exception 'anonymous_auth_required'; end if;
 perform pg_advisory_xact_lock(hashtextextended(u::text||op,0));
 insert into public.request_budgets(identity,operation) values(u,op) on conflict do nothing;
 select * into b from public.request_budgets where identity=u and operation=op for update;
 if b.window_start < now()-interval '1 minute' then update public.request_budgets set window_start=now(),attempts=1 where identity=u and operation=op;
 elsif b.attempts>=maximum then raise exception 'rate_limit';
 else update public.request_budgets set attempts=attempts+1 where identity=u and operation=op; end if;
end $$;
create function public.sync_recommend_count() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if TG_OP='INSERT' then update public.spots set recommend_count=recommend_count+1,updated_at=now() where id=new.spot_id; return new;
 else update public.spots set recommend_count=greatest(0,recommend_count-1),updated_at=now() where id=old.spot_id; return old; end if;
end $$;
create trigger recommendation_count after insert or delete on public.anonymous_recommendations for each row execute function public.sync_recommend_count();
create function public.toggle_recommendation(p_spot_id uuid) returns jsonb language plpgsql security definer set search_path='' as $$
declare u uuid:=auth.uid(); selected boolean; n integer;
begin
 perform public.enforce_budget('vote',20);
 perform 1 from public.spots where id=p_spot_id and is_published for update;
 if not found then raise exception 'spot_unavailable'; end if;
 delete from public.anonymous_recommendations where spot_id=p_spot_id and anonymous_id=u;
 if found then selected:=false;
 else insert into public.anonymous_recommendations(spot_id,anonymous_id) values(p_spot_id,u);selected:=true;end if;
 select recommend_count into n from public.spots where id=p_spot_id;
 return jsonb_build_object('voted',selected,'recommend_count',n);
end $$;
create function public.my_recommendations() returns table(spot_id uuid) language sql stable security definer set search_path='' as $$select spot_id from public.anonymous_recommendations where anonymous_id=auth.uid()$$;
create function public.submit_request(kind text,payload jsonb) returns uuid language plpgsql security definer set search_path='' as $$
declare new_id uuid;
begin
 perform public.enforce_budget('submission',3);
 if octet_length(payload::text)>16000 or length(trim(coalesce(payload->>'reason','')))=0 or length(payload->>'reason')>3000 then raise exception 'invalid_payload';end if;
 if kind='suggest' then
  if length(trim(coalesce(payload->>'name','')))=0 or length(trim(coalesce(payload->>'municipality','')))=0 or length(payload->>'name')>300 or length(payload->>'municipality')>300
   or coalesce(payload->>'category','') not in ('sightseeing','gourmet','cycling','camp','onsen','michinoeki','stay','fishing','surfing','activity')
   or coalesce(payload->>'area','') not in ('kochi_city','east','west','north_niyodo') then raise exception 'invalid_payload';end if;
  insert into public.spot_suggestions(submitted_by,name,category,area,municipality,reason,details)
  values(auth.uid(),payload->>'name',payload->>'category',payload->>'area',payload->>'municipality',payload->>'reason',payload-'status'-'submitted_by') returning id into new_id;
 elsif kind='correction' then
  if coalesce(payload->>'target','') not in ('営業時間','定休日','住所','電話','料金','駐車場','公式URL','店名/施設名','閉店/休業','写真','その他') then raise exception 'invalid_payload';end if;
  if not exists(select 1 from public.spots where id=(payload->>'spot_id')::uuid and is_published) then raise exception 'spot_unavailable';end if;
  insert into public.spot_correction_requests(submitted_by,spot_id,target,reason,details)
  values(auth.uid(),(payload->>'spot_id')::uuid,payload->>'target',payload->>'reason',payload-'status'-'submitted_by') returning id into new_id;
 else raise exception 'invalid_kind';end if;
 return new_id;
end $$;
-- This service-role-only transaction approves and publishes a reviewed suggestion at 0 votes.
create function public.approve_suggestion(p_id uuid,p_slug text,p_rank integer) returns uuid language plpgsql security definer set search_path='' as $$
declare s public.spot_suggestions;new_id uuid;
begin
 select * into s from public.spot_suggestions where id=p_id and status='pending' for update;
 if not found then raise exception 'pending_suggestion_not_found';end if;
 insert into public.spots(slug,name,category,area,municipality,initial_rank,short_description,is_published)
 values(p_slug,s.name,s.category,s.area,s.municipality,p_rank,s.reason,true) returning id into new_id;
 update public.spot_suggestions set status='approved',approved_spot_id=new_id where id=p_id;
 return new_id;
end $$;
-- Deny direct public writes everywhere, including counters and moderation status.
do $$ declare t text;begin foreach t in array array['spots','anonymous_recommendations','profiles','favorites','reviews','courses','course_spots','spot_images','spot_suggestions','spot_correction_requests','events','request_budgets'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('revoke all on public.%I from anon, authenticated',t);
end loop;end $$;
grant select on public.spots,public.courses,public.course_spots,public.spot_images,public.events to anon,authenticated;
create policy public_spots on public.spots for select using(is_published);
create policy public_courses on public.courses for select using(is_published);
create policy public_course_spots on public.course_spots for select using(exists(select 1 from public.courses where id=course_id and is_published));
create policy public_images on public.spot_images for select using(is_approved and exists(select 1 from public.spots where id=spot_id and is_published));
create policy public_events on public.events for select using(is_published);
revoke all on function public.enforce_budget(text,integer),public.sync_recommend_count(),public.toggle_recommendation(uuid),public.my_recommendations(),public.submit_request(text,jsonb),public.approve_suggestion(uuid,text,integer) from public,anon,authenticated;
grant execute on function public.toggle_recommendation(uuid),public.my_recommendations(),public.submit_request(text,jsonb) to authenticated;
grant execute on function public.approve_suggestion(uuid,text,integer) to service_role;
commit;
