-- e-commerce: esquema lógico (MySQL 8 / MariaDB 10.5+)

drop database if exists ecommerce;
create database ecommerce character set utf8mb4 collate utf8mb4_unicode_ci;
use ecommerce;

-- cliente é PF ou PJ, nunca os dois.
-- O tipo fica na tabela pai e as filhas referenciam (id, tipo) com tipo fixo,
-- então o mesmo id não consegue entrar nas duas.
create table cliente (
    id_cliente int auto_increment primary key,
    tipo       char(2)      not null check (tipo in ('PF','PJ')),
    email      varchar(100) not null unique,
    telefone   varchar(20),
    endereco   varchar(150) not null,
    unique (id_cliente, tipo)
);

create table cliente_pf (
    id_cliente      int primary key,
    tipo            char(2)     not null default 'PF' check (tipo = 'PF'),
    nome            varchar(40) not null,
    sobrenome       varchar(40) not null,
    cpf             char(11)    not null unique,
    data_nascimento date,
    foreign key (id_cliente, tipo) references cliente (id_cliente, tipo)
);

create table cliente_pj (
    id_cliente    int primary key,
    tipo          char(2)      not null default 'PJ' check (tipo = 'PJ'),
    razao_social  varchar(100) not null,
    nome_fantasia varchar(100),
    cnpj          char(14)     not null unique,
    foreign key (id_cliente, tipo) references cliente (id_cliente, tipo)
);

create table produto (
    id_produto int auto_increment primary key,
    nome       varchar(60)   not null,
    categoria  enum('Eletrônico','Vestimenta','Brinquedos','Alimentos','Móveis') not null,
    descricao  varchar(150),
    valor      decimal(10,2) not null check (valor >= 0),
    avaliacao  decimal(2,1)  default 0,
    dimensao   varchar(20)
);

-- formas de pagamento cadastradas pelo cliente (pode ter várias)
create table forma_pagamento (
    id_forma_pagamento int auto_increment primary key,
    id_cliente         int not null,
    tipo               enum('Boleto','Cartão de crédito','Cartão de débito','Pix') not null,
    apelido            varchar(40),
    final_cartao       char(4),
    validade           char(7),
    foreign key (id_cliente) references cliente (id_cliente)
);

create table pedido (
    id_pedido   int auto_increment primary key,
    id_cliente  int  not null,
    status      enum('Cancelado','Confirmado','Em processamento') not null default 'Em processamento',
    descricao   varchar(255),
    frete       decimal(10,2) not null default 10,
    data_pedido date not null,
    foreign key (id_cliente) references cliente (id_cliente),
    index idx_pedido_data (data_pedido)
);

-- como cada pedido foi pago (uma ou mais formas)
create table pedido_pagamento (
    id_pedido          int not null,
    id_forma_pagamento int not null,
    valor_pago         decimal(10,2) not null,
    primary key (id_pedido, id_forma_pagamento),
    foreign key (id_pedido) references pedido (id_pedido),
    foreign key (id_forma_pagamento) references forma_pagamento (id_forma_pagamento)
);

-- uma entrega por pedido; o código de rastreio só existe depois do envio
create table entrega (
    id_entrega      int auto_increment primary key,
    id_pedido       int not null unique,
    status          enum('Aguardando envio','Em transporte','Saiu para entrega','Entregue','Devolvido')
                    not null default 'Aguardando envio',
    codigo_rastreio varchar(20) unique,
    data_envio      date,
    data_entrega    date,
    foreign key (id_pedido) references pedido (id_pedido)
);

create table fornecedor (
    id_fornecedor int auto_increment primary key,
    razao_social  varchar(100) not null,
    cnpj          char(14)     not null unique,
    contato       varchar(20)
);

create table vendedor (
    id_vendedor    int auto_increment primary key,
    razao_social   varchar(100) not null,
    nome_fantasia  varchar(100),
    cnpj           char(14) unique,
    cpf            char(11) unique,
    local_vendedor varchar(60),
    contato        varchar(20),
    check (cnpj is not null or cpf is not null)
);

create table estoque (
    id_estoque    int auto_increment primary key,
    local_estoque varchar(60) not null
);

create table produto_fornecedor (
    id_fornecedor int not null,
    id_produto    int not null,
    quantidade    int not null,
    primary key (id_fornecedor, id_produto),
    foreign key (id_fornecedor) references fornecedor (id_fornecedor),
    foreign key (id_produto) references produto (id_produto)
);

create table produto_vendedor (
    id_vendedor int not null,
    id_produto  int not null,
    quantidade  int not null default 1,
    primary key (id_vendedor, id_produto),
    foreign key (id_vendedor) references vendedor (id_vendedor),
    foreign key (id_produto) references produto (id_produto)
);

create table produto_estoque (
    id_produto int not null,
    id_estoque int not null,
    quantidade int not null default 0,
    primary key (id_produto, id_estoque),
    foreign key (id_produto) references produto (id_produto),
    foreign key (id_estoque) references estoque (id_estoque)
);

create table produto_pedido (
    id_produto     int not null,
    id_pedido      int not null,
    quantidade     int not null default 1,
    valor_unitario decimal(10,2) not null,
    primary key (id_produto, id_pedido),
    foreign key (id_produto) references produto (id_produto),
    foreign key (id_pedido) references pedido (id_pedido)
);

-- nome e documento do cliente, seja PF ou PJ
create view vw_cliente as
select c.id_cliente,
       c.tipo,
       coalesce(concat(pf.nome, ' ', pf.sobrenome), pj.razao_social) as nome,
       coalesce(pf.cpf, pj.cnpj) as documento
from cliente c
left join cliente_pf pf on pf.id_cliente = c.id_cliente
left join cliente_pj pj on pj.id_cliente = c.id_cliente;

-- subtotal e total de cada pedido
create view vw_pedido_total as
select p.id_pedido,
       p.id_cliente,
       p.status,
       sum(i.quantidade * i.valor_unitario)             as subtotal,
       p.frete,
       sum(i.quantidade * i.valor_unitario) + p.frete   as total
from pedido p
join produto_pedido i on i.id_pedido = p.id_pedido
group by p.id_pedido, p.id_cliente, p.status, p.frete;
