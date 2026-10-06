-- Exclusão lógica em cascata: cliente -> veículos, serviços e pagamentos;
-- serviço -> pagamentos. (Casos C1–C4 de docs/qa/fase-02.md)
-- Roda como usuário autenticado (a cascata precisa funcionar sob RLS).
begin;
create extension if not exists pgtap with schema extensions;

select plan(10);

insert into auth.users (id, email) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'conta-a@teste.local');

set local role authenticated;
set local request.jwt.claims to '{"sub": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "role": "authenticated"}';

-- c1: cliente que será excluído; c2: outro cliente (não pode ser afetado);
-- c3: cliente cujo serviço s4 será excluído sozinho.
insert into public.clientes (id, nome, telefone) values
  ('c0000000-0000-0000-0000-000000000001', 'Excluído', '11 90000-0001'),
  ('c0000000-0000-0000-0000-000000000002', 'Outro', '11 90000-0002'),
  ('c0000000-0000-0000-0000-000000000003', 'Terceiro', '11 90000-0003');

insert into public.veiculos (id, cliente_id, placa, deleted_at) values
  ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'AAA1A11', null),
  ('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'AAA2A22', null),
  ('d0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'AAA3A33', '2020-01-01 00:00:00+00'),
  ('d0000000-0000-0000-0000-000000000021', 'c0000000-0000-0000-0000-000000000002', 'BBB1B11', null);

insert into public.servicos (id, cliente_id, veiculo_id, descricao, mao_de_obra_centavos, data_entrada, deleted_at) values
  ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'Freios', 10000, '2026-10-01', null),
  ('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', null, 'Avulso', 5000, '2026-10-01', null),
  ('e0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000001', null, 'Já excluído', 5000, '2026-10-01', '2020-01-01 00:00:00+00'),
  ('e0000000-0000-0000-0000-000000000021', 'c0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000021', 'Outro serviço', 7000, '2026-10-01', null),
  ('e0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000003', null, 'Fica', 3000, '2026-10-01', null),
  ('e0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000003', null, 'Sai', 3000, '2026-10-01', null);

insert into public.pagamentos (id, servico_id, valor_centavos, data, deleted_at) values
  ('f0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 1000, '2026-10-01', null),
  ('f0000000-0000-0000-0000-000000000002', 'e0000000-0000-0000-0000-000000000002', 1000, '2026-10-01', null),
  ('f0000000-0000-0000-0000-000000000003', 'e0000000-0000-0000-0000-000000000002', 1000, '2026-10-01', null),
  ('f0000000-0000-0000-0000-000000000004', 'e0000000-0000-0000-0000-000000000001', 1000, '2026-10-01', '2020-01-01 00:00:00+00'),
  -- pagamento ainda ativo de um serviço já excluído (pode chegar assim via sync)
  ('f0000000-0000-0000-0000-000000000008', 'e0000000-0000-0000-0000-000000000005', 1000, '2026-10-01', null),
  ('f0000000-0000-0000-0000-000000000021', 'e0000000-0000-0000-0000-000000000021', 1000, '2026-10-01', null),
  ('f0000000-0000-0000-0000-000000000005', 'e0000000-0000-0000-0000-000000000003', 1000, '2026-10-01', null),
  ('f0000000-0000-0000-0000-000000000006', 'e0000000-0000-0000-0000-000000000003', 1000, '2026-10-01', null),
  ('f0000000-0000-0000-0000-000000000007', 'e0000000-0000-0000-0000-000000000004', 1000, '2026-10-01', null);

-- C1: excluir o cliente c1 ---------------------------------------------------
update public.clientes set deleted_at = '2026-10-05 10:00:00+00'
 where id = 'c0000000-0000-0000-0000-000000000001';

select results_eq(
  $$ select id, deleted_at from public.veiculos
      where cliente_id = 'c0000000-0000-0000-0000-000000000001' order by id $$,
  $$ values
       ('d0000000-0000-0000-0000-000000000001'::uuid, '2026-10-05 10:00:00+00'::timestamptz),
       ('d0000000-0000-0000-0000-000000000002'::uuid, '2026-10-05 10:00:00+00'::timestamptz),
       ('d0000000-0000-0000-0000-000000000003'::uuid, '2020-01-01 00:00:00+00'::timestamptz) $$,
  'veículos do cliente excluídos (já excluído mantém a data original)'
);
select results_eq(
  $$ select id, deleted_at from public.servicos
      where cliente_id = 'c0000000-0000-0000-0000-000000000001' order by id $$,
  $$ values
       ('e0000000-0000-0000-0000-000000000001'::uuid, '2026-10-05 10:00:00+00'::timestamptz),
       ('e0000000-0000-0000-0000-000000000002'::uuid, '2026-10-05 10:00:00+00'::timestamptz),
       ('e0000000-0000-0000-0000-000000000005'::uuid, '2020-01-01 00:00:00+00'::timestamptz) $$,
  'serviços do cliente excluídos (já excluído mantém a data original)'
);
select results_eq(
  $$ select p.id, p.deleted_at from public.pagamentos p
       join public.servicos s on s.id = p.servico_id
      where s.cliente_id = 'c0000000-0000-0000-0000-000000000001' order by p.id $$,
  $$ values
       ('f0000000-0000-0000-0000-000000000001'::uuid, '2026-10-05 10:00:00+00'::timestamptz),
       ('f0000000-0000-0000-0000-000000000002'::uuid, '2026-10-05 10:00:00+00'::timestamptz),
       ('f0000000-0000-0000-0000-000000000003'::uuid, '2026-10-05 10:00:00+00'::timestamptz),
       ('f0000000-0000-0000-0000-000000000004'::uuid, '2020-01-01 00:00:00+00'::timestamptz),
       ('f0000000-0000-0000-0000-000000000008'::uuid, '2026-10-05 10:00:00+00'::timestamptz) $$,
  'pagamentos dos serviços do cliente excluídos (inclusive de serviço já excluído)'
);

-- C3: outro cliente não é afetado
select is(
  (select count(*) from public.clientes where id <> 'c0000000-0000-0000-0000-000000000001' and deleted_at is not null)
  + (select count(*) from public.veiculos where cliente_id <> 'c0000000-0000-0000-0000-000000000001' and deleted_at is not null)
  + (select count(*) from public.servicos where cliente_id <> 'c0000000-0000-0000-0000-000000000001' and deleted_at is not null)
  + (select count(*) from public.pagamentos p join public.servicos s on s.id = p.servico_id
      where s.cliente_id <> 'c0000000-0000-0000-0000-000000000001' and p.deleted_at is not null),
  0::bigint,
  'registros de outros clientes não são afetados'
);

-- C4: filhos atingidos ganham updated_at novo; os já excluídos não são tocados
select is(
  (select count(*) from (
     select updated_at > created_at as avancou from public.veiculos
      where id in ('d0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000002')
     union all
     select updated_at > created_at from public.servicos
      where id in ('e0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002')
     union all
     select updated_at > created_at from public.pagamentos
      where id in ('f0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002',
                   'f0000000-0000-0000-0000-000000000003', 'f0000000-0000-0000-0000-000000000008')
   ) t where avancou),
  8::bigint,
  'filhos excluídos pela cascata têm updated_at avançado (o sync baixa)'
);
select is(
  (select count(*) from (
     select updated_at = created_at as intacto from public.veiculos where id = 'd0000000-0000-0000-0000-000000000003'
     union all
     select updated_at = created_at from public.servicos where id = 'e0000000-0000-0000-0000-000000000005'
     union all
     select updated_at = created_at from public.pagamentos where id = 'f0000000-0000-0000-0000-000000000004'
   ) t where intacto),
  3::bigint,
  'itens já excluídos não são reescritos pela cascata'
);

-- C2: excluir só o serviço s4 -------------------------------------------------
update public.servicos set deleted_at = '2026-10-05 11:00:00+00'
 where id = 'e0000000-0000-0000-0000-000000000004';

select is(
  (select deleted_at from public.pagamentos where id = 'f0000000-0000-0000-0000-000000000007'),
  '2026-10-05 11:00:00+00'::timestamptz,
  'excluir serviço exclui os pagamentos dele'
);
select is(
  (select count(*) from public.pagamentos
    where id in ('f0000000-0000-0000-0000-000000000005', 'f0000000-0000-0000-0000-000000000006')
      and deleted_at is null),
  2::bigint,
  'pagamentos de outro serviço do mesmo cliente continuam ativos'
);
select ok(
  (select deleted_at is null from public.clientes where id = 'c0000000-0000-0000-0000-000000000003'),
  'excluir serviço não exclui o cliente'
);

-- Escrita obsoleta de exclusão não dispara a cascata ---------------------------
update public.clientes set deleted_at = '2026-10-05 12:00:00+00', updated_at = '2000-01-01 00:00:00+00'
 where id = 'c0000000-0000-0000-0000-000000000002';
select ok(
  (select c.deleted_at is null and v.deleted_at is null
     from public.clientes c join public.veiculos v on v.cliente_id = c.id
    where c.id = 'c0000000-0000-0000-0000-000000000002'),
  'exclusão obsoleta (updated_at antigo) é descartada e não cascateia'
);

select * from finish();
rollback;
