create or replace function public.get_my_resident_profile()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select to_jsonb(r)
  from public.resident_profiles r
  where r.id = auth.uid();
$$;

revoke all on function public.get_my_resident_profile() from public;
grant execute on function public.get_my_resident_profile() to authenticated;
