-- Link the developer/owner account to a resident profile so its own QR is available.
-- The room is intentionally left unset because no room number was supplied.

insert into public.profiles (id, is_admin, role)
select id, true, 'owner'
from auth.users
where lower(email) = lower('amoghblue333@gmail.com')
on conflict (id) do update
set is_admin = true,
    role = 'owner';

insert into public.resident_profiles
  (id, full_name, room_number, access_until, person_type, active)
select
  id,
  coalesce(nullif(raw_user_meta_data ->> 'full_name', ''), 'AMOGH'),
  null,
  null,
  'hostel resident',
  true
from auth.users
where lower(email) = lower('amoghblue333@gmail.com')
on conflict (id) do update
set full_name = excluded.full_name,
    access_until = null,
    person_type = 'hostel resident',
    active = true;

select
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
where lower(u.email) = lower('amoghblue333@gmail.com');
