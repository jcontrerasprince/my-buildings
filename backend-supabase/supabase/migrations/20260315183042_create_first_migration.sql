create schema if not exists "private";


  create table "private"."profiles" (
    "user_id" uuid not null,
    "first_name" character varying,
    "last_name" character varying,
    "email" character varying,
    "avatar_url" text,
    "is_superadmin" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "private"."profiles" enable row level security;

CREATE UNIQUE INDEX profiles_pkey ON private.profiles USING btree (user_id);

alter table "private"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "private"."profiles" add constraint "profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "private"."profiles" validate constraint "profiles_user_id_fkey";

CREATE OR REPLACE FUNCTION private.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into private.profiles (user_id, first_name, last_name, email, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'first_name',
    new.raw_user_meta_data ->> 'last_name',
    new.email,
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$function$
;

grant delete on table "private"."profiles" to "supabase_auth_admin";

grant insert on table "private"."profiles" to "supabase_auth_admin";

grant references on table "private"."profiles" to "supabase_auth_admin";

grant select on table "private"."profiles" to "supabase_auth_admin";

grant trigger on table "private"."profiles" to "supabase_auth_admin";

grant truncate on table "private"."profiles" to "supabase_auth_admin";

grant update on table "private"."profiles" to "supabase_auth_admin";


  create policy "Delete profiles for authenticated users"
  on "private"."profiles"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "Insert profiles for authenticated users"
  on "private"."profiles"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Select profiles for authenticated users"
  on "private"."profiles"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Update profiles for authenticated users"
  on "private"."profiles"
  as permissive
  for update
  to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));

-- trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure private.handle_new_user();

