-- Keep a resident account active on one device at a time.
-- A second device is refused; the existing device is not revoked.

alter table public.resident_profiles
add column if not exists device_lock_id text;

create or replace function public.claim_resident_device(p_device_id text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  current_lock text;
begin
  if length(coalesce(trim(p_device_id), '')) < 16 then
    raise exception 'A valid device identifier is required';
  end if;

  select device_lock_id into current_lock
  from public.resident_profiles
  where id = auth.uid()
  for update;

  if not found then
    raise exception 'No resident profile is linked to this account';
  end if;

  if current_lock is not null and current_lock <> p_device_id then
    return false;
  end if;

  update public.resident_profiles
  set device_lock_id = p_device_id
  where id = auth.uid();
  return true;
end;
$$;

create or replace function public.release_resident_device()
returns void
language sql
security definer
set search_path = public
as $$
  update public.resident_profiles
  set device_lock_id = null
  where id = auth.uid();
$$;

revoke all on function public.claim_resident_device(text) from public;
grant execute on function public.claim_resident_device(text) to authenticated;
revoke all on function public.release_resident_device() from public;
grant execute on function public.release_resident_device() to authenticated;
