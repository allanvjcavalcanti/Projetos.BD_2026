# SQL e NoSQL no dia a dia de quem trabalha com engenharia de dados

Anotações que fiz sobre bancos relacionais e não relacionais e onde cada um aparece num pipeline de dados.

## O papel do banco no pipeline

Quem trabalha com engenharia de dados cuida do caminho que o dado faz: coleta, armazenamento, transformação e entrega para quem vai usar (BI, APIs, modelos). Quase nenhum pipeline usa um banco só. Os sistemas de origem costumam misturar SQL e NoSQL, o armazenamento analítico quase sempre é SQL colunar, e a camada de serviço (cache, APIs) costuma ser NoSQL.

Então a pergunta útil não é "qual é o melhor banco", e sim "qual banco combina com a forma como esse dado vai ser lido e escrito".

## Bancos relacionais (SQL)

Guardam dados em tabelas, com esquema definido antes de gravar. Os relacionamentos são feitos com chave primária e estrangeira, e as consultas usam SQL.

- Integridade garantida pelo próprio banco (`NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`).
- Transações ACID.
- `JOIN` entre tabelas normalizadas.
- Ecossistema enorme: ferramentas de BI, ORMs, ETL.
- Escala bem na vertical. Na horizontal dá mais trabalho (réplicas de leitura, sharding, ou bancos distribuídos como CockroachDB).

Exemplos: PostgreSQL, MySQL/MariaDB, SQL Server, Oracle. Para análise: BigQuery, Snowflake, Redshift, ClickHouse.

Funcionam bem para pedidos, pagamentos, estoque, ERP, e em qualquer lugar onde as regras de integridade importam.

## Bancos não relacionais (NoSQL)

É um nome que cobre vários modelos diferentes. O que eles têm em comum é fugir do modelo de tabelas, em geral com esquema flexível e escala horizontal.

| Tipo | Exemplos | Quando usar |
|---|---|---|
| Chave-valor | Redis, DynamoDB | cache, sessão, carrinho de compras |
| Documento | MongoDB, Firestore | catálogo com atributos variados, perfis, JSON de APIs |
| Colunar (wide-column) | Cassandra, HBase | muita escrita, séries temporais, logs, IoT |
| Grafo | Neo4j, Neptune | recomendação, detecção de fraude, redes de relacionamento |
| Séries temporais | InfluxDB, TimescaleDB | métricas e monitoramento |
| Busca | Elasticsearch, OpenSearch | busca textual, análise de logs |

Em geral a modelagem parte das consultas: primeiro se define como o dado vai ser lido e depois se desenha a estrutura.

## Comparando

| | SQL | NoSQL |
|---|---|---|
| Esquema | fixo, validado na escrita | flexível, interpretado na leitura |
| Relacionamentos | `JOIN` | dados aninhados ou referências |
| Transações | ACID | depende do banco (de ACID a consistência eventual) |
| Escala | vertical, horizontal com mais esforço | horizontal por natureza |
| Consultas ad hoc | muito boas | limitadas ao que foi modelado |
| Mudar o esquema | migração (`ALTER TABLE`) | fácil, mas exige disciplina |

A fronteira já não é tão nítida: o PostgreSQL tem `JSONB`, o MongoDB tem transações entre documentos e os bancos NewSQL juntam SQL com escala horizontal.

## ACID, BASE e CAP

ACID (comum em SQL): atomicidade, consistência, isolamento e durabilidade. A transação acontece inteira ou não acontece, e depois do commit o dado não se perde.

BASE (comum em NoSQL distribuído): basicamente disponível, estado "mole" e consistência eventual. As réplicas podem ficar diferentes por um tempo, mas convergem.

O teorema CAP diz que, quando há uma partição de rede, o sistema precisa escolher entre consistência e disponibilidade. Cassandra e DynamoDB tendem a priorizar disponibilidade; HBase e bancos distribuídos de SQL tendem a priorizar consistência. Muitos permitem ajustar isso por operação (por exemplo, o nível de quorum no Cassandra).

## Normalizar ou desnormalizar

No modelo relacional, normaliza-se para não repetir dado. No NoSQL, é comum repetir de propósito para ler tudo numa consulta só.

```text
SQL                              MongoDB
cliente (id, nome)               {
pedido  (id, cliente_id)           "_id": 1001,
item    (pedido_id, produto_id,    "cliente": { "id": 7, "nome": "Maria" },
         qtd, preco)               "itens": [
produto (id, nome)                   { "produto": "Fone", "qtd": 2, "preco": 199.9 },
                                     { "produto": "Cabo", "qtd": 1, "preco": 29.9 }
                                   ]
                                 }
```

O documento devolve o pedido inteiro numa leitura, mas se o nome do cliente mudar é preciso atualizar vários documentos. No SQL o nome fica num lugar só, mas a leitura exige `JOIN`.

## Escala

