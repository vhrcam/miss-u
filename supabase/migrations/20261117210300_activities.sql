create function public.activity_duration(p_kind text) returns interval
language sql immutable set search_path = '' as $$
  select case p_kind
    when 'sleeping' then interval '10 hours'
    when 'music' then interval '3 hours'
    when 'shopping' then interval '2 hours'
    when 'gaming' then interval '3 hours'
    when 'studying' then interval '3 hours'
    when 'working' then interval '8 hours'
    when 'coffee' then interval '1 hour'
    when 'tv' then interval '3 hours'
    when 'exercising' then interval '2 hours'
    when 'missing_you' then interval '1 hour'
  end
$$;

create function public.set_activity(p_kind text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  length interval := public.activity_duration(p_kind);
begin
  if p_kind is not null and length is null then raise exception 'unknown_activity'; end if;
  update public.activities set
    kind = p_kind,
    source = 'manual',
    started_at = case when p_kind is null then null else now() end,
    expires_at = now() + length,
    previous_kind = null,
    previous_expires_at = null,
    updated_at = now()
  where user_id = auth.uid();
  if not found then raise exception 'no_profile'; end if;
end $$;

create function public.headphones_changed(p_connected boolean) returns void
language plpgsql security definer set search_path = '' as $$
declare
  a public.activities;
  keep boolean;
begin
  select * into a from public.activities where user_id = auth.uid() for update;
  if not found then raise exception 'no_profile'; end if;

  if p_connected and a.source = 'headphones' then
    update public.activities set expires_at = now() + public.activity_duration('music'), updated_at = now()
      where user_id = a.user_id;
  elsif p_connected then
    keep := a.kind is not null and a.expires_at > now();
    update public.activities set
      previous_kind = case when keep then a.kind end,
      previous_expires_at = case when keep then a.expires_at end,
      kind = 'music',
      source = 'headphones',
      started_at = now(),
      expires_at = now() + public.activity_duration('music'),
      updated_at = now()
    where user_id = a.user_id;
  elsif a.source = 'headphones' then
    keep := a.previous_expires_at > now();
    update public.activities set
      kind = case when keep then a.previous_kind end,
      source = 'manual',
      started_at = case when keep then now() end,
      expires_at = case when keep then a.previous_expires_at end,
      previous_kind = null,
      previous_expires_at = null,
      updated_at = now()
    where user_id = a.user_id;
  end if;
end $$;

revoke all on function public.activity_duration(text), public.set_activity(text), public.headphones_changed(boolean)
  from public, anon, authenticated;
grant execute on function public.set_activity(text), public.headphones_changed(boolean) to authenticated;
