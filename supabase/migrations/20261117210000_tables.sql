create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9_.]{3,20}$'),
  partner_id uuid unique references public.profiles on delete set null check (partner_id <> id),
  partner_since timestamptz,
  notify_requests boolean not null default true,
  notify_widget boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.avatars (
  user_id uuid primary key references public.profiles on delete cascade,
  config jsonb not null default '{}',
  updated_at timestamptz not null default now()
);

create table public.activities (
  user_id uuid primary key references public.profiles on delete cascade,
  kind text,
  source text not null default 'manual' check (source in ('manual', 'headphones')),
  started_at timestamptz,
  expires_at timestamptz,
  previous_kind text,
  previous_expires_at timestamptz,
  updated_at timestamptz not null default now()
);

create table public.widget_configs (
  owner_id uuid primary key references public.profiles on delete cascade,
  style jsonb not null default '{}',
  own_style jsonb not null default '{}',
  allow_partner boolean not null default true,
  updated_by uuid references public.profiles on delete set null,
  updated_at timestamptz not null default now()
);

create table public.connection_requests (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles on delete cascade,
  receiver_id uuid not null references public.profiles on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'declined', 'canceled')),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  check (sender_id <> receiver_id)
);

create unique index one_outgoing_request on public.connection_requests (sender_id) where status = 'pending';
create unique index one_request_per_pair on public.connection_requests (least(sender_id, receiver_id), greatest(sender_id, receiver_id)) where status = 'pending';
create index requests_by_receiver on public.connection_requests (receiver_id) where status = 'pending';

create table public.widget_tokens (
  token_hash text primary key,
  user_id uuid not null references public.profiles on delete cascade,
  created_at timestamptz not null default now()
);

create index widget_tokens_by_user on public.widget_tokens (user_id);

create function public.my_partner_id() returns uuid
language sql stable security definer set search_path = '' as $$
  select partner_id from public.profiles where id = auth.uid()
$$;

alter table public.profiles enable row level security;
alter table public.avatars enable row level security;
alter table public.activities enable row level security;
alter table public.widget_configs enable row level security;
alter table public.connection_requests enable row level security;
alter table public.widget_tokens enable row level security;

create policy "Me and my partner" on public.profiles for select to authenticated
  using (id = (select auth.uid()) or id = (select public.my_partner_id()));
create policy "Me and my partner" on public.avatars for select to authenticated
  using (user_id = (select auth.uid()) or user_id = (select public.my_partner_id()));
create policy "Me and my partner" on public.activities for select to authenticated
  using (user_id = (select auth.uid()) or user_id = (select public.my_partner_id()));
create policy "Me and my partner" on public.widget_configs for select to authenticated
  using (owner_id = (select auth.uid()) or owner_id = (select public.my_partner_id()));
create policy "Requests I sent or got" on public.connection_requests for select to authenticated
  using (sender_id = (select auth.uid()) or receiver_id = (select auth.uid()));

revoke all on public.profiles, public.avatars, public.activities, public.widget_configs, public.connection_requests, public.widget_tokens from anon, authenticated;
grant select on public.profiles, public.avatars, public.activities, public.widget_configs, public.connection_requests to authenticated;

revoke all on function public.my_partner_id() from public, anon;
grant execute on function public.my_partner_id() to authenticated;

alter publication supabase_realtime add table public.profiles, public.avatars, public.activities, public.widget_configs, public.connection_requests;