create type "public"."floor_type_enum" as enum ('wood', 'carpet', 'tile', 'laminate', 'vinyl', 'concrete', 'other');


  create table "public"."bookings" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "room_id" uuid not null,
    "responsible_id" uuid not null,
    "start_date" date not null,
    "end_date" date not null,
    "start_time" time without time zone,
    "end_time" time without time zone,
    "status" character varying not null,
    "days_of_week" integer[] not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."bookings" enable row level security;


  create table "public"."buildings" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "schedule_id" uuid,
    "name" character varying not null,
    "description" text,
    "address" text,
    "timezone" character varying not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."buildings" enable row level security;


  create table "public"."floors" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "building_id" uuid not null,
    "schedule_id" uuid,
    "name" character varying not null,
    "description" text,
    "floor_number" integer not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."floors" enable row level security;


  create table "public"."rooms" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "floor_id" uuid not null,
    "schedule_id" uuid,
    "name" character varying not null,
    "description" text,
    "floor_type" public.floor_type_enum,
    "area_sq_meters" integer,
    "tables" integer,
    "windows" integer,
    "chairs" integer,
    "boards" integer,
    "screens" integer,
    "projectors" integer,
    "outlets" integer,
    "lights" integer,
    "background_color" character varying,
    "backyards" integer,
    "balconies" integer,
    "autoacept_requests" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."rooms" enable row level security;


  create table "public"."schedules" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "name" character varying not null,
    "description" text,
    "start_time" time without time zone not null,
    "end_time" time without time zone not null,
    "timezone" character varying,
    "days_of_week" integer[] not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."schedules" enable row level security;


  create table "public"."sessions" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "booking_id" uuid,
    "responsible_id" uuid not null,
    "room_id" uuid,
    "date" date not null,
    "status" character varying not null,
    "start_time" time without time zone,
    "end_time" time without time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."sessions" enable row level security;


  create table "public"."tenants" (
    "id" uuid not null default gen_random_uuid(),
    "name" character varying not null,
    "description" text,
    "owner_id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."tenants" enable row level security;


  create table "public"."tenants_users" (
    "id" uuid not null default gen_random_uuid(),
    "tenant_id" uuid not null,
    "user_id" uuid not null,
    "role" character varying not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "public"."tenants_users" enable row level security;

CREATE UNIQUE INDEX bookings_pkey ON public.bookings USING btree (id);

CREATE UNIQUE INDEX buildings_pkey ON public.buildings USING btree (id);

CREATE UNIQUE INDEX floors_pkey ON public.floors USING btree (id);

CREATE UNIQUE INDEX rooms_pkey ON public.rooms USING btree (id);

CREATE UNIQUE INDEX schedules_pkey ON public.schedules USING btree (id);

CREATE UNIQUE INDEX sessions_pkey ON public.sessions USING btree (id);

CREATE UNIQUE INDEX tenants_pkey ON public.tenants USING btree (id);

CREATE UNIQUE INDEX tenants_users_pkey ON public.tenants_users USING btree (id);

CREATE UNIQUE INDEX tenants_users_tenant_id_user_id_key ON public.tenants_users USING btree (tenant_id, user_id);

alter table "public"."bookings" add constraint "bookings_pkey" PRIMARY KEY using index "bookings_pkey";

alter table "public"."buildings" add constraint "buildings_pkey" PRIMARY KEY using index "buildings_pkey";

alter table "public"."floors" add constraint "floors_pkey" PRIMARY KEY using index "floors_pkey";

alter table "public"."rooms" add constraint "rooms_pkey" PRIMARY KEY using index "rooms_pkey";

alter table "public"."schedules" add constraint "schedules_pkey" PRIMARY KEY using index "schedules_pkey";

alter table "public"."sessions" add constraint "sessions_pkey" PRIMARY KEY using index "sessions_pkey";

alter table "public"."tenants" add constraint "tenants_pkey" PRIMARY KEY using index "tenants_pkey";

alter table "public"."tenants_users" add constraint "tenants_users_pkey" PRIMARY KEY using index "tenants_users_pkey";

alter table "public"."bookings" add constraint "bookings_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_created_by_fkey";

alter table "public"."bookings" add constraint "bookings_days_of_week_check" CHECK ((((array_length(days_of_week, 1) >= 1) AND (array_length(days_of_week, 1) <= 7)) AND (days_of_week <@ ARRAY[1, 2, 3, 4, 5, 6, 7]))) not valid;

alter table "public"."bookings" validate constraint "bookings_days_of_week_check";

alter table "public"."bookings" add constraint "bookings_responsible_id_fkey" FOREIGN KEY (responsible_id) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_responsible_id_fkey";

alter table "public"."bookings" add constraint "bookings_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_room_id_fkey";

alter table "public"."bookings" add constraint "bookings_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."bookings" validate constraint "bookings_tenant_id_fkey";

alter table "public"."bookings" add constraint "bookings_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."bookings" validate constraint "bookings_updated_by_fkey";

alter table "public"."buildings" add constraint "buildings_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."buildings" validate constraint "buildings_created_by_fkey";

alter table "public"."buildings" add constraint "buildings_schedule_id_fkey" FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON DELETE SET NULL not valid;

alter table "public"."buildings" validate constraint "buildings_schedule_id_fkey";

alter table "public"."buildings" add constraint "buildings_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."buildings" validate constraint "buildings_tenant_id_fkey";

alter table "public"."buildings" add constraint "buildings_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."buildings" validate constraint "buildings_updated_by_fkey";

alter table "public"."floors" add constraint "floors_building_id_fkey" FOREIGN KEY (building_id) REFERENCES public.buildings(id) ON DELETE CASCADE not valid;

alter table "public"."floors" validate constraint "floors_building_id_fkey";

alter table "public"."floors" add constraint "floors_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."floors" validate constraint "floors_created_by_fkey";

alter table "public"."floors" add constraint "floors_schedule_id_fkey" FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON DELETE SET NULL not valid;

alter table "public"."floors" validate constraint "floors_schedule_id_fkey";

alter table "public"."floors" add constraint "floors_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."floors" validate constraint "floors_tenant_id_fkey";

alter table "public"."floors" add constraint "floors_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."floors" validate constraint "floors_updated_by_fkey";

alter table "public"."rooms" add constraint "rooms_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."rooms" validate constraint "rooms_created_by_fkey";

alter table "public"."rooms" add constraint "rooms_floor_id_fkey" FOREIGN KEY (floor_id) REFERENCES public.floors(id) ON DELETE CASCADE not valid;

alter table "public"."rooms" validate constraint "rooms_floor_id_fkey";

alter table "public"."rooms" add constraint "rooms_schedule_id_fkey" FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON DELETE SET NULL not valid;

alter table "public"."rooms" validate constraint "rooms_schedule_id_fkey";

alter table "public"."rooms" add constraint "rooms_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."rooms" validate constraint "rooms_tenant_id_fkey";

alter table "public"."rooms" add constraint "rooms_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."rooms" validate constraint "rooms_updated_by_fkey";

alter table "public"."schedules" add constraint "schedules_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."schedules" validate constraint "schedules_created_by_fkey";

alter table "public"."schedules" add constraint "schedules_days_of_week_check" CHECK ((((array_length(days_of_week, 1) >= 1) AND (array_length(days_of_week, 1) <= 7)) AND (days_of_week <@ ARRAY[1, 2, 3, 4, 5, 6, 7]))) not valid;

alter table "public"."schedules" validate constraint "schedules_days_of_week_check";

alter table "public"."schedules" add constraint "schedules_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."schedules" validate constraint "schedules_tenant_id_fkey";

alter table "public"."schedules" add constraint "schedules_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."schedules" validate constraint "schedules_updated_by_fkey";

alter table "public"."sessions" add constraint "sessions_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL not valid;

alter table "public"."sessions" validate constraint "sessions_booking_id_fkey";

alter table "public"."sessions" add constraint "sessions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."sessions" validate constraint "sessions_created_by_fkey";

alter table "public"."sessions" add constraint "sessions_responsible_id_fkey" FOREIGN KEY (responsible_id) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."sessions" validate constraint "sessions_responsible_id_fkey";

alter table "public"."sessions" add constraint "sessions_room_id_fkey" FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE SET NULL not valid;

alter table "public"."sessions" validate constraint "sessions_room_id_fkey";

alter table "public"."sessions" add constraint "sessions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."sessions" validate constraint "sessions_tenant_id_fkey";

alter table "public"."sessions" add constraint "sessions_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."sessions" validate constraint "sessions_updated_by_fkey";

alter table "public"."tenants" add constraint "tenants_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."tenants" validate constraint "tenants_created_by_fkey";

alter table "public"."tenants" add constraint "tenants_owner_id_fkey" FOREIGN KEY (owner_id) REFERENCES private.profiles(user_id) ON DELETE CASCADE not valid;

alter table "public"."tenants" validate constraint "tenants_owner_id_fkey";

alter table "public"."tenants" add constraint "tenants_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."tenants" validate constraint "tenants_updated_by_fkey";

alter table "public"."tenants_users" add constraint "tenants_users_created_by_fkey" FOREIGN KEY (created_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."tenants_users" validate constraint "tenants_users_created_by_fkey";

alter table "public"."tenants_users" add constraint "tenants_users_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE not valid;

alter table "public"."tenants_users" validate constraint "tenants_users_tenant_id_fkey";

alter table "public"."tenants_users" add constraint "tenants_users_tenant_id_user_id_key" UNIQUE using index "tenants_users_tenant_id_user_id_key";

alter table "public"."tenants_users" add constraint "tenants_users_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES private.profiles(user_id) ON DELETE SET NULL not valid;

alter table "public"."tenants_users" validate constraint "tenants_users_updated_by_fkey";

alter table "public"."tenants_users" add constraint "tenants_users_user_id_fkey" FOREIGN KEY (user_id) REFERENCES private.profiles(user_id) ON DELETE CASCADE not valid;

alter table "public"."tenants_users" validate constraint "tenants_users_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.custom_access_token_hook(event jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.handle_timestamps_and_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    -- Set updated_at on both INSERT and UPDATE
    NEW.updated_at = now();
    NEW.updated_by = auth.uid();
    
    -- Set created_by only on INSERT
    if TG_OP = 'INSERT' then
        NEW.created_by = auth.uid();
    end if;
    
    return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    -- Set updated_at on both INSERT and UPDATE
    NEW.updated_at = now();
    return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.is_superadmin()
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from private.profiles
    where user_id = (select auth.uid())
    and is_superadmin = true
  )
$function$
;

CREATE OR REPLACE FUNCTION public.is_tenant_owner(_tenant uuid)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.tenants
    where id = _tenant
    and owner_id = (select auth.uid())
  )
$function$
;

CREATE OR REPLACE FUNCTION public.user_role_in_tenant(_tenant uuid)
 RETURNS text
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select role
  from public.tenants_users
  where tenant_id = _tenant
  and user_id = (select auth.uid())
$function$
;

CREATE OR REPLACE FUNCTION public.user_tenant_ids()
 RETURNS SETOF uuid
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select tenant_id
  from public.tenants_users
  where user_id = (select auth.uid())
$function$
;

grant delete on table "public"."bookings" to "anon";

grant insert on table "public"."bookings" to "anon";

grant references on table "public"."bookings" to "anon";

grant select on table "public"."bookings" to "anon";

grant trigger on table "public"."bookings" to "anon";

grant truncate on table "public"."bookings" to "anon";

grant update on table "public"."bookings" to "anon";

grant delete on table "public"."bookings" to "authenticated";

grant insert on table "public"."bookings" to "authenticated";

grant references on table "public"."bookings" to "authenticated";

grant select on table "public"."bookings" to "authenticated";

grant trigger on table "public"."bookings" to "authenticated";

grant truncate on table "public"."bookings" to "authenticated";

grant update on table "public"."bookings" to "authenticated";

grant delete on table "public"."bookings" to "service_role";

grant insert on table "public"."bookings" to "service_role";

grant references on table "public"."bookings" to "service_role";

grant select on table "public"."bookings" to "service_role";

grant trigger on table "public"."bookings" to "service_role";

grant truncate on table "public"."bookings" to "service_role";

grant update on table "public"."bookings" to "service_role";

grant delete on table "public"."buildings" to "anon";

grant insert on table "public"."buildings" to "anon";

grant references on table "public"."buildings" to "anon";

grant select on table "public"."buildings" to "anon";

grant trigger on table "public"."buildings" to "anon";

grant truncate on table "public"."buildings" to "anon";

grant update on table "public"."buildings" to "anon";

grant delete on table "public"."buildings" to "authenticated";

grant insert on table "public"."buildings" to "authenticated";

grant references on table "public"."buildings" to "authenticated";

grant select on table "public"."buildings" to "authenticated";

grant trigger on table "public"."buildings" to "authenticated";

grant truncate on table "public"."buildings" to "authenticated";

grant update on table "public"."buildings" to "authenticated";

grant delete on table "public"."buildings" to "service_role";

grant insert on table "public"."buildings" to "service_role";

grant references on table "public"."buildings" to "service_role";

grant select on table "public"."buildings" to "service_role";

grant trigger on table "public"."buildings" to "service_role";

grant truncate on table "public"."buildings" to "service_role";

grant update on table "public"."buildings" to "service_role";

grant delete on table "public"."floors" to "anon";

grant insert on table "public"."floors" to "anon";

grant references on table "public"."floors" to "anon";

grant select on table "public"."floors" to "anon";

grant trigger on table "public"."floors" to "anon";

grant truncate on table "public"."floors" to "anon";

grant update on table "public"."floors" to "anon";

grant delete on table "public"."floors" to "authenticated";

grant insert on table "public"."floors" to "authenticated";

grant references on table "public"."floors" to "authenticated";

grant select on table "public"."floors" to "authenticated";

grant trigger on table "public"."floors" to "authenticated";

grant truncate on table "public"."floors" to "authenticated";

grant update on table "public"."floors" to "authenticated";

grant delete on table "public"."floors" to "service_role";

grant insert on table "public"."floors" to "service_role";

grant references on table "public"."floors" to "service_role";

grant select on table "public"."floors" to "service_role";

grant trigger on table "public"."floors" to "service_role";

grant truncate on table "public"."floors" to "service_role";

grant update on table "public"."floors" to "service_role";

grant delete on table "public"."rooms" to "anon";

grant insert on table "public"."rooms" to "anon";

grant references on table "public"."rooms" to "anon";

grant select on table "public"."rooms" to "anon";

grant trigger on table "public"."rooms" to "anon";

grant truncate on table "public"."rooms" to "anon";

grant update on table "public"."rooms" to "anon";

grant delete on table "public"."rooms" to "authenticated";

grant insert on table "public"."rooms" to "authenticated";

grant references on table "public"."rooms" to "authenticated";

grant select on table "public"."rooms" to "authenticated";

grant trigger on table "public"."rooms" to "authenticated";

grant truncate on table "public"."rooms" to "authenticated";

grant update on table "public"."rooms" to "authenticated";

grant delete on table "public"."rooms" to "service_role";

grant insert on table "public"."rooms" to "service_role";

grant references on table "public"."rooms" to "service_role";

grant select on table "public"."rooms" to "service_role";

grant trigger on table "public"."rooms" to "service_role";

grant truncate on table "public"."rooms" to "service_role";

grant update on table "public"."rooms" to "service_role";

grant delete on table "public"."schedules" to "anon";

grant insert on table "public"."schedules" to "anon";

grant references on table "public"."schedules" to "anon";

grant select on table "public"."schedules" to "anon";

grant trigger on table "public"."schedules" to "anon";

grant truncate on table "public"."schedules" to "anon";

grant update on table "public"."schedules" to "anon";

grant delete on table "public"."schedules" to "authenticated";

grant insert on table "public"."schedules" to "authenticated";

grant references on table "public"."schedules" to "authenticated";

grant select on table "public"."schedules" to "authenticated";

grant trigger on table "public"."schedules" to "authenticated";

grant truncate on table "public"."schedules" to "authenticated";

grant update on table "public"."schedules" to "authenticated";

grant delete on table "public"."schedules" to "service_role";

grant insert on table "public"."schedules" to "service_role";

grant references on table "public"."schedules" to "service_role";

grant select on table "public"."schedules" to "service_role";

grant trigger on table "public"."schedules" to "service_role";

grant truncate on table "public"."schedules" to "service_role";

grant update on table "public"."schedules" to "service_role";

grant delete on table "public"."sessions" to "anon";

grant insert on table "public"."sessions" to "anon";

grant references on table "public"."sessions" to "anon";

grant select on table "public"."sessions" to "anon";

grant trigger on table "public"."sessions" to "anon";

grant truncate on table "public"."sessions" to "anon";

grant update on table "public"."sessions" to "anon";

grant delete on table "public"."sessions" to "authenticated";

grant insert on table "public"."sessions" to "authenticated";

grant references on table "public"."sessions" to "authenticated";

grant select on table "public"."sessions" to "authenticated";

grant trigger on table "public"."sessions" to "authenticated";

grant truncate on table "public"."sessions" to "authenticated";

grant update on table "public"."sessions" to "authenticated";

grant delete on table "public"."sessions" to "service_role";

grant insert on table "public"."sessions" to "service_role";

grant references on table "public"."sessions" to "service_role";

grant select on table "public"."sessions" to "service_role";

grant trigger on table "public"."sessions" to "service_role";

grant truncate on table "public"."sessions" to "service_role";

grant update on table "public"."sessions" to "service_role";

grant delete on table "public"."tenants" to "anon";

grant insert on table "public"."tenants" to "anon";

grant references on table "public"."tenants" to "anon";

grant select on table "public"."tenants" to "anon";

grant trigger on table "public"."tenants" to "anon";

grant truncate on table "public"."tenants" to "anon";

grant update on table "public"."tenants" to "anon";

grant delete on table "public"."tenants" to "authenticated";

grant insert on table "public"."tenants" to "authenticated";

grant references on table "public"."tenants" to "authenticated";

grant select on table "public"."tenants" to "authenticated";

grant trigger on table "public"."tenants" to "authenticated";

grant truncate on table "public"."tenants" to "authenticated";

grant update on table "public"."tenants" to "authenticated";

grant delete on table "public"."tenants" to "service_role";

grant insert on table "public"."tenants" to "service_role";

grant references on table "public"."tenants" to "service_role";

grant select on table "public"."tenants" to "service_role";

grant trigger on table "public"."tenants" to "service_role";

grant truncate on table "public"."tenants" to "service_role";

grant update on table "public"."tenants" to "service_role";

grant delete on table "public"."tenants_users" to "anon";

grant insert on table "public"."tenants_users" to "anon";

grant references on table "public"."tenants_users" to "anon";

grant select on table "public"."tenants_users" to "anon";

grant trigger on table "public"."tenants_users" to "anon";

grant truncate on table "public"."tenants_users" to "anon";

grant update on table "public"."tenants_users" to "anon";

grant delete on table "public"."tenants_users" to "authenticated";

grant insert on table "public"."tenants_users" to "authenticated";

grant references on table "public"."tenants_users" to "authenticated";

grant select on table "public"."tenants_users" to "authenticated";

grant trigger on table "public"."tenants_users" to "authenticated";

grant truncate on table "public"."tenants_users" to "authenticated";

grant update on table "public"."tenants_users" to "authenticated";

grant delete on table "public"."tenants_users" to "service_role";

grant insert on table "public"."tenants_users" to "service_role";

grant references on table "public"."tenants_users" to "service_role";

grant select on table "public"."tenants_users" to "service_role";

grant trigger on table "public"."tenants_users" to "service_role";

grant truncate on table "public"."tenants_users" to "service_role";

grant update on table "public"."tenants_users" to "service_role";


  create policy "Delete bookings for admins owners or creator"
  on "public"."bookings"
  as permissive
  for delete
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id) OR (created_by = ( SELECT auth.uid() AS uid))));



  create policy "Delete bookings for superadmins"
  on "public"."bookings"
  as permissive
  for delete
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert bookings for superadmins"
  on "public"."bookings"
  as permissive
  for insert
  to authenticated
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert bookings for tenant members"
  on "public"."bookings"
  as permissive
  for insert
  to authenticated
