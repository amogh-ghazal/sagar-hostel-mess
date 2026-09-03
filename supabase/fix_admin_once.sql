do $$
begin
  if to_regclass('public.profiles') is null then
    raise exception 'public.profiles does not exist';
  end if;

  execute 'alter table public.profiles drop constraint if exists profiles_id_fkey';
  execute 'alter table public.profiles add constraint profiles_id_fkey foreign key (id) references auth.users(id) on delete cascade';

  insert into public.profiles (id, is_admin)
  select id, true
  from auth.users
  where lower(email) in ('amoghblue333@gmail.com', 'amoghsuresh3@gmail.com')
  on conflict (id) do update set is_admin = true;
end $$;

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and is_admin = true
  );
$$;

grant execute on function public.is_admin() to anon, authenticated;
