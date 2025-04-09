USE [FBS_VirgenDelCisne]
GO

/****** Object:  StoredProcedure [FBS_REPORTES].[L_TAB_CAPTACIONES_ENLINEA]    Script Date: 9/4/2025 11:23:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JOSE GARCIA
-- Create date: 09042025
-- Description:	Carga de datos de informacion captaciones
-- =============================================
CREATE PROCEDURE [FBS_REPORTES].[L_TAB_CAPTACIONES_ENLINEA]
	@FECHAPROCESO varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT 
		 (DATEPART(year , BDP.FECHADATOS) * 10000) + (DATEPART(month , BDP.FECHADATOS)*100) + DATEPART(day , BDP.FECHADATOS) FECHA
		,BDP.SECUENCIALOFICINA
		,BDP.CODIGOOFICIAL
		,MAX(BDP.PLAZO) MAXNUMDIASPLAZO
		,MIN(BDP.PLAZO) MINNUMDIASPLAZO
		,AVG(BDP.PLAZO) PROMNUMDIASPLAZO
		,MAX(BDP.MONTO) MAXMONTO
		,MIN(BDP.MONTO) MINMONTO
		,AVG(BDP.MONTO) PROMMONTO
		,BDP.CODIGOTIPODEPOSITO
		,COUNT(BDP.CODIGOTIPODEPOSITO) CANTTIPODEPOSITO
		,PE.SECUENCIALTIPOIDENTIFICACION 
		,COUNT (PE.SECUENCIALTIPOIDENTIFICACION ) CANTTIPOIDENTIFICACION
		,MAX(BDP.TASA) MAXTASA
		,MIN(BDP.TASA) MINTASA
		,AVG(BDP.TASA) PROMTASA
		,MAX(BDP.INTERES) MAXINTERES
		,MIN(BDP.INTERES) MININTERES
		,AVG(BDP.INTERES) PROMINTERES
		,BDP.ESTADO ESTADODOCUMENTO
		,count(BDP.ESTADO ) CONTESTADODOCUMENTO

		  FROM [FBS_HistoricosVDCIS].[FBS_HISTORICOS].[BASEDEPOSITOSPLAZOFIJO] BDP
		  inner join FBS_VirgenDelCisne.FBS_PERSONAS.PERSONA PE on BDP.SECUENCIALPERSONA=PE.SECUENCIAL
		  inner join FBS_VirgenDelCisne.FBS_GENERALES.TIPOIDENTIFICACION TI on PE.SECUENCIALTIPOIDENTIFICACION=TI.SECUENCIAL
		  WHERE BDP.FECHADATOS=@FECHAPROCESO
		  group by 
		BDP.FECHADATOS
		,BDP.SECUENCIALOFICINA
		,BDP.CODIGOOFICIAL
		,BDP.CODIGOTIPODEPOSITO
		,PE.SECUENCIALTIPOIDENTIFICACION 
		,BDP.ESTADO 
END
GO


