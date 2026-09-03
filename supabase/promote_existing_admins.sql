-- Create a profile for every current Auth account, ordinary by default.
insert into public.profiles (id, is_admin)
select id, false
from auth.users
on conflict (id) do nothing;

-- Promote only trusted mess administrators by their current email addresses.
update public.profiles p
set is_admin = true
from auth.users u
where p.id = u.id
  and lower(u.email) in (
    'amoghblue333@gmail.com',
    'amoghsuresh3@gmail.com'
  );

-- Verify the result without exposing passwords or tokens.
select u.email, p.is_admin
from auth.users u
join public.profiles p on p.id = u.id
where lower(u.email) in (
  'amoghblue333@gmail.com',
  'amoghsuresh3@gmail.com'
)
order by u.email;
