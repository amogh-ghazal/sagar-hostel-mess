-- The app currently sends BREAKFAST/LUNCH/DINNER in uppercase.
-- Accept either case while keeping the allowed values restricted.

alter table public.checkins
drop constraint if exists checkins_meal_period_check;

alter table public.checkins
add constraint checkins_meal_period_check
check (lower(meal_period) in ('breakfast', 'lunch', 'dinner'));

-- Verify the constraint exists.
select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'public.checkins'::regclass
  and conname = 'checkins_meal_period_check';