with check ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Select bookings for superadmins"
  on "public"."bookings"
  as permissive
  for select
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Select bookings for tenant members"
  on "public"."bookings"
  as permissive
  for select
  to authenticated
using ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Update bookings for admins owners or creator"
  on "public"."bookings"
  as permissive
  for update
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id) OR (created_by = ( SELECT auth.uid() AS uid))))
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id) OR (created_by = ( SELECT auth.uid() AS uid))));



  create policy "Update bookings for superadmins"
  on "public"."bookings"
  as permissive
  for update
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin))
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Delete buildings for superadmins"
  on "public"."buildings"
  as permissive
  for delete
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Delete buildings for tenant admins or owners"
  on "public"."buildings"
  as permissive
  for delete
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Insert buildings for superadmins"
  on "public"."buildings"
  as permissive
  for insert
  to authenticated
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert buildings for tenant admins or owners"
  on "public"."buildings"
  as permissive
  for insert
  to authenticated
with check (((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)) AND ((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id))));



  create policy "Select buildings for superadmins"
  on "public"."buildings"
  as permissive
  for select
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Select buildings for tenant members"
  on "public"."buildings"
  as permissive
  for select
  to authenticated
using ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Update buildings for superadmins"
  on "public"."buildings"
  as permissive
  for update
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin))
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Update buildings for tenant admins or owners"
  on "public"."buildings"
  as permissive
  for update
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)))
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Delete floors for superadmins"
  on "public"."floors"
  as permissive
  for delete
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Delete floors for tenant admins or owners"
  on "public"."floors"
  as permissive
  for delete
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Insert floors for superadmins"
  on "public"."floors"
  as permissive
  for insert
  to authenticated
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert floors for tenant admins or owners"
  on "public"."floors"
  as permissive
  for insert
  to authenticated
