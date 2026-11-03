use oficina;

-- OS em aberto
select numero, data_emissao, data_entrega_prevista, status
from ordem_servico
where status not in ('Concluída', 'Cancelada');

-- mecânicos especialistas em motor
select codigo, nome
from mecanico
where especialidade = 'Motor';

-- dias de diferença entre o prazo e a conclusão (negativo = entregou antes)
select numero, data_entrega_prevista, data_conclusao,
       datediff(data_conclusao, data_entrega_prevista) as dias_de_atraso
from ordem_servico
where data_conclusao is not null;

-- mão de obra, peças e total de cada OS, conferindo com o valor gravado
select v.numero, v.mao_obra, v.pecas, v.total, os.valor as valor_gravado
from vw_os_valor v
join ordem_servico os on os.numero = v.numero
order by v.total desc;

-- OS com cliente, veículo e equipe
select os.numero, c.nome as cliente,
       concat(ve.marca, ' ', ve.modelo, ' (', ve.placa, ')') as veiculo,
       e.nome as equipe, os.status, os.valor
from ordem_servico os
join veiculo ve on ve.id_veiculo = os.id_veiculo
join cliente c on c.id_cliente = ve.id_cliente
join equipe e on e.id_equipe = os.id_equipe
order by os.numero;

-- mecânicos de cada equipe
select e.nome as equipe, m.codigo, m.nome as mecanico, m.especialidade
from equipe e
join mecanico m on m.id_equipe = e.id_equipe
order by e.nome, m.nome;

-- serviços e peças de cada OS
select os.numero, 'serviço' as tipo, s.descricao as item, x.quantidade, x.valor_unitario
from ordem_servico os
join os_servico x on x.numero = os.numero
join servico s on s.id_servico = x.id_servico
union all
select os.numero, 'peça', p.descricao, x.quantidade, x.valor_unitario
from ordem_servico os
join os_peca x on x.numero = os.numero
join peca p on p.id_peca = x.id_peca
order by numero, tipo desc, item;

-- equipes com pelo menos 2 OS (sem contar canceladas)
select e.nome as equipe, count(*) as qtd_os
from equipe e
join ordem_servico os on os.id_equipe = e.id_equipe
where os.status <> 'Cancelada'
group by e.id_equipe, e.nome
having count(*) >= 2;

-- clientes com mais de R$ 300 gastos em OS concluídas
select c.nome, count(*) as qtd_os, sum(os.valor) as total_gasto
from cliente c
join veiculo ve on ve.id_cliente = c.id_cliente
join ordem_servico os on os.id_veiculo = ve.id_veiculo
where os.status = 'Concluída'
group by c.id_cliente, c.nome
having sum(os.valor) > 300
order by total_gasto desc;

-- serviços pedidos em mais de uma OS
select s.descricao, count(*) as vezes
from os_servico x
join servico s on s.id_servico = x.id_servico
group by s.id_servico, s.descricao
having count(*) > 1;

-- OS esperando autorização do cliente
select os.numero, c.nome as cliente, c.telefone, os.valor
from ordem_servico os
join veiculo ve on ve.id_veiculo = os.id_veiculo
join cliente c on c.id_cliente = ve.id_cliente
where os.status = 'Aguardando autorização';

-- clientes com mais de um veículo
select c.nome, count(*) as qtd_veiculos
from cliente c
join veiculo ve on ve.id_cliente = c.id_cliente
group by c.id_cliente, c.nome
having count(*) > 1;
