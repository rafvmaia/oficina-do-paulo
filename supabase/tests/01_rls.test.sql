-- Isolamento por RLS entre duas contas (A e B), anônimo e delete físico.
-- (Casos R1–R8 de docs/qa/fase-02.md)
begin;
create extension if not exists pgtap with schema extensions;

select plan(33);

-- Preparação (como postgres) -------------------------------------------------
insert into auth.users (id, email) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'conta-a@teste.local'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'conta-b@teste.local');

insert into public.clientes (id, owner_id, nome, telefone) values
  ('c0000000-0000-0000-0000-00000000000a', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Cliente A', '11 99999-0001'),
  ('c0000000-0000-0000-0000-0000000000a2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Cliente A sem filhos', '11 99999-0002'),
  ('c0000000-0000-0000-0000-00000000000b', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Cliente B', '21 99999-0001');
insert into public.veiculos (id, owner_id, cliente_id, placa) values
  ('d0000000-0000-0000-0000-00000000000a', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'c0000000-0000-0000-0000-00000000000a', 'AAA1A11'),
  ('d0000000-0000-0000-0000-00000000000b', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'c0000000-0000-0000-0000-00000000000b', 'BBB2B22');
insert into public.servicos (id, owner_id, cliente_id, veiculo_id, descricao, mao_de_obra_centavos, data_entrada) values
  ('e0000000-0000-0000-0000-00000000000a', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'c0000000-0000-0000-0000-00000000000a', 'd0000000-0000-0000-0000-00000000000a', 'Serviço A', 10000, '2026-10-01'),
  ('e0000000-0000-0000-0000-00000000000b', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'c0000000-0000-0000-0000-00000000000b', 'd0000000-0000-0000-0000-00000000000b', 'Serviço B', 20000, '2026-10-01');
insert into public.pagamentos (id, owner_id, servico_id, valor_centavos, data, forma) values
  ('f0000000-0000-0000-0000-00000000000a', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'e0000000-0000-0000-0000-00000000000a', 5000, '2026-10-01', 'PIX'),
  ('f0000000-0000-0000-0000-00000000000b', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'e0000000-0000-0000-0000-00000000000b', 5000, '2026-10-01', 'PIX');

-- Conta A ---------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims to '{"sub": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "role": "authenticated"}';

-- R1: A só vê o que é dele
select results_eq(
  'select id from public.clientes order by id',
  array['c0000000-0000-0000-0000-00000000000a', 'c0000000-0000-0000-0000-0000000000a2']::uuid[],
  'A só vê os próprios clientes'
);
select results_eq('select id from public.veiculos', array['d0000000-0000-0000-0000-00000000000a']::uuid[], 'A só vê os próprios veículos');
select results_eq('select id from public.servicos', array['e0000000-0000-0000-0000-00000000000a']::uuid[], 'A só vê os próprios serviços');
select results_eq('select id from public.pagamentos', array['f0000000-0000-0000-0000-00000000000a']::uuid[], 'A só vê os próprios pagamentos');
select results_eq('select id from public.servicos_resumo', array['e0000000-0000-0000-0000-00000000000a']::uuid[], 'A só vê os próprios serviços na view');

-- R2: A não altera registros de B (0 linhas afetadas)
select is_empty(
  $$ update public.clientes set nome = 'Invadido' where id = 'c0000000-0000-0000-0000-00000000000b' returning id $$,
  'A não altera cliente de B'
);
select is_empty(
  $$ update public.veiculos set placa = 'XXX0X00' where id = 'd0000000-0000-0000-0000-00000000000b' returning id $$,
  'A não altera veículo de B'
);
select is_empty(
  $$ update public.servicos set descricao = 'Invadido' where id = 'e0000000-0000-0000-0000-00000000000b' returning id $$,
  'A não altera serviço de B'
);
select is_empty(
  $$ update public.pagamentos set valor_centavos = 1 where id = 'f0000000-0000-0000-0000-00000000000b' returning id $$,
  'A não altera pagamento de B'
);

-- R3: A não insere com owner_id de B
select throws_ok(
  $$ insert into public.clientes (owner_id, nome, telefone)
     values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Intruso', '11 0000-0000') $$,
  '42501', null, 'A não insere cliente com owner_id de B'
);
select throws_ok(
  $$ insert into public.veiculos (owner_id, cliente_id, placa)
     values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'c0000000-0000-0000-0000-00000000000b', 'INT0R00') $$,
  '42501', null, 'A não insere veículo com owner_id de B'
);
select throws_ok(
  $$ insert into public.servicos (owner_id, cliente_id, descricao, data_entrada)
     values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'c0000000-0000-0000-0000-00000000000b', 'Intruso', '2026-10-01') $$,
  '42501', null, 'A não insere serviço com owner_id de B'
);
select throws_ok(
  $$ insert into public.pagamentos (owner_id, servico_id, valor_centavos, data)
     values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'e0000000-0000-0000-0000-00000000000b', 100, '2026-10-01') $$,
  '42501', null, 'A não insere pagamento com owner_id de B'
);

