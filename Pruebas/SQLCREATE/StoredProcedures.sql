
use Access_Control_One
GO
CREATE procedure pruebaactivarmartes
as begin
	update MartesActivado set activada = 1
end

/*Inicio Introducir los Datos*/
CREATE PROCEDURE QR_AccessControl
	@ID as INT,
	@Usuario as Varchar(40)
	as begin
	if exists( select 1 from personal where User_ControlGreg = @Usuario and ID = @ID)
		begin
			print 'EXISTE'
			INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) 
										VALUES (@ID, @Usuario, DATEPART(DAY,GETDATE()),DATEPART(MONTH,GETDATE()), DATEPART(YEAR,GETDATE()), DATEPART(HOUR,GETDATE()), DATEPART(MINUTE,GETDATE()));
		end
	end


/*Fin Introducir los Datos*/


/*---------INICIO----------------Pagar a tabla_por_pagar_y_registro_de_pagados*/
CREATE procedure PagandoAEmpleado
		@Usuario varchar(40),
		@MontoAPagar Numeric(10,2)
	AS BEGIN
		declare @MontoPorPagar as Numeric(10,2);
		declare @Ano as INT;
		declare @Mes as INT;
		declare @Dia as INT;
		declare @Resta as Numeric(10,2);
		declare @ID as INT;
		DECLARE @MontoPagado NUMERIC(10,2);
		declare @MontoSumaTemporal as Numeric(10,2);
		declare @Movimiento as INT;
		IF (@MontoAPagar<=0)
			BEGIN
			print 'no puedes pagar menos de $0 o $0'
			END
		ELSE
			BEGIN
				SELECT @MontoSumaTemporal = SUM(MontoPorPagar) from salario_a_la_semana where User_ControlGreg_Salario = @Usuario AND Pagado = 'no';
				IF NOT(@MontoSumaTemporal < @MontoAPagar)
					while(@MontoAPagar>0)
						Begin
							/*SELECT TOP 1 @Movimiento = Movimiento, @MontoPorPagar = MontoPorPagar , @Ano = AnoInicio , @Mes = MesInicio, @Dia=DiaIncio, @ID = ID_User  FROM salario_a_la_semana AS s WHERE EXISTS (
																		SELECT 1 FROM salario_a_la_semana WHERE Pagado = 'no' AND User_ControlGreg_Salario = @Usuario
																	) AND Pagado = 'no' AND User_ControlGreg_Salario = @Usuario 
																	ORDER BY Movimiento ASC; --AnoInicio ASC, MesInicio ASC, DiaIncio ASC;*/
							SELECT TOP 1
										@Movimiento = Movimiento, @MontoPorPagar = MontoPorPagar, @Ano = AnoInicio, @Mes = MesInicio, @Dia = DiaIncio, @ID = ID_User
											FROM salario_a_la_semana
											WHERE Pagado = 'no' AND User_ControlGreg_Salario = @Usuario
											ORDER BY Movimiento ASC;
							IF (@MontoAPagar>@MontoPorPagar)
								Begin
									UPDATE salario_a_la_semana SET Pagado = 'si', MontoPorPagar = 0 WHERE  MontoPorPagar = @MontoPorPagar  AND  AnoInicio =@Ano AND MesInicio = @Mes AND DiaIncio = @Dia AND User_ControlGreg_Salario = @Usuario AND Pagado = 'no' and Movimiento = @Movimiento;					
								end
							ElSE IF(@MontoAPagar=@MontoPorPagar)
								BEGIN
									set @Resta = @MontoPorPagar - @MontoAPagar;
									UPDATE salario_a_la_semana SET Pagado = 'si', MontoPorPagar = @Resta WHERE MontoPorPagar = @MontoPorPagar  AND  AnoInicio =@Ano AND MesInicio = @Mes AND DiaIncio = @Dia AND User_ControlGreg_Salario = @Usuario AND Pagado = 'no' and Movimiento = @Movimiento;					
									SET @MontoPagado = @MontoAPagar;
								END
							ElSE IF(@MontoAPagar<@MontoPorPagar)
								BEGIN
									set @Resta = @MontoPorPagar - @MontoAPagar;
									UPDATE salario_a_la_semana SET Pagado = 'no', MontoPorPagar = @Resta WHERE @MontoPorPagar = MontoPorPagar AND @Ano = AnoInicio AND @Mes = MesInicio AND @dia=DiaIncio AND User_ControlGreg_Salario = @Usuario AND Pagado = 'no' and Movimiento = @Movimiento;		
								END
							SELECT @MontoSumaTemporal = SUM(MontoPorPagar) from salario_a_la_semana where User_ControlGreg_Salario = @Usuario AND Pagado = 'no';
									INSERT INTO tabla_por_pagar_y_registro_de_pagados(ID_User, User_ControlGreg, MontoPorSerPagado, MontoPorSerPagado_Adicion, MontoPagado, Dia, Mes, Ano) 
											VALUES(@ID,@Usuario,@MontoSumaTemporal,0,@MontoAPagar,DAY(GETDATE()),MONTH(GETDATE()), YEAR(GETDATE()));
							set @MontoAPagar -= @MontoPagado;
						END
				ELSE 
					begin
						PRINT 'No puedes pagar mas de lo que debes'
					END
			END
END

/*---------FIN------------Pagar a tabla_por_pagar_y_registro_de_pagados---------------------------------------------------------*/




/*---------INICIO----------------Monto Agregado de los que quedan por pagar a tabla_por_pagar_y_registro_de_pagados-------------*/
CREATE PROCEDURE ParaPagarTrabajador_Registro
		@Usuario as varchar(40),
		@MontoParaAdicional as Numeric(10,2)
	as begin
		declare @MontoSumaTemporal numeric(10,2) = 0;
		declare @MontoTotal numeric(10,2) = 0;
		declare @ID as INT;
		Select @ID = ID from personal where User_ControlGreg = @Usuario;

		if not exists( SELECT 1 FROM tabla_por_pagar_y_registro_de_pagados where User_ControlGreg = @Usuario)
			begin
				INSERT INTO tabla_por_pagar_y_registro_de_pagados(ID_User, User_ControlGreg, MontoPorSerPagado, MontoPorSerPagado_Adicion, MontoPagado, Dia, Mes, Ano) 
					VALUES(@ID,@Usuario,@MontoParaAdicional,@MontoParaAdicional,0,DAY(GETDATE()),MONTH(GETDATE()), YEAR(GETDATE()));
			end
		else
			begin
				select TOP 1 @MontoTotal = MontoPorSerPagado from tabla_por_pagar_y_registro_de_pagados where User_ControlGreg = @Usuario ORDER BY Movimiento DESC
				set @MontoTotal += @MontoParaAdicional;
				INSERT INTO tabla_por_pagar_y_registro_de_pagados(ID_User, User_ControlGreg, MontoPorSerPagado, MontoPorSerPagado_Adicion, MontoPagado, Dia, Mes, Ano) 
					VALUES(@ID,@Usuario,@MontoTotal,@MontoParaAdicional,0,DAY(GETDATE()),MONTH(GETDATE()), YEAR(GETDATE()));
			end
END--*/
/*---------FIN-------Monto Agregado de los que quedan por pagar a tabla_por_pagar_y_registro_de_pagados-------------*/


/*-----------CREACION DE USUARIOS NUEVOS Y MODIFICACION DE TODO MENOS EL ID*/
ALTER PROCEDURE SP_CrearUsuarioAndSalarioDeUsuario --Solo lo uso para prueba
	@Usuario as varchar(40),
	@Password as VARBINARY(512),
	@Email as varchar(100),
	@Rank as varchar(40),
	@SalarioPorHora as numeric(10,2),
	@TipoDePago as varchar(20)
	AS BEGIN
	DECLARE @ID as INT;
	--Declare @HoraFinal INT;
	print'Debemos crear el usuario y lo que conlleva con als tablas: personal, salario_de_usuario_por_dia'
	IF(@SalarioPorHora>0)
		BEGIN
			IF NOT EXISTS((select 1 from salario_de_usuario_por_dia where User_ControlGreg = @Usuario) union (Select 1 from personal where User_ControlGreg = @Usuario))
				BEGIN
					IF((EXISTS(SELECT 1 FROM correo_puede_ser where @Email like '%'+correo)) and
						(exists(select 1 from datos_pueden_ser_ranks where @Rank like Ranks)) and
						(exists(select 1 from datos_pueden_ser_tipodepago where @TipoDePago like TipoDePago))
						)
						BEGIN
							PRINT'CREANDO, NO EXISTE EL USUARIO'
							insert into personal(User_ControlGreg,Password_Control,Rank_Control,email) values(@Usuario,@Password,@Rank,@Email);
							select @ID = ID from personal where User_ControlGreg = @Usuario;
							insert into salario_de_usuario_por_dia(ID_User,User_ControlGreg, SalarioPorHora,TipoDePago)values(@ID,@Usuario,@SalarioPorHora,@TipoDePago);
						END
					ELSE
						BEGIN
							PRINT 'ERROR, EL EMAIL, RANGO Y/O TIPO DE PAGO NO APARECE EN LA LISTA'
						END
				END
			ELSE
				BEGIN
					PRINT 'ESTE USUARIO YA EXISTE'
				END
		END
	ELSE
		BEGIN
			PRINT 'NO PUEDES GANAR $0 O MENOS'
		END
END

/*                            EDICION GENERAL               EDICION GENERAL              EDICION GENERAL              EDICION GENERAL              */


ALTER PROCEDURE SP_EDICION_GENERAL
	@User_ControlGreg_Old as varchar(40),
	@User_ControlGreg_New as varchar(40),	 
	@Password_Control_New as varbinary(512),
	@Password_Confirmation as INT,
	@Rank_New as varchar(40),	 
	@TipoDePago_New as varchar(40),
	@SalarioPorHora_New as numeric(10,2),
	@Email_New as varchar(100),
	@EdicionCompletada as varchar(50) OUTPUT