with check (((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)) AND ((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id))));



  create policy "Select floors for superadmins"
  on "public"."floors"
  as permissive
  for select
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Select floors for tenant members"
  on "public"."floors"
  as permissive
  for select
  to authenticated
using ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Update floors for superadmins"
  on "public"."floors"
  as permissive
  for update
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin))
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Update floors for tenant admins or owners"
  on "public"."floors"
  as permissive
  for update
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)))
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Delete rooms for superadmins"
  on "public"."rooms"
  as permissive
  for delete
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Delete rooms for tenant admins or owners"
  on "public"."rooms"
  as permissive
  for delete
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Insert rooms for superadmins"
  on "public"."rooms"
  as permissive
  for insert
  to authenticated
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert rooms for tenant admins or owners"
  on "public"."rooms"
  as permissive
  for insert
  to authenticated
with check (((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)) AND ((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id))));



  create policy "Select rooms for superadmins"
  on "public"."rooms"
  as permissive
  for select
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Select rooms for tenant members"
  on "public"."rooms"
  as permissive
  for select
  to authenticated
using ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Update rooms for superadmins"
  on "public"."rooms"
  as permissive
  for update
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin))
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Update rooms for tenant admins or owners"
  on "public"."rooms"
  as permissive
  for update
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)))
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Delete schedules for superadmins"
  on "public"."schedules"
  as permissive
  for delete
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Delete schedules for tenant admins or owners"
  on "public"."schedules"
  as permissive
  for delete
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Insert schedules for superadmins"
  on "public"."schedules"
  as permissive
  for insert
  to authenticated
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert schedules for tenant admins or owners"
  on "public"."schedules"
  as permissive
  for insert
  to authenticated
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Select schedules for superadmins"
  on "public"."schedules"
  as permissive
  for select
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Select schedules for tenant members"
  on "public"."schedules"
  as permissive
  for select
  to authenticated
using ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Update schedules for superadmins"
  on "public"."schedules"
  as permissive
  for update
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin))
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Update schedules for tenant admins or owners"
  on "public"."schedules"
  as permissive
  for update
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)))
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Delete sessions for admins owners or creator"
  on "public"."sessions"
  as permissive
  for delete
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id) OR (created_by = ( SELECT auth.uid() AS uid))));



  create policy "Delete sessions for superadmins"
  on "public"."sessions"
  as permissive
  for delete
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert sessions for superadmins"
  on "public"."sessions"
  as permissive
  for insert
  to authenticated
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Insert sessions for tenant members"
  on "public"."sessions"
  as permissive
  for insert
  to authenticated
with check ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Select sessions for superadmins"
  on "public"."sessions"
  as permissive
  for select
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Select sessions for tenant members"
  on "public"."sessions"
  as permissive
  for select
  to authenticated
using ((tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)));



  create policy "Update sessions for admins owners or creator"
  on "public"."sessions"
  as permissive
  for update
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id) OR (created_by = ( SELECT auth.uid() AS uid))))
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id) OR (created_by = ( SELECT auth.uid() AS uid))));



  create policy "Update sessions for superadmins"
  on "public"."sessions"
  as permissive
  for update
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin))
with check (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Delete tenants for authenticated users"
  on "public"."tenants"
  as permissive
  for delete
  to authenticated
using (((owner_id = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM private.profiles p
  WHERE ((p.user_id = ( SELECT auth.uid() AS uid)) AND (p.is_superadmin = true))))));



  create policy "Insert tenants for authenticated users"
  on "public"."tenants"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Select tenants for authenticated users or owners or superadmins"
  on "public"."tenants"
  as permissive
  for select
  to authenticated
