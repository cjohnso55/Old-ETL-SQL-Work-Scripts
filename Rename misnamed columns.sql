use INCH
DECLARE @TABLE_SCHEMA varchar(100)
DECLARE @table_Name varchar(100)
DECLARE @statement varchar(1000)

--DECLARE @OLD_COLUMN_Name varchar(100) = 'SUMM_ISSR_US_FEE_AMT'
--DECLARE @NEW_COLUMN_Name varchar(100) = 'SUM_ISSR_US_FEE_AMT'
DECLARE @OLD_COLUMN_Name varchar(100) = 'DEST_FEE_AMT'
DECLARE @NEW_COLUMN_Name varchar(100) = 'SUM_DEST_FEE_AMT'
--DECLARE @OLD_COLUMN_Name varchar(100) = 'SUM_DRF_ELASPE_DAYS'
--DECLARE @NEW_COLUMN_Name varchar(100) = 'SUM_DRF_ELAPSE_DAYS'

WHILE 1=1
BEGIN
	select top 1 @TABLE_SCHEMA=TABLE_SCHEMA, @table_Name=table_Name 
	from INFORMATION_SCHEMA.COLUMNS
	where column_name = @OLD_COLUMN_Name


	SET @statement = 'exec sp_rename ''' + @TABLE_SCHEMA + '.' + @TABLE_Name + '.' + @OLD_COLUMN_Name + ''', ''' + @New_Column_Name + ''''

	print @statement
	IF(LEN(@statement)>5)
	BEGIN
		exec(@statement)
	END
	ELSE
	BEGIN
		BREAK
	END
	SET @table_Name = NULL
END