AS BEGIN
	declare @ID as INT
	declare @Password_Control_Old as varbinary(512)
	declare @Rank_Old as varchar(40)
	declare @SalarioPorHora_Old as numeric(10,2)
	declare @TipoDePago_Old as varchar(40)
	declare @Email_Old as varchar (100)
	declare @Cambio_User as INT = 0
	declare @Cambio_Password as INT = 0
	declare @Cambio_Rank as INT = 0
	declare @Cambio_TipoDePago as INT = 0
	declare @Cambio_SalarioPorHora as INT = 0
	declare @Cambio_Email as INT = 0
	DECLARE @PS_MESSAGE AS VARCHAR(40) = ''
	SET @EdicionCompletada = 'No se Realizo Algun Cambio'
	DECLARE @Dia as INT = DAY(GETDATE()), @Mes as INT = MONTH(GETDATE()), @Ano as INT = YEAR(GETDATE());
	select @ID = P.ID, @Rank_Old = p.Rank_Control, @SalarioPorHora_Old = s.SalarioPorHora, @TipoDePago_Old = s.TipoDePago, @Email_Old = p.email
	from (personal as p inner join salario_de_usuario_por_dia as s on p.User_ControlGreg = s.User_ControlGreg)
	where p.User_ControlGreg = @User_ControlGreg_Old;
	set @Cambio_User = 0;
	IF	(@User_ControlGreg_Old <> @User_ControlGreg_New) OR (@Password_Confirmation =1) OR (@Rank_Old <> @Rank_New) OR
		(@TipoDePago_Old <> @TipoDePago_New) OR (@SalarioPorHora_Old <> @SalarioPorHora_New) OR (@Email_Old <> @Email_New)
		BEGIN
			--User
			exec SP_EdicionGeneral_DeUsuarios_Nombre @User_ControlGreg_Old, @User_ControlGreg_New, @Cambio_User Output;
			if not (@Cambio_User = 1)
				begin
				set @User_ControlGreg_New = @User_ControlGreg_Old;
				print 'Nombre De Usuario Cambiado' 
				end
			-- Password	
			SET @PS_MESSAGE = 'No Cambio'
			IF (@Password_Confirmation = 1)
				begin
					exec SP_EdicionGeneral_DeUsuarios_Password @User_ControlGreg_New,@Password_Control_New, @Cambio_Password OUTPUT;					
					IF NOT (@Cambio_Password = 1)
						BEGIN
						SET @PS_MESSAGE = 'Contrasena No Cambio'
						END				
					Else
						Begin
						SET @PS_MESSAGE = 'Contrasena Cambiada'
						END
				END
			PRINT CAST(@PS_MESSAGE AS VARCHAR(60))
			-- 
			--*/
			--RANK
			exec SP_EdicionGeneral_DeUsuarios_Rank_Control @User_ControlGreg_New, @Rank_New, @Cambio_Rank OUTPUT
			if not (@Cambio_Rank = 1)
				begin
					set @Rank_New = @Rank_Old;
					print 'Rango Cambiado' 
				end
			--tipo de pago
			exec SP_EdicionGeneral_DeUsuarios_TipoDePago @User_ControlGreg_New, @TipoDePago_New, @Cambio_TipoDePago OUTPUT
			if not (@Cambio_TipoDePago = 1)
				begin
					set @TipoDePago_New = @TipoDePago_Old;
					print 'Tipo de Pago Cambiado' 
				end
			-- Salario Por Hora
			exec SP_EdicionGeneral_DeUsuarios_SalarioPorHora @User_ControlGreg_New, @SalarioPorHora_New, @Cambio_SalarioPorHora OUTPUT
			if not (@Cambio_SalarioPorHora = 1)
				begin
					set @SalarioPorHora_New = @SalarioPorHora_Old;
					print 'Salario Por Hora Cambiado' 
				end
			--email
			exec SP_EdicionGeneral_DeUsuarios_Email @User_ControlGreg_New, @Email_New, @Cambio_Email OUTPUT
			if not (@Cambio_Email = 1)
				BEGIN
					set @Email_New = @Email_Old;
					print 'Email Cambiado' 
				END
		END
	IF(@Cambio_User = 1 or @Cambio_Password = 1 or @Cambio_Rank = 1 or @Cambio_TipoDePago = 1 or @Cambio_SalarioPorHora = 1 or @Cambio_Email = 1)
		begin		
		INSERT INTO registro_de_modificaciones
		(ID,User_ControlGreg_Old,User_ControlGreg_New,Password_Control_Old,Password_Control_New,Rank_Old, Rank_New, SalarioPorHora_Old,SalarioPorHora_New,TipoDePago_Old,TipoDePago_New,Email_Old,Email_New,Dia,Mes,Ano) VALUES
		(@ID,@User_ControlGreg_Old,@User_ControlGreg_New,@PS_MESSAGE,@PS_MESSAGE,@Rank_Old,@Rank_New,@SalarioPorHora_Old,@SalarioPorHora_New,@TipoDePago_Old,@TipoDePago_New,@Email_Old,@Email_New,@Dia,@Mes,@Ano)
		SET @EdicionCompletada = 'Se Aplicaron Los Cambios de Manera Exitosa'
		print 'SE MODIFICO ALGUN DATO' 
		end
	ELSE
		begin
		print 'NO HUBO CAMBIOS'
		end
END


/*                          FIN EDICION GENERAL           FIN EDICION GENERAL          FIN EDICION GENERAL          FIN EDICION GENERAL              */

/* FUNCIONES EDICION GENERAL*/
ALTER PROCEDURE SP_EdicionGeneral_DeUsuarios_Nombre --cambiando el nombre por partes
		@UsuarioActualEntrada as varchar(40),
		@UsuarioNombreRemplazo as varchar(40),
		@Cambio as INT OUTPUT
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @Password as varchar(40), @Rank as varchar(40), @SalarioPorHora as numeric(10,2), @TipoDePago as varchar(40);
		--DECLARE @Dia as INT = DAY(GETDATE()), @Mes as INT = MONTH(GETDATE()), @Ano as INT = YEAR(GETDATE());
		set @Cambio = 0;
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @UsuarioActualEntrada) and (@UsuarioActualEntrada <> @UsuarioNombreRemplazo)
			BEGIN
				IF (NOT EXISTS(select 1 from personal where User_ControlGreg = @UsuarioNombreRemplazo)) AND not @UsuarioNombreRemplazo = ''
					BEGIN
						SELECT @ID = ID, @Password = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @UsuarioActualEntrada;
						SELECT @SalarioPorHora = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @UsuarioActualEntrada;
						IF		EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
								EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
								EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada) AND --3
								EXISTS(SELECT 1 FROM salario_al_dia							WHERE ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada) AND --4
								EXISTS(SELECT 1 FROM salario_a_la_semana					WHERE ID_User = @ID AND User_ControlGreg_Salario = @UsuarioActualEntrada) AND --5
								EXISTS(SELECT 1 FROM tabla_por_pagar_y_registro_de_pagados	WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) --6
								BEGIN --EXISTE EL MISMO NOMBRE DE USUARIO EN TODAS LAS TABLAS -- 6
									PRINT 'EL USUARIO EXISTE EN TODAS LAS TABLAS, EL NOMBRE SERA MODIFICADO'
									PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos, salario_al_dia, salario_a_la_semana, tabla_por_pagar_y_registro_de_pagados'
									--INICIO DESACTIVAR LLAVES
									--1
									--2
									
									ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
									ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
									--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
									--3
									ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
									ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
									--4
									ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_SalarioAlDia_Personal;
									ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
									--5
									ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_SalarioALaSemana_Personal;
									ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
									--6
									ALTER TABLE tabla_por_pagar_y_registro_de_pagados NOCHECK CONSTRAINT FK_TablaPorPagarYRegistroDePagos_Personal;
									ALTER TABLE tabla_por_pagar_y_registro_de_pagados NOCHECK CONSTRAINT FK_Two_TablaPorPagarYRegistroDePagos_Personal;
									--FIN DESACTIVAR LLAVES
										
										UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID				AND User_ControlGreg = @UsuarioActualEntrada; --1
										UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
										UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
										UPDATE salario_al_dia set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Salario = @UsuarioActualEntrada; --4
										UPDATE salario_a_la_semana set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada; --5
										UPDATE tabla_por_pagar_y_registro_de_pagados set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --6
										
									--INICIO ACTIVAR LLAVES
									--1
									--2
									ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
									ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
									--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
									--3
									ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
									ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
									--4
									ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_SalarioAlDia_Personal;
									ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
									--5
									ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_SalarioALaSemana_Personal;
									ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
									--6
									ALTER TABLE tabla_por_pagar_y_registro_de_pagados CHECK CONSTRAINT FK_TablaPorPagarYRegistroDePagos_Personal;
									ALTER TABLE tabla_por_pagar_y_registro_de_pagados CHECK CONSTRAINT FK_Two_TablaPorPagarYRegistroDePagos_Personal;
									--FIN ACTIVAR LLAVES	
									--*/
									set @Cambio = 1;
								END
						ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
								EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
								EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada) AND --3
								EXISTS(SELECT 1 FROM salario_al_dia							WHERE ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada) AND --4
								EXISTS(SELECT 1 FROM salario_a_la_semana					WHERE ID_User = @ID AND User_ControlGreg_Salario = @UsuarioActualEntrada)--5
									BEGIN --5
										PRINT 'NO EXISTE EN LA TABLA DE PAGOS'
										PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos, salario_al_dia, salario_a_la_semana'
										
										--INICIO DESACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--3
										ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
										ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
										--4
										ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_SalarioAlDia_Personal;
										ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
										--5
										ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_SalarioALaSemana_Personal;
										ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
										--FIN DESACTIVAR LLAVES

											UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID				AND User_ControlGreg = @UsuarioActualEntrada; --1
											UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
											UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
											UPDATE salario_al_dia set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Salario = @UsuarioActualEntrada; --4
											UPDATE salario_a_la_semana set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada; --5
										
										--INICIO ACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--3
										ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
										ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
										--4
										ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_SalarioAlDia_Personal;
										ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
										--5
										ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_SalarioALaSemana_Personal;
										ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
										--FIN ACTIVAR LLAVES
										--*/
										set @Cambio = 1;
									END
						ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
								EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
								EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada) AND --3
								EXISTS(SELECT 1 FROM salario_al_dia							WHERE ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada)--4
									BEGIN --4
										PRINT 'NO EXISTE EN LA TABLA DE PAGOS Y EN EL DE LOS SALARIOS GENERADOS A LA SEMANA'
										PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos, salario_al_dia'
										
										--INICIO DESACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--3
										ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
										ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
										--4
										ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_SalarioAlDia_Personal;
										ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
										--FIN DESACTIVAR LLAVES
											UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID							AND User_ControlGreg = @UsuarioActualEntrada; --1
											UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
											UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
											UPDATE salario_al_dia set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Salario = @UsuarioActualEntrada; --4
										--INICIO ACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--3
										ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
										ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
										--4
										ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_SalarioAlDia_Personal;
										ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
										--FIN ACTIVAR LLAVES
										--*/
										set @Cambio = 1;
									END
						ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
								EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
								EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada)--3	
									BEGIN --3
										PRINT 'NO EXISTE EN LA TABLA DE PAGOS Y EN EL DE LOS SALARIOS GENERADOS A LA SEMANA, NI EN SALARIO AL DIA'
										PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos'
										
										--INICIO DESACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--3
										ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
										ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
										--FIN DESACTIVAR LLAVES
											UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID							AND User_ControlGreg = @UsuarioActualEntrada; --1
											UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
											UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
										--INICIO ACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--3
										ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
										ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
										--FIN ACTIVAR LLAVES
										--*/
										set @Cambio = 1;
									END
						ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
								EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada)--2	
									BEGIN --2
										PRINT 'NO EXISTE EN LA TABLA DE PAGOS, NI EN EL DE LOS SALARIOS GENERADOS A LA SEMANA, NI EN SALARIO AL DIA, NI CONTIENE ACCESOS'
										PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia'
										
										--INICIO DESACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--FIN DESACTIVAR LLAVES
											UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID							AND User_ControlGreg = @UsuarioActualEntrada; --1
											UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
										--INICIO ACTIVAR LLAVES
										--1
										--2
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
										ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
										--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
										--FIN ACTIVAR LLAVES
										--*/
										set @Cambio = 1;
									END
						ELSE
							BEGIN
								PRINT 'EL USUARIO NO EXISTE'
								set @Cambio = 0;
							END						
						END
					
				ELSE
					BEGIN
						PRINT 'No De Pudo Modificar, el Usuario Ya Existe'
						set @Cambio = 0;
					END
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE O ES EL MISMO AL ACTUAL'
				set @Cambio = 0;
			END
	--return @Cambio;
