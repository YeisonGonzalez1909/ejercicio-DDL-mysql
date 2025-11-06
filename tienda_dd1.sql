create database if not exists tienda_dd1
character set utf8mb
collate utf8mb4_general_ci;

use tienda_dd1;

create table if not exists categorias(
	id int primary key auto_increment,
    nombre varchar(45) not null unique
);

create table if not exists productos(
	id int primary key auto_increment,
    nombre varchar(45) not null,
    precio decimal(10,2)  not null check(precio>0),
    categoria_id int not null,
    foreign key (categoria_id) references categorias(id) on delete restrict
);

insert into categorias (nombre) values ('electronica'), ('ropa');

select * from categorias;

INSERT INTO productos (nombre, precio, categoria_id) VALUES
('Celular Samsung', 1200000.00, 1),
('Audífonos Bluetooth', 250000.00, 1),
('Camiseta Deportiva', 60000.00, 2);

select * from productos;

-- probar el check 
INSERT INTO productos (nombre, precio, categoria_id) VALUES
('Producto Inválido', -1.00, 1);
-- dio error de codigo al ser negativo el precio 


-- nivel 2

alter table productos 
add column sku varchar(62);

INSERT INTO productos (nombre, precio, categoria_id, sku)
VALUES ('Monitor', 500.00, 1, 'SKU001');

INSERT INTO productos (nombre, precio, categoria_id, sku)
VALUES ('radio', 300.00, 1, 'SKU002');

-- Cambia nombre de productos a permitir NULL y luego vuelve a NOT NULL.

alter table productos 
modify nombre varchar(50) null;

-- volver a not null
alter table productos
modify nombre varchar(50) not null;

-- Añade índice único compuesto a productos para (nombre, categoria_id).
alter table productos 
add constraint uq_nombre_categoria unique  (nombre, categoria_id);

-- Renombrar la columna precio → precio_unitario
ALTER TABLE productos
rename column precio to precio_unitario;

show columns from productos;

-- no deja renombrar precio por el check que hay, entonces se va a eliminar y volver a crear otra vez.

alter table productos drop check productos_chk_1;

alter table productos rename column precio to precio_unitario;

alter table productos
add constraint uq_precio_unitario check (precio_unitario > 0);

show create table productos;

-- NIVEL 3 - relaciones y cascadas 

create table clientes (
	id int  auto_increment  primary key,
    email varchar(45) not null unique,
    nombre varchar(45) not null
);

create table pedidos (
	id int primary key auto_increment,
    cliente_id int not null,
    creado_en datetime not null default current_timestamp,
    constraint fk_cliente foreign key (cliente_id) references clientes(id) on delete cascade
);

-- crear la tabla pedido_detalle

create table pedido_detalle (
	pedido_id int not null,
    linea int not null,
    producto_id int not null,
    cantidad  int not null,
    precio_unitario decimal (10,2) not null,
    primary key (pedido_id, linea),
    constraint fk_pedido foreign key (pedido_id) references pedidos(id),
    constraint fk_producto foreign key  (producto_id) references  productos(id),
    constraint chk_cantidad check  (cantidad >0),
    constraint chk_precio_detalle check (precio_unitario >=0)
);

-- inseInserta un cliente, un pedido y dos líneas de detalle. Luego elimina el cliente y verifica que el pedido y su detalle se borren en cascada.

-- insertar un cliente

insert into  clientes  (email,  nombre) 
values ('yesion@gmail.com' , 'yeison');

-- insertar un pedido

insert into pedidos (cliente_id)
values (1);

-- insertar detalles del pedido

insert into pedido_detalle (pedido_id, linea, producto_id, cantidad, precio_unitario)
values (1,1,1,2, 80.59),
	(1, 2, 2, 1, 50.09);
    
-- verificar 
select * from clientes;
select * from pedidos;
select * from pedido_detalle;

alter table  pedido_detalle 
drop  foreign key fk_pedido;

alter table pedido_detalle
add constraint fk_pedido
foreign key  (pedido_id) references pedidos(id)
on delete cascade;

-- verifica que el pedido y su detalle se borren en cascada.
delete  from clientes  where  id=1;

-- NIVEL 4 Limpieza y drops

use tienda_dd1;

drop table if exists pedido_detalle;

drop table if exists pedidos;

drop table if exists clientes;

drop table if exists productos;

drop table if exists categorias;

drop database if exists tienda_dd1;



