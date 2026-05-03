------------------------------------------------------------
-- Enum floor_type_enum
------------------------------------------------------------
create type public.floor_type_enum as enum ('wood', 'carpet', 'tile', 'laminate', 'vinyl', 'concrete', 'other');

------------------------------------------------------------
-- Table rooms (enabling RLS and adding triggers for timestamps and user tracking)
------------------------------------------------------------
create table public.rooms (
  id uuid not null default gen_random_uuid (),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  floor_id uuid not null references public.floors (id) on delete cascade,
  schedule_id uuid references public.schedules (id) on delete set null,
  name varchar not null,
  description text,
  floor_type public.floor_type_enum,
  area_sq_meters integer,
  tables integer,
  windows integer,
  chairs integer,
  boards integer,
  screens integer,
  projectors integer,
  outlets integer,
  lights integer,
  background_color varchar,
  backyards integer,
  balconies integer,
  autoacept_requests boolean default false,
  created_at timestamp with time zone null default now (),
  updated_at timestamp with time zone null default now (),
  created_by uuid references private.profiles (user_id) on delete set null,
  updated_by uuid references private.profiles (user_id) on delete set null,
  primary key (id)
);

alter table public.rooms enable row level security;

create trigger trigger_timestamps_and_user_rooms
before insert or update on public.rooms
for each row
execute function handle_timestamps_and_user();

-- RLS Policies for rooms table
------------------------------------------------------------
-- SELECT
------------------------------------------------------------

-- Policy: Select rooms for tenant members
create policy "Select rooms for tenant members"
on public.rooms
for select
to authenticated
using (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Select rooms for superadmins
create policy "Select rooms for superadmins"
on public.rooms
for select
to authenticated
using (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- INSERT
------------------------------------------------------------

-- Policy: Insert rooms for tenant admins or owners
create policy "Insert rooms for tenant admins or owners"
on public.rooms
for insert
to authenticated
with check (
  tenant_id in (select public.user_tenant_ids())
  and (
    public.user_role_in_tenant(tenant_id) in ('admin','owner')
    or public.is_tenant_owner(tenant_id)
  )
);

-- Policy: Insert rooms for superadmins
create policy "Insert rooms for superadmins"
on public.rooms
for insert
to authenticated
with check (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

-- Policy: Update rooms for tenant admins or owners
create policy "Update rooms for tenant admins or owners"
on public.rooms
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

-- Policy: Update rooms for superadmins
create policy "Update rooms for superadmins"
on public.rooms
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

-- Policy: Delete rooms for tenant admins or owners
create policy "Delete rooms for tenant admins or owners"
on public.rooms
for delete
to authenticated
using (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Delete rooms for superadmins
create policy "Delete rooms for superadmins"
on public.rooms
for delete
to authenticated
using (
  (select public.is_superadmin())
);