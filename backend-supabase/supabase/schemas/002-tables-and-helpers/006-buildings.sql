------------------------------------------------------------
-- Table buildings (enabling RLS and adding triggers for timestamps and user tracking)
------------------------------------------------------------
create table public.buildings (
  id uuid not null default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  schedule_id uuid references public.schedules(id) on delete set null,
  name varchar not null,
  description text,
  address text,
  timezone varchar not null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  created_by uuid references private.profiles(user_id) on delete set null,
  updated_by uuid references private.profiles(user_id) on delete set null,
  primary key (id)
);

alter table public.buildings enable row level security;

create trigger trigger_timestamps_and_user_buildings
before insert or update on public.buildings
for each row
execute function handle_timestamps_and_user();

-- RLS Policies for buildings table
------------------------------------------------------------
-- SELECT
------------------------------------------------------------

-- Policy: Select buildings for tenant members
create policy "Select buildings for tenant members"
on public.buildings
for select
to authenticated
using (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Select buildings for superadmins
create policy "Select buildings for superadmins"
on public.buildings
for select
to authenticated
using (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- INSERT
------------------------------------------------------------

-- Policy: Insert buildings for tenant admins or owners
create policy "Insert buildings for tenant admins or owners"
on public.buildings
for insert
to authenticated
with check (
  tenant_id in (select public.user_tenant_ids())
  and (
    public.user_role_in_tenant(tenant_id) in ('admin','owner')
    or public.is_tenant_owner(tenant_id)
  )
);

-- Policy: Insert buildings for superadmins
create policy "Insert buildings for superadmins"
on public.buildings
for insert
to authenticated
with check (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

-- Policy: Update buildings for tenant admins or owners
create policy "Update buildings for tenant admins or owners"
on public.buildings
for update
to authenticated
using (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
)
with check (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Update buildings for superadmins
create policy "Update buildings for superadmins"
on public.buildings
for update
to authenticated
using (
  (select public.is_superadmin())
)
with check (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- DELETE
------------------------------------------------------------

-- Policy: Delete buildings for tenant admins or owners
create policy "Delete buildings for tenant admins or owners"
on public.buildings
for delete
to authenticated
using (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Delete buildings for superadmins
create policy "Delete buildings for superadmins"
on public.buildings
for delete
to authenticated
using (
  (select public.is_superadmin())
);