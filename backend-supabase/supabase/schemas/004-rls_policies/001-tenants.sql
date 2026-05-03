-- Create RLS policy to select tenants
create policy "Select tenants for authenticated users or owners or superadmins"
on public.tenants for select
to authenticated
using (
  owner_id = (select auth.uid())
  or exists (
    select 1 from public.tenants_users tu
    where tu.tenant_id = tenants.id
      and tu.user_id = (select auth.uid())
  )
  or exists (
    select 1 from private.profiles p
    where p.user_id = (select auth.uid()) and p.is_superadmin = true
  )
);

-- Create RLS policy to insert tenants
create policy "Insert tenants for authenticated users"
on public.tenants for insert
to authenticated
with check (true);

-- Create RLS policy to update tenants
create policy "Update tenants for authenticated users"
on public.tenants for update
to authenticated
using (
  owner_id = (select auth.uid())
  OR exists (
    select 1 from public.tenants_users tu
    where tu.tenant_id = tenants.id
      and tu.user_id = (select auth.uid())
      and tu.role = 'admin'
  )
  OR exists (
    select 1 from private.profiles p
    where p.user_id = (select auth.uid()) and p.is_superadmin = true
  )
)
with check (true);

-- Create RLS policy to delete tenants
create policy "Delete tenants for authenticated users"
on public.tenants for delete
to authenticated
using (
  owner_id = (select auth.uid())
  OR exists (
    select 1 from private.profiles p
    where p.user_id = (select auth.uid()) and p.is_superadmin = true
  )
);