using (((owner_id = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM public.tenants_users tu
  WHERE ((tu.tenant_id = tenants.id) AND (tu.user_id = ( SELECT auth.uid() AS uid))))) OR (EXISTS ( SELECT 1
   FROM private.profiles p
  WHERE ((p.user_id = ( SELECT auth.uid() AS uid)) AND (p.is_superadmin = true))))));



  create policy "Update tenants for authenticated users"
  on "public"."tenants"
  as permissive
  for update
  to authenticated
using (((owner_id = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM public.tenants_users tu
  WHERE ((tu.tenant_id = tenants.id) AND (tu.user_id = ( SELECT auth.uid() AS uid)) AND ((tu.role)::text = 'admin'::text)))) OR (EXISTS ( SELECT 1
   FROM private.profiles p
  WHERE ((p.user_id = ( SELECT auth.uid() AS uid)) AND (p.is_superadmin = true))))))
with check (true);



  create policy "Delete tenants_users for superadmins"
  on "public"."tenants_users"
  as permissive
  for delete
  to authenticated
using ((EXISTS ( SELECT 1
   FROM private.profiles p
  WHERE ((p.user_id = auth.uid()) AND (p.is_superadmin = true)))));



  create policy "Delete tenants_users for tenant admins or owners"
  on "public"."tenants_users"
  as permissive
  for delete
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Insert tenants_users for superadmins"
  on "public"."tenants_users"
  as permissive
  for insert
  to authenticated
