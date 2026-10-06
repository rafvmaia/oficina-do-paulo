-- Regras de negócio no banco: total_centavos, constraints e updated_at do sync.
-- (Casos V1–V5 e U1–U4 de docs/qa/fase-02.md). Roda como usuário autenticado.
begin;
create extension if not exists pgtap with schema extensions;

select plan(33);

insert into auth.users (id, email) values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'conta-a@teste.local');

set local role authenticated;
set local request.jwt.claims to '{"sub": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "role": "authenticated"}';

insert into public.clientes (id, nome, telefone) values
  ('c0000000-0000-0000-0000-000000000001', 'Maria', '11 99999-0001'),
  ('c0000000-0000-0000-0000-000000000002', 'João', '11 99999-0002');
insert into public.veiculos (id, cliente_id, placa) values
  ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'ABC1D23');
insert into public.servicos (id, cliente_id, descricao, mao_de_obra_centavos, data_entrada) values
  ('e0000000-0000-0000-0000-000000000099', 'c0000000-0000-0000-0000-000000000001', 'Base para pagamentos', 50000, '2026-10-01');
insert into public.pagamentos (id, servico_id, valor_centavos, data) values
  ('f0000000-0000-0000-0000-000000000099', 'e0000000-0000-0000-0000-000000000099', 1000, '2026-10-01');

-- V1: total_centavos calculado -------------------------------------------------
insert into public.servicos (id, cliente_id, descricao, mao_de_obra_centavos, pecas_centavos, total_centavos, data_entrada)
values ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Revisão', 10000, 2550, 1, '2026-10-01');

select is(
  (select total_centavos from public.servicos where id = 'e0000000-0000-0000-0000-000000000001'),
  12550::bigint,
  'insert: total = mão de obra + peças (ignora total enviado)'
);

update public.servicos set pecas_centavos = 5000 where id = 'e0000000-0000-0000-0000-000000000001';
select is(
  (select total_centavos from public.servicos where id = 'e0000000-0000-0000-0000-000000000001'),
  15000::bigint,
  'update: total recalculado ao mudar peças'
);

update public.servicos set total_centavos = 999 where id = 'e0000000-0000-0000-0000-000000000001';
select is(
  (select total_centavos from public.servicos where id = 'e0000000-0000-0000-0000-000000000001'),
  15000::bigint,
  'update: total enviado à mão é ignorado'
);

