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
  if not exists (select 1 from public.profiles where id = auth.uid() and is_admin = true) then
    raise exception 'Only approved admins can record check-ins';
  end if;
  select * into resident from public.resident_profiles where qr_token = p_qr_token;
  if not found then raise exception 'This QR code is not registered'; end if;
  if resident.active is not true then raise exception 'Resident access is inactive'; end if;
  if resident.access_until is not null and resident.access_until < current_date then
    raise exception 'Resident access has expired';
  end if;
  insert into public.checkins (resident_id, scanned_by, meal_period, entry_status)
  values (resident.id, auth.uid(), p_meal_period, 'eligible');
  return jsonb_build_object('id', resident.id, 'full_name', resident.full_name,
    'room_number', resident.room_number, 'access_until', resident.access_until,
    'person_type', resident.person_type);
end;
$$;
revoke all on function public.record_checkin(uuid, text) from public;
grant execute on function public.record_checkin(uuid, text) to authenticated;
