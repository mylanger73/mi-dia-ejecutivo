-- =====================================================
-- Mi Día Ejecutivo · Setup de base de datos en Supabase
-- =====================================================
-- Pega TODO este archivo en el SQL Editor de Supabase
-- (Dashboard → SQL Editor → New query → Run)

-- 1. Tabla de tareas
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null,
  status text not null default 'pending', -- pending | completed | delegated
  date date not null,
  is_priority boolean not null default false,
  priority text default 'normal', -- alta | normal | baja
  focus text,
  responsible text,
  delegate_date date,
  delegate_note text,
  due_date date,
  note text,
  created_at timestamptz default now(),
  completed_at timestamptz,
  delegated_at timestamptz,
  deferred_count int default 0,
  first_seen_date date not null
);

create index if not exists tasks_user_date_idx on public.tasks(user_id, date);
create index if not exists tasks_user_status_idx on public.tasks(user_id, status);

-- 2. Tabla de días cerrados (historial)
create table if not exists public.closed_days (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  closed_at timestamptz default now(),
  stats jsonb,
  first_priority_tomorrow text,
  unique (user_id, date)
);

create index if not exists closed_days_user_date_idx on public.closed_days(user_id, date desc);

-- 3. Tabla de configuración por usuario
create table if not exists public.user_settings (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  focuses jsonb default '["Ventas","Finanzas","Operaciones","Equipo","Clientes","Proyectos","Personal"]'::jsonb,
  updated_at timestamptz default now()
);

-- =====================================================
-- 4. Row Level Security (RLS)
-- Cada usuario solo ve y modifica sus propios datos
-- =====================================================

alter table public.tasks enable row level security;
alter table public.closed_days enable row level security;
alter table public.user_settings enable row level security;

-- TASKS policies
drop policy if exists "tasks_select_own" on public.tasks;
drop policy if exists "tasks_insert_own" on public.tasks;
drop policy if exists "tasks_update_own" on public.tasks;
drop policy if exists "tasks_delete_own" on public.tasks;

create policy "tasks_select_own" on public.tasks for select using (auth.uid() = user_id);
create policy "tasks_insert_own" on public.tasks for insert with check (auth.uid() = user_id);
create policy "tasks_update_own" on public.tasks for update using (auth.uid() = user_id);
create policy "tasks_delete_own" on public.tasks for delete using (auth.uid() = user_id);

-- CLOSED_DAYS policies
drop policy if exists "closed_days_select_own" on public.closed_days;
drop policy if exists "closed_days_insert_own" on public.closed_days;
drop policy if exists "closed_days_update_own" on public.closed_days;
drop policy if exists "closed_days_delete_own" on public.closed_days;

create policy "closed_days_select_own" on public.closed_days for select using (auth.uid() = user_id);
create policy "closed_days_insert_own" on public.closed_days for insert with check (auth.uid() = user_id);
create policy "closed_days_update_own" on public.closed_days for update using (auth.uid() = user_id);
create policy "closed_days_delete_own" on public.closed_days for delete using (auth.uid() = user_id);

-- USER_SETTINGS policies
drop policy if exists "user_settings_select_own" on public.user_settings;
drop policy if exists "user_settings_insert_own" on public.user_settings;
drop policy if exists "user_settings_update_own" on public.user_settings;

create policy "user_settings_select_own" on public.user_settings for select using (auth.uid() = user_id);
create policy "user_settings_insert_own" on public.user_settings for insert with check (auth.uid() = user_id);
create policy "user_settings_update_own" on public.user_settings for update using (auth.uid() = user_id);

-- =====================================================
-- Listo. Ahora cualquier usuario autenticado puede
-- crear/leer/editar/borrar SOLO sus propios datos.
-- =====================================================
