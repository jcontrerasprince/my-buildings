-- Custom access hook function to filter claims in the access token

create or replace function public.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
as $$
declare
  claims jsonb;
  tenants jsonb;
  is_superadmin boolean;
begin

  -- obtener si el usuario es superadmin
  select is_superadmin
  into is_superadmin
  from private.profiles
  where user_id = (event->>'user_id')::uuid;

  claims := event->'claims';

  -- obtener tenants del usuario
  select jsonb_agg(
    jsonb_build_object(
      'tenant_id', tenant_id,
      'role', role
    )
  )
  into tenants
  from public.tenants_users
  where user_id = (event->>'user_id')::uuid;

  -- asegurar que exista app_metadata
  if jsonb_typeof(claims->'app_metadata') is null then
    claims := jsonb_set(claims, '{app_metadata}', '{}');
  end if;

  -- insertar tenants en el JWT
  claims := jsonb_set(
    claims,
    '{app_metadata,tenants}',
    coalesce(tenants, '[]'::jsonb)
  );

  -- insertar is_superadmin en el JWT
  claims := jsonb_set(
    claims,
    '{app_metadata,is_superadmin}',
    to_jsonb(is_superadmin)
  );

  -- guardar claims de vuelta
  event := jsonb_set(event, '{claims}', claims);

  return event;
  end;
$$;

grant all on table private.profiles to supabase_auth_admin;

revoke all on table private.profiles from authenticated, anon, public;