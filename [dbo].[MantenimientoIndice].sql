USE [FBS_VirgenDelCisne]
GO
/****** Object:  StoredProcedure [dbo].[MantenimientoIndice]    Script Date: 9/4/2025 11:25:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JOSE LUIS GARCIA
-- Create date: 2025-03-09
-- Description:	Mantenimiento de los indices de la base 
-- =============================================
ALTER PROCEDURE [dbo].[MantenimientoIndice]
	@dia int
AS
BEGIN
	
	SET NOCOUNT ON;
DECLARE @TableName NVARCHAR(128);
DECLARE @IndexName NVARCHAR(128);
DECLARE @SchemaName NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);
DECLARE @Fragmentation float

DECLARE IndexCursor CURSOR FOR
SELECT 
    dbschemas.[name] as 'Schema',
    dbtables.[name] as 'Table',
    dbindexes.[name] as 'Index',
    indexstats.avg_fragmentation_in_percent
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
    INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
    INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
    INNER JOIN sys.indexes dbindexes on dbindexes.[object_id] = indexstats.[object_id] AND indexstats.index_id = dbindexes.index_id
	INNER join [FBS_VirgenDelCisne].[dbo].[MANTENIMIENTO_TABLAS] B on dbschemas.name=B.[SCHEMA] and b.ESTAACTIVO=1

WHERE 
    indexstats.database_id = DB_ID()
	and indexstats.avg_fragmentation_in_percent>=5
	and B.DIA=@dia;
	--and dbtables.name='BOVEDACOMPONENTE_BOVEDA'

OPEN IndexCursor;
FETCH NEXT FROM IndexCursor INTO @SchemaName, @TableName, @IndexName, @Fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
	--SET @sql = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD  WITH (FILLFACTOR = 80)';
    IF @Fragmentation > 30
    BEGIN
        SET @sql = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD  WITH (FILLFACTOR = 80)';
    END
    ELSE IF @Fragmentation BETWEEN 5 AND 30
    BEGIN
        SET @sql = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REORGANIZE';
    END
    
	--print @sql;
    EXEC sp_executesql @sql;
    
    FETCH NEXT FROM IndexCursor INTO @SchemaName, @TableName, @IndexName, @Fragmentation;
END

CLOSE IndexCursor;
DEALLOCATE IndexCursor;
  
END
