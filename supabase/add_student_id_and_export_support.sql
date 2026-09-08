-- Optional student identifier used by the administrator's Excel register export.
alter table public.resident_profiles
  add column if not exists student_id text;

notify pgrst, 'reload schema';
