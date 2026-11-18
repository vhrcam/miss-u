create function public.person_json(p_id uuid) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'id', p.id,
    'username', p.username,
    'avatar', coalesce(av.config, '{}'),
    'activity', case when ac.kind is null then null else jsonb_build_object(
      'kind', ac.kind,
      'source', ac.source,
      'started_at', extract(epoch from ac.started_at),
      'expires_at', extract(epoch from ac.expires_at)) end
  )
  from public.profiles p
  left join public.avatars av on av.user_id = p.id
  left join public.activities ac on ac.user_id = p.id
  where p.id = p_id
$$;

create function public.get_state() returns jsonb
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
      'partner_since', extract(epoch from me.partner_since)),
    'partner', case when me.partner_id is null then null else public.person_json(me.partner_id) end,
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

revoke all on function public.person_json(uuid), public.get_state() from public, anon, authenticated;
grant execute on function public.get_state() to authenticated;
