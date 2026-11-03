use ecommerce;

insert into cliente (tipo, email, telefone, endereco) values
 ('PF','carla.mendonca@email.com','81991110001','Rua das Flores, 100 - Recife/PE'),
 ('PF','rafael.teixeira@email.com','81991110002','Av. Boa Viagem, 2000 - Recife/PE'),
 ('PF','bianca.albuquerque@email.com','81991110003','Rua do Sol, 45 - Olinda/PE'),
 ('PF','diego.fonseca@email.com','81991110004','Rua Nova, 12 - Jaboatão dos Guararapes/PE'),
 ('PJ','compras@bytecom.com.br','8133330001','Av. Agamenon Magalhães, 500 - Recife/PE'),
 ('PJ','financeiro@moveisaurora.com.br','8133330002','Rua da Aurora, 321 - Recife/PE');

insert into cliente_pf (id_cliente, nome, sobrenome, cpf, data_nascimento) values
 (1,'Carla','Mendonça','11111111111','1995-03-10'),
 (2,'Rafael','Teixeira','22222222222','1990-07-21'),
 (3,'Bianca','Albuquerque','33333333333','2000-11-02'),
 (4,'Diego','Fonseca','44444444444','1988-01-15');

insert into cliente_pj (id_cliente, razao_social, nome_fantasia, cnpj) values
 (5,'Bytecom Informática Ltda','Bytecom','12345678000101'),
 (6,'Móveis Aurora ME','Aurora','98765432000102');

insert into produto (nome, categoria, descricao, valor, avaliacao, dimensao) values
 ('Fone Bluetooth','Eletrônico','Fone sem fio com cancelamento de ruído',199.90,4.5,'10x8x4'),
 ('Smartwatch','Eletrônico','Relógio inteligente com GPS',599.00,4.2,'5x5x1'),
 ('Camiseta Dry Fit','Vestimenta','Camiseta esportiva',59.90,4.0,null),
 ('Boneca Articulada','Brinquedos','Boneca com acessórios',89.90,4.7,'30x10x6'),
 ('Chocolate 70% Cacau','Alimentos','Barra de 100g',12.50,4.8,null),
 ('Sofá 3 Lugares','Móveis','Sofá retrátil cinza',1899.00,4.1,'200x90x95'),
 ('Notebook 15"','Eletrônico','i5, 16GB, SSD 512GB',3799.00,4.6,'36x25x2');

insert into forma_pagamento (id_cliente, tipo, apelido, final_cartao, validade) values
 (1,'Cartão de crédito','Nubank','1234','12/2028'),
 (1,'Pix','Chave CPF',null,null),
 (2,'Cartão de crédito','Itaú','5678','06/2027'),
 (3,'Boleto',null,null,null),
 (4,'Cartão de débito','Bradesco','9012','03/2029'),
 (5,'Boleto','Boleto faturado',null,null),
 (5,'Cartão de crédito','Cartão corporativo','3456','09/2029'),
 (6,'Pix','Chave CNPJ',null,null);

insert into pedido (id_cliente, status, descricao, frete, data_pedido) values
 (1,'Confirmado','Fones e camiseta',15.00,'2026-10-01'),
 (1,'Em processamento','Camisetas',10.00,'2026-10-20'),
 (2,'Confirmado','Smartwatch',20.00,'2026-10-05'),
 (3,'Cancelado','Boneca',12.00,'2026-10-07'),
 (4,'Confirmado','Chocolates',8.00,'2026-10-10'),
 (5,'Confirmado','Notebooks para o escritório',0.00,'2026-10-12'),
 (6,'Confirmado','Sofás para o showroom',150.00,'2026-10-15'),
 (5,'Em processamento','Fones para a equipe',0.00,'2026-10-28');

insert into produto_pedido (id_produto, id_pedido, quantidade, valor_unitario) values
 (1,1,2,199.90),(3,1,1,59.90),
 (3,2,3,59.90),
 (2,3,1,599.00),
 (4,4,1,89.90),
 (5,5,10,12.50),
 (7,6,5,3799.00),
 (6,7,2,1899.00),
 (1,8,10,199.90);

-- o pedido 1 foi pago em duas formas; o 4 foi cancelado (sem pagamento nem entrega)
insert into pedido_pagamento (id_pedido, id_forma_pagamento, valor_pago) values
 (1,1,300.00),(1,2,174.70),
 (3,3,619.00),
 (5,5,133.00),
 (6,6,18995.00),
 (7,8,3948.00);

insert into entrega (id_pedido, status, codigo_rastreio, data_envio, data_entrega) values
 (1,'Entregue','BR123456789BR','2026-10-02','2026-10-06'),
 (2,'Aguardando envio',null,null,null),
 (3,'Em transporte','BR987654321BR','2026-10-06',null),
 (5,'Saiu para entrega','BR444444444BR','2026-10-11',null),
 (6,'Entregue','BR333333333BR','2026-10-13','2026-10-16'),
 (7,'Em transporte','BR222222222BR','2026-10-16',null);

insert into fornecedor (razao_social, cnpj, contato) values
 ('Eletro Distribuidora Ltda','11222333000144','8132000001'),
 ('Moda Têxtil S.A.','22333444000155','8132000002'),
 ('Doce Sabor Alimentos','33444555000166','8132000003'),
 ('Bytecom Informática Ltda','12345678000101','8133330001');

insert into vendedor (razao_social, nome_fantasia, cnpj, cpf, local_vendedor, contato) values
 ('Bytecom Informática Ltda','Bytecom','12345678000101',null,'Recife','8133330001'),
 ('Presentes do Zé ME','Zé Presentes','44555666000177',null,'Olinda','8132000010'),
 ('Pedro Alves',null,null,'55555555555','Jaboatão dos Guararapes','81991110099');

insert into estoque (local_estoque) values ('Recife - CD Central'),('Olinda - Filial'),('Jaboatão - Depósito');

insert into produto_fornecedor (id_fornecedor, id_produto, quantidade) values
 (1,1,200),(1,2,80),(1,7,40),(2,3,500),(3,5,1000),(4,7,25),(4,1,60);

insert into produto_vendedor (id_vendedor, id_produto, quantidade) values
 (1,1,30),(1,7,10),(2,4,15),(2,3,40),(3,6,5);

insert into produto_estoque (id_produto, id_estoque, quantidade) values
 (1,1,150),(1,2,40),(2,1,60),(3,1,300),(3,3,120),(4,2,35),(5,1,800),(6,3,12),(7,1,30);
