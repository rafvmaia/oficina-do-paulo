-- Estrutura do schema: tabelas, colunas, tipos, FKs, índices, RLS, políticas,
-- privilégios e a view servicos_resumo. (Casos E1–E7 de docs/qa/fase-02.md)
begin;
create extension if not exists pgtap with schema extensions;

select plan(48);

-- E1: tabelas e view ----------------------------------------------------------
select has_table('public', 'clientes', 'tabela clientes existe');
select has_table('public', 'veiculos', 'tabela veiculos existe');
select has_table('public', 'servicos', 'tabela servicos existe');
select has_table('public', 'pagamentos', 'tabela pagamentos existe');
select has_view('public', 'servicos_resumo', 'view servicos_resumo existe');

-- E2/E3: colunas, tipos e obrigatoriedade -------------------------------------
select results_eq(
  $$ select column_name::text collate "default", data_type::text collate "default", is_nullable::text collate "default"
       from information_schema.columns
      where table_schema = 'public' and table_name = 'clientes'
      order by column_name::text collate "C" $$,
  $$ select * from (values
       ('created_at', 'timestamp with time zone', 'NO'),
       ('deleted_at', 'timestamp with time zone', 'YES'),
       ('documento', 'text', 'YES'),
       ('endereco', 'text', 'YES'),
       ('id', 'uuid', 'NO'),
       ('nome', 'text', 'NO'),
       ('observacoes', 'text', 'YES'),
       ('owner_id', 'uuid', 'NO'),
       ('telefone', 'text', 'NO'),
       ('updated_at', 'timestamp with time zone', 'NO')
     ) v(c, t, n) order by c collate "C" $$,
  'clientes: colunas, tipos e obrigatoriedade'
);

select results_eq(
  $$ select column_name::text collate "default", data_type::text collate "default", is_nullable::text collate "default"
       from information_schema.columns
      where table_schema = 'public' and table_name = 'veiculos'
      order by column_name::text collate "C" $$,
  $$ select * from (values
       ('ano', 'integer', 'YES'),
       ('cliente_id', 'uuid', 'NO'),
       ('cor', 'text', 'YES'),
       ('created_at', 'timestamp with time zone', 'NO'),
       ('deleted_at', 'timestamp with time zone', 'YES'),
       ('id', 'uuid', 'NO'),
       ('km', 'integer', 'YES'),
       ('marca', 'text', 'YES'),
       ('modelo', 'text', 'YES'),
       ('owner_id', 'uuid', 'NO'),
       ('placa', 'text', 'NO'),
       ('updated_at', 'timestamp with time zone', 'NO')
     ) v(c, t, n) order by c collate "C" $$,
  'veiculos: colunas, tipos e obrigatoriedade'
);

select results_eq(
  $$ select column_name::text collate "default", data_type::text collate "default", is_nullable::text collate "default"
       from information_schema.columns
      where table_schema = 'public' and table_name = 'servicos'
      order by column_name::text collate "C" $$,
  $$ select * from (values
       ('cliente_id', 'uuid', 'NO'),
       ('created_at', 'timestamp with time zone', 'NO'),
       ('data_conclusao', 'date', 'YES'),
       ('data_entrada', 'date', 'NO'),
       ('deleted_at', 'timestamp with time zone', 'YES'),
       ('descricao', 'text', 'NO'),
       ('id', 'uuid', 'NO'),
       ('mao_de_obra_centavos', 'bigint', 'NO'),
       ('observacoes', 'text', 'YES'),
       ('owner_id', 'uuid', 'NO'),
       ('pecas', 'text', 'YES'),
       ('pecas_centavos', 'bigint', 'NO'),
       ('status_servico', 'text', 'NO'),
       ('total_centavos', 'bigint', 'NO'),
       ('updated_at', 'timestamp with time zone', 'NO'),
       ('veiculo_id', 'uuid', 'YES')
     ) v(c, t, n) order by c collate "C" $$,
  'servicos: colunas, tipos e obrigatoriedade'
);