with check ((EXISTS ( SELECT 1
   FROM private.profiles p
  WHERE ((p.user_id = ( SELECT auth.uid() AS uid)) AND (p.is_superadmin = true)))));



  create policy "Insert tenants_users for tenant admins or owners"
  on "public"."tenants_users"
  as permissive
  for insert
  to authenticated
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));



  create policy "Select tenants_users for superadmins"
  on "public"."tenants_users"
  as permissive
  for select
  to authenticated
using (( SELECT public.is_superadmin() AS is_superadmin));



  create policy "Select tenants_users for users or tenant members or owners"
  on "public"."tenants_users"
  as permissive
  for select
  to authenticated
using (((user_id = ( SELECT auth.uid() AS uid)) OR (tenant_id IN ( SELECT public.user_tenant_ids() AS user_tenant_ids)) OR public.is_tenant_owner(tenant_id)));



  create policy "Update tenants_users for superadmins"
  on "public"."tenants_users"
  as permissive
  for update
  to authenticated
using ((EXISTS ( SELECT 1
   FROM private.profiles p
  WHERE ((p.user_id = auth.uid()) AND (p.is_superadmin = true)))))
with check ((EXISTS ( SELECT 1
   FROM private.profiles p
  WHERE ((p.user_id = auth.uid()) AND (p.is_superadmin = true)))));



  create policy "Update tenants_users for tenant admins or owners"
  on "public"."tenants_users"
  as permissive
  for update
  to authenticated
using (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)))
with check (((public.user_role_in_tenant(tenant_id) = ANY (ARRAY['admin'::text, 'owner'::text])) OR public.is_tenant_owner(tenant_id)));


CREATE TRIGGER trigger_timestamps_and_user_bookings BEFORE INSERT OR UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_timestamps_and_user_buildings BEFORE INSERT OR UPDATE ON public.buildings FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_timestamps_and_user_floors BEFORE INSERT OR UPDATE ON public.floors FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_timestamps_and_user_rooms BEFORE INSERT OR UPDATE ON public.rooms FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_timestamps_and_user_schedules BEFORE INSERT OR UPDATE ON public.schedules FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_timestamps_and_user_sessions BEFORE INSERT OR UPDATE ON public.sessions FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_timestamps_and_user_tenants BEFORE INSERT OR UPDATE ON public.tenants FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_timestamps_and_user_tenants_users BEFORE INSERT OR UPDATE ON public.tenants_users FOR EACH ROW EXECUTE FUNCTION public.handle_timestamps_and_user();

CREATE TRIGGER trigger_updated_at_profiles BEFORE INSERT OR UPDATE ON private.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


