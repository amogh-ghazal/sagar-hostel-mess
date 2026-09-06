-- Link SREEROOP's confirmed Auth account as an owner and resident.
-- Auth user ID was obtained from Supabase Auth.

insert into public.profiles (id, is_admin, role)
values (
  'cda590bb-8f08-495c-8d2e-868cfe8fe94e'::uuid,
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
    'cda590bb-8f08-495c-8d2e-868cfe8fe94e'::uuid,
    'SREEROOP',
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
where u.id = 'cda590bb-8f08-495c-8d2e-868cfe8fe94e'::uuid;
