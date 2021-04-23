Use Step_1
Go

DECLARE @TABLE_NAME varchar(100)
DECLARE @QUERY_TOP1 VARCHAR(MAX) = 'USE step_1' + CHAR(13) +
'INSERT INTO dbo.MonthlyTotals' + CHAR(13) +
'SELECT '''

DECLARE @QUERY_TOP2 VARCHAR(MAX) = ''' AS TABLE_NAME' + CHAR(13) +
'	,[FEE_SIGN]' + CHAR(13) +
'	, left(ACQR_BIN, 1) AS BIN' + CHAR(13) +
'	, cpd_month_ID' + CHAR(13) +
'	, case when TRAN_CD = ''05'' THEN ''Sale'' when TRAN_CD = ''25'' THEN ''Sale Reversal'' when TRAN_CD = ''06'' THEN ''Credit'' ELSE ''Other'' END as Transaction_Type' + CHAR(13) +
'	, case when USAGE_CD = ''1'' THEN ''Original'' ELSE ''Other'' END as Transaction_Usage_Type' + CHAR(13) +
'	, CASE WHEN MRCH_CTRY_CD IN (''840'', ''850'', ''630'', ''316'', ''16'', ''016'') THEN MRCH_CTRY_CD ELSE ''000'' END as Merchant_Country_Code' + CHAR(13) +
'   , null ' + Char(13) +
'   , CASE WHEN MRCH_CATG_CD IN(''6010'',''6011'') THEN ''EXCL'' ELSE ''INCL'' END as MCC' + Char(13) +
'   , null ' + Char(13) +
'   , SYS_SRC_CD' + Char(13) +
'   , Left(ARN_BIN,1) ' + Char(13) +
'   , null' + Char(13) +
'	, SUM([SUM_ACQR_US_FEE_AMT]) AS [SUM_ACQR_US_FEE_AMT]' + CHAR(13) +
'	, SUM([SUM_ACQR_FEE_CNT]) AS [SUM_ACQR_FEE_CNT]' + CHAR(13) +
'	, SUM([SUM_ISSR_US_FEE_AMT]) AS [SUM_ISSR_US_FEE_AMT]' + CHAR(13) +
'	, SUM([SUM_ISSR_FEE_CNT]) AS [SUM_ISSR_FEE_CNT]' + CHAR(13) +
'	, SUM([SUM_DRF_US_TRAN_AMT]) AS [SUM_DRF_US_TRAN_AMT]' + CHAR(13) +
'	, SUM([SUM_DRF_TRAN_CNT]) AS [SUM_DRF_TRAN_CN]' + CHAR(13) +
'	, SUM([SUM_DEST_FEE_AMT]) AS [SUM_DEST_FEE_AMT]' + CHAR(13) +
'	, SUM([SUM_DRF_CSHBK_AMT_R]) AS [SUM_DRF_CSHBK_AMT_R]' + CHAR(13) +
'	, SUM([SUM_DRF_CSHBK_CNT]) AS [SUM_DRF_CSHBK_CNT]' + CHAR(13) +
'	, SUM([SUM_DRF_ELAPSE_DAYS]) AS [SUM_DRF_ELAPSE_DAYS]' + CHAR(13) +
'	, SUM([SUM_DRF_INTRCH_FEE_AMT]) AS [SUM_DRF_INTRCH_FEE_AMT]' + CHAR(13) +
'	, SUM([SUM_DRF_NATL_REIMBM_FEE_AMT]) AS [SUM_DRF_NATL_REIMBM_FEE_AMT]' + CHAR(13) +
'	, SUM([SUM_DRF_SRCHG_AMT]) AS [SUM_DRF_SRCHG_AMT]' + CHAR(13) +
'	, SUM([SUM_LCL_SLS_TAX_AMT]) AS [SUM_LCL_SLS_TAX_AMT]' + CHAR(13) +
'	, SUM([SUM_SRCE_FEE_AMT]) AS [SUM_SRCE_FEE_AMT]' + CHAR(13) +
'	, SUM([SUM_DRF_TRAN_AMT]) AS [SUM_DRF_TRAN_AMT]' + CHAR(13) +
'	, SUM([SUM_CCC_ISC_AMT]) AS [SUM_CCC_ISC_AMT]' + CHAR(13) +
'	, SUM([SUM_ACQR_TRAN_AMT]) AS [SUM_ACQR_TRAN_AMT]' + CHAR(13) +
'	, SUM([SUM_ISSR_TRAN_AMT]) AS [SUM_ISSR_TRAN_AMT]' + CHAR(13) +
'	, SUM([SUM_CSHBK_AMT]) AS [SUM_CSHBK_AMT]' + CHAR(13) +
'	, SUM([SUM_DRF_US_TRAN_AMT_NR]) AS [SUM_DRF_US_TRAN_AMT_NR]' + CHAR(13) +
'	, COUNT(*) as TotalRows' + CHAR(13) +
'   , null ' + Char(13) +
'FROM '


DECLARE @QUERY_BOTTOM VARCHAR(MAX) = CHAR(13) + 'GROUP BY [FEE_SIGN]' + CHAR(13) +
'      , cpd_month_ID' + CHAR(13) +
'      , left(ACQR_BIN, 1)' + CHAR(13) +
'      , case when TRAN_CD = ''05'' THEN ''Sale'' when TRAN_CD = ''25'' THEN ''Sale Reversal'' when TRAN_CD = ''06'' THEN ''Credit'' ELSE ''Other'' END' + CHAR(13) +
'      , case when USAGE_CD = ''1'' THEN ''Original'' ELSE ''Other'' END ' + CHAR(13) +
'      , CASE WHEN MRCH_CTRY_CD IN (''840'', ''850'', ''630'', ''316'', ''16'', ''016'') THEN MRCH_CTRY_CD ELSE ''000'' END' + Char(13) +
'      , CASE WHEN MRCH_CATG_CD IN(''6010'',''6011'') THEN ''EXCL'' ELSE ''INCL'' END' + Char(13) +
'      , SYS_SRC_CD' + Char(13) +
'      , Left(ARN_BIN,1)   ' + Char(13) 
DECLARE @QUERY VARCHAR(MAX)

select top 1 @TABLE_NAME = t.TABLE_NAME
from INFORMATION_SCHEMA.TABLES t with (nolock)
WHERE TABLE_CATALOG = 'Step_1'
	and TABLE_NAME like 'txn_2010%'
	and NOT EXISTS (SELECT 1 from dbo.MonthlyTotals mt where mt.TABLE_NAME = t.TABLE_NAME)


WHILE @@ROWCOUNT = 1
BEGIN	
	PRINT @TABLE_NAME
	SET @QUERY = @QUERY_TOP1 + @TABLE_NAME + @QUERY_TOP2 + @TABLE_NAME + @QUERY_BOTTOM
	--print @QUERY
	--Break
	
	EXEC (@QUERY)

	select top 1 @TABLE_NAME = t.TABLE_NAME
	from INFORMATION_SCHEMA.TABLES t
	WHERE TABLE_CATALOG = 'Step_1'
		and TABLE_NAME like 'txn_2010%'
		and NOT EXISTS (SELECT 1 from dbo.MonthlyTotals mt where mt.TABLE_NAME = t.TABLE_NAME)
END