-- R4: A não transfere um registro próprio para B
select throws_ok(
  $$ update public.clientes set owner_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
      where id = 'c0000000-0000-0000-0000-0000000000a2' $$,
  '42501', null, 'A não muda o owner_id de um cliente para B'
);

-- R5: A não pendura registros em dados de B (FK composta com owner_id)
select throws_ok(
  $$ insert into public.veiculos (cliente_id, placa)
     values ('c0000000-0000-0000-0000-00000000000b', 'AAA9A99') $$,
  '23503', null, 'A não cria veículo em cliente de B'
);
select throws_ok(
  $$ insert into public.servicos (cliente_id, veiculo_id, descricao, data_entrada)
     values ('c0000000-0000-0000-0000-00000000000a', 'd0000000-0000-0000-0000-00000000000b', 'Troca de óleo', '2026-10-01') $$,
  '23503', null, 'A não cria serviço com veículo de B'
);
select throws_ok(
  $$ insert into public.pagamentos (servico_id, valor_centavos, data)
     values ('e0000000-0000-0000-0000-00000000000b', 100, '2026-10-01') $$,
  '23503', null, 'A não lança pagamento em serviço de B'
);

-- R8: insert sem owner_id grava auth.uid()
select lives_ok(
  $$ insert into public.clientes (id, nome, telefone)
     values ('c0000000-0000-0000-0000-0000000000a3', 'Cliente novo', '11 98888-7777') $$,
  'A insere cliente sem informar owner_id'
);
select is(
  (select owner_id from public.clientes where id = 'c0000000-0000-0000-0000-0000000000a3'),
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
  'owner_id preenchido com auth.uid()'
);

-- R7: delete físico e truncate negados
select throws_ok($$ delete from public.clientes where id = 'c0000000-0000-0000-0000-00000000000a' $$, '42501', null, 'delete físico negado em clientes');
select throws_ok($$ delete from public.veiculos where id = 'd0000000-0000-0000-0000-00000000000a' $$, '42501', null, 'delete físico negado em veiculos');
select throws_ok($$ delete from public.servicos where id = 'e0000000-0000-0000-0000-00000000000a' $$, '42501', null, 'delete físico negado em servicos');
select throws_ok($$ delete from public.pagamentos where id = 'f0000000-0000-0000-0000-00000000000a' $$, '42501', null, 'delete físico negado em pagamentos');
select throws_ok($$ truncate public.pagamentos $$, '42501', null, 'truncate negado');

-- Conta B ---------------------------------------------------------------------
set local request.jwt.claims to '{"sub": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb", "role": "authenticated"}';
select results_eq('select id from public.clientes', array['c0000000-0000-0000-0000-00000000000b']::uuid[], 'B só vê os próprios clientes');

-- R6: anônimo -----------------------------------------------------------------
reset role;
set local role anon;
set local request.jwt.claims to '{"role": "anon"}';

select throws_ok('select * from public.clientes', '42501', null, 'anônimo não lê clientes');
select throws_ok('select * from public.veiculos', '42501', null, 'anônimo não lê veículos');
select throws_ok('select * from public.servicos', '42501', null, 'anônimo não lê serviços');
select throws_ok('select * from public.pagamentos', '42501', null, 'anônimo não lê pagamentos');
select throws_ok('select * from public.servicos_resumo', '42501', null, 'anônimo não lê servicos_resumo');
select throws_ok(
  $$ insert into public.clientes (owner_id, nome, telefone)
     values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Anônimo', '0') $$,
  '42501', null, 'anônimo não insere'
);

-- Conferência final (como postgres) ------------------------------------------
reset role;

select is(
  (select c.nome || '|' || v.placa || '|' || s.descricao || '|' || p.valor_centavos
     from public.clientes c
     join public.veiculos v on v.cliente_id = c.id
     join public.servicos s on s.cliente_id = c.id
     join public.pagamentos p on p.servico_id = s.id
    where c.id = 'c0000000-0000-0000-0000-00000000000b'),
  'Cliente B|BBB2B22|Serviço B|5000',
  'dados de B continuam intactos'
);
select is(
  (select count(*) from public.clientes where id = 'c0000000-0000-0000-0000-00000000000a')
  + (select count(*) from public.veiculos where id = 'd0000000-0000-0000-0000-00000000000a')
  + (select count(*) from public.servicos where id = 'e0000000-0000-0000-0000-00000000000a')
  + (select count(*) from public.pagamentos where id = 'f0000000-0000-0000-0000-00000000000a'),
  4::bigint,
  'registros de A continuam existindo após tentativas de delete'
);

select * from finish();
rollback;
