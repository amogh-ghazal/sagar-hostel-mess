-- Role and duty-day permissions. This creates no admin profiles.

alter table public.profiles
add column if not exists role text not null default 'duty_admin';

alter table public.profiles
drop constraint if exists profiles_role_check;

alter table public.profiles
add constraint profiles_role_check
check (role in ('owner', 'duty_admin'));

update public.profiles p
set role = 'owner', is_admin = true
from auth.users u
where p.id = u.id
  and lower(u.email) = lower('amoghblue333@gmail.com');

create table if not exists public.duty_assignments (
  duty_date date not null,
  admin_id uuid not null references auth.users(id) on delete cascade,
  primary key (duty_date, admin_id)
);

alter table public.duty_assignments enable row level security;

create or replace function public.is_owner()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'owner');
$$;

revoke all on function public.is_owner() from public;
grant execute on function public.is_owner() to authenticated;

drop policy if exists "Owner manages duty assignments" on public.duty_assignments;
create policy "Owner manages duty assignments"
on public.duty_assignments for all
using (public.is_owner())
with check (public.is_owner());

create or replace function public.can_checkin_today()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.is_admin = true
      and (
        p.role = 'owner'
        or exists (
          select 1 from public.duty_assignments d
          where d.admin_id = auth.uid()
            and d.duty_date = (now() at time zone 'Asia/Kolkata')::date
        )
      )
  );
$$;

revoke all on function public.can_checkin_today() from public;
grant execute on function public.can_checkin_today() to authenticated;

-- Replace the check-in RPC so the database enforces duty-day access too.
create or replace function public.record_checkin(
  p_qr_token uuid,
  p_meal_period text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare resident public.resident_profiles%rowtype;
begin
  if not public.can_checkin_today() then
    raise exception 'QR check-in is only available to the owner or today''s assigned mess-duty admin';
  end if;
  select * into resident from public.resident_profiles where qr_token = p_qr_token;
  if not found then raise exception 'This QR code is not registered'; end if;
  if resident.active is not true then raise exception 'Resident access is inactive'; end if;
  if resident.access_until is not null and resident.access_until < (now() at time zone 'Asia/Kolkata')::date then
    raise exception 'Resident access has expired';
  end if;
  insert into public.checkins (resident_id, scanned_by, meal_period, entry_status)
  values (resident.id, auth.uid(), lower(p_meal_period), 'eligible');
  return jsonb_build_object('id', resident.id, 'full_name', resident.full_name,
    'room_number', resident.room_number, 'access_until', resident.access_until,
    'person_type', resident.person_type);
end;
$$;

revoke all on function public.record_checkin(uuid, text) from public;
grant execute on function public.record_checkin(uuid, text) to authenticated;

notify pgrst, 'reload schema';
