-- Trigger function to handle created_by, updated_at, and updated_by
create or replace function handle_timestamps_and_user()
returns trigger as $$
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
$$ language plpgsql security definer;

/*
-- Example trigger (apply to your table name)
create trigger trigger_timestamps_and_user
before insert or update on your_table_name
for each row
execute function handle_timestamps_and_user();
*/

-- Trigger function to handle created_by and updated_at
create or replace function handle_updated_at()
returns trigger as $$
begin
    -- Set updated_at on both INSERT and UPDATE
    NEW.updated_at = now();
    return new;
end;
$$ language plpgsql security definer;