END
-----------------NOMBRE DE USUARIO GENERAL
--PASSWORD
ALTER PROCEDURE SP_EdicionGeneral_DeUsuarios_Password --actaliza la contrasena
    @Usuario AS VARCHAR(40),
    @PasswordRemplazo AS VARBINARY(512),
	@Cambio as INT OUTPUT
AS
BEGIN
    DECLARE @ID AS INT;
    DECLARE @PasswordActual AS VARBINARY(512), @Rank AS VARCHAR(40), @SalarioPorHora AS NUMERIC(10,2), @TipoDePago AS VARCHAR(40);
	SET @Cambio = 0

    IF EXISTS(SELECT 1 FROM personal WHERE User_ControlGreg = @Usuario)
    BEGIN
        PRINT 'USUARIO EXISTE';
        SELECT @ID = ID, @PasswordActual = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
        SELECT @SalarioPorHora = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia WHERE ID_User = @ID AND User_ControlGreg = @Usuario;

        -- Actualizar la contraseña
        UPDATE personal SET Password_Control = @PasswordRemplazo WHERE ID = @ID AND User_ControlGreg = @Usuario;
		SET @Cambio = 1
        -- Registrar la modificación
        
    END
    ELSE
    BEGIN
        PRINT 'EL USUARIO NO EXISTE, NO SE LE PUEDE CAMBIAR LA CONTRASEÑA';
		set @Cambio = 0
    END
END

--PASSWORD
---RANK
ALTER PROCEDURE SP_EdicionGeneral_DeUsuarios_Rank_Control --cambiando el nombre por partes
		@Usuario as varchar(40),
		@RankNew as varchar(40),
		@Cambio as INT OUTPUT
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @PasswordActual as varchar(40), @RankActual as varchar(40), @SalarioPorHora as numeric(10,2), @TipoDePago as varchar(40);
		set @Cambio = 0
		SELECT @ID = ID,  @PasswordActual = Password_Control, @RankActual = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
		SELECT @SalarioPorHora = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @Usuario;
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario) and (@RankActual <> @RankNew)
			BEGIN
			PRINT 'USUARIO EXISTE'				
					IF EXISTS(Select 1 from datos_pueden_ser_ranks where Ranks = @RankNew) and (@RankActual <> @RankNew)
						BEGIN
							print 'CAMBIANDO El Rango'
							update personal set Rank_Control = @RankNew where ID = @ID AND User_ControlGreg = @Usuario;
							set @Cambio = 1
						END
					ELSE
						BEGIN
							PRINT 'EL RANGO QUE QUIERE INTRODUCIR NO APARECE EN LISTA O ES EL MISMO AL ACTUAL'
							set @Cambio = 0
						END
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE O LO QUE DESEAS CAMBIAR ES EL MISMO AL DATO ACTUAL'
				set @Cambio = 0
			END
END
ALTER PROCEDURE SP_EdicionGeneral_DeUsuarios_TipoDePago --cambiando el nombre por partes
		@Usuario as varchar(40),
		@TipoDePagoNuevo as varchar(40),
		@Cambio as INT OUTPUT
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @PasswordActual as varchar(40), @Rank as varchar(40), @SalarioPorHora as numeric(10,2), @TipoDePagoActual as varchar(40);
		SET @Cambio = 0;
		SELECT @ID = ID,  @PasswordActual = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
		SELECT @SalarioPorHora = SalarioPorHora, @TipoDePagoActual = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @Usuario;
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario)
			BEGIN
			PRINT 'USUARIO EXISTE'
				
					IF EXISTS(Select 1 from datos_pueden_ser_tipodepago where TipoDePago = @TipoDePagoNuevo) and (@TipoDePagoActual <> @TipoDePagoNuevo)
						BEGIN
							print 'CAMBIANDO El TIPO DE PAGO'
							
							update salario_de_usuario_por_dia set TipoDePago = @TipoDePagoNuevo where ID_User = @ID AND User_ControlGreg = @Usuario;
							--*/
							SET @Cambio = 1;
						END
					ELSE
						BEGIN
							PRINT 'EL TIPO DE PAGO QUE QUIERE INTRODUCIR NO APARECE EN LISTA O ES EL MISMO AL ACTUAL'
							SET @Cambio = 0;
						END
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE O LO QUE DESEAS CAMBIAR ES EL MISMO AL DATO ACTUAL'
				SET @Cambio = 0; 
			END
END
-- SALARIO POR HORA
ALTER PROCEDURE SP_EdicionGeneral_DeUsuarios_SalarioPorHora --cambiando el nombre por partes
		@Usuario as varchar(40),
		@SalarioPorHoraNuevo as numeric(10,2),
		@Cambio as INT OUTPUT
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @PasswordActual as varchar(40), @Rank as varchar(40), @SalarioPorHoraActual as numeric(10,2), @TipoDePago as varchar(40);
		set @Cambio = 0;
		SELECT @ID = ID,  @PasswordActual = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
		SELECT @SalarioPorHoraActual = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @Usuario;
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario) and (@SalarioPorHoraActual <> @SalarioPorHoraNuevo)
			BEGIN
			PRINT 'USUARIO EXISTE'
					IF (@SalarioPorHoraNuevo>0)
						BEGIN
							print 'CAMBIANDO El SALARIO POR HORA'
							update salario_de_usuario_por_dia set SalarioPorHora = @SalarioPorHoraNuevo where ID_User = @ID AND User_ControlGreg = @Usuario;
							set @Cambio = 1;
						END
					ELSE
						BEGIN
							PRINT 'EL SALARIO POR HORA NO PUEDE SER DE $0 O MENOR'
							set @Cambio = 0;
						END
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE O LO QUE DESEAS CAMBIAR ES EL MISMO AL DATO ACTUAL'
			END
END

ALTER PROCEDURE SP_EdicionGeneral_DeUsuarios_Email
	@Usuario as varchar(40),
	@Email_New AS VARCHAR(100),
	@Cambio as INT OUTPUT
AS BEGIN
	DECLARE @ID AS INT;
	DECLARE @PasswordActual as varchar(40), @Rank as varchar(40), @SalarioPorHoraActual as numeric(10,2), @TipoDePago as varchar(40), @EmailActual as varchar(100);
	set @Cambio = 0;
	SELECT @ID = ID,  @PasswordActual = Password_Control, @Rank = Rank_Control, @EmailActual = email FROM personal WHERE User_ControlGreg = @Usuario;
	SELECT @SalarioPorHoraActual = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @Usuario;
	IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario) and (@EmailActual <> @Email_New)
		BEGIN
				
		IF(EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario AND email = @EmailActual)and Exists(select 1 from correo_puede_ser where @Email_New like '%'+correo))
			BEGIN
				PRINT 'EMAIL CAMBIADO'
				UPDATE personal set email  = @Email_New where User_ControlGreg = @Usuario AND email = @EmailActual;
				set @Cambio =1;
			END
		ELSE
			BEGIN
			PRINT 'EMAIL SIN CAMBIAR, EMAIL NO CONCUERDA CON USUARIO O NO EXISTE EMAIL CON ESA TERMINACION'
			SET @Cambio =0;
			END
		END
	ELSE
		BEGIN
		PRINT 'EL USUARIO NO EXISTE O LO QUE DESEAS CAMBIAR ES EL MISMO AL DATO ACTUAL'
		SET @Cambio =0;
		END

END
/* FUNCIONES EDICION GEENRAL END */




