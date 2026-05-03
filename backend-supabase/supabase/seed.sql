SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict jfmsJfZKJrnBcYyyBUF5OBzm4P1KkFMQfyyOrGqYji8SJsuuOneEFBoKpzc5n0c

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '633adbb4-d507-4e7b-ae05-34750f31d469', 'authenticated', 'authenticated', 'jorge@email.com', '$2a$10$4IVXLaml0qVHQhaOqgNH.O/W/XdBYqwpdFu1FFnSltKMChevezKr.', '2026-03-15 19:48:12.481356+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-15 19:48:12.491322+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "633adbb4-d507-4e7b-ae05-34750f31d469", "email": "jorge@email.com", "last_name": "Contreras", "avatar_url": "https://my-avatar-url.com/jorge-contreras", "first_name": "Jorge", "email_verified": true, "phone_verified": false}', NULL, '2026-03-15 19:48:12.47423+00', '2026-03-15 19:48:12.493799+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '90c1bb46-f920-4f82-bc18-f42f6d1edc68', 'authenticated', 'authenticated', 'user1@email.com', '$2a$10$QzBTICk/kc3FwtpqcDQzkOSo91AemVf02T5zAaEZuwGWWymS3t1Li', '2026-03-15 19:48:36.70982+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-15 19:48:36.719436+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "90c1bb46-f920-4f82-bc18-f42f6d1edc68", "email": "user1@email.com", "last_name": "Buildings", "avatar_url": "https://my-avatar-url.com/user1", "first_name": "User1", "email_verified": true, "phone_verified": false}', NULL, '2026-03-15 19:48:36.702242+00', '2026-03-15 19:48:36.722207+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'a8a15999-a318-45b7-8a5c-1f7cde922b21', 'authenticated', 'authenticated', 'user3@email.com', '$2a$10$N4.lJ2ZVo1cCbkDrwL6TqeBOoM3BKxIM5ZvfHqx13uEKUGABqIiMS', '2026-03-15 19:48:56.363953+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-15 19:48:56.373457+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "a8a15999-a318-45b7-8a5c-1f7cde922b21", "email": "user3@email.com", "last_name": "Buildings", "avatar_url": "https://my-avatar-url.com/user3", "first_name": "User3", "email_verified": true, "phone_verified": false}', NULL, '2026-03-15 19:48:56.356797+00', '2026-03-15 19:48:56.376059+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '5bee1545-0254-4c25-86e1-fcc6ccf81de7', 'authenticated', 'authenticated', 'user2@email.com', '$2a$10$qhkMFmPV/NOJtGKkQEK4XOprtVY8MNx8O7um1ibXvUDHi4sTiqYSe', '2026-03-15 19:48:45.447328+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-15 19:48:45.456459+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "5bee1545-0254-4c25-86e1-fcc6ccf81de7", "email": "user2@email.com", "last_name": "Buildings", "avatar_url": "https://my-avatar-url.com/user2", "first_name": "User2", "email_verified": true, "phone_verified": false}', NULL, '2026-03-15 19:48:45.440028+00', '2026-03-15 19:48:45.458903+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('633adbb4-d507-4e7b-ae05-34750f31d469', '633adbb4-d507-4e7b-ae05-34750f31d469', '{"sub": "633adbb4-d507-4e7b-ae05-34750f31d469", "email": "jorge@email.com", "last_name": "Contreras", "avatar_url": "https://my-avatar-url.com/jorge-contreras", "first_name": "Jorge", "email_verified": false, "phone_verified": false}', 'email', '2026-03-15 19:48:12.478822+00', '2026-03-15 19:48:12.478853+00', '2026-03-15 19:48:12.478853+00', 'd849bb1a-b8f6-4612-8e1e-887eba8012db'),
	('90c1bb46-f920-4f82-bc18-f42f6d1edc68', '90c1bb46-f920-4f82-bc18-f42f6d1edc68', '{"sub": "90c1bb46-f920-4f82-bc18-f42f6d1edc68", "email": "user1@email.com", "last_name": "Buildings", "avatar_url": "https://my-avatar-url.com/user1", "first_name": "User1", "email_verified": false, "phone_verified": false}', 'email', '2026-03-15 19:48:36.706903+00', '2026-03-15 19:48:36.706921+00', '2026-03-15 19:48:36.706921+00', '517c77e9-baaf-47e3-a082-f354b261ef49'),
	('3ad84f3f-3d1a-4246-b47e-c1462628fa3a', '3ad84f3f-3d1a-4246-b47e-c1462628fa3a', '{"sub": "3ad84f3f-3d1a-4246-b47e-c1462628fa3a", "email": "user2@email.com", "last_name": "Buildings", "avatar_url": "https://my-avatar-url.com/user2", "first_name": "User2", "email_verified": false, "phone_verified": false}', 'email', '2026-03-15 19:48:45.444332+00', '2026-03-15 19:48:45.44435+00', '2026-03-15 19:48:45.44435+00', '4b1db505-5203-47e3-a28f-299a46fd970d'),
	('a8a15999-a318-45b7-8a5c-1f7cde922b21', 'a8a15999-a318-45b7-8a5c-1f7cde922b21', '{"sub": "a8a15999-a318-45b7-8a5c-1f7cde922b21", "email": "user3@email.com", "last_name": "Buildings", "avatar_url": "https://my-avatar-url.com/user3", "first_name": "User3", "email_verified": false, "phone_verified": false}', 'email', '2026-03-15 19:48:56.361281+00', '2026-03-15 19:48:56.361298+00', '2026-03-15 19:48:56.361298+00', '6c5e3e0e-8b03-44bf-918e-372a1804c571');

