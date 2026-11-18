create function public.clean_style(p jsonb) returns jsonb
language sql immutable set search_path = '' as $$
  select jsonb_build_object(
    'background', case when p ->> 'background' in ('cream', 'white', 'pink', 'lavender', 'sky') then p ->> 'background' else 'cream' end,
    'pattern', case when p ->> 'pattern' in ('none', 'hearts', 'sparkles', 'dots') then p ->> 'pattern' else 'hearts' end,
    'spot', case when p ->> 'spot' in ('left', 'center', 'right') then p ->> 'spot' else 'center' end,
    'caption', left(trim(coalesce(p ->> 'caption', '')), 30)
  )
$$;

create function public.clean_avatar(p jsonb) returns jsonb
language sql immutable set search_path = '' as $$
  select coalesce(jsonb_object_agg(key, left(value #>> '{}', 24)), '{}')
  from jsonb_each(coalesce(p, '{}'))
  where key in ('color', 'presentation', 'hair', 'outfit', 'shirt', 'accessory') and jsonb_typeof(value) = 'string'
$$;

create function public.username_available(p_username text) returns boolean
language sql stable security definer set search_path = '' as $$
  select not exists (select 1 from public.profiles where username = lower(trim(p_username)))
$$;

create function public.create_profile(p_username text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  name text := lower(trim(p_username));
begin
  if me is null then raise exception 'not_signed_in'; end if;
  if name !~ '^[a-z0-9_.]{3,20}$' then raise exception 'invalid_username'; end if;
  if exists (select 1 from public.profiles where id = me) then raise exception 'profile_exists'; end if;
  begin
    insert into public.profiles (id, username) values (me, name);
  exception when unique_violation then
    raise exception 'username_taken';
  end;
  insert into public.avatars (user_id) values (me);
  insert into public.activities (user_id) values (me);
  insert into public.widget_configs (owner_id, style, own_style, updated_by)
    values (me, public.clean_style('{}'), public.clean_style('{}'), me);
end $$;

create function public.save_avatar(p_config jsonb) returns void
language plpgsql security definer set search_path = '' as $$
begin
  update public.avatars set config = public.clean_avatar(p_config), updated_at = now() where user_id = auth.uid();
  if not found then raise exception 'no_profile'; end if;
end $$;

create function public.set_notifications(p_requests boolean, p_widget boolean) returns void
language sql security definer set search_path = '' as $$
  update public.profiles set notify_requests = p_requests, notify_widget = p_widget where id = auth.uid()
$$;

create function public.delete_account() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'not_signed_in'; end if;
  delete from auth.users where id = auth.uid();
end $$;

revoke all on function public.clean_style(jsonb), public.clean_avatar(jsonb), public.username_available(text),
  public.create_profile(text), public.save_avatar(jsonb), public.set_notifications(boolean, boolean),
  public.delete_account() from public, anon, authenticated;

grant execute on function public.username_available(text) to anon, authenticated;
grant execute on function public.create_profile(text), public.save_avatar(jsonb),
  public.set_notifications(boolean, boolean), public.delete_account() to authenticated;
