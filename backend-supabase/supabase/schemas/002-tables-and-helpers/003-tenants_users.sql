create table public.tenants_users (
  id uuid not null default gen_random_uuid (),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  user_id uuid not null references private.profiles (user_id) on delete cascade,
  role varchar not null,
  created_at timestamp with time zone null default now (),
  updated_at timestamp with time zone null default now (),
  created_by uuid references private.profiles (user_id) on delete set null,
  updated_by uuid references private.profiles (user_id) on delete set null,
  primary key (id),
  unique (tenant_id, user_id)
);

alter table public.tenants_users enable row level security;

create trigger trigger_timestamps_and_user_tenants_users
before insert or update on public.tenants_users
for each row
execute function handle_timestamps_and_user();