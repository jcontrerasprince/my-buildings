------------------------------------------------------------
-- Table floors (enabling RLS and adding triggers for timestamps and user tracking)
------------------------------------------------------------
create table public.floors (
  id uuid not null default gen_random_uuid (),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  building_id uuid not null references public.buildings (id) on delete cascade,
  schedule_id uuid references public.schedules (id) on delete set null,
  name varchar not null,
  description text,
  floor_number integer not null,
  created_at timestamp with time zone null default now (),
  updated_at timestamp with time zone null default now (),
  created_by uuid references private.profiles (user_id) on delete set null,
  updated_by uuid references private.profiles (user_id) on delete set null,
  primary key (id)
);

alter table public.floors enable row level security;

create trigger trigger_timestamps_and_user_floors
before insert or update on public.floors
for each row
execute function handle_timestamps_and_user();

-- RLS Policies for floors table
------------------------------------------------------------
-- SELECT
------------------------------------------------------------

-- Policy: Select floors for tenant members
create policy "Select floors for tenant members"
on public.floors
for select
to authenticated
using (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Select floors for superadmins
create policy "Select floors for superadmins"
on public.floors
for select
to authenticated
using (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- INSERT
------------------------------------------------------------

-- Policy: Insert floors for tenant admins or owners
create policy "Insert floors for tenant admins or owners"
on public.floors
for insert
to authenticated
with check (
  tenant_id in (select public.user_tenant_ids())
  and (
    public.user_role_in_tenant(tenant_id) in ('admin','owner')
    or public.is_tenant_owner(tenant_id)
  )
);

-- Policy: Insert floors for superadmins
create policy "Insert floors for superadmins"
on public.floors
for insert
to authenticated
with check (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

-- Policy: Update floors for tenant admins or owners
create policy "Update floors for tenant admins or owners"
on public.floors
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

-- Policy: Update floors for superadmins
create policy "Update floors for superadmins"
on public.floors
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

-- Policy: Delete floors for tenant admins or owners
create policy "Delete floors for tenant admins or owners"
on public.floors
for delete
to authenticated
using (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Delete floors for superadmins
create policy "Delete floors for superadmins"
on public.floors
for delete
to authenticated
using (
  (select public.is_superadmin())
);