select results_eq(
  $$ select column_name::text collate "default", data_type::text collate "default", is_nullable::text collate "default"
       from information_schema.columns
      where table_schema = 'public' and table_name = 'pagamentos'
      order by column_name::text collate "C" $$,
  $$ select * from (values
       ('created_at', 'timestamp with time zone', 'NO'),
       ('data', 'date', 'NO'),
       ('deleted_at', 'timestamp with time zone', 'YES'),
       ('forma', 'text', 'NO'),
       ('id', 'uuid', 'NO'),
       ('observacao', 'text', 'YES'),
       ('owner_id', 'uuid', 'NO'),
       ('servico_id', 'uuid', 'NO'),
       ('updated_at', 'timestamp with time zone', 'NO'),
       ('valor_centavos', 'bigint', 'NO')
     ) v(c, t, n) order by c collate "C" $$,
  'pagamentos: colunas, tipos e obrigatoriedade'
);

select results_eq(
  $$ select table_name::text collate "default", column_default::text collate "default"
       from information_schema.columns
      where table_schema = 'public' and column_name = 'owner_id'
        and table_name in ('clientes', 'veiculos', 'servicos', 'pagamentos')
      order by table_name::text collate "C" $$,
  $$ select * from (values
       ('clientes', 'auth.uid()'),
       ('pagamentos', 'auth.uid()'),
       ('servicos', 'auth.uid()'),
       ('veiculos', 'auth.uid()')
     ) v(t, d) order by t collate "C" $$,
  'owner_id tem padrão auth.uid() em todas as tabelas'
);

-- E4: chaves estrangeiras -----------------------------------------------------
select fk_ok('public', 'clientes', 'owner_id', 'auth', 'users', 'id', 'clientes.owner_id -> auth.users');
select fk_ok('public', 'veiculos', 'owner_id', 'auth', 'users', 'id', 'veiculos.owner_id -> auth.users');
select fk_ok('public', 'servicos', 'owner_id', 'auth', 'users', 'id', 'servicos.owner_id -> auth.users');
select fk_ok('public', 'pagamentos', 'owner_id', 'auth', 'users', 'id', 'pagamentos.owner_id -> auth.users');
select fk_ok(
  'public', 'veiculos', array['cliente_id', 'owner_id']::name[],
  'public', 'clientes', array['id', 'owner_id']::name[],
  'veiculos -> clientes (mesmo dono)'
);
select fk_ok(
  'public', 'servicos', array['cliente_id', 'owner_id']::name[],
  'public', 'clientes', array['id', 'owner_id']::name[],
  'servicos -> clientes (mesmo dono)'
);
select fk_ok(
  'public', 'servicos', array['veiculo_id', 'owner_id']::name[],
  'public', 'veiculos', array['id', 'owner_id']::name[],
  'servicos -> veiculos (mesmo dono)'
);
select fk_ok(
  'public', 'pagamentos', array['servico_id', 'owner_id']::name[],
  'public', 'servicos', array['id', 'owner_id']::name[],
  'pagamentos -> servicos (mesmo dono)'
);

-- E5: índices -----------------------------------------------------------------
select has_index('public', 'clientes', 'clientes_owner_updated_idx', array['owner_id', 'updated_at']::name[], 'índice clientes(owner_id, updated_at)');
select has_index('public', 'clientes', 'clientes_nome_idx', array['nome']::name[], 'índice clientes(nome)');
select has_index('public', 'veiculos', 'veiculos_owner_updated_idx', array['owner_id', 'updated_at']::name[], 'índice veiculos(owner_id, updated_at)');
select has_index('public', 'veiculos', 'veiculos_cliente_idx', array['cliente_id']::name[], 'índice veiculos(cliente_id)');
select has_index('public', 'veiculos', 'veiculos_placa_idx', array['owner_id', 'placa']::name[], 'índice veiculos(owner_id, placa)');
select has_index('public', 'servicos', 'servicos_owner_updated_idx', array['owner_id', 'updated_at']::name[], 'índice servicos(owner_id, updated_at)');
select has_index('public', 'servicos', 'servicos_cliente_idx', array['cliente_id']::name[], 'índice servicos(cliente_id)');
select has_index('public', 'servicos', 'servicos_veiculo_idx', array['veiculo_id']::name[], 'índice servicos(veiculo_id)');
select has_index('public', 'pagamentos', 'pagamentos_owner_updated_idx', array['owner_id', 'updated_at']::name[], 'índice pagamentos(owner_id, updated_at)');
select has_index('public', 'pagamentos', 'pagamentos_servico_idx', array['servico_id']::name[], 'índice pagamentos(servico_id)');

