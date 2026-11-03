-- oficina mecânica: esquema lógico (MySQL 8 / MariaDB 10.5+)

drop database if exists oficina;
create database oficina character set utf8mb4 collate utf8mb4_unicode_ci;
use oficina;

create table cliente (
    id_cliente int auto_increment primary key,
    nome       varchar(80) not null,
    cpf        char(11)    not null unique,
    telefone   varchar(20),
    endereco   varchar(150)
);

create table veiculo (
    id_veiculo int auto_increment primary key,
    id_cliente int         not null,
    placa      char(7)     not null unique,
    marca      varchar(30) not null,
    modelo     varchar(40) not null,
    ano        smallint,
    foreign key (id_cliente) references cliente (id_cliente)
);

create table equipe (
    id_equipe int auto_increment primary key,
    nome      varchar(40) not null unique
);

create table mecanico (
    codigo        int auto_increment primary key,
    id_equipe     int         not null,
    nome          varchar(80) not null,
    endereco      varchar(150),
    especialidade varchar(40) not null,
    foreign key (id_equipe) references equipe (id_equipe)
);

-- valor_mao_obra faz o papel da tabela de referência de mão de obra
create table servico (
    id_servico     int auto_increment primary key,
    descricao      varchar(100)  not null unique,
    valor_mao_obra decimal(10,2) not null check (valor_mao_obra >= 0)
);

create table peca (
    id_peca   int auto_increment primary key,
    descricao varchar(100)  not null,
    valor     decimal(10,2) not null check (valor >= 0)
);

-- a mesma equipe avalia e executa, por isso só há um id_equipe na OS
create table ordem_servico (
    numero                int auto_increment primary key,
    id_veiculo            int  not null,
    id_equipe             int  not null,
    data_emissao          date not null,
    data_entrega_prevista date not null,
    data_conclusao        date,
    valor                 decimal(10,2) not null default 0,
    status                enum('Em avaliação','Aguardando autorização','Autorizada',
                               'Em execução','Concluída','Cancelada') not null default 'Em avaliação',
    autorizada            boolean not null default false,
    data_autorizacao      date,
    foreign key (id_veiculo) references veiculo (id_veiculo),
    foreign key (id_equipe) references equipe (id_equipe),
    check (data_entrega_prevista >= data_emissao),
    index idx_os_status (status)
);

-- os valores são copiados na hora da OS, então reajustes futuros não mudam OS antigas
create table os_servico (
    numero         int not null,
    id_servico     int not null,
    quantidade     int not null default 1,
    valor_unitario decimal(10,2) not null,
    primary key (numero, id_servico),
    foreign key (numero) references ordem_servico (numero),
    foreign key (id_servico) references servico (id_servico)
);

create table os_peca (
    numero         int not null,
    id_peca        int not null,
    quantidade     int not null default 1,
    valor_unitario decimal(10,2) not null,
    primary key (numero, id_peca),
    foreign key (numero) references ordem_servico (numero),
    foreign key (id_peca) references peca (id_peca)
);

-- mão de obra + peças de cada OS
create view vw_os_valor as
select os.numero,
       coalesce(s.total, 0) as mao_obra,
       coalesce(p.total, 0) as pecas,
       coalesce(s.total, 0) + coalesce(p.total, 0) as total
from ordem_servico os
left join (select numero, sum(quantidade * valor_unitario) as total
           from os_servico group by numero) s on s.numero = os.numero
left join (select numero, sum(quantidade * valor_unitario) as total
           from os_peca group by numero) p on p.numero = os.numero;
