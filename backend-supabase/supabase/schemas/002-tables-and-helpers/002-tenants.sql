-- Create tenants table

create table public.tenants (
  id uuid not null default gen_random_uuid(),
  name varchar not null,
  description text,
  owner_id uuid not null references private.profiles(user_id) on delete cascade,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  created_by uuid references private.profiles(user_id) on delete set null,
  updated_by uuid references private.profiles(user_id) on delete set null,
  primary key (id)
);

alter table public.tenants enable row level security;

create trigger trigger_timestamps_and_user_tenants
before insert or update on public.tenants
for each row
execute function handle_timestamps_and_user();

-- Policies for tenants are defined in 003-rls_policies/001-tenants.sql