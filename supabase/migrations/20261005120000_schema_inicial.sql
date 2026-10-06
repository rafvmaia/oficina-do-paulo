-- =============================================================================
-- Oficina do Paulo — schema inicial
--
-- Tabelas: clientes, veiculos, servicos, pagamentos (+ view servicos_resumo).
-- Regras:
--   * ids são UUID gerados no app; owner_id = auth.uid() (RLS);
--   * dinheiro sempre em centavos inteiros (bigint);
--   * nada é apagado fisicamente: exclusão lógica via deleted_at (com cascata);
--   * updated_at é o critério de desempate do sync (vence o mais recente);
--   * status de pagamento é derivado (view), nunca gravado.
--
-- Esta migration é idempotente: pode ser reaplicada no mesmo banco sem erro.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabelas
-- -----------------------------------------------------------------------------

create table if not exists public.clientes (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id),
  nome text not null,
  telefone text not null,
  documento text,
  endereco text,
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint clientes_id_owner_key unique (id, owner_id),
  constraint clientes_nome_preenchido check (btrim(nome) <> ''),
  constraint clientes_telefone_preenchido check (btrim(telefone) <> '')
);

create table if not exists public.veiculos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id),
  cliente_id uuid not null,
  placa text not null,
  marca text,
  modelo text,
  ano integer,
  cor text,
  km integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint veiculos_id_owner_key unique (id, owner_id),
  -- FK composta: o veículo só pode apontar para um cliente do mesmo dono.
  constraint veiculos_cliente_fkey foreign key (cliente_id, owner_id)
    references public.clientes (id, owner_id),
  constraint veiculos_placa_preenchida check (btrim(placa) <> ''),
  constraint veiculos_ano_valido check (ano is null or ano between 1900 and 2100),
  constraint veiculos_km_valido check (km is null or km >= 0)
);

create table if not exists public.servicos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id),
  cliente_id uuid not null,
  veiculo_id uuid,
  descricao text not null,
  pecas text,
  mao_de_obra_centavos bigint not null default 0,
  pecas_centavos bigint not null default 0,
  total_centavos bigint not null default 0,
  data_entrada date not null,
  data_conclusao date,
  status_servico text not null default 'ORCAMENTO',
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint servicos_id_owner_key unique (id, owner_id),
  constraint servicos_cliente_fkey foreign key (cliente_id, owner_id)
    references public.clientes (id, owner_id),
  -- veiculo_id é opcional: com valor nulo a FK composta não é verificada.
  constraint servicos_veiculo_fkey foreign key (veiculo_id, owner_id)
    references public.veiculos (id, owner_id),
  constraint servicos_descricao_preenchida check (btrim(descricao) <> ''),
  constraint servicos_mao_de_obra_nao_negativa check (mao_de_obra_centavos >= 0),
  constraint servicos_pecas_nao_negativa check (pecas_centavos >= 0),
  constraint servicos_total_nao_negativo check (total_centavos >= 0),
  constraint servicos_status_valido check (
    status_servico in ('ORCAMENTO', 'EM_ANDAMENTO', 'CONCLUIDO', 'ENTREGUE')
  )
);

create table if not exists public.pagamentos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users (id),
  servico_id uuid not null,
  valor_centavos bigint not null,
  data date not null,
  forma text not null default 'DINHEIRO',
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint pagamentos_servico_fkey foreign key (servico_id, owner_id)
    references public.servicos (id, owner_id),
  constraint pagamentos_valor_positivo check (valor_centavos > 0),
  constraint pagamentos_forma_valida check (
    forma in ('DINHEIRO', 'PIX', 'DEBITO', 'CREDITO', 'TRANSFERENCIA', 'OUTRO')
  )
);

-- -----------------------------------------------------------------------------
-- Índices (owner_id + updated_at atende o RLS e a consulta incremental do sync)
-- -----------------------------------------------------------------------------

create index if not exists clientes_owner_updated_idx on public.clientes (owner_id, updated_at);
create index if not exists clientes_nome_idx on public.clientes (nome);

create index if not exists veiculos_owner_updated_idx on public.veiculos (owner_id, updated_at);
create index if not exists veiculos_cliente_idx on public.veiculos (cliente_id);
create index if not exists veiculos_placa_idx on public.veiculos (owner_id, placa);

