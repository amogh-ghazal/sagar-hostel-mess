-- Return the resident's latest eligible check-in while its 30-minute QR cooldown is active.
create or replace function public.get_my_recent_checkin()
returns jsonb
language sql stable security definer set search_path = public
as $$
  select to_jsonb(x)
  from (
    select
      c.meal_period,
      c.scanned_at,
      c.scanned_at + interval '30 minutes' as available_again_at
    from public.checkins c
    where c.resident_id = auth.uid()
      and c.entry_status = 'eligible'
      and c.scanned_at > now() - interval '30 minutes'
    order by c.scanned_at desc
    limit 1
  ) x;
$$;

revoke all on function public.get_my_recent_checkin() from public;
grant execute on function public.get_my_recent_checkin() to authenticated;

notify pgrst, 'reload schema';
