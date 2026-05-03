------------------------------------------------------------
-- Table bookings (enabling RLS and adding triggers for timestamps and user tracking)
------------------------------------------------------------
-- TODO: create a enum type for status (pending, approved, rejected, cancelled)
create table public.bookings (
  id uuid not null default gen_random_uuid (),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  room_id uuid not null references public.rooms (id) on delete set null,
  responsible_id uuid not null references private.profiles (user_id) on delete set null,
  start_date date not null,
  end_date date not null,
  start_time time without time zone,
  end_time time without time zone,
  status varchar not null,
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

alter table public.bookings enable row level security;

create trigger trigger_timestamps_and_user_bookings
before insert or update on public.bookings
for each row
execute function handle_timestamps_and_user();

-- RLS Policies for bookings table
------------------------------------------------------------
-- SELECT
------------------------------------------------------------

-- Policy: Select bookings for tenant members
create policy "Select bookings for tenant members"
on public.bookings
for select
to authenticated
using (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Select bookings for superadmins
create policy "Select bookings for superadmins"
on public.bookings
for select
to authenticated
using (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- INSERT
------------------------------------------------------------

-- Policy: Insert bookings for tenant members
create policy "Insert bookings for tenant members"
on public.bookings
for insert
to authenticated
with check (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Insert bookings for superadmins
create policy "Insert bookings for superadmins"
on public.bookings
for insert
to authenticated
with check (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

-- Policy: Update bookings for admins, owners or creator
create policy "Update bookings for admins owners or creator"
on public.bookings
for update
to authenticated
using (
  (
    public.user_role_in_tenant(tenant_id) in ('admin','owner')
    or public.is_tenant_owner(tenant_id)
    or created_by = (select auth.uid())
  )
)
with check (
  (
    public.user_role_in_tenant(tenant_id) in ('admin','owner')
    or public.is_tenant_owner(tenant_id)
    or created_by = (select auth.uid())
  )
);

-- Policy: Update bookings for superadmins
create policy "Update bookings for superadmins"
on public.bookings
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

-- Policy: Delete bookings for admins owners or creator
create policy "Delete bookings for admins owners or creator"
on public.bookings
for delete
to authenticated
using (
  (
    public.user_role_in_tenant(tenant_id) in ('admin','owner')
    or public.is_tenant_owner(tenant_id)
    or created_by = (select auth.uid())
  )
);

-- Policy: Delete bookings for superadmins
create policy "Delete bookings for superadmins"
on public.bookings
for delete
to authenticated
using (
  (select public.is_superadmin())
);