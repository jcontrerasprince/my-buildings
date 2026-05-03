-- This are rpc functions that will be used in policies to filter data based on the claims in the access token

-- This function returns the tenant ids that the user belongs to, based on the user id in the access token
create or replace function public.user_tenant_ids()
returns setof uuid
language sql
security definer
set search_path = public
as $$
  select tenant_id
  from public.tenants_users
  where user_id = (select auth.uid())
$$;

-- This function returns the role of the user in a specific tenant, based on the
-- user id in the access token and the tenant id passed as a parameter
create or replace function public.user_role_in_tenant(_tenant uuid)
returns text
language sql
security definer
set search_path = public
as $$
  select role
  from public.tenants_users
  where tenant_id = _tenant
  and user_id = (select auth.uid())
$$;

-- This function checks if the user is an owner of a specific tenant, based on the
-- user id in the access token and the tenant id passed as a parameter
create or replace function public.is_tenant_owner(_tenant uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.tenants
    where id = _tenant
    and owner_id = (select auth.uid())
  )
$$;

-- This function checks if the user is a superadmin, based on the user id in the access token
create or replace function public.is_superadmin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from private.profiles
    where user_id = (select auth.uid())
    and is_superadmin = true
  )
$$;