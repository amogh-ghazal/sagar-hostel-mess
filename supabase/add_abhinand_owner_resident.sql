-- Link the newly-created Auth user to both application roles.
-- Auth user ID was obtained from Supabase Auth, not invented.

insert into public.profiles (id, is_admin, role)
values (
  '1982dd14-d523-4caa-b4c8-d8a869c1d76c'::uuid,
  true,
  'owner'
)
on conflict (id) do update
set is_admin = true,
    role = 'owner';

insert into public.resident_profiles
  (id, full_name, room_number, access_until, person_type, active)
values
  (
    '1982dd14-d523-4caa-b4c8-d8a869c1d76c'::uuid,
    'ABHINAND M V',
    '7',
    null,
    'hostel resident',
    true
  )
on conflict (id) do update
set full_name = excluded.full_name,
    room_number = excluded.room_number,
    person_type = excluded.person_type,
    active = true;

select
  u.id,
  u.email,
  u.email_confirmed_at,
  p.is_admin,
  p.role,
  r.full_name,
  r.room_number,
  r.access_until,
  r.qr_token
from auth.users u
left join public.profiles p on p.id = u.id
left join public.resident_profiles r on r.id = u.id
where u.id = '1982dd14-d523-4caa-b4c8-d8a869c1d76c'::uuid;
