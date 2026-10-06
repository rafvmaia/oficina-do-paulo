-- View servicos_resumo: total pago, falta e status de pagamento derivado.
-- (Casos S1–S7 de docs/qa/fase-02.md). Roda como usuário autenticado.
begin;
create extension if not exists pgtap with schema extensions;

select plan(12);

insert into auth.users (id, email) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'conta-a@teste.local');

set local role authenticated;
set local request.jwt.claims to '{"sub": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "role": "authenticated"}';

insert into public.clientes (id, nome, telefone) values
  ('c0000000-0000-0000-0000-000000000001', 'Maria', '11 99999-0001');

insert into public.servicos (id, cliente_id, descricao, mao_de_obra_centavos, pecas_centavos, data_entrada) values
  ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Sem pagamento', 8000, 2000, '2026-10-01'),
  ('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'Parcial', 10000, 0, '2026-10-01'),
  ('e0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'Pago exato', 10000, 0, '2026-10-01'),
  ('e0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000001', 'Pago com sobra', 10000, 0, '2026-10-01'),
  ('e0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000001', 'Total zero', 0, 0, '2026-10-01'),
  ('e0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000001', 'Pagamento excluído', 10000, 0, '2026-10-01'),
  ('e0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000001', 'Valores altos', 9000000000000, 0, '2026-10-01'),
  ('e0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000001', 'Só excluído', 5000, 0, '2026-10-01');

insert into public.pagamentos (servico_id, valor_centavos, data, forma, deleted_at) values
  ('e0000000-0000-0000-0000-000000000002', 3000, '2026-10-02', 'PIX', null),
  ('e0000000-0000-0000-0000-000000000003', 6000, '2026-10-02', 'DINHEIRO', null),
  ('e0000000-0000-0000-0000-000000000003', 4000, '2026-10-03', 'PIX', null),
  ('e0000000-0000-0000-0000-000000000004', 15000, '2026-10-02', 'CREDITO', null),
  ('e0000000-0000-0000-0000-000000000006', 10000, '2026-10-02', 'PIX', '2026-10-03 10:00:00+00'),
  ('e0000000-0000-0000-0000-000000000006', 2000, '2026-10-02', 'DINHEIRO', null),
  ('e0000000-0000-0000-0000-000000000007', 4000000000000, '2026-10-02', 'TRANSFERENCIA', null),
  ('e0000000-0000-0000-0000-000000000007', 4000000000000, '2026-10-03', 'TRANSFERENCIA', null),
  ('e0000000-0000-0000-0000-000000000008', 5000, '2026-10-02', 'PIX', '2026-10-03 10:00:00+00');

-- Tipos das colunas derivadas
select col_type_is('public', 'servicos_resumo', 'total_pago_centavos', 'bigint', 'total_pago_centavos é bigint');
select col_type_is('public', 'servicos_resumo', 'falta_centavos', 'bigint', 'falta_centavos é bigint');
select col_type_is('public', 'servicos_resumo', 'status_pagamento', 'text', 'status_pagamento é text');

-- S1..S7
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000001' $$,
  $$ values (0::bigint, 10000::bigint, 'PENDENTE'::text) $$,
  'sem pagamentos: PENDENTE e falta = total'
);
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000002' $$,
  $$ values (3000::bigint, 7000::bigint, 'PARCIAL'::text) $$,
  'pagamento parcial: PARCIAL e falta correta'
);
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000003' $$,
  $$ values (10000::bigint, 0::bigint, 'PAGO'::text) $$,
  'soma exata (dois pagamentos): PAGO e falta 0'
);
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000004' $$,
  $$ values (15000::bigint, 0::bigint, 'PAGO'::text) $$,
  'pago com sobra: PAGO e falta 0 (nunca negativa)'
);
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000005' $$,
  $$ values (0::bigint, 0::bigint, 'PAGO'::text) $$,
  'total 0: PAGO'
);
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000006' $$,
  $$ values (2000::bigint, 8000::bigint, 'PARCIAL'::text) $$,
  'pagamento excluído logicamente é ignorado na soma'
);
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000007' $$,
  $$ values (8000000000000::bigint, 1000000000000::bigint, 'PARCIAL'::text) $$,
  'valores altos (bigint) somados sem perda'
);
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000008' $$,
  $$ values (0::bigint, 5000::bigint, 'PENDENTE'::text) $$,
  'único pagamento excluído: volta a PENDENTE'
);

-- Excluir logicamente um pagamento muda o status na hora
update public.pagamentos set deleted_at = '2026-10-04 10:00:00+00'
 where servico_id = 'e0000000-0000-0000-0000-000000000002';
select results_eq(
  $$ select total_pago_centavos, falta_centavos, status_pagamento from public.servicos_resumo
      where id = 'e0000000-0000-0000-0000-000000000002' $$,
  $$ values (0::bigint, 10000::bigint, 'PENDENTE'::text) $$,
  'excluir o pagamento parcial volta o serviço para PENDENTE'
);

select * from finish();
rollback;
