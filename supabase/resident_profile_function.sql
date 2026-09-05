drop function if exists public.get_my_resident_profile();
create or replace function public.get_my_resident_profile(p_email text)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select to_jsonb(r)
  from public.resident_profiles r
  join auth.users u on u.id = r.id
  where lower(u.email) = lower(p_email)
    and lower(u.email) = lower(coalesce(auth.jwt() ->> 'email', ''));
$$;

revoke all on function public.get_my_resident_profile(text) from public;
grant execute on function public.get_my_resident_profile(text) to authenticated;