create index if not exists servicos_owner_updated_idx on public.servicos (owner_id, updated_at);
create index if not exists servicos_cliente_idx on public.servicos (cliente_id);
create index if not exists servicos_veiculo_idx on public.servicos (veiculo_id);

create index if not exists pagamentos_owner_updated_idx on public.pagamentos (owner_id, updated_at);
create index if not exists pagamentos_servico_idx on public.pagamentos (servico_id);

-- -----------------------------------------------------------------------------
-- Trigger: updated_at (desempate do sync — vence o mais recente)
--
--   * app enviou updated_at MAIS NOVO que o gravado  -> mantém o valor do app;
--   * app não enviou (ou enviou o mesmo valor)        -> servidor avança updated_at
--     (now(), e sempre ao menos 1 ms acima do anterior, para o sync baixar);
--   * app enviou updated_at MAIS ANTIGO               -> escrita obsoleta: a linha
--     não é alterada (o trigger descarta o UPDATE, inclusive em upsert).
-- -----------------------------------------------------------------------------

create or replace function public.definir_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.updated_at is null or new.updated_at = old.updated_at then
    new.updated_at := greatest(now(), old.updated_at + interval '1 millisecond');
  elsif new.updated_at < old.updated_at then
    return null;
  end if;
  return new;
end;
$$;

-- Os nomes começam com "a_" para rodarem antes dos demais triggers BEFORE
-- (o Postgres dispara triggers do mesmo evento em ordem alfabética).
drop trigger if exists a_definir_updated_at on public.clientes;
create trigger a_definir_updated_at
  before update on public.clientes
  for each row execute function public.definir_updated_at();

drop trigger if exists a_definir_updated_at on public.veiculos;
create trigger a_definir_updated_at
  before update on public.veiculos
  for each row execute function public.definir_updated_at();

drop trigger if exists a_definir_updated_at on public.servicos;
create trigger a_definir_updated_at
  before update on public.servicos
  for each row execute function public.definir_updated_at();

drop trigger if exists a_definir_updated_at on public.pagamentos;
create trigger a_definir_updated_at
  before update on public.pagamentos
  for each row execute function public.definir_updated_at();

-- -----------------------------------------------------------------------------
-- Trigger: total_centavos = mao_de_obra_centavos + pecas_centavos
-- (o valor de total enviado pelo app é sempre recalculado)
-- -----------------------------------------------------------------------------

create or replace function public.calcular_total_servico()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.mao_de_obra_centavos := coalesce(new.mao_de_obra_centavos, 0);
  new.pecas_centavos := coalesce(new.pecas_centavos, 0);
  new.total_centavos := new.mao_de_obra_centavos + new.pecas_centavos;
  return new;
end;
$$;

drop trigger if exists b_calcular_total on public.servicos;
create trigger b_calcular_total
  before insert or update on public.servicos
  for each row execute function public.calcular_total_servico();

-- -----------------------------------------------------------------------------
-- Triggers: exclusão lógica em cascata
--   cliente -> veículos, serviços e pagamentos
--   serviço -> pagamentos
-- Só propaga na transição "ativo -> excluído"; filhos já excluídos mantêm a
-- data original. Os filhos ganham updated_at novo pelo trigger acima.
-- -----------------------------------------------------------------------------

create or replace function public.cascatear_exclusao_cliente()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  update public.veiculos
     set deleted_at = new.deleted_at
   where cliente_id = new.id
     and deleted_at is null;

  -- Excluir os serviços dispara a cascata serviço -> pagamentos.
  update public.servicos
     set deleted_at = new.deleted_at
   where cliente_id = new.id
     and deleted_at is null;

  -- Garante também pagamentos ativos de serviços que já estavam excluídos.
  update public.pagamentos p
     set deleted_at = new.deleted_at
    from public.servicos s
   where p.servico_id = s.id
     and s.cliente_id = new.id
     and p.deleted_at is null;

  return null;
end;
$$;

create or replace function public.cascatear_exclusao_servico()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  update public.pagamentos
     set deleted_at = new.deleted_at
   where servico_id = new.id
     and deleted_at is null;

  return null;
end;
$$;

drop trigger if exists cascatear_exclusao on public.clientes;
create trigger cascatear_exclusao
  after update on public.clientes
  for each row
  when (old.deleted_at is null and new.deleted_at is not null)
  execute function public.cascatear_exclusao_cliente();

