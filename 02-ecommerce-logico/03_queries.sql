use ecommerce;

-- eletrônicos acima de R$ 500
select nome, valor
from produto
where categoria = 'Eletrônico' and valor > 500;

-- pedidos de outubro ainda ativos
select id_pedido, id_cliente, status, data_pedido
from pedido
where data_pedido between '2026-10-01' and '2026-10-31'
  and status <> 'Cancelado';

-- nome completo e idade dos clientes PF (atributos derivados)
select concat(nome, ' ', sobrenome) as nome_completo,
       timestampdiff(year, data_nascimento, curdate()) as idade
from cliente_pf
order by idade desc;

-- subtotal, frete e total de cada pedido, do maior para o menor
select id_pedido, subtotal, frete, total
from vw_pedido_total
order by total desc;

-- quantos pedidos cada cliente fez (inclui quem nunca comprou)
select c.nome, c.tipo, count(p.id_pedido) as qtd_pedidos
from vw_cliente c
left join pedido p on p.id_cliente = c.id_cliente
group by c.id_cliente, c.nome, c.tipo
order by qtd_pedidos desc, c.nome;

-- clientes com mais de um pedido
select c.nome, count(*) as qtd_pedidos
from vw_cliente c
join pedido p on p.id_cliente = c.id_cliente
group by c.id_cliente, c.nome
having count(*) > 1;

-- clientes que já gastaram mais de R$ 1.000 (sem contar cancelados)
select c.nome, sum(t.total) as total_gasto
from vw_pedido_total t
join vw_cliente c on c.id_cliente = t.id_cliente
where t.status <> 'Cancelado'
group by c.id_cliente, c.nome
having sum(t.total) > 1000
order by total_gasto desc;

-- algum vendedor também é fornecedor? (compara pelo CNPJ)
select v.razao_social as vendedor, f.razao_social as fornecedor, v.cnpj
from vendedor v
join fornecedor f on f.cnpj = v.cnpj;

-- produtos, fornecedores e estoque
-- o estoque é somado antes do join para não multiplicar linhas
select pr.nome as produto,
       f.razao_social as fornecedor,
       pf.quantidade as qtd_fornecida,
       coalesce(e.total, 0) as qtd_em_estoque
from produto pr
join produto_fornecedor pf on pf.id_produto = pr.id_produto
join fornecedor f on f.id_fornecedor = pf.id_fornecedor
left join (select id_produto, sum(quantidade) as total
           from produto_estoque
           group by id_produto) e on e.id_produto = pr.id_produto
order by pr.nome, f.razao_social;

-- nomes dos fornecedores e dos produtos que fornecem
select f.razao_social as fornecedor, pr.nome as produto
from fornecedor f
join produto_fornecedor pf on pf.id_fornecedor = f.id_fornecedor
join produto pr on pr.id_produto = pf.id_produto
order by f.razao_social, pr.nome;

-- status e rastreio das entregas
select p.id_pedido, c.nome as cliente, e.status,
       coalesce(e.codigo_rastreio, 'sem código') as rastreio
from entrega e
join pedido p on p.id_pedido = e.id_pedido
join vw_cliente c on c.id_cliente = p.id_cliente
order by e.status, p.id_pedido;

-- pedidos pagos com mais de uma forma de pagamento
select id_pedido, count(*) as formas, sum(valor_pago) as total_pago
from pedido_pagamento
group by id_pedido
having count(*) > 1;

-- clientes com mais de uma forma de pagamento cadastrada
select c.nome, count(*) as formas_cadastradas
from forma_pagamento fp
join vw_cliente c on c.id_cliente = fp.id_cliente
group by c.id_cliente, c.nome
having count(*) > 1;
