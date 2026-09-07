-- Allow authenticated admins to read the recent mess-entry register.
-- The check-in RPC remains responsible for creating entries.

alter table public.checkins enable row level security;
alter table public.resident_profiles enable row level security;

grant select on public.checkins to authenticated;
grant select on public.resident_profiles to authenticated;

drop policy if exists "Admins can view checkins" on public.checkins;
create policy "Admins can view checkins"
on public.checkins for select
using (public.is_admin());

drop policy if exists "Admins can view resident profiles" on public.resident_profiles;
create policy "Admins can view resident profiles"
on public.resident_profiles for select
using (public.is_admin() or auth.uid() = id);

notify pgrst, 'reload schema';
