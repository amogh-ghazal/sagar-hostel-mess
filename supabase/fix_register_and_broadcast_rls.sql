-- Restore the intended RLS policies for the admin register and broadcasts.
-- Residents can read announcements; only the owner can publish them.

alter table public.checkins enable row level security;

drop policy if exists "Admins can view checkins" on public.checkins;
create policy "Admins can view checkins"
on public.checkins for select
using (public.is_admin());

drop policy if exists "Admins can record checkins" on public.checkins;
create policy "Admins can record checkins"
on public.checkins for insert
with check (public.can_checkin_today());

alter table public.announcements enable row level security;

drop policy if exists "Anyone can read announcements" on public.announcements;
create policy "Anyone can read announcements"
on public.announcements for select
using (true);

drop policy if exists "Owner can publish announcements" on public.announcements;
create policy "Owner can publish announcements"
on public.announcements for insert
with check (public.is_owner());

drop policy if exists "Owner can update announcements" on public.announcements;
create policy "Owner can update announcements"
on public.announcements for update
using (public.is_owner())
with check (public.is_owner());

drop policy if exists "Owner can delete announcements" on public.announcements;
create policy "Owner can delete announcements"
on public.announcements for delete
using (public.is_owner());