-- V2: centavos nulos viram 0; total 0 permitido ------------------------------
insert into public.servicos (id, cliente_id, descricao, mao_de_obra_centavos, pecas_centavos, data_entrada)
values ('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'Cortesia', null, null, '2026-10-01');
select is(
  (select mao_de_obra_centavos || '|' || pecas_centavos || '|' || total_centavos
     from public.servicos where id = 'e0000000-0000-0000-0000-000000000002'),
  '0|0|0',
  'centavos nulos viram 0 e total 0 é aceito'
);

-- V3: valores inválidos --------------------------------------------------------
select throws_ok(
  $$ insert into public.pagamentos (servico_id, valor_centavos, data)
     values ('e0000000-0000-0000-0000-000000000099', 0, '2026-10-01') $$,
  '23514', null, 'pagamento com valor 0 é rejeitado'
);
select throws_ok(
  $$ insert into public.pagamentos (servico_id, valor_centavos, data)
     values ('e0000000-0000-0000-0000-000000000099', -100, '2026-10-01') $$,
  '23514', null, 'pagamento com valor negativo é rejeitado'
);
select throws_ok(
  $$ insert into public.servicos (cliente_id, descricao, mao_de_obra_centavos, data_entrada)
     values ('c0000000-0000-0000-0000-000000000001', 'Negativo', -1, '2026-10-01') $$,
  '23514', null, 'mão de obra negativa é rejeitada'
);
select throws_ok(
  $$ insert into public.servicos (cliente_id, descricao, pecas_centavos, data_entrada)
     values ('c0000000-0000-0000-0000-000000000001', 'Negativo', -1, '2026-10-01') $$,
  '23514', null, 'peças negativas são rejeitadas'
);
select lives_ok(
  $$ insert into public.pagamentos (servico_id, valor_centavos, data)
     values ('e0000000-0000-0000-0000-000000000099', 1, '2026-10-01') $$,
  'pagamento de 1 centavo é aceito'
);

-- V4: enums ------------------------------------------------------------------
select throws_ok(
  $$ insert into public.servicos (cliente_id, descricao, status_servico, data_entrada)
     values ('c0000000-0000-0000-0000-000000000001', 'Status inválido', 'CANCELADO', '2026-10-01') $$,
  '23514', null, 'status_servico inválido é rejeitado'
);
select throws_ok(
  $$ insert into public.pagamentos (servico_id, valor_centavos, data, forma)
     values ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'CHEQUE') $$,
  '23514', null, 'forma de pagamento inválida é rejeitada'
);
select throws_ok(
  $$ insert into public.pagamentos (servico_id, valor_centavos, data, forma)
     values ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'pix') $$,
  '23514', null, 'forma de pagamento em minúsculas é rejeitada'
);
select lives_ok(
  $$ insert into public.servicos (cliente_id, descricao, status_servico, data_entrada) values
       ('c0000000-0000-0000-0000-000000000001', 'S1', 'ORCAMENTO', '2026-10-01'),
       ('c0000000-0000-0000-0000-000000000001', 'S2', 'EM_ANDAMENTO', '2026-10-01'),
       ('c0000000-0000-0000-0000-000000000001', 'S3', 'CONCLUIDO', '2026-10-01'),
       ('c0000000-0000-0000-0000-000000000001', 'S4', 'ENTREGUE', '2026-10-01') $$,
  'todos os status_servico válidos são aceitos'
);
select lives_ok(
  $$ insert into public.pagamentos (servico_id, valor_centavos, data, forma) values
       ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'DINHEIRO'),
       ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'PIX'),
       ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'DEBITO'),
       ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'CREDITO'),
       ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'TRANSFERENCIA'),
       ('e0000000-0000-0000-0000-000000000099', 100, '2026-10-01', 'OUTRO') $$,
  'todas as formas de pagamento válidas são aceitas'
);

-- V5: campos obrigatórios e faixas --------------------------------------------
select throws_ok(
  $$ insert into public.clientes (nome, telefone) values ('   ', '11 90000-0000') $$,
  '23514', null, 'nome em branco é rejeitado'
);
select throws_ok(
  $$ insert into public.clientes (nome, telefone) values (null, '11 90000-0000') $$,
  '23502', null, 'nome nulo é rejeitado'
);
select throws_ok(
  $$ insert into public.clientes (nome, telefone) values ('Pedro', '') $$,
  '23514', null, 'telefone vazio é rejeitado'
);
select throws_ok(
  $$ insert into public.veiculos (cliente_id, placa) values ('c0000000-0000-0000-0000-000000000001', '') $$,
  '23514', null, 'placa vazia é rejeitada'
);
select throws_ok(
  $$ insert into public.servicos (cliente_id, descricao, data_entrada)
     values ('c0000000-0000-0000-0000-000000000001', ' ', '2026-10-01') $$,
  '23514', null, 'descrição em branco é rejeitada'
);
select throws_ok(
  $$ insert into public.veiculos (cliente_id, placa, ano) values ('c0000000-0000-0000-0000-000000000001', 'ANO0A00', 1800) $$,
  '23514', null, 'ano fora da faixa é rejeitado'
);
select throws_ok(
  $$ insert into public.veiculos (cliente_id, placa, km) values ('c0000000-0000-0000-0000-000000000001', 'KMN0K00', -1) $$,
  '23514', null, 'km negativo é rejeitado'
);

