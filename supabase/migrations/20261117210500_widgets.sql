create function public.style_my_widget(p_style jsonb) returns void
language plpgsql security definer set search_path = '' as $$
declare
  s jsonb := public.clean_style(p_style);
begin
  update public.widget_configs set style = s, own_style = s, updated_by = owner_id, updated_at = now()
    where owner_id = auth.uid();
  if not found then raise exception 'no_profile'; end if;
end $$;

create function public.style_partner_widget(p_style jsonb) returns void
language plpgsql security definer set search_path = '' as $$
declare
  them uuid := public.my_partner_id();
begin
  if them is null then raise exception 'no_partner'; end if;
  update public.widget_configs set style = public.clean_style(p_style), updated_by = auth.uid(), updated_at = now()
    where owner_id = them and allow_partner;
  if not found then raise exception 'partner_changes_off'; end if;
end $$;

create function public.restore_my_widget() returns void
language sql security definer set search_path = '' as $$
  update public.widget_configs set style = own_style, updated_by = owner_id, updated_at = now()
    where owner_id = auth.uid()
$$;

create function public.reset_my_widget() returns void
language sql security definer set search_path = '' as $$
  update public.widget_configs
    set style = public.clean_style('{}'), own_style = public.clean_style('{}'), updated_by = owner_id, updated_at = now()
    where owner_id = auth.uid()
$$;

create function public.allow_partner_changes(p_allowed boolean) returns void
language sql security definer set search_path = '' as $$
  update public.widget_configs set allow_partner = p_allowed where owner_id = auth.uid()
$$;

create function public.issue_widget_token() returns text
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  token text := encode(extensions.gen_random_bytes(24), 'hex');
begin
  if not exists (select 1 from public.profiles where id = me) then raise exception 'no_profile'; end if;
  insert into public.widget_tokens (token_hash, user_id) values (encode(extensions.digest(token, 'sha256'), 'hex'), me);
  delete from public.widget_tokens where user_id = me and token_hash not in (
    select token_hash from public.widget_tokens where user_id = me order by created_at desc limit 5);
  return token;
end $$;

create function public.revoke_widget_token(p_token text) returns void
language sql security definer set search_path = '' as $$
  delete from public.widget_tokens
    where token_hash = encode(extensions.digest(p_token, 'sha256'), 'hex') and user_id = auth.uid()
$$;

create function public.widget_snapshot(p_token text) returns jsonb
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
    'style', (select w.style from public.widget_configs w where w.owner_id = me.id),
    'by_partner', (select w.updated_by is not null and w.updated_by <> w.owner_id
                   from public.widget_configs w where w.owner_id = me.id)
  );
end $$;

revoke all on function public.style_my_widget(jsonb), public.style_partner_widget(jsonb), public.restore_my_widget(),
  public.reset_my_widget(), public.allow_partner_changes(boolean), public.issue_widget_token(),
  public.revoke_widget_token(text), public.widget_snapshot(text) from public, anon, authenticated;

grant execute on function public.style_my_widget(jsonb), public.style_partner_widget(jsonb), public.restore_my_widget(),
  public.reset_my_widget(), public.allow_partner_changes(boolean), public.issue_widget_token(),
  public.revoke_widget_token(text) to authenticated;
grant execute on function public.widget_snapshot(text) to anon, authenticated;
