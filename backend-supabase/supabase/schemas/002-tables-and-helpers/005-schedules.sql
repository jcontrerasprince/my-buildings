------------------------------------------------------------
-- Table schedules (enabling RLS and adding triggers for timestamps and user tracking)
------------------------------------------------------------
create table public.schedules (
  id uuid not null default gen_random_uuid (),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  name varchar not null,
  description text,
  start_time time not null,
  end_time time not null,
  timezone varchar null,
  days_of_week int[] not null,
  created_at timestamp with time zone null default now (),
  updated_at timestamp with time zone null default now (),
  created_by uuid references private.profiles (user_id) on delete set null,
  updated_by uuid references private.profiles (user_id) on delete set null,
  primary key (id),
  check (
    array_length(days_of_week,1) between 1 and 7
    and days_of_week <@ ARRAY[1,2,3,4,5,6,7]
  )
);

alter table public.schedules enable row level security;

create trigger trigger_timestamps_and_user_schedules
before insert or update on public.schedules
for each row
execute function handle_timestamps_and_user();


-- RLS Policies for schedules table
------------------------------------------------------------
-- SELECT
------------------------------------------------------------

-- Policy: Select schedules for tenant members
create policy "Select schedules for tenant members"
on public.schedules
for select
to authenticated
using (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Select schedules for superadmins
create policy "Select schedules for superadmins"
on public.schedules
for select
to authenticated
using (
  (select public.is_superadmin())
);

------------------------------------------------------------
-- INSERT
------------------------------------------------------------

-- Policy: Insert schedules for tenant admins or owners
create policy "Insert schedules for tenant admins or owners"
on public.schedules
for insert
to authenticated
with check (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Insert schedules for superadmins
create policy "Insert schedules for superadmins"
on public.schedules
for insert
to authenticated
with check (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

-- Policy: Update schedules for tenant admins or owners
create policy "Update schedules for tenant admins or owners"
on public.schedules
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

-- Policy: Update schedules for superadmins
create policy "Update schedules for superadmins"
on public.schedules
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

-- Policy: Delete schedules for tenant admins or owners
create policy "Delete schedules for tenant admins or owners"
on public.schedules
for delete
to authenticated
using (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Delete schedules for superadmins
create policy "Delete schedules for superadmins"
on public.schedules
for delete
to authenticated
using (
  (select public.is_superadmin())
);