-- U1: update sem updated_at -> servidor avança (sempre crescente) -------------
-- (now() é fixo dentro da transação; o trigger garante +1 ms a cada alteração)
update public.clientes set nome = 'Maria Silva' where id = 'c0000000-0000-0000-0000-000000000001';
select is(
  (select updated_at from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  now() + interval '1 millisecond',
  'update sem updated_at avança updated_at'
);
update public.clientes set nome = 'Maria S.' where id = 'c0000000-0000-0000-0000-000000000001';
select is(
  (select updated_at from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  now() + interval '2 milliseconds',
  'segundo update avança de novo (nunca repete)'
);

-- U2: app envia updated_at mais novo -> valor do app é mantido ----------------
update public.clientes
   set nome = 'Maria App', updated_at = '2030-01-01 12:00:00+00'
 where id = 'c0000000-0000-0000-0000-000000000001';
select is(
  (select updated_at from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  '2030-01-01 12:00:00+00'::timestamptz,
  'updated_at mais novo enviado pelo app é mantido'
);
select is(
  (select nome from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  'Maria App',
  'alteração com updated_at mais novo é aplicada'
);

-- U3: app envia updated_at mais antigo -> escrita obsoleta descartada ---------
update public.clientes
   set nome = 'Maria Velha', updated_at = '2029-01-01 12:00:00+00'
 where id = 'c0000000-0000-0000-0000-000000000001';
select is(
  (select updated_at from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  '2030-01-01 12:00:00+00'::timestamptz,
  'updated_at mais antigo não sobrescreve o mais novo'
);
select is(
  (select nome from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  'Maria App',
  'dados da escrita obsoleta são descartados'
);

update public.clientes
   set nome = 'Maria Igual', updated_at = '2030-01-01 12:00:00+00'
 where id = 'c0000000-0000-0000-0000-000000000001';
select ok(
  (select nome = 'Maria Igual' and updated_at = '2030-01-01 12:00:00.001+00'::timestamptz
     from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  'mesmo updated_at: alteração aplicada e updated_at avança 1 ms'
);

-- U4: upsert (como o sync faz) ------------------------------------------------
insert into public.clientes (id, nome, telefone, updated_at)
values ('c0000000-0000-0000-0000-000000000001', 'Upsert velho', '11 90000-0000', '2028-01-01 00:00:00+00')
on conflict (id) do update
   set nome = excluded.nome, telefone = excluded.telefone, updated_at = excluded.updated_at;
select is(
  (select nome from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  'Maria Igual',
  'upsert com updated_at antigo é descartado'
);

insert into public.clientes (id, nome, telefone, updated_at)
values ('c0000000-0000-0000-0000-000000000001', 'Upsert novo', '11 90000-0000', '2031-01-01 00:00:00+00')
on conflict (id) do update
   set nome = excluded.nome, telefone = excluded.telefone, updated_at = excluded.updated_at;
select ok(
  (select nome = 'Upsert novo' and updated_at = '2031-01-01 00:00:00+00'::timestamptz
     from public.clientes where id = 'c0000000-0000-0000-0000-000000000001'),
  'upsert com updated_at novo é aplicado'
);

-- Escrita obsoleta também é descartada nas demais tabelas ---------------------
update public.veiculos set placa = 'OLD0O00', updated_at = '2000-01-01 00:00:00+00'
 where id = 'd0000000-0000-0000-0000-000000000001';
select is(
  (select placa from public.veiculos where id = 'd0000000-0000-0000-0000-000000000001'),
  'ABC1D23',
  'veiculos: escrita obsoleta descartada'
);
update public.servicos set descricao = 'Velho', updated_at = '2000-01-01 00:00:00+00'
 where id = 'e0000000-0000-0000-0000-000000000099';
select is(
  (select descricao from public.servicos where id = 'e0000000-0000-0000-0000-000000000099'),
  'Base para pagamentos',
  'servicos: escrita obsoleta descartada'
);
update public.pagamentos set valor_centavos = 7, updated_at = '2000-01-01 00:00:00+00'
 where id = 'f0000000-0000-0000-0000-000000000099';
select is(
  (select valor_centavos from public.pagamentos where id = 'f0000000-0000-0000-0000-000000000099'),
  1000::bigint,
  'pagamentos: escrita obsoleta descartada'
);

select * from finish();
rollback;
