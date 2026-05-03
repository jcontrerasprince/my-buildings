------------------------------------------------------------
-- Table sessions (enabling RLS and adding triggers for timestamps and user tracking)
------------------------------------------------------------
-- TODO: create a enum type for status (scheduled, cancelled, completed)
create table sessions (
  id uuid not null default gen_random_uuid (),
  tenant_id uuid not null references public.tenants (id) on delete cascade,
  booking_id uuid null references public.bookings (id) on delete set null,
  responsible_id uuid not null references private.profiles (user_id) on delete set null,
  room_id uuid null references public.rooms (id) on delete set null,
  "date" date not null,
  status varchar not null,
  start_time time without time zone null,
  end_time time without time zone null,
  created_at timestamp with time zone null default now (),
  updated_at timestamp with time zone null default now (),
  created_by uuid references private.profiles (user_id) on delete set null,
  updated_by uuid references private.profiles (user_id) on delete set null,
  primary key (id)
);

alter table public.sessions enable row level security;

create trigger trigger_timestamps_and_user_sessions
before insert or update on public.sessions
for each row
execute function handle_timestamps_and_user();

-- RLS Policies for sessions table
------------------------------------------------------------
-- SELECT
------------------------------------------------------------

-- Policy: Select sessions for tenant members
create policy "Select sessions for tenant members"
on public.sessions
for select
to authenticated
using (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Select sessions for superadmins
create policy "Select sessions for superadmins"
on public.sessions
for select
to authenticated
using (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- INSERT
------------------------------------------------------------

-- Policy: Insert sessions for tenant members
create policy "Insert sessions for tenant members"
on public.sessions
for insert
to authenticated
with check (
  tenant_id in (select public.user_tenant_ids())
);

-- Policy: Insert sessions for superadmins
create policy "Insert sessions for superadmins"
on public.sessions
for insert
to authenticated
with check (
  (select public.is_superadmin())
);


------------------------------------------------------------
-- UPDATE
------------------------------------------------------------

-- Policy: Update sessions for admins owners or creator
create policy "Update sessions for admins owners or creator"
on public.sessions
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

-- Policy: Update sessions for superadmins
create policy "Update sessions for superadmins"
on public.sessions
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

-- Policy: Delete sessions for admins owners or creator
create policy "Delete sessions for admins owners or creator"
on public.sessions
for delete
to authenticated
using (
  (
    public.user_role_in_tenant(tenant_id) in ('admin','owner')
    or public.is_tenant_owner(tenant_id)
    or created_by = (select auth.uid())
  )
);

-- Policy: Delete sessions for superadmins
create policy "Delete sessions for superadmins"
on public.sessions
for delete
to authenticated
using (
  (select public.is_superadmin())
);