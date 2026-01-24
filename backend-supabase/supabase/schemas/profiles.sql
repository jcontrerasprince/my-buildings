create table profiles (
    id bigint generated always as identity primary key,
    name varchar,
    email text,
    address text,
    date_of_birth date,
    avatar_url text
)