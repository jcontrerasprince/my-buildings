-- RLS Policies for tenants_users table


------------------------------------------------------------
-- SELECT
------------------------------------------------------------

-- Policy: Select tenants_users for authenticated users or tenant members or owners
create policy "Select tenants_users for users or tenant members or owners"
on public.tenants_users
for select
to authenticated
using (
    user_id = (select auth.uid())

    or tenant_id in (select public.user_tenant_ids())

    or public.is_tenant_owner(tenant_id)
);

-- Policy: Select tenants_users for superadmins
create policy "Select tenants_users for superadmins"
on public.tenants_users
for select
to authenticated
using (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- INSERT
------------------------------------------------------------

-- Policy: Insert tenants_users for tenant admins or owners
create policy "Insert tenants_users for tenant admins or owners"
on public.tenants_users
for insert
to authenticated
with check (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Insert tenants_users for superadmins
create policy "Insert tenants_users for superadmins"
on public.tenants_users
for insert
to authenticated
with check (
  exists (
    select 1
    from private.profiles p
    where p.user_id = (select auth.uid())
    and p.is_superadmin = true
  )
);


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

-- Policy: Update tenants_users for tenant admins or owners
create policy "Update tenants_users for tenant admins or owners"
on public.tenants_users
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

-- Policy: Update tenants_users for superadmins
create policy "Update tenants_users for superadmins"
on public.tenants_users
for update
to authenticated
using (
  exists (
    select 1
    from private.profiles p
    where p.user_id = auth.uid()
    and p.is_superadmin = true
  )
)
with check (
  exists (
    select 1
    from private.profiles p
    where p.user_id = auth.uid()
    and p.is_superadmin = true
  )
);


------------------------------------------------------------
-- DELETE
------------------------------------------------------------

-- Policy: Delete tenants_users for tenant admins or owners
create policy "Delete tenants_users for tenant admins or owners"
on public.tenants_users
for delete
to authenticated
using (
  public.user_role_in_tenant(tenant_id) in ('admin','owner')
  or public.is_tenant_owner(tenant_id)
);

-- Policy: Delete tenants_users for superadmins
create policy "Delete tenants_users for superadmins"
on public.tenants_users
for delete
to authenticated
using (
  exists (
    select 1
    from private.profiles p
    where p.user_id = auth.uid()
    and p.is_superadmin = true
  )
);