create function public.link_partners(p_a uuid, p_b uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform 1 from public.profiles where id in (p_a, p_b) order by id for update;
  if exists (select 1 from public.profiles where id in (p_a, p_b) and partner_id is not null) then
    raise exception 'already_connected';
  end if;
  update public.profiles
    set partner_id = case when id = p_a then p_b else p_a end, partner_since = now()
    where id in (p_a, p_b);
  update public.connection_requests set status = 'canceled', responded_at = now()
    where status = 'pending' and (sender_id in (p_a, p_b) or receiver_id in (p_a, p_b));
end $$;

create function public.send_request(p_username text) returns text
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  them uuid;
  theirs uuid;
begin
  if me is null then raise exception 'not_signed_in'; end if;
  select id into them from public.profiles where username = lower(trim(p_username));
  if them is null then raise exception 'user_not_found'; end if;
  if them = me then raise exception 'cannot_add_self'; end if;
  if exists (select 1 from public.profiles where id = me and partner_id is not null) then raise exception 'already_connected'; end if;
  if exists (select 1 from public.profiles where id = them and partner_id is not null) then raise exception 'user_unavailable'; end if;

  select id into theirs from public.connection_requests
    where sender_id = them and receiver_id = me and status = 'pending' for update;
  if theirs is not null then
    update public.connection_requests set status = 'accepted', responded_at = now() where id = theirs;
    perform public.link_partners(them, me);
    return 'connected';
  end if;

  if exists (select 1 from public.connection_requests where sender_id = me and status = 'pending') then
    raise exception 'request_pending';
  end if;
  if exists (select 1 from public.connection_requests where sender_id = me and receiver_id = them
             and status = 'declined' and responded_at > now() - interval '1 day') then
    raise exception 'user_unavailable';
  end if;

  begin
    insert into public.connection_requests (sender_id, receiver_id) values (me, them);
  exception when unique_violation then
    raise exception 'request_pending';
  end;
  return 'sent';
end $$;

create function public.respond_request(p_request uuid, p_accept boolean) returns void
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  them uuid;
begin
  select sender_id into them from public.connection_requests
    where id = p_request and receiver_id = me and status = 'pending' for update;
  if them is null then raise exception 'request_not_found'; end if;
  update public.connection_requests
    set status = case when p_accept then 'accepted' else 'declined' end, responded_at = now()
    where id = p_request;
  if p_accept then perform public.link_partners(them, me); end if;
end $$;

create function public.cancel_request(p_request uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  update public.connection_requests set status = 'canceled', responded_at = now()
    where id = p_request and sender_id = auth.uid() and status = 'pending';
  if not found then raise exception 'request_not_found'; end if;
end $$;

create function public.disconnect_partner() returns void
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
end $$;

revoke all on function public.link_partners(uuid, uuid), public.send_request(text), public.respond_request(uuid, boolean),
  public.cancel_request(uuid), public.disconnect_partner() from public, anon, authenticated;

grant execute on function public.send_request(text), public.respond_request(uuid, boolean),
  public.cancel_request(uuid), public.disconnect_partner() to authenticated;
