alter table public.profiles add column notify_interactions boolean not null default true;

create table public.interactions (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles on delete cascade,
  receiver_id uuid not null references public.profiles on delete cascade,
  kind text not null check (kind in ('kiss', 'hug', 'poke', 'heart')),
  created_at timestamptz not null default now(),
  seen_at timestamptz
);

create index interactions_to on public.interactions (receiver_id, created_at desc);
create index interactions_from on public.interactions (sender_id, created_at desc);

alter table public.interactions enable row level security;
create policy "Ones I sent or got" on public.interactions for select to authenticated
  using (sender_id = (select auth.uid()) or receiver_id = (select auth.uid()));
revoke all on public.interactions from anon, authenticated;
grant select on public.interactions to authenticated;
alter publication supabase_realtime add table public.interactions;

create function public.send_interaction(p_kind text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  them uuid := public.my_partner_id();
begin
  if them is null then raise exception 'no_partner'; end if;
  if p_kind is null or p_kind not in ('kiss', 'hug', 'poke', 'heart') then raise exception 'unknown_interaction'; end if;
  if exists (select 1 from public.interactions where sender_id = me and created_at > now() - interval '2 seconds') then
    raise exception 'too_fast';
  end if;
  insert into public.interactions (sender_id, receiver_id, kind) values (me, them, p_kind);
end $$;

create function public.mark_interactions_seen() returns void
language sql security definer set search_path = '' as $$
  update public.interactions set seen_at = now() where receiver_id = auth.uid() and seen_at is null
$$;

create function public.latest_interaction(p_user uuid) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'kind', i.kind,
    'created_at', extract(epoch from i.created_at),
    'seen', i.seen_at is not null)
  from public.interactions i
  join public.profiles p on p.id = p_user
  where i.receiver_id = p_user and i.sender_id = p.partner_id and i.created_at > now() - interval '1 day'
  order by i.created_at desc
  limit 1
$$;

drop function public.set_notifications(boolean, boolean);

create function public.set_notifications(p_requests boolean, p_widget boolean, p_interactions boolean) returns void
language sql security definer set search_path = '' as $$
  update public.profiles
    set notify_requests = p_requests, notify_widget = p_widget, notify_interactions = p_interactions
    where id = auth.uid()
$$;

create or replace function public.disconnect_partner() returns void
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  them uuid := public.my_partner_id();
begin
  if them is null then return; end if;
  perform 1 from public.profiles where id in (me, them) order by id for update;
  update public.profiles set partner_id = null, partner_since = null
    where id in (me, them) and partner_id in (me, them);
  update public.widget_configs set style = own_style, updated_by = owner_id, updated_at = now()
    where owner_id in (me, them) and updated_by is distinct from owner_id;
  delete from public.interactions
    where (sender_id = me and receiver_id = them) or (sender_id = them and receiver_id = me);
end $$;

create or replace function public.get_state() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me public.profiles;
begin
  select * into me from public.profiles where id = auth.uid();
  if not found then return null; end if;
  return jsonb_build_object(
    'me', public.person_json(me.id) || jsonb_build_object(
      'notify_requests', me.notify_requests,
      'notify_widget', me.notify_widget,
      'notify_interactions', me.notify_interactions,
      'partner_since', extract(epoch from me.partner_since)),
    'partner', case when me.partner_id is null then null else public.person_json(me.partner_id) end,
    'interaction', public.latest_interaction(me.id),
    'my_widget', (
      select jsonb_build_object(
        'style', w.style,
        'own_style', w.own_style,
        'allow_partner', w.allow_partner,
        'by_partner', w.updated_by is not null and w.updated_by <> w.owner_id,
        'updated_at', extract(epoch from w.updated_at))
      from public.widget_configs w where w.owner_id = me.id),
    'partner_widget', (
      select jsonb_build_object(
        'style', w.style,
        'allow_partner', w.allow_partner,
        'by_me', w.updated_by is not distinct from me.id,
        'updated_at', extract(epoch from w.updated_at))
      from public.widget_configs w where w.owner_id = me.partner_id),
    'incoming', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', r.id,
        'username', p.username,
        'avatar', coalesce(av.config, '{}'),
        'created_at', extract(epoch from r.created_at)) order by r.created_at desc)
      from public.connection_requests r
      join public.profiles p on p.id = r.sender_id
      left join public.avatars av on av.user_id = r.sender_id
      where r.receiver_id = me.id and r.status = 'pending'), '[]'),
    'outgoing', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', r.id,
        'username', p.username,
        'created_at', extract(epoch from r.created_at)))
      from public.connection_requests r
      join public.profiles p on p.id = r.receiver_id
      where r.sender_id = me.id and r.status = 'pending'), '[]')
  );
end $$;

create or replace function public.widget_snapshot(p_token text) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  me public.profiles;
begin
  select p.* into me from public.widget_tokens t join public.profiles p on p.id = t.user_id
    where t.token_hash = encode(extensions.digest(p_token, 'sha256'), 'hex');
  if not found then return null; end if;
  return jsonb_build_object(
    'me', public.person_json(me.id),
    'partner', case when me.partner_id is null then null else public.person_json(me.partner_id) end,
    'interaction', public.latest_interaction(me.id),
    'style', (select w.style from public.widget_configs w where w.owner_id = me.id),
    'by_partner', (select w.updated_by is not null and w.updated_by <> w.owner_id
                   from public.widget_configs w where w.owner_id = me.id)
  );
end $$;

revoke all on function public.send_interaction(text), public.mark_interactions_seen(), public.latest_interaction(uuid),
  public.set_notifications(boolean, boolean, boolean) from public, anon, authenticated;
grant execute on function public.send_interaction(text), public.mark_interactions_seen(),
  public.set_notifications(boolean, boolean, boolean) to authenticated;
