use oficina;

insert into cliente (nome, cpf, telefone, endereco) values
 ('Roberto Almeida','11122233344','81990000001','Rua A, 10 - Recife/PE'),
 ('Fernanda Costa','22233344455','81990000002','Rua B, 20 - Olinda/PE'),
 ('Marcos Tavares','33344455566','81990000003','Av. C, 30 - Recife/PE'),
 ('Juliana Nunes','44455566677','81990000004','Rua D, 40 - Jaboatão dos Guararapes/PE');

insert into veiculo (id_cliente, placa, marca, modelo, ano) values
 (1,'ABC1D23','Fiat','Uno',2014),
 (1,'DEF4G56','Honda','Civic',2019),
 (2,'GHI7J89','Volkswagen','Gol',2016),
 (3,'JKL0M12','Chevrolet','Onix',2021),
 (4,'MNO3P45','Toyota','Corolla',2020);

insert into equipe (nome) values ('Alfa'),('Beta'),('Gama');

insert into mecanico (id_equipe, nome, endereco, especialidade) values
 (1,'Paulo Ribeiro','Rua E, 50 - Recife/PE','Motor'),
 (1,'Sérgio Matos','Rua F, 60 - Recife/PE','Elétrica'),
 (2,'Luciana Prado','Rua G, 70 - Olinda/PE','Suspensão e freios'),
 (2,'Anderson Cruz','Rua H, 80 - Recife/PE','Motor'),
 (3,'Tiago Barros','Rua I, 90 - Jaboatão dos Guararapes/PE','Ar-condicionado'),
 (3,'Helena Dias','Rua J, 100 - Recife/PE','Câmbio');

insert into servico (descricao, valor_mao_obra) values
 ('Troca de óleo e filtro',80.00),
 ('Alinhamento e balanceamento',120.00),
 ('Troca de pastilhas de freio',150.00),
 ('Revisão completa',350.00),
 ('Reparo no sistema elétrico',220.00),
 ('Troca de correia dentada',280.00),
 ('Higienização do ar-condicionado',130.00);

insert into peca (descricao, valor) values
 ('Óleo 5W30 (1L)',45.00),
 ('Filtro de óleo',35.00),
 ('Pastilha de freio (jogo)',180.00),
 ('Correia dentada (kit)',320.00),
 ('Bateria 60Ah',480.00),
 ('Filtro de cabine',55.00);

insert into ordem_servico
    (id_veiculo, id_equipe, data_emissao, data_entrega_prevista, data_conclusao, status, autorizada, data_autorizacao) values
 (1,1,'2026-09-02','2026-09-04','2026-09-04','Concluída',true,'2026-09-02'),
 (2,2,'2026-09-10','2026-09-12','2026-09-11','Concluída',true,'2026-09-10'),
 (3,1,'2026-10-05','2026-10-08','2026-10-08','Concluída',true,'2026-10-05'),
 (4,3,'2026-10-15','2026-10-16',null,'Em execução',true,'2026-10-15'),
 (5,2,'2026-10-28','2026-10-31',null,'Aguardando autorização',false,null),
 (1,3,'2026-11-01','2026-11-03',null,'Em avaliação',false,null),
 (3,2,'2026-10-20','2026-10-22',null,'Cancelada',false,null);

insert into os_servico (numero, id_servico, quantidade, valor_unitario) values
 (1,1,1,80.00),
 (2,3,1,150.00),(2,2,1,120.00),
 (3,4,1,350.00),
 (4,7,1,130.00),
 (5,6,1,280.00),(5,1,1,80.00),
 (7,5,1,220.00);

insert into os_peca (numero, id_peca, quantidade, valor_unitario) values
 (1,1,4,45.00),(1,2,1,35.00),
 (2,3,1,180.00),
 (3,1,4,45.00),(3,2,1,35.00),(3,6,1,55.00),
 (4,6,1,55.00),
 (5,4,1,320.00),(5,1,4,45.00),(5,2,1,35.00);

update ordem_servico os
join vw_os_valor v on v.numero = os.numero
set os.valor = v.total;