--
-- Data for Name: profiles; Type: TABLE DATA; Schema: private; Owner: postgres
--

INSERT INTO "private"."profiles" ("user_id", "first_name", "last_name", "email", "avatar_url", "is_superadmin", "created_at", "updated_at") VALUES
	('633adbb4-d507-4e7b-ae05-34750f31d469', 'Jorge', 'Contreras', 'jorge@email.com', 'https://my-avatar-url.com/jorge-contreras', false, '2026-03-15 19:48:12.474+00', '2026-03-15 19:48:12.474+00'),
	('90c1bb46-f920-4f82-bc18-f42f6d1edc68', 'User1', 'Buildings', 'user1@email.com', 'https://my-avatar-url.com/user1', false, '2026-03-15 19:48:36.702008+00', '2026-03-15 19:48:36.702008+00'),
	('3ad84f3f-3d1a-4246-b47e-c1462628fa3a', 'User2', 'Buildings', 'user2@email.com', 'https://my-avatar-url.com/user2', false, '2026-03-15 19:48:45.43979+00', '2026-03-15 19:48:45.43979+00'),
	('a8a15999-a318-45b7-8a5c-1f7cde922b21', 'User3', 'Buildings', 'user3@email.com', 'https://my-avatar-url.com/user3', false, '2026-03-15 19:48:56.356528+00', '2026-03-15 19:48:56.356528+00');


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tenants" ("id", "name", "description", "owner_id", "created_at", "updated_at", "created_by", "updated_by") VALUES
	('7ef9c7d0-a4ba-4502-a1f2-5bf47da7107c', 'Acme Corp', 'This is my first tenant', '90c1bb46-f920-4f82-bc18-f42f6d1edc68', '2026-03-15 19:49:59.228282+00', '2026-03-15 19:51:38.867156+00', '90c1bb46-f920-4f82-bc18-f42f6d1edc68', NULL),
	('ebcdf6b3-1e82-40d3-bd1d-ea15a75b23ad', 'Beta LTD', 'This is my second tenant', '3ad84f3f-3d1a-4246-b47e-c1462628fa3a', '2026-03-15 19:50:30.790873+00', '2026-03-15 19:51:53.56768+00', '3ad84f3f-3d1a-4246-b47e-c1462628fa3a', NULL),
	('6514d911-505f-4c6e-a21a-5ecdf1ad5c6b', 'Charlie Inc.', 'This is my third tenant', 'a8a15999-a318-45b7-8a5c-1f7cde922b21', '2026-03-15 19:51:03.994632+00', '2026-03-15 19:51:59.573781+00', 'a8a15999-a318-45b7-8a5c-1f7cde922b21', NULL);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

-- \unrestrict jfmsJfZKJrnBcYyyBUF5OBzm4P1KkFMQfyyOrGqYji8SJsuuOneEFBoKpzc5n0c

RESET ALL;