Escalar na vertical é comprar uma máquina maior: simples, mas tem limite e fica caro. Escalar na horizontal é dividir o dado entre várias máquinas, com replicação (cópias, para disponibilidade) e particionamento ou sharding (dividir pelos dados de uma chave). A escolha da chave de partição pesa muito: uma chave ruim concentra tudo num nó só.

## OLTP e OLAP

OLTP é o banco que opera o negócio: muitas leituras e escritas pequenas e rápidas, armazenamento por linha (PostgreSQL, MySQL, MongoDB, Redis). OLAP é o banco que analisa: poucas consultas pesadas sobre muito dado, armazenamento por coluna (BigQuery, Snowflake, ClickHouse).

```text
fontes OLTP         ingestão               analítico              consumo
PostgreSQL  ─┐                          ┌ data lake
MongoDB     ─┼─►  ETL/ELT, CDC, Kafka ─►┤ data warehouse  ─►  BI, ML, APIs
APIs, logs  ─┘                          └ lakehouse
```

- ETL transforma antes de carregar; ELT carrega primeiro e transforma no destino (comum com warehouses na nuvem e ferramentas como dbt).
- CDC (change data capture) captura as mudanças do banco de origem quase em tempo real.
- O data lake guarda o dado bruto; o warehouse guarda o dado tratado e modelado, consultado em SQL.

## A mesma consulta em cada banco

"Quais clientes têm mais de um pedido?"

```sql
-- SQL
select c.nome, count(*) as qtd_pedidos
from cliente c
join pedido p on p.cliente_id = c.id
group by c.id, c.nome
having count(*) > 1;
```

```javascript
// MongoDB
db.pedidos.aggregate([
  { $group: { _id: "$cliente.nome", qtd_pedidos: { $sum: 1 } } },
  { $match: { qtd_pedidos: { $gt: 1 } } }
]);
```

```sql
-- Cassandra (CQL): a tabela já é criada pensando na consulta
create table pedidos_por_cliente (
  cliente_id int, data_pedido timestamp, pedido_id uuid, total decimal,
  primary key ((cliente_id), data_pedido)
) with clustering order by (data_pedido desc);

select * from pedidos_por_cliente where cliente_id = 7;
```

No Redis seria um contador por cliente (`INCR pedidos:cliente:7`), o que responde bem "quantos", mas não "quais".

## Como escolher

SQL costuma ser a melhor escolha quando os dados são estruturados e cheios de relacionamentos, quando integridade e transação importam, quando vão aparecer consultas imprevisíveis ou quando o time já domina SQL.

NoSQL faz mais sentido quando o esquema muda muito, quando o volume exige escala horizontal, quando o acesso é simples e conhecido (por chave, por usuário, por intervalo de tempo) ou quando é preciso latência muito baixa ou um modelo específico (grafo, série temporal, busca).

| Cenário | Escolha provável |
|---|---|
| Pedidos, pagamentos e estoque | PostgreSQL ou MySQL |
| Catálogo com atributos muito diferentes | MongoDB |
| Carrinho e sessão | Redis ou DynamoDB |
| Telemetria de sensores | Cassandra ou TimescaleDB |
| "Quem comprou X também comprou Y" | Neo4j |
| Busca em produtos e logs | Elasticsearch |
| Relatórios e dashboards | BigQuery ou Snowflake |

## Persistência poliglota

Num sistema real é comum usar vários bancos, cada um no que faz melhor. Num e-commerce, por exemplo: PostgreSQL para pedidos e pagamentos, MongoDB para o catálogo, Redis para carrinho e cache, Elasticsearch para busca, Kafka com CDC para levar as mudanças ao warehouse e BigQuery ou Snowflake para análise. O custo é operacional: mais coisa para monitorar e mais risco de os dados ficarem divergentes, e é aí que o trabalho de engenharia de dados entra.

## Glossário rápido

- **Schema-on-write / schema-on-read:** esquema validado ao gravar / interpretado ao ler.
- **Sharding:** dividir os dados entre servidores a partir de uma chave.
- **Consistência eventual:** as réplicas só ficam iguais depois de um tempo.
- **Quorum:** número mínimo de réplicas que precisam concordar numa operação.
- **Data lake / warehouse / lakehouse:** dado bruto / dado modelado para análise / os dois juntos.
- **NewSQL:** bancos SQL com transações distribuídas e escala horizontal.

## Para estudar mais

- Martin Kleppmann, *Designing Data-Intensive Applications*
- Joe Reis e Matt Housley, *Fundamentals of Data Engineering*
- Documentação do [PostgreSQL](https://www.postgresql.org/docs/), [MongoDB](https://www.mongodb.com/docs/), [Redis](https://redis.io/docs/) e [Cassandra](https://cassandra.apache.org/doc/latest/)

Veja também a modelagem relacional aplicada em [e-commerce]($U/ecommerce-projeto-logico-bd) e [oficina]($U/oficina-projeto-logico-bd).


