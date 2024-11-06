create database Access_Control_One
use Access_Control_One

CREATE TABLE personal (
    ID INT NOT NULL IDENTITY(1,1),
    User_ControlGreg VARCHAR(40) NOT NULL,
    Password_Control VARBINARY(512) NOT NULL,
    Rank_Control VARCHAR(20) NOT NULL,
	email varchar(100) not null,
    PRIMARY KEY (ID),
    CONSTRAINT UQ_User_ControlGreg UNIQUE (User_ControlGreg),
	constraint UQ_User_ControlGreg_Email unique (email)
);

create table salario_de_usuario_por_dia( --usuario
	ID_User INT not null,
	User_ControlGreg VARCHAR(40) NOT NULL,
	SalarioPorHora NUMERIC(10,2) not null,
	TipoDePago varchar(40) not null
	constraint FK_One_salario_de_usuario_por_dia_personal foreign key (ID_User) REFERENCES personal(ID),
	constraint FK_Two_salario_de_usuario_por_dia_personal foreign key (User_ControlGreg) REFERENCES personal(User_ControlGreg)
);
create table datos_pueden_ser_ranks(
	Ranks varchar(20) NOT NULL primary key,
	RankNumber int not null
	);

create table datos_pueden_ser_tipodepago(
	TipoDePago varchar(40) NOT NULL primary key
	);


CREATE TABLE control_de_accesos ( --Esta tabla lleva los registros de entrada y salida, solo se actualiza a las 10PM
    ID_User INT NOT NULL ,
    User_ControlGreg_Time VARCHAR(40) NOT NULL,
    Dia INT NOT NULL,
    Mes INT NOT NULL,
    Ano INT NOT NULL,
    Hora INT NOT NULL,
    Minuto INT NOT NULL
    CONSTRAINT FK_ControlAccesos_Personal FOREIGN KEY (ID_User) REFERENCES personal(ID),
	constraint FK_Two_ControlAccesos_Personal foreign key (User_ControlGreg_Time) REFERENCES personal(User_ControlGreg)
);


Create table salario_al_dia( --Tabla para calcular el salario al dia despues de haber eliminado los datos "basura"
	ID_User INT NOT NULL,
	User_ControlGreg_Salario VARCHAR(40) NOT NULL,
	Dia INT NOT NULL,
	Mes INT NOT NULL,
	Ano INT NOT NULL,
	Monto numeric(10,2) NOT NULL,
	HoraInicio INT NOT NULL,
	MinutoInicio INT NOT NULL,
	HoraFinal INT NOT NULL,
	MinutoFinal INT NOT NULL,
	HorasTrabajadas INT not null,
	MinutosTrabajados INT not null,
	Constraint FK_SalarioAlDia_Personal FOREIGN KEY (ID_USER) REFERENCES personal(ID),
	constraint FK_Two_SalarioAlDia_Personal foreign key (User_ControlGreg_Salario) REFERENCES personal(User_ControlGreg)
);

create table salario_a_la_semana(
	Movimiento INT not null IDENTITY(1,1) PRIMARY KEY,
	ID_User INT NOT NULL,
	User_ControlGreg_Salario VARCHAR(40) NOT NULL,
	Monto numeric(10,2) NOT NULL,
	HorasTrabajadas INT Not Null,  --Maximo 168
	MinutosTrabajados INT not null,
	DiaIncio INT NOT NULL,
	MesInicio INT NOT NULL,
	SemanaMesInicio INT NOT NULL,
	AnoInicio INT not null,
	DiaFinal INT NOT NULL,
	MesFinal INT NOT NULL,
	SemanaMesFinal INT NOT NULL,
	AnoFinal INT not null,
	Pagado Varchar(10) NOT NULL,
	MontoPorPagar Numeric(10,2) not null,
	Constraint FK_SalarioALaSemana_Personal FOREIGN KEY (ID_USER) REFERENCES personal(ID),	
	Constraint FK_Two_SalarioALaSemana_Personal FOREIGN KEY (User_ControlGreg_Salario) REFERENCES personal(User_ControlGreg)
);


create table tabla_por_pagar_y_registro_de_pagados(
	Movimiento INT not null IDENTITY(1,1) PRIMARY KEY,
	ID_User INT not null,
	User_ControlGreg VARCHAR(40) NOT NULL,
	MontoPorSerPagado Numeric(10,2) not null,
	MontoPorSerPagado_Adicion Numeric(10,2) not null,
	MontoPagado numeric(10,2) not null,
	Dia INT not null,
	Mes INT not null,
	Ano INT not null,
	constraint FK_TablaPorPagarYRegistroDePagos_Personal foreign key (ID_USER) references personal(ID),
	constraint FK_Two_TablaPorPagarYRegistroDePagos_Personal foreign key (User_ControlGreg) REFERENCES personal(User_ControlGreg)
);

create table registro_de_modificaciones(
	Movimiento INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ID INT NOT NULL,
	User_ControlGreg_Old varchar(40) NOT NULL,
	User_ControlGreg_New varchar(40) NOT NULL,
	Password_Control_Old varchar(40) NOT NULL,
	Password_Control_New varchar(40) NOT NULL,
	Rank_Old varchar(40) NOT NULL,
	Rank_New varchar(40) NOT NULL,
	SalarioPorHora_Old numeric(10,2) NOT NULL,
	SalarioPorHora_New numeric(10,2) NOT NULL,
	TipoDePago_Old varchar(40) NOT NULL,
	TipoDePago_New varchar(40) NOT NULL,
	Email_Old varchar(100) NOT NULL,
	Email_New varchar(100) NOT NULL,
	Dia INT NOT NULL,
	Mes INT NOT NULL,
	Ano INT NOT NULL
);

create table MartesActivado(
	activada int not null
);

/*por estandarizacion utiliza el minuzculas para el usuario, asi saben al ,momento de buscar que no existen mayusculas, esto puede ser controlado en la programacion*/


create table test_user(
	username_test varchar(20),
	password_test varchar(20),
	email varchar(50),
	autorization varchar(3),
	password_test_hash varbinary(512)
);



create table correo_puede_ser(
	correo varchar(30) primary key
);


Select @@SERVERNAME