--Edicion del nombre de usuario
CREATE PROCEDURE SP_Edicion_DeUsuarios_Nombre --cambiando el nombre por partes
		@UsuarioActualEntrada as varchar(40),
		@UsuarioNombreRemplazo as varchar(40)
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @Password as varchar(40), @Rank as varchar(40), @SalarioPorHora as numeric(10,2), @TipoDePago as varchar(40);
		DECLARE @Dia as INT = DAY(GETDATE()), @Mes as INT = MONTH(GETDATE()), @Ano as INT = YEAR(GETDATE());
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @UsuarioActualEntrada)
			BEGIN
				SELECT @ID = ID, @Password = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @UsuarioActualEntrada;
				SELECT @SalarioPorHora = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @UsuarioActualEntrada;
				IF		EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
						EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
						EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada) AND --3
						EXISTS(SELECT 1 FROM salario_al_dia							WHERE ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada) AND --4
						EXISTS(SELECT 1 FROM salario_a_la_semana					WHERE ID_User = @ID AND User_ControlGreg_Salario = @UsuarioActualEntrada) AND --5
						EXISTS(SELECT 1 FROM tabla_por_pagar_y_registro_de_pagados	WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) --6
						BEGIN --EXISTE EL MISMO NOMBRE DE USUARIO EN TODAS LAS TABLAS -- 6
							PRINT 'EL USUARIO EXISTE EN TODAS LAS TABLAS, EL NOMBRE SERA MODIFICADO'
							PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos, salario_al_dia, salario_a_la_semana, tabla_por_pagar_y_registro_de_pagados'
							--INICIO DESACTIVAR LLAVES
							--1
							--2
							ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
							ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
							--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
							--3
							ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
							ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
							--4
							ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_SalarioAlDia_Personal;
							ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
							--5
							ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_SalarioALaSemana_Personal;
							ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
							--6
							ALTER TABLE tabla_por_pagar_y_registro_de_pagados NOCHECK CONSTRAINT FK_TablaPorPagarYRegistroDePagos_Personal;
							ALTER TABLE tabla_por_pagar_y_registro_de_pagados NOCHECK CONSTRAINT FK_Two_TablaPorPagarYRegistroDePagos_Personal;
							--FIN DESACTIVAR LLAVES

								UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID				AND User_ControlGreg = @UsuarioActualEntrada; --1
								UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
								UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
								UPDATE salario_al_dia set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Salario = @UsuarioActualEntrada; --4
								UPDATE salario_a_la_semana set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada; --5
								UPDATE tabla_por_pagar_y_registro_de_pagados set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --6
					
							--INICIO ACTIVAR LLAVES
							--1
							--2
							ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
							ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
							--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
							--3
							ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
							ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
							--4
							ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_SalarioAlDia_Personal;
							ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
							--5
							ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_SalarioALaSemana_Personal;
							ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
							--6
							ALTER TABLE tabla_por_pagar_y_registro_de_pagados CHECK CONSTRAINT FK_TablaPorPagarYRegistroDePagos_Personal;
							ALTER TABLE tabla_por_pagar_y_registro_de_pagados CHECK CONSTRAINT FK_Two_TablaPorPagarYRegistroDePagos_Personal;
							--FIN ACTIVAR LLAVES	
							
						END
				ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
						EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
						EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada) AND --3
						EXISTS(SELECT 1 FROM salario_al_dia							WHERE ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada) AND --4
						EXISTS(SELECT 1 FROM salario_a_la_semana					WHERE ID_User = @ID AND User_ControlGreg_Salario = @UsuarioActualEntrada)--5
							BEGIN --5
								PRINT 'NO EXISTE EN LA TABLA DE PAGOS'
								PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos, salario_al_dia, salario_a_la_semana'
								--INICIO DESACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--3
								ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
								ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
								--4
								ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_SalarioAlDia_Personal;
								ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
								--5
								ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_SalarioALaSemana_Personal;
								ALTER TABLE salario_a_la_semana NOCHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
								--FIN DESACTIVAR LLAVES
									UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID				AND User_ControlGreg = @UsuarioActualEntrada; --1
									UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
									UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
									UPDATE salario_al_dia set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Salario = @UsuarioActualEntrada; --4
									UPDATE salario_a_la_semana set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada; --5
								--INICIO ACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--3
								ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
								ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
								--4
								ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_SalarioAlDia_Personal;
								ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
								--5
								ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_SalarioALaSemana_Personal;
								ALTER TABLE salario_a_la_semana CHECK CONSTRAINT FK_Two_SalarioALaSemana_Personal;
								--FIN ACTIVAR LLAVES
							END
				ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
						EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
						EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada) AND --3
						EXISTS(SELECT 1 FROM salario_al_dia							WHERE ID_User = @ID	AND User_ControlGreg_Salario = @UsuarioActualEntrada)--4
							BEGIN --4
								PRINT 'NO EXISTE EN LA TABLA DE PAGOS Y EN EL DE LOS SALARIOS GENERADOS A LA SEMANA'
								PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos, salario_al_dia'
								--INICIO DESACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--3
								ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
								ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
								--4
								ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_SalarioAlDia_Personal;
								ALTER TABLE salario_al_dia NOCHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
								--FIN DESACTIVAR LLAVES
									UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID							AND User_ControlGreg = @UsuarioActualEntrada; --1
									UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
									UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
									UPDATE salario_al_dia set User_ControlGreg_Salario = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Salario = @UsuarioActualEntrada; --4
								--INICIO ACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--3
								ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
								ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
								--4
								ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_SalarioAlDia_Personal;
								ALTER TABLE salario_al_dia CHECK CONSTRAINT FK_Two_SalarioAlDia_Personal;
								--FIN ACTIVAR LLAVES
							END
				ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
						EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada) AND --2
						EXISTS(SELECT 1 FROM control_de_accesos						WHERE ID_User = @ID	AND User_ControlGreg_Time = @UsuarioActualEntrada)--3	
							BEGIN --3
								PRINT 'NO EXISTE EN LA TABLA DE PAGOS Y EN EL DE LOS SALARIOS GENERADOS A LA SEMANA, NI EN SALARIO AL DIA'
								PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia, control_de_accesos'
								--INICIO DESACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--3
								ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_ControlAccesos_Personal;
								ALTER TABLE control_de_accesos NOCHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
								--FIN DESACTIVAR LLAVES
									UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID							AND User_ControlGreg = @UsuarioActualEntrada; --1
									UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
									UPDATE control_de_accesos set User_ControlGreg_Time = @UsuarioNombreRemplazo where ID_User = @ID		AND User_ControlGreg_Time = @UsuarioActualEntrada; --3
								--INICIO ACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--3
								ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_ControlAccesos_Personal;
								ALTER TABLE control_de_accesos CHECK CONSTRAINT FK_Two_ControlAccesos_Personal;
								--FIN ACTIVAR LLAVES
							END
				ELSE IF EXISTS(SELECT 1 FROM personal								where ID = @ID		AND User_ControlGreg = @UsuarioActualEntrada) AND --1
						EXISTS(SELECT 1 FROM salario_de_usuario_por_dia				WHERE ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada)--2	
							BEGIN --2
								PRINT 'NO EXISTE EN LA TABLA DE PAGOS, NI EN EL DE LOS SALARIOS GENERADOS A LA SEMANA, NI EN SALARIO AL DIA, NI CONTIENE ACCESOS'
								PRINT 'MODIFICANDO EN: peronal, salario_de_usuario_por_dia'
								--INICIO DESACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia NOCHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--FIN DESACTIVAR LLAVES
									UPDATE personal set User_ControlGreg = @UsuarioNombreRemplazo where ID = @ID							AND User_ControlGreg = @UsuarioActualEntrada; --1
									UPDATE salario_de_usuario_por_dia set User_ControlGreg = @UsuarioNombreRemplazo where ID_User = @ID	AND User_ControlGreg = @UsuarioActualEntrada; --2
								--INICIO ACTIVAR LLAVES
								--1
								--2
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_One_salario_de_usuario_por_dia_personal;
								ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_Two_salario_de_usuario_por_dia_personal;
								--ALTER TABLE salario_de_usuario_por_dia CHECK CONSTRAINT FK_salario_de_usuario_por_dia_personal;
								--FIN ACTIVAR LLAVES
							END
				ELSE
					BEGIN
						PRINT 'EL USUARIO NO EXISTE'
					END
				INSERT INTO registro_de_modificaciones (ID,User_ControlGreg_Old,User_ControlGreg_New,Password_Control_Old,Password_Control_New,Rank_Old, Rank_New,
							SalarioPorHora_Old,SalarioPorHora_New,TipoDePago_Old,TipoDePago_New,Dia,Mes,Ano)
					VALUES(@ID,@UsuarioActualEntrada,@UsuarioNombreRemplazo, @Password,@Password, @Rank, @Rank, @SalarioPorHora, @SalarioPorHora, @TipoDePago,@TipoDePago,
									@Dia, @Mes, @Ano);
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE'
			END
END
--Editar Password
CREATE PROCEDURE SP_Edicion_DeUsuarios_Password --actaliza la contrasena
    @Usuario AS VARCHAR(40),
    @PasswordRemplazo AS VARBINARY(512)
AS
BEGIN
    DECLARE @ID AS INT;
    DECLARE @PasswordActual AS VARBINARY(512), @Rank AS VARCHAR(40), @SalarioPorHora AS NUMERIC(10,2), @TipoDePago AS VARCHAR(40);
    DECLARE @Dia AS INT = DAY(GETDATE()), @Mes AS INT = MONTH(GETDATE()), @Ano AS INT = YEAR(GETDATE());

    IF EXISTS(SELECT 1 FROM personal WHERE User_ControlGreg = @Usuario)
    BEGIN
        PRINT 'USUARIO EXISTE';
        SELECT @ID = ID, @PasswordActual = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
        SELECT @SalarioPorHora = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia WHERE ID_User = @ID AND User_ControlGreg = @Usuario;

        -- Actualizar la contraseña
        UPDATE personal SET Password_Control = @PasswordRemplazo WHERE ID = @ID AND User_ControlGreg = @Usuario;

        -- Registrar la modificación
        INSERT INTO registro_de_modificaciones (
            ID, User_ControlGreg_Old, User_ControlGreg_New, Password_Control_Old, Password_Control_New, Rank_Old, Rank_New,
            SalarioPorHora_Old, SalarioPorHora_New, TipoDePago_Old, TipoDePago_New, Dia, Mes, Ano
        )
        VALUES (
            @ID, @Usuario, @Usuario, 'OldPassword', 'NewPassword', @Rank, @Rank, @SalarioPorHora, @SalarioPorHora,
            @TipoDePago, @TipoDePago, @Dia, @Mes, @Ano
        );
    END
    ELSE
    BEGIN
        PRINT 'EL USUARIO NO EXISTE, NO SE LE PUEDE CAMBIAR LA CONTRASEÑA';
    END
END

--Actualizar el Rango
CREATE PROCEDURE SP_Edicion_DeUsuarios_Rank_Control --cambiando el nombre por partes
		@Usuario as varchar(40),
		@RankNew as varchar(40)
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @PasswordActual as varchar(40), @RankActual as varchar(40), @SalarioPorHora as numeric(10,2), @TipoDePago as varchar(40);
		DECLARE @Dia as INT = DAY(GETDATE()), @Mes as INT = MONTH(GETDATE()), @Ano as INT = YEAR(GETDATE());
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario)
			BEGIN
			PRINT 'USUARIO EXISTE'
				SELECT @ID = ID,  @PasswordActual = Password_Control, @RankActual = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
				SELECT @SalarioPorHora = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @Usuario;
					IF EXISTS(Select 1 from datos_pueden_ser_ranks where Ranks = @RankNew)
						BEGIN
							print 'CAMBIANDO El Rango'
							update personal set Rank_Control = @RankNew where ID = @ID AND User_ControlGreg = @Usuario;
							INSERT INTO registro_de_modificaciones (ID,User_ControlGreg_Old,User_ControlGreg_New,Password_Control_Old,Password_Control_New,Rank_Old, Rank_New,
								SalarioPorHora_Old,SalarioPorHora_New,TipoDePago_Old,TipoDePago_New,Dia,Mes,Ano)
							VALUES(@ID,@Usuario,@Usuario, @PasswordActual, @PasswordActual, @RankActual, @RankNew, @SalarioPorHora, @SalarioPorHora, @TipoDePago,@TipoDePago,@Dia, @Mes, @Ano);
						END
					ELSE
						BEGIN
							PRINT 'EL RANGO QUE QUIERE INTRODUCIR NO APARECE EN LISTA'
						END
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE, NO SE LE PUEDE CAMBIAR LA CONTRASENA'
			END
END
--Tipo de Pago..Semanal y eso
CREATE PROCEDURE SP_Edicion_DeUsuarios_TipoDePago --cambiando el nombre por partes
		@Usuario as varchar(40),
		@TipoDePagoNuevo as varchar(40)
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @PasswordActual as varchar(40), @Rank as varchar(40), @SalarioPorHora as numeric(10,2), @TipoDePagoActual as varchar(40);
		DECLARE @Dia as INT = DAY(GETDATE()), @Mes as INT = MONTH(GETDATE()), @Ano as INT = YEAR(GETDATE());
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario)
			BEGIN
			PRINT 'USUARIO EXISTE'
				SELECT @ID = ID,  @PasswordActual = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
				SELECT @SalarioPorHora = SalarioPorHora, @TipoDePagoActual = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @Usuario;
					IF EXISTS(Select 1 from datos_pueden_ser_tipodepago where TipoDePago = @TipoDePagoNuevo)
						BEGIN
							print 'CAMBIANDO El TIPO DE PAGO'
							update salario_de_usuario_por_dia set TipoDePago = @TipoDePagoNuevo where ID_User = @ID AND User_ControlGreg = @Usuario;
							INSERT INTO registro_de_modificaciones (ID,User_ControlGreg_Old,User_ControlGreg_New,Password_Control_Old,Password_Control_New,Rank_Old, Rank_New,
								SalarioPorHora_Old,SalarioPorHora_New,TipoDePago_Old,TipoDePago_New,Dia,Mes,Ano)
							VALUES(@ID,@Usuario,@Usuario, @PasswordActual, @PasswordActual, @Rank, @Rank, @SalarioPorHora, @SalarioPorHora, @TipoDePagoActual,@TipoDePagoNuevo,@Dia, @Mes, @Ano);--*/
						END
					ELSE
						BEGIN
							PRINT 'EL TIPO DE PAGO QUE QUIERE INTRODUCIR NO APARECE EN LISTA'
						END
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE, NO SE LE PUEDE CAMBIAR LA CONTRASENA'
			END
