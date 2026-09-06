-- Prevent two admins scanning the same resident at the same time from
-- creating duplicate entries during the 30-minute cooldown.

create or replace function public.record_checkin(
  p_qr_token uuid,
  p_meal_period text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  resident public.resident_profiles%rowtype;
  meal text := lower(trim(p_meal_period));
begin
  if not public.can_checkin_today() then
    raise exception 'QR check-in is only available to the owner or today''s assigned mess-duty admin';
  end if;
  if meal not in ('breakfast', 'lunch', 'dinner') then
    raise exception 'Invalid meal period';
  end if;

  select * into resident
  from public.resident_profiles
  where qr_token = p_qr_token;
  if not found then raise exception 'This QR code is not registered'; end if;
  if resident.active is not true then raise exception 'Resident access is inactive'; end if;
  if resident.access_until is not null
     and resident.access_until < (now() at time zone 'Asia/Kolkata')::date then
    raise exception 'Resident access has expired';
  end if;

  -- The same resident cannot be checked in twice during the QR cooldown.
  perform pg_advisory_xact_lock(
    hashtextextended(resident.id::text || ':' || meal, 0)
  );
  if exists (
    select 1 from public.checkins c
    where c.resident_id = resident.id
      and c.entry_status = 'eligible'
      and c.scanned_at > now() - interval '30 minutes'
  ) then
    raise exception 'Resident is already checked in. QR will return after 30 minutes';
  end if;

  insert into public.checkins
    (resident_id, scanned_by, meal_period, entry_status)
  values
    (resident.id, auth.uid(), meal, 'eligible');

  return jsonb_build_object(
    'id', resident.id,
    'full_name', resident.full_name,
    'room_number', resident.room_number,
    'access_until', resident.access_until,
    'person_type', resident.person_type
  );
end;
$$;

revoke all on function public.record_checkin(uuid, text) from public;
grant execute on function public.record_checkin(uuid, text) to authenticated;
notify pgrst, 'reload schema';
