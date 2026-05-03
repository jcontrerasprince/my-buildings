-- Create table profiles
create table private.profiles (
  user_id uuid not null references auth.users on delete cascade,
  first_name varchar,
  last_name varchar,
  email varchar,
  avatar_url text,
  is_superadmin boolean default false,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  primary key (user_id)
);

-- Enable RLS
alter table private.profiles enable row level security;

-- Trigger to handle updated_at timestamp
create trigger trigger_updated_at_profiles
before insert or update on private.profiles
for each row
execute function handle_updated_at();

-- Create RLS policy to select users to all authenticated users
create policy "Select profiles for authenticated users"
on private.profiles for select
to authenticated
using (true);

-- Create RLS policy to insert users to all authenticated users
create policy "Insert profiles for authenticated users"
on private.profiles for insert
to authenticated
with check (true);

-- Create RLS policy to insert users to all authenticated users
create policy "Update profiles for authenticated users"
on private.profiles for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

-- Create RLS policy to delete users to all authenticated users
create policy "Delete profiles for authenticated users"
on private.profiles for delete
to authenticated
using (true);