END
-- CUANTO GANA POR HORA
CREATE PROCEDURE SP_Edicion_DeUsuarios_SalarioPorHora --cambiando el nombre por partes
		@Usuario as varchar(40),
		@SalarioPorHoraNuevo as numeric(10,2)
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @PasswordActual as varchar(40), @Rank as varchar(40), @SalarioPorHoraActual as numeric(10,2), @TipoDePago as varchar(40);
		DECLARE @Dia as INT = DAY(GETDATE()), @Mes as INT = MONTH(GETDATE()), @Ano as INT = YEAR(GETDATE());
		IF EXISTS(SELECT 1 FROM personal where User_ControlGreg = @Usuario)
			BEGIN
			PRINT 'USUARIO EXISTE'
				SELECT @ID = ID,  @PasswordActual = Password_Control, @Rank = Rank_Control FROM personal WHERE User_ControlGreg = @Usuario;
				SELECT @SalarioPorHoraActual = SalarioPorHora, @TipoDePago = TipoDePago FROM salario_de_usuario_por_dia where ID_User = @ID AND User_ControlGreg = @Usuario;
					IF (@SalarioPorHoraNuevo>0)
						BEGIN
							print 'CAMBIANDO El SALARIO POR HORA'
							update salario_de_usuario_por_dia set SalarioPorHora = @SalarioPorHoraNuevo where ID_User = @ID AND User_ControlGreg = @Usuario;
							INSERT INTO registro_de_modificaciones (ID,User_ControlGreg_Old,User_ControlGreg_New,Password_Control_Old,Password_Control_New,Rank_Old, Rank_New,
								SalarioPorHora_Old,SalarioPorHora_New,TipoDePago_Old,TipoDePago_New,Dia,Mes,Ano)
							VALUES(@ID,@Usuario,@Usuario, @PasswordActual, @PasswordActual, @Rank, @Rank, @SalarioPorHoraActual, @SalarioPorHoraNuevo, @TipoDePago,@TipoDePago,@Dia, @Mes, @Ano);--*/
						END
					ELSE
						BEGIN
							PRINT 'EL SALARIO POR HORA NO PUEDE SER DE $0 O MENOR'
						END
			END
		ELSE
			BEGIN
				PRINT 'EL USUARIO NO EXISTE, NO SE LE PUEDE CAMBIAR LA CONTRASENA'
			END
END
--Editar Hora de Entrada o Salida
CREATE PROCEDURE SP_EditarHoraDe_Entrada_Salida
		@Dia as INT,
		@Mes as INT,
		@Ano as INT,
		@Usuario as Varchar(40),
		@OpcionARealizar as INT,
		@Hora as INT,
		@Minuto as INT
	AS BEGIN
		DECLARE  @FechaIngresada as DATE;
		DECLARE @FechaActual as DATE = GETDATE();
		DECLARE @UltimoMartes as DATE;
		DECLARE @ProximoMartes as DATE;

		IF NOT EXISTS (SELECT 1 FROM personal WHERE User_ControlGreg = @Usuario)--No puedes editar algo que no existe
				BEGIN
					PRINT 'El usuario no existe en la tabla personal.';
					RETURN;
				END
		SET @FechaIngresada = DATEFROMPARTS(@Ano, @Mes, @Dia);
		SET @UltimoMartes = DATEADD(DAY, - (DATEPART(WEEKDAY, GETDATE()) + 4) % 7, GETDATE());
		SET @ProximoMartes = DATEADD(DAY,7 - (DATEPART(WEEKDAY, GETDATE()) + 4) % 7, GETDATE());
			IF ((@FechaIngresada >= @UltimoMartes) and (@FechaIngresada < @ProximoMartes))
				BEGIN
					PRINT 'El Valor esta dentro del rango editable';
						IF(@OpcionARealizar = 1)
							BEGIN
								PRINT 'Configurando la hora de entrada'
								exec SP_Configurar_HoraDeEntrada @Dia,@Mes,@Ano,@Usuario, @Hora,@Minuto
							END
						ELSE IF (@OpcionARealizar = 2) --Configurando Hora de Salida
							BEGIN
								EXEC SP_Configurar_HoraDeSalida @Dia,@Mes,@Ano,@Usuario, @Hora,@Minuto
							END
				END
		ELSE
				BEGIN
					PRINT 'Esta fecha no puede ser editada, solo puedes editar la fecha dentro del rango de Martes a Lunes de la semana actual, no de una que ya cerro';
				END
END
--HORA DE ENTRADA
CREATE PROCEDURE SP_Configurar_HoraDeEntrada
		@Dia as INT,
		@Mes as INT,
		@Ano as INT,
		@Usuario as Varchar(40),
		@HoraIntroducir as INT,
		@MinutoIntroducir as INT
	AS BEGIN
		DECLARE @HoraFinal_Mostrar AS INT;
		DECLARE @HoraInicial_Mostrar AS INT;
		DECLARE @MinutoMinimo_Mostrar AS INT;
		DECLARE @MinutoMaximo_Mostrar AS INT;
		DECLARE @ID AS INT;
		SELECT @ID = ID FROM personal WHERE User_ControlGreg = @Usuario
			IF NOT EXISTS (SELECT 1 FROM personal WHERE User_ControlGreg = @Usuario) --solo por si acaso
				BEGIN
					PRINT 'El usuario no existe en la tabla personal.';
					RETURN;
				END
		-- Obtener las HORAS mínimos y máximos
		EXEC ObtenerHoraMinimaAndMaxima @Ano, @Mes, @Dia, @Usuario, 
			@HoraFinal = @HoraFinal_Mostrar OUTPUT, 
			@HoraInicial = @HoraInicial_Mostrar OUTPUT;	

		-- Obtener los minutos mínimos y máximos
		EXEC ObtenerMinutoMinimoAndMaximo @Ano, @Mes, @Dia, @Usuario, 
			@HoraInicial_Mostrar, @HoraFinal_Mostrar, 
			@MinutoMinimo = @MinutoMinimo_Mostrar OUTPUT, 
			@MinutoMaximo = @MinutoMaximo_Mostrar OUTPUT;

		IF NOT EXISTS(SELECT 1 FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia)
			BEGIN
			print 'NO EXISTEN REGISTROS ESTA FECHA'
				INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
			END
		ELSE
			BEGIN	
				IF(@HoraIntroducir > @HoraFinal_Mostrar) --1
					BEGIN
						print 'La Hora de inicio supera a la de final, se eliminaran todos los registros'
								DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia;
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
					END
				
				ELSE IF(@HoraIntroducir = @HoraFinal_Mostrar) --La Hora de inicio supera a la de final --1
					BEGIN
						print 'La Hora de inicio es igual a la del Final'
						IF(@MinutoIntroducir > @MinutoMaximo_Mostrar) --2
							BEGIN
								DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia;
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END
						ELSE IF(@HoraIntroducir = @HoraInicial_Mostrar)--2
							BEGIN
								IF(@MinutoIntroducir > @MinutoMinimo_Mostrar) --3
									BEGIN
										DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia AND NOT( Hora = @HoraFinal_Mostrar and Minuto = @MinutoMaximo_Mostrar);
										INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
									END
								ELSE IF(@MinutoIntroducir <= @MinutoMinimo_Mostrar) --3
									BEGIN
										INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
									END
							END
						ELSE --2
							BEGIN
								print 'El Minuto de inicio es igual o menor a la de final, se eliminaran todos los registros menos el de salida'								
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END
						END
				ELSE IF(@HoraIntroducir > @HoraInicial_Mostrar)
					BEGIN
						DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia AND NOT(Hora = @HoraFinal_Mostrar and Minuto = @MinutoMaximo_Mostrar);
						INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
					END
				ELSE IF(@HoraIntroducir = @HoraInicial_Mostrar) --1
					BEGIN
						IF(@MinutoIntroducir > @MinutoMinimo_Mostrar) --2
							BEGIN
								DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia AND NOT( Hora = @HoraFinal_Mostrar and Minuto = @MinutoMaximo_Mostrar);
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END
						ELSE IF(@MinutoIntroducir <= @MinutoMinimo_Mostrar) --2
							BEGIN
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END
					END
				
				ELSE IF(@HoraIntroducir < @HoraInicial_Mostrar) --1
					BEGIN
						print 'La Hora de inicio es menor a la de Entrada'
						INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
					END
				print 'GENERANDO EL SALARIO DIARIO'
				exec GenerarSalarioDiario @Dia,@Mes,@Ano, @Usuario
			END--*/
	
END
------------------CONFIGURAR LA SALIDA
CREATE PROCEDURE SP_Configurar_HoraDeSalida
		@Dia as INT,
		@Mes as INT,
		@Ano as INT,
		@Usuario as Varchar(40),
		@HoraIntroducir as INT,
		@MinutoIntroducir as INT
	AS BEGIN
		DECLARE @HoraFinal_Mostrar AS INT;
		DECLARE @HoraInicial_Mostrar AS INT;
		DECLARE @MinutoMinimo_Mostrar AS INT;
		DECLARE @MinutoMaximo_Mostrar AS INT;
		DECLARE @ID AS INT;
		SELECT @ID = ID FROM personal WHERE User_ControlGreg = @Usuario
			IF NOT EXISTS (SELECT 1 FROM personal WHERE User_ControlGreg = @Usuario) --solo por si acaso
				BEGIN
					PRINT 'El usuario no existe en la tabla personal.';
					RETURN;
				END
		-- Obtener las HORAS mínimos y máximos
		EXEC ObtenerHoraMinimaAndMaxima @Ano, @Mes, @Dia, @Usuario, 
			@HoraFinal = @HoraFinal_Mostrar OUTPUT, 
			@HoraInicial = @HoraInicial_Mostrar OUTPUT;	

		-- Obtener los minutos mínimos y máximos
		EXEC ObtenerMinutoMinimoAndMaximo @Ano, @Mes, @Dia, @Usuario, 
			@HoraInicial_Mostrar, @HoraFinal_Mostrar, 
			@MinutoMinimo = @MinutoMinimo_Mostrar OUTPUT, 
			@MinutoMaximo = @MinutoMaximo_Mostrar OUTPUT;

		IF NOT EXISTS(SELECT 1 FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia)
			BEGIN
			print 'NO EXISTEN REGISTROS ESTA FECHA'
				INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
			END
		ELSE
			BEGIN	
				IF(@HoraIntroducir < @HoraInicial_Mostrar) --1
					BEGIN
						DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia;
						INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
					END
				ELSE IF(@HoraIntroducir = @HoraInicial_Mostrar) --1
					BEGIN
						IF(@MinutoIntroducir <= @MinutoMinimo_Mostrar) --2
							BEGIN
								DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia;
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END	
						ELSE IF(@HoraIntroducir = @HoraFinal_Mostrar) --2
							BEGIN
								IF(@MinutoIntroducir < @MinutoMaximo_Mostrar) --3
									BEGIN
										DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia AND NOT(Hora = @HoraInicial_Mostrar AND Minuto = @MinutoMinimo_Mostrar);
										INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
									END
								ELSE IF( @MinutoIntroducir >= @MinutoMaximo_Mostrar) --3
									BEGIN
										INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
									END
							END
						ELSE --2
							BEGIN
								DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia AND NOT( Hora = @HoraInicial_Mostrar and Minuto = @MinutoMinimo_Mostrar);
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END
					END
				ELSE IF(@HoraIntroducir = @HoraFinal_Mostrar) --1
					BEGIN
						IF(@MinutoIntroducir < @MinutoMaximo_Mostrar)
							BEGIN
								DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia AND NOT(Hora = @HoraInicial_Mostrar AND Minuto = @MinutoMinimo_Mostrar);
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END
						ELSE IF(@MinutoIntroducir >= @MinutoMaximo_Mostrar)
							BEGIN
								INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
							END
					END
				ELSE IF(@HoraIntroducir < @HoraFinal_Mostrar)--1
					Begin
						DELETE FROM control_de_accesos where User_ControlGreg_Time = @Usuario AND Mes = @Mes AND Ano = @Ano AND Dia = @Dia AND NOT( Hora = @HoraInicial_Mostrar and Minuto = @MinutoMinimo_Mostrar);
						INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
					end
				ELSE IF(@HoraIntroducir > @HoraFinal_Mostrar)--1
					Begin
						INSERT INTO control_de_accesos (ID_User, User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto) VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @HoraIntroducir, @MinutoIntroducir);
					end
				print 'GENERANDO EL SALARIO DIARIO'
				exec GenerarSalarioDiario @Dia,@Mes,@Ano, @Usuario
			END--*/
	
END

/*------------------------------------------------------------------------------------------------------------------------------*/





/*Esta funcion realiza la accion de informar en que semana del mes estamos
*/
/*-------------CALCULANDO EN QUE SEMANA ESTAMOS Y QUE MES TIENE 31,30 DIAS, FEBRERO ES ESPECIAL-------------------------*/
CREATE PROCEDURE CalcularSemanaDelMes
		@Dia as INT,
		@Mes as INT,
		@Ano as INT,
		@SemanaDelMes as INT OUTPUT
	AS BEGIN
		DECLARE @Fecha DATE;
		DECLARE @PrimerDiaDelMes DATE;
		DECLARE @SemanaActual INT;
		DECLARE @DiaDeLaSemanaPrimerDia INT;
		DECLARE @SemanaInicioMes INT;	

		IF @Dia <= 0 OR @Dia > 31 OR @Mes <= 0 OR @Mes > 12 OR @Ano <= 0
			BEGIN
				RAISERROR('Fecha inválida proporcionada. Verifique el día, mes y año.', 16, 1);
				RETURN set @SemanaActual = 0;
			END
		ELSE
			BEGIN
				--SET DATEFIRST 2; --Establecemso que la semana inicie por el dia martes
				SET @Fecha = DATEFROMPARTS(@Ano, @Mes, @Dia); --creamos la fecha con los datos proporcionados
				SET @PrimerDiaDelMes = DATEFROMPARTS(@Ano,@Mes,1) --Primer dia del mes
				--SET @Fecha = DATEADD(DAY, - (DATEPART(WEEKDAY, @Fecha) - 2), @Fecha); --Forzamos que la semanas inicien por el dia martes (2), 1 es lunes
			
				SET @SemanaActual = DATEPART(WEEK, @Fecha); 
				SET @SemanaInicioMes = DATEPART(WEEK, @PrimerDiaDelMes);--Obtenemos la semana actual
			
				SET @SemanaDelMes = @SemanaActual - @SemanaInicioMes + 1; --Obtenemos la semana
			END
END --*/

-- */

CREATE PROCEDURE MesTreinaOTreintaiuno --Calculamos si el mes tiene 30 o 31 dias a excepcion de febrero
		@Mes_MTT AS INT,              -- Mes que pedimos
		@Ano_MTT AS INT,			  -- Año para controlar a febrero
		@Answer_MTT AS INT OUTPUT     -- Variable de salida para el número de días
	AS
	BEGIN    
		DECLARE @MesTreintaiuno TABLE (MesTreintaiuno INT); -- Tabla o arreglo de meses con 31 días
		INSERT INTO @MesTreintaiuno VALUES (1), (3), (5), (7), (8), (10), (12);

		DECLARE @MesTreinta TABLE (MesTreinta INT); -- Tabla arreglo de meses con 30 días
		INSERT INTO @MesTreinta VALUES (4), (6), (9), (11);

		IF EXISTS (SELECT 1 FROM @MesTreintaiuno WHERE MesTreintaiuno = @Mes_MTT) -- Verificar si el mes tiene 31 días
			BEGIN
				SET @Answer_MTT = 31;
			END
    
		ELSE IF EXISTS (SELECT 1 FROM @MesTreinta WHERE MesTreinta = @Mes_MTT) -- Verificar si el mes tiene 30 días
			BEGIN
				SET @Answer_MTT = 30;
			END
    
		ELSE IF @Mes_MTT = 2 -- Si el mes es febrero entonces
			IF (@Ano_MTT % 4 = 0 AND @Ano_MTT % 100 != 0) OR (@Ano_MTT % 400 = 0) --si es multiplo de 400 es viciesto
				BEGIN
					SET @Answer_MTT = 29;
				END
			ELSE
				BEGIN
					SET @Answer_MTT = 28;
				END
		ELSE
		BEGIN
			SET @Answer_MTT = -1; -- Valor por defecto para un mes no válido
		END
END;
/*------------------------FIN CALCULAR SEMANA Y DIA EN EL QUE ESTAMOS-----------------------*/



/*----------------CALCULAMOS EL SALARIO AL DIA (SE PUEDE MODIFICAR SIEMPRE Y CUANDO NO HAYA SIDO UNA SEMANA QUE YA PASO)----------*/
/*----------------CALCULAMOS EL SALARIO DE MANERA SEMANAL------------------------------------------------------------------------*/
--Empieza Codigo Para Los Salarios
--Salario Semanal, si es martes solo generara desde el lunes (dia anterior) hasta el martes de la semana pasada
--Tener en consideracion: si se corre un dia que no es martes el dia>al siguiente martes entonces va a buscar el dia que fue martes anterior
--Si lo encuentra entonces contara 7 dias hacia atras
CREATE PROCEDURE CalcularSalarioSemana
		@Dia INT,
		@Mes INT,
		@Ano INT,
		@Usuario VARCHAR(40)
	AS BEGIN
		DECLARE @ID AS INT;
		DECLARE @DiaPrograma AS INT = @Dia;
		DECLARE @DiaPrograma_Final AS INT = @Dia; -- Inicializamos con el día actual
		DECLARE @MesPrograma AS INT = @Mes;
		DECLARE @MesPrograma_Final AS INT = @Mes;
		DECLARE @AnoPrograma AS INT = @Ano;
		DECLARE @AnoPrograma_Final AS INT = @Ano;
		DECLARE @SemanaDelMesA AS INT;
		DECLARE @SemanaDelMesB AS INT;
		DECLARE @i AS INT = 7;
		DECLARE @SalarioSemanal AS NUMERIC(10,2) = 0;
		DECLARE @SalarioSemanalTemporal AS NUMERIC(10,2) = 0;
		DECLARE @NombreDelDia AS VARCHAR(10);
		declare @DiasMesAnterior as int;
		declare @HorasAcumuladas_S as INT =0;
		declare @HoraTemporal as INT;
		declare @MinutosAcumulados_S as INT =0;
		declare @MinutoTemporal as INT;
		declare @HoraAdicional as INT = 0;
		declare @MinRestar as INT = 0;

		--Necesitamos comprobar si el dia es martes TEXTUALMENTE
		SELECT @ID = ID from personal where User_ControlGreg = @Usuario
		SELECT @NombreDelDia = DATENAME(WEEKDAY, DATEFROMPARTS(@Ano, @Mes, @Dia))--Dia Especifico
			While ((@NombreDelDia <> 'Martes') AND (@NombreDelDia <> 'Tuesday'))
				begin
					set @DiaPrograma -=1;
					--set @DiaPrograma_Final = @DiaPrograma;
					IF (@DiaPrograma <= 0)
						begin
							SET @MesPrograma -= 1						
							IF (@MesPrograma <=0)
								begin
									set @MesPrograma = 12;
									set @AnoPrograma -=1; 
									--set @MesPrograma_Final = @MesPrograma;
									--set @AnoPrograma_Final = @AnoPrograma; 
								end
							exec MesTreinaOTreintaiuno @MesPrograma, @AnoPrograma, @DiasMesAnterior OUTPUT	
							SET @DiaPrograma = @DiasMesAnterior;
						end
					SELECT @NombreDelDia = DATENAME(WEEKDAY, DATEFROMPARTS(@AnoPrograma, @MesPrograma, @DiaPrograma))--Dia Especifico
				end
		set @MesPrograma_Final = @MesPrograma;
		set @AnoPrograma_Final = @AnoPrograma; 
		set @DiaPrograma_Final = @DiaPrograma;
		--Ya comprobo que el dia es martes para calcular desde el dia anterior (lunes) hasta el martes pasado
		SET @DiaPrograma_Final -= 1;
			IF (@DiaPrograma_Final <=1)
					begin	
					set @MesPrograma_Final -=1;
						IF (@MesPrograma_Final <=0)
							begin
								set @MesPrograma_Final = 12;
								set @AnoPrograma_Final -=1; 
							end
						EXEC MesTreinaOTreintaiuno @MesPrograma_Final, @AnoPrograma_Final, @DiasMesAnterior OUTPUT;
						SET @DiaPrograma_Final = @DiasMesAnterior;			
					end
				SET @HorasAcumuladas_S = 0;
				SET @MinutosAcumulados_S = 0;
		set @i = 7;
		while @i > 0
			begin
				set @DiaPrograma -=1;
				IF (@DiaPrograma <= 0)
					begin
						SET @MesPrograma -= 1
						IF (@MesPrograma <=0 or @MesPrograma>12)
							begin
								set @MesPrograma = 12;
								set @AnoPrograma -=1; 
							end
						EXEC MesTreinaOTreintaiuno @MesPrograma, @AnoPrograma, @DiasMesAnterior OUTPUT;
						SET @DiaPrograma = @DiasMesAnterior;				
					end
			SET @SalarioSemanalTemporal = 0;
			
				--Si el dia es 1 y el siguiente es 0 hay que saber si el mes anterior tenia 30 o 31 dias y si el mes es 1 y el anterior es 0 convertirlo a 12
				IF EXISTS(Select Monto from salario_al_dia where Dia = @DiaPrograma AND Mes = @MesPrograma AND Ano = @AnoPrograma AND User_ControlGreg_Salario = @Usuario)
					begin
						Select @SalarioSemanalTemporal = Monto, @HoraTemporal = HorasTrabajadas, @MinutoTemporal = MinutosTrabajados from salario_al_dia where Dia = @DiaPrograma AND Mes = @MesPrograma AND Ano = @AnoPrograma AND User_ControlGreg_Salario = @Usuario;
					
						set @SalarioSemanal += @SalarioSemanalTemporal;
						set @HorasAcumuladas_S +=  @HoraTemporal;
						set @MinutosAcumulados_S +=  @MinutoTemporal;					
					end			
				set @i -=1
			end
			--print 'Hora: '+cast(@Horatemporal as varchar(15))+', Minutos: '+cast(@MinutoTemporal as varchar(15))
			exec CalcularSemanaDelMes @DiaPrograma, @MesPrograma,@AnoPrograma, @SemanaDelMesA OUTPUT
			exec CalcularSemanaDelMes @DiaPrograma_Final, @MesPrograma_Final,@AnoPrograma_Final, @SemanaDelMesB OUTPUT

			--set @SemanaDelMesA = 1
			--set  @SemanaDelMesB = 1
			
				DELETE FROM salario_a_la_semana
				WHERE ID_User = @ID
				AND User_ControlGreg_Salario = @Usuario
				--AND Monto = @SalarioSemanal
				AND DiaIncio = @DiaPrograma
				AND MesInicio = @MesPrograma
				AND SemanaMesInicio = @SemanaDelMesA
				AND AnoInicio = @AnoPrograma
				AND DiaFinal = @DiaPrograma_Final
				AND MesFinal = @MesPrograma_Final
				AND SemanaMesFinal = @SemanaDelMesB
				AND AnoFinal = @AnoPrograma_Final;

				--Calculamos las horas y Minutos nuevos de las semana
				declare @sino as varchar(3) = 'no'
				SET @HoraAdicional = @MinutosAcumulados_S/60;
				SET @MinRestar = @HoraAdicional*60;
				SET @MinutosAcumulados_S = @MinutosAcumulados_S - @MinRestar;
				SET @HorasAcumuladas_S = @HorasAcumuladas_S  + @HoraAdicional; --*/
				if @SalarioSemanal <=0
					begin
					set @sino = 'si'
					end

				Insert INTO salario_a_la_semana(ID_User,User_ControlGreg_Salario,Monto, HorasTrabajadas,MinutosTrabajados,DiaIncio,MesInicio,SemanaMesInicio,AnoInicio,DiaFinal,MesFinal,SemanaMesFinal,AnoFinal,Pagado,MontoPorPagar)
										 values(@ID,@Usuario,@SalarioSemanal,@HorasAcumuladas_S,@MinutosAcumulados_S,@DiaPrograma,@MesPrograma,@SemanaDelMesA,@AnoPrograma,@DiaPrograma_Final,@MesPrograma_Final,@SemanaDelMesB,@AnoPrograma_Final,@sino,@SalarioSemanal)
				exec ParaPagarTrabajador_Registro @Usuario,@SalarioSemanal;
				update salario_a_la_semana set Pagado = 'si' where MontoPorPagar = 0 and Pagado = 'no'
				--print 'Hora: '+cast(@HorasAcumuladas_S as varchar(15))+', Minutos: '+cast(@MinutosAcumulados_S as varchar(15)) 
				--print ' Salario Acumulado : [' + CAST(@SalarioSemanal AS VARCHAR(15)) + ']'
				--PRINT 'Salario Acumulado Desde el Día: [' + CAST(@DiaPrograma AS VARCHAR(3)) + '], Mes :[' + CAST(@MesPrograma AS VARCHAR(3)) + '], Año : [' + CAST(@AnoPrograma AS VARCHAR(5))+'] Semana del mes: ['+cast(@SemanaDelMes as varchar(4))+', Hasta el Día: [' + CAST(@DiaPrograma_Final AS VARCHAR(3)) + '], Mes :[' + CAST(@MesPrograma_Final AS VARCHAR(3)) + '], Año : [' + CAST(@AnoPrograma_Final AS VARCHAR(5)) + ']';
				--PRINT ', Hasta el Día: [' + CAST(@DiaPrograma_Final AS VARCHAR(3)) + '], Mes :[' + CAST(@MesPrograma_Final AS VARCHAR(3)) + '], Año : [' + CAST(@AnoPrograma_Final AS VARCHAR(5)) + ']';
END

--FIN SALARIO SEMANAL */




/*----------------CALCULAMOS EL SALARIO AL DIA (SE PUEDE MODIFICAR SIEMPRE Y CUANDO NO HAYA SIDO UNA SEMANA QUE YA PASO)----------*/
--Salario Diario
CREATE PROCEDURE GenerarSalarioDiario
		@Dia INT,
		@Mes INT,
		@Ano INT,
		@Usuario VARCHAR(40)
	AS 
	BEGIN    

		DECLARE @PagoPorHora AS Numeric(5,2)
		DECLARE @HoraFinal_Mostrar AS INT;
		DECLARE @HoraInicial_Mostrar AS INT;
		DECLARE @MinutoMinimo_Mostrar AS INT;
		DECLARE @MinutoMaximo_Mostrar AS INT;
		DECLARE @ID AS INT;
		DECLARE @Horas INT;
		DECLARE @Minutos as INT;
		DECLARE @Monto_Hora AS NUMERIC(10,2);
		DECLARE @Monto_Minutos AS NUMERIC(10,2);
		DECLARE @Monto AS NUMERIC(10,2);

		-- Obtener el ID del usuario
		-- Verificar si el usuario existe en la tabla 'personal'
			IF NOT EXISTS (SELECT 1 FROM personal WHERE User_ControlGreg = @Usuario)
				BEGIN
					PRINT 'El usuario no existe en la tabla personal.';
					RETURN;
				END
			-- Obtener el ID del usuario
			SELECT @ID = ID FROM personal WHERE User_ControlGreg = @Usuario;
			-- Verificar si el salario por hora existe para el usuario en la tabla 'salario_de_usuario_por_dia'
				IF NOT EXISTS (SELECT 1 FROM salario_de_usuario_por_dia WHERE ID_User = @ID AND User_ControlGreg = @Usuario)
				BEGIN
					PRINT 'No se encontró el salario por hora para el usuario.';
					RETURN;
				END
			-- Obtener el salario por hora
		SELECT @PagoPorHora = SalarioPorHora FROM salario_de_usuario_por_dia WHERE ID_User = @ID AND User_ControlGreg = @Usuario;
		-- Ejecutar el procedimiento para obtener la hora mínima y máxima
		EXEC ObtenerHoraMinimaAndMaxima @Ano, @Mes, @Dia, @Usuario, 
			@HoraFinal = @HoraFinal_Mostrar OUTPUT, 
			@HoraInicial = @HoraInicial_Mostrar OUTPUT;

		-- Calcular las horas trabajadas
		SET @Horas = @HoraFinal_Mostrar - @HoraInicial_Mostrar;

		-- Obtener los minutos mínimos y máximos
		EXEC ObtenerMinutoMinimoAndMaximo @Ano, @Mes, @Dia, @Usuario, 
			@HoraInicial_Mostrar, @HoraFinal_Mostrar, 
			@MinutoMinimo = @MinutoMinimo_Mostrar OUTPUT, 
			@MinutoMaximo = @MinutoMaximo_Mostrar OUTPUT;

		-- Calcular el monto en función de los minutos
		IF @MinutoMinimo_Mostrar > @MinutoMaximo_Mostrar
			BEGIN
				SET @Horas = @Horas - 1; -- Resta una hora si faltan minutos
				SET @Minutos = ((@MinutoMaximo_Mostrar + 60) - @MinutoMinimo_Mostrar);
				SET @Monto_Minutos = (@Minutos/ 60.0) * @PagoPorHora;
			END
		ELSE
			BEGIN
				SET @Minutos = (@MinutoMaximo_Mostrar - @MinutoMinimo_Mostrar);
				SET @Monto_Minutos = (@Minutos / 60.0) * @PagoPorHora;
			END

		-- Calcular el monto total en función de las horas y minutos
		SET @Monto_Hora = @Horas * @PagoPorHora;
		SET @Monto = @Monto_Hora + @Monto_Minutos;
		IF @Monto IS NULL
			BEGIN
				IF EXISTS(SELECT Monto FROM salario_al_dia WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario)
				BEGIN
					UPDATE salario_al_dia SET Monto = 0 WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
					UPDATE salario_al_dia SET HorasTrabajadas = 0 WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
					UPDATE salario_al_dia SET MinutosTrabajados = 0 WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
					--
					UPDATE salario_al_dia SET HoraInicio = 0 WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
					UPDATE salario_al_dia SET MinutoInicio = 0 WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
					UPDATE salario_al_dia SET HoraFinal = 0 WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
					UPDATE salario_al_dia SET MinutoFinal = 0 WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;

				END
				PRINT 'El monto es null, no hay salario porque no hay tiempo para el dia: ['+cast(@Dia as varchar(3))+'], Para el Usuario: ['+cast(@Usuario as varchar(40))+']';        
			END
		else
			begin
			-- Actualizar o insertar en la tabla salario_al_dia
				IF EXISTS(SELECT Monto FROM salario_al_dia WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario)
					BEGIN
						UPDATE salario_al_dia SET Monto = @Monto WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
						UPDATE salario_al_dia SET HorasTrabajadas = @Horas WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
						UPDATE salario_al_dia SET MinutosTrabajados = @Minutos WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
						--
						UPDATE salario_al_dia SET HoraInicio = @HoraInicial_Mostrar WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
						UPDATE salario_al_dia SET MinutoInicio = @MinutoMinimo_Mostrar WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
						UPDATE salario_al_dia SET HoraFinal = @HoraFinal_Mostrar WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
						UPDATE salario_al_dia SET MinutoFinal = @MinutoMaximo_Mostrar WHERE Dia = @Dia AND Mes = @Mes AND Ano = @Ano AND User_ControlGreg_Salario = @Usuario;
					END
				ELSE
					BEGIN
						INSERT INTO salario_al_dia(ID_User, User_ControlGreg_Salario, Dia, Mes, Ano, Monto, HoraInicio,MinutoInicio,HoraFinal,MinutoFinal, HorasTrabajadas, MinutosTrabajados) 
						VALUES (@ID, @Usuario, @Dia, @Mes, @Ano, @Monto, @HoraInicial_Mostrar,@MinutoMinimo_Mostrar,@HoraFinal_Mostrar,@MinutoMaximo_Mostrar, @Horas, @Minutos);
					END
			END
END;
--Salario Semanal Y diario termina
--Termina Codigo Para los Salarios



/*------------OBTENEMOS LA HORA DE ENTRADA Y HORA DE SALIDA*/
create procedure ObtenerMinutoMinimoAndMaximo -- Obtenemos los minutos minimos y maximos despues de tener la hora
		@Ano_M as INT,
		 @Mes_M as INT,
		 @Dia_M as INT,
		 @Usuario_Input_M as varchar(40),
		 @HoraMinima as INT,
		 @HoraMaxima as INT,
		 @MinutoMinimo as INT OUTPUT,
		 @MinutoMaximo as INT OUTPUT
	as begin	
		select @MinutoMinimo = min(Minuto) from control_de_accesos where User_ControlGreg_Time = @Usuario_Input_M AND Mes = @Mes_M AND Ano = @Ano_M AND Dia = @Dia_M AND Hora = @HoraMinima;
		select @MinutoMaximo = max(Minuto) from control_de_accesos where User_ControlGreg_Time = @Usuario_Input_M AND Mes = @Mes_M AND Ano = @Ano_M AND Dia = @Dia_M AND Hora = @HoraMaxima;
END


CREATE Procedure ObtenerHoraMinimaAndMaxima -- 	Obtenemos las horas en rango 
		 @Ano_D as INT,
		 @Mes_D as INT,
		 @Dia_D as INT,
		 @Usuario_Input as varchar(40),
		 @HoraFinal INT OUTPUT,
		 @HoraInicial INT OUTPUT

	As Begin
		Select @HoraFinal = MAX(Hora), @HoraInicial = Min(Hora) from control_de_accesos as a where a.User_ControlGreg_Time = @Usuario_Input AND Mes = @Mes_D AND Ano = @Ano_D AND Dia = @Dia_D;
END
/*-------------FIN DE CONSEGUIR LA HORA Y MINUTO DE ENTRADA Y SALIDA--------------------*/



/*-------------INICIO PARA ELIMINAR DATOS NO NECESARIOS DE LA TABLA PARA EL CONTROL DE ACCESO--------------------*/
CREATE procedure EliminaDuplicas --Si existe algun registro duplicado lo elimina (1 de n cantidad)
	as begin
			WITH RegistrosDuplicados AS (SELECT *,
				   ROW_NUMBER() OVER (PARTITION BY User_ControlGreg_Time, Dia, Mes, Ano, Hora, Minuto ORDER BY (SELECT NULL)) AS fila
			FROM control_de_accesos)
		-- Eliminar las filas duplicadas, manteniendo solo una
		DELETE FROM RegistrosDuplicados WHERE fila > 1;
end