drop trigger if exists cascatear_exclusao on public.servicos;
create trigger cascatear_exclusao
  after update on public.servicos
  for each row
  when (old.deleted_at is null and new.deleted_at is not null)
  execute function public.cascatear_exclusao_servico();

-- -----------------------------------------------------------------------------
-- Row Level Security: cada conta só enxerga e altera o que é dela.
-- Sem política de DELETE (só exclusão lógica).
-- -----------------------------------------------------------------------------

alter table public.clientes enable row level security;
alter table public.veiculos enable row level security;
alter table public.servicos enable row level security;
alter table public.pagamentos enable row level security;

drop policy if exists clientes_select on public.clientes;
create policy clientes_select on public.clientes
  for select to authenticated
  using (owner_id = (select auth.uid()));
drop policy if exists clientes_insert on public.clientes;
create policy clientes_insert on public.clientes
  for insert to authenticated
  with check (owner_id = (select auth.uid()));
drop policy if exists clientes_update on public.clientes;
create policy clientes_update on public.clientes
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists veiculos_select on public.veiculos;
create policy veiculos_select on public.veiculos
  for select to authenticated
  using (owner_id = (select auth.uid()));
drop policy if exists veiculos_insert on public.veiculos;
create policy veiculos_insert on public.veiculos
  for insert to authenticated
  with check (owner_id = (select auth.uid()));
drop policy if exists veiculos_update on public.veiculos;
create policy veiculos_update on public.veiculos
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists servicos_select on public.servicos;
create policy servicos_select on public.servicos
  for select to authenticated
  using (owner_id = (select auth.uid()));
drop policy if exists servicos_insert on public.servicos;
create policy servicos_insert on public.servicos
  for insert to authenticated
  with check (owner_id = (select auth.uid()));
drop policy if exists servicos_update on public.servicos;
create policy servicos_update on public.servicos
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy if exists pagamentos_select on public.pagamentos;
create policy pagamentos_select on public.pagamentos
  for select to authenticated
  using (owner_id = (select auth.uid()));
drop policy if exists pagamentos_insert on public.pagamentos;
create policy pagamentos_insert on public.pagamentos
  for insert to authenticated
  with check (owner_id = (select auth.uid()));
drop policy if exists pagamentos_update on public.pagamentos;
create policy pagamentos_update on public.pagamentos
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

-- Privilégios: anônimo não acessa nada; autenticado só lê, insere e altera
-- (sem DELETE e sem TRUNCATE — TRUNCATE ignoraria o RLS).
revoke all on table public.clientes, public.veiculos, public.servicos, public.pagamentos
  from anon, authenticated;
grant select, insert, update on table public.clientes, public.veiculos, public.servicos, public.pagamentos
  to authenticated;

-- -----------------------------------------------------------------------------
-- View servicos_resumo: status de pagamento derivado (pagamentos excluídos
-- logicamente são ignorados). security_invoker = true -> respeita o RLS de quem
-- consulta.
--   PENDENTE: pago = 0 (e total > 0)
--   PARCIAL : 0 < pago < total
--   PAGO    : pago >= total (total 0 conta como PAGO)
--   falta   : max(total - pago, 0)
-- -----------------------------------------------------------------------------

create or replace view public.servicos_resumo
with (security_invoker = true)
as
select
  s.id,
  s.owner_id,
  s.cliente_id,
  s.veiculo_id,
  s.descricao,
  s.pecas,
  s.mao_de_obra_centavos,
  s.pecas_centavos,
  s.total_centavos,
  s.data_entrada,
  s.data_conclusao,
  s.status_servico,
  s.observacoes,
  s.created_at,
  s.updated_at,
  s.deleted_at,
  pg.total_pago_centavos,
  greatest(s.total_centavos - pg.total_pago_centavos, 0)::bigint as falta_centavos,
  case
    when pg.total_pago_centavos >= s.total_centavos then 'PAGO'
    when pg.total_pago_centavos = 0 then 'PENDENTE'
    else 'PARCIAL'
  end as status_pagamento
from public.servicos s
cross join lateral (
  select coalesce(sum(p.valor_centavos), 0)::bigint as total_pago_centavos
    from public.pagamentos p
   where p.servico_id = s.id
     and p.deleted_at is null
) pg;

revoke all on table public.servicos_resumo from anon, authenticated;
grant select on table public.servicos_resumo to authenticated;