-- E6: RLS e políticas ---------------------------------------------------------
select ok((select relrowsecurity from pg_class where oid = 'public.clientes'::regclass), 'RLS ativo em clientes');
select ok((select relrowsecurity from pg_class where oid = 'public.veiculos'::regclass), 'RLS ativo em veiculos');
select ok((select relrowsecurity from pg_class where oid = 'public.servicos'::regclass), 'RLS ativo em servicos');
select ok((select relrowsecurity from pg_class where oid = 'public.pagamentos'::regclass), 'RLS ativo em pagamentos');

select policies_are('public', 'clientes', array['clientes_select', 'clientes_insert', 'clientes_update']::name[], 'clientes: só select/insert/update');
select policies_are('public', 'veiculos', array['veiculos_select', 'veiculos_insert', 'veiculos_update']::name[], 'veiculos: só select/insert/update');
select policies_are('public', 'servicos', array['servicos_select', 'servicos_insert', 'servicos_update']::name[], 'servicos: só select/insert/update');
select policies_are('public', 'pagamentos', array['pagamentos_select', 'pagamentos_insert', 'pagamentos_update']::name[], 'pagamentos: só select/insert/update');

select is(
  (select count(*) from pg_policies
    where schemaname = 'public'
      and tablename in ('clientes', 'veiculos', 'servicos', 'pagamentos')
      and cmd in ('DELETE', 'ALL')),
  0::bigint,
  'nenhuma política de DELETE (nem ALL)'
);

-- E7: view com security_invoker ----------------------------------------------
select ok(
  (select 'security_invoker=true' = any(reloptions) from pg_class where oid = 'public.servicos_resumo'::regclass),
  'servicos_resumo usa security_invoker = true'
);

-- Privilégios: anônimo sem acesso; autenticado sem DELETE/TRUNCATE -----------
select table_privs_are('public', 'clientes', 'anon', array[]::name[], 'anon sem privilégios em clientes');
select table_privs_are('public', 'veiculos', 'anon', array[]::name[], 'anon sem privilégios em veiculos');
select table_privs_are('public', 'servicos', 'anon', array[]::name[], 'anon sem privilégios em servicos');
select table_privs_are('public', 'pagamentos', 'anon', array[]::name[], 'anon sem privilégios em pagamentos');
select table_privs_are('public', 'servicos_resumo', 'anon', array[]::name[], 'anon sem privilégios em servicos_resumo');
select table_privs_are('public', 'clientes', 'authenticated', array['SELECT', 'INSERT', 'UPDATE']::name[], 'authenticated: select/insert/update em clientes');
select table_privs_are('public', 'veiculos', 'authenticated', array['SELECT', 'INSERT', 'UPDATE']::name[], 'authenticated: select/insert/update em veiculos');
select table_privs_are('public', 'servicos', 'authenticated', array['SELECT', 'INSERT', 'UPDATE']::name[], 'authenticated: select/insert/update em servicos');
select table_privs_are('public', 'pagamentos', 'authenticated', array['SELECT', 'INSERT', 'UPDATE']::name[], 'authenticated: select/insert/update em pagamentos');
select table_privs_are('public', 'servicos_resumo', 'authenticated', array['SELECT']::name[], 'authenticated: só select em servicos_resumo');

select * from finish();
rollback;