CREATE procedure ElminarDatosInnecesesarios --Esta funcion es la que realmente los borra
		@Ano_E as INT,
		@Mes_E as INT,
		@Dia_E as INT,
		@Usuario_Input_E as varchar(40),
		@HoraMinima_E as INT,
		@HoraMaxima_E as INT,
		@MinutoMinimo_E as INT,
		@MinutoMaximo_E as INT
	as begin
		delete from control_de_accesos where User_ControlGreg_Time = @Usuario_Input_E AND Mes = @Mes_E AND Ano = @Ano_E AND Dia = @Dia_E And not ((Hora = @HoraMinima_E AND Minuto = @MinutoMinimo_E) or (Hora = @HoraMaxima_E AND Minuto = @MinutoMaximo_E))
End

CREATE procedure EliminarRegistrosInecesariosEntreMayorMenor --Elimina los registros que no son necesarios, solo deja 2 por dias, entrada y salida (prepara el camino)
		@Ano_Mostrar as INT,
		@Mes_Mostrar as INT,
		@Dia_Mostrar as INT,
		@Usuario_Mostrar as varchar(40)
	AS Begin
		Declare @HoraFinal_Mostrar INT;
		Declare @HoraInicial_Mostrar INT;
		DECLARE @MinutoMinimo_Mostrar INT;
		DECLARE @MinutoMaximo_Mostrar INT;
		Exec ObtenerHoraMinimaAndMaxima @Ano_Mostrar, @Mes_Mostrar, @Dia_Mostrar, @Usuario_Mostrar, @HoraFinal = @HoraFinal_Mostrar OUTPUT, @HoraInicial = @HoraInicial_Mostrar OUTPUT; --Obtenemos la hora Minima y Maxima
		Exec ObtenerMinutoMinimoAndMaximo @Ano_Mostrar, @Mes_Mostrar, @Dia_Mostrar, @Usuario_Mostrar, @HoraInicial_Mostrar,@HoraFinal_Mostrar, @MinutoMinimo = @MinutoMinimo_Mostrar OUTPUT, @MinutoMaximo = @MinutoMaximo_Mostrar OUTPUT --Obtenemos los minutos minimos y maximos
		Exec ElminarDatosInnecesesarios @Ano_Mostrar, @Mes_Mostrar,	 @Dia_Mostrar, @Usuario_Mostrar, @HoraInicial_Mostrar, @HoraFinal_Mostrar, @MinutoMinimo_Mostrar, @MinutoMaximo_Mostrar
		--Eliminar los registros innecesarios

		print 'Hora Minima es: '+ cast(@HoraInicial_Mostrar as varchar(40))+', MinutoMinimo: '+cast(@MinutoMinimo_Mostrar as varchar(40))+', La Hora Maximo es: '+ cast(@HoraFinal_Mostrar as varchar(40));
END


/*------------------------------------INICIO------------AUTOMATIZACION------------------------------------------*/
/*--Para que funcione bien, debe ejecutarse todos los dias, en un horario de 10PM, maximo 11:57PM, en caso contrario consultar a Joel para llamar a Greg Torres*/
CREATE procedure AcualizarRegistroControlAccesoTodosDiario 
	as begin
		Declare @Usuario NVARCHAR(40);
		--Declare @Usuario_INT as INT;
		--Declare @i as int = 0;
		Declare @DiaActual as INT = DAY(GETDATE());
		Declare @MesActual as INT = MONTH(GETDATE());
		Declare @AnoActual as INT = YEAR(GETDATE());

		--select @Usuario_INT = count(distinct User_ControlGreg) from personal
		--print 'Cantidad Diferentes de Usuarios: '+cast(@Usuario_INT as varchar(40))
		DECLARE UsuarioChar CURSOR FOR
		SELECT User_ControlGreg FROM personal;
		open UsuarioChar
		FETCH NEXT FROM UsuarioChar into @Usuario --aqui recoremos de fila en fila
		While @@FETCH_STATUS = 0
		Begin
			print 'Usuario Pos: '+cast(@Usuario as varchar(40)) --siguiente elemento en la fila
			--exec MostrarLoCreado @AnoActual,@MesActual,@DiaActual,@Usuario
			exec EliminarRegistrosInecesariosEntreMayorMenor @AnoActual,@MesActual,@DiaActual,@Usuario 
			exec GenerarSalarioDiario @DiaActual,@MesActual,@AnoActual,@Usuario
			FETCH NEXT FROM UsuarioChar into @Usuario
			--Set @i += 1;
		END
		exec EliminaDuplicas
		CLOSE UsuarioChar
		DEALLOCATE UsuarioChar

end

--Semanal---------------------------------------------
create procedure ActualizarSalarioSemanal_Automatico
	AS
	BEGIN
	declare @Usuario as varchar(40);
    DECLARE @NombreDelDia as VARCHAR(10);
	DECLARE @Dia as INT = DAY(GETDATE());
	declare @Mes as INT = MONTH(GETDATE());
	declare @Ano as INT =  YEAR(GETDATE());
	declare @activar as int = 0;

    SET @NombreDelDia = DATENAME(WEEKDAY, GETDATE());
	Select @activar = activada from MartesActivado;
	IF (@activar = 1)
		BEGIN			
			IF @NombreDelDia = 'Martes' OR @NombreDelDia = 'Tuesday'
			BEGIN
				update MartesActivado set activada = 0;
				DECLARE PersonalCursor CURSOR FOR
				SELECT User_ControlGreg FROM personal;

				OPEN PersonalCursor;
				FETCH NEXT FROM PersonalCursor INTO @Usuario;
				WHILE @@FETCH_STATUS = 0
					BEGIN
						-- Ejecutar el procedimiento 'CalcularSalarioSemana' para cada usuario
						EXEC CalcularSalarioSemana @Dia, @Mes, @Ano, @Usuario;

						-- Leer el siguiente registro
						FETCH NEXT FROM PersonalCursor INTO @Usuario;
					END

				-- Cerrar y liberar el cursor
				CLOSE PersonalCursor;
				DEALLOCATE PersonalCursor;

			END
			ELSE
			BEGIN
				-- Si no es martes, salir del procedimiento
				PRINT 'Este procedimiento solo puede ejecutarse los martes.';
				RETURN;
			END
			update MartesActivado set activada = 0;
			set @activar = 0;
		END
		ELSE
			begin
				print 'Ya Se ejecuto una vez el programa esta semana el dia martes'
			end
END;
--CADA JUEVES SABADOS LUNES
CREATE procedure ActivarMartes_ElJuevesSabadoLunes
	as begin
		 DECLARE @NombreDelDia VARCHAR(10);
		SET @NombreDelDia = DATENAME(WEEKDAY, GETDATE());
		IF @NombreDelDia = 'Lunes' OR @NombreDelDia = 'Monday'  or @NombreDelDia = 'Jueves' OR @NombreDelDia = 'Thursday' or @NombreDelDia = 'Saturday' OR @NombreDelDia = 'Sabado'
			BEGIN
				PRINT 'El procedimiento se está ejecutando porque es lunes.';
				update MartesActivado set activada = 1;
			END
		ELSE
			BEGIN
				PRINT 'Este procedimiento solo puede ejecutarse los lunes.';
				RETURN;
			END
	end
/*----------------------FIN PROCEDURES AUTOMATIZADOS---------------------------------------*/





/*------------------- ACTUALIZAR REGISTROS SEMANA DE MANERA MANUAL------NO USAR-------------------*/
CREATE procedure AcualizarRegistroControlAccesoTodos_Manual 
		@DiaActual as INT,
		@MesActual as INT,
		@AnoActual as INT
	as begin
		Declare @Usuario NVARCHAR(40);
		--Declare @Usuario_INT as INT;
		--Declare @i as int = 0;
	
		--select @Usuario_INT = count(distinct User_ControlGreg) from personal
		--print 'Cantidad Diferentes de Usuarios: '+cast(@Usuario_INT as varchar(40))
		DECLARE UsuarioChar CURSOR FOR
		SELECT User_ControlGreg FROM personal;
		open UsuarioChar
		FETCH NEXT FROM UsuarioChar into @Usuario --aqui recoremos de fila en fila
		While @@FETCH_STATUS = 0
		Begin
			print 'Usuario Pos: '+cast(@Usuario as varchar(40)) --siguiente elemento en la fila
			--exec MostrarLoCreado @AnoActual,@MesActual,@DiaActual,@Usuario
			exec EliminarRegistrosInecesariosEntreMayorMenor @AnoActual,@MesActual,@DiaActual,@Usuario 
			exec GenerarSalarioDiario @DiaActual,@MesActual,@AnoActual,@Usuario
			FETCH NEXT FROM UsuarioChar into @Usuario
			--Set @i += 1;
		END
		exec EliminaDuplicas
		CLOSE UsuarioChar
		DEALLOCATE UsuarioChar

end
/* termina la manera manual*/




/*-----------SOLO MOSTRABA LO QUE ESTA EN LOS PROCEDURES PERO YA NO LO USO*/

CREATE procedure MostrarLoCreado --solo lo utilizo para saber si las consultas funcionan antes de implementarlas
		@Ano_Mostrar as INT,
		@Mes_Mostrar as INT,
		@Dia_Mostrar as INT,
		@Usuario_Mostrar as varchar(40)
	AS Begin
		Declare @HoraFinal_Mostrar INT;
		Declare @HoraInicial_Mostrar INT;
		DECLARE @MinutoMinimo_Mostrar INT;
		DECLARE @MinutoMaximo_Mostrar INT;
		Exec ObtenerHoraMinimaAndMaxima @Ano_Mostrar, @Mes_Mostrar, @Dia_Mostrar, @Usuario_Mostrar, @HoraFinal = @HoraFinal_Mostrar OUTPUT, @HoraInicial = @HoraInicial_Mostrar OUTPUT; --Obtenemos la hora Minima y Maxima
		Exec ObtenerMinutoMinimoAndMaximo @Ano_Mostrar, @Mes_Mostrar, @Dia_Mostrar, @Usuario_Mostrar, @HoraInicial_Mostrar,@HoraFinal_Mostrar, @MinutoMinimo = @MinutoMinimo_Mostrar OUTPUT, @MinutoMaximo = @MinutoMaximo_Mostrar OUTPUT --Solo Obtenemos el Minuto Minimo de la Hora Minima
		print 'Hora Minima es: '+ cast(@HoraInicial_Mostrar as varchar(40))+', MinutoMinimo: '+cast(@MinutoMinimo_Mostrar as varchar(40))+', La Hora Maximo es: '+ cast(@HoraFinal_Mostrar as varchar(40))+', El Minuto Maximo es: '+cast(@MinutoMaximo_Mostrar as varchar(40));
END

-----------------COMPROBACIONES-----------------------------------
ALTER PROCEDURE SP_UserSessionIsBiggerThannUserEdit
	@usernameSession as varchar(40),
	@usernameEdit as varchar(40),
	@answer as INT OUTPUT
AS BEGIN
	declare @RankSession as INT = 9
	declare @RankEdit as INT = 9
	set @answer = 0
	Select @RankSession = r.RankNumber from (personal as p inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks) where p.User_ControlGreg = @usernameSession
	Select @RankEdit = r.RankNumber from (personal as p inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks) where p.User_ControlGreg = @usernameEdit
	IF(@RankSession < @RankEdit)
		BEGIN
			SET @answer = 1
			print 'El Rango del Usuario Session es Superior puede Cambiar al Usuario Edit, Answer is: '+cast(@answer as varchar(1))
		END
END