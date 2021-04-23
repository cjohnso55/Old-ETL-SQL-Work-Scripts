Use Step_1
Go




Declare @SourceTableName VarChar(Max)
Declare @TargetTableName VarChar(Max) = 'Step_1.dbo.MonthlyTotals'
Declare @SQL             VarChar(Max)

Declare @SelectBody VarChar(Max) =      ' as Table_Name	
                                	    , null as FEE_SIGN
                                		, substring(cast(ACQ_BIN as varchar(25)), 1, 1) AS BIN 
                                		, YYYYMM as cpd_month_ID
                                		, case when TRAN_CD = ''05'' THEN ''Sale'' ELSE ''Other'' END as Transaction_Type
                                		, case when Tran_USAGE_CD = ''1'' THEN ''Original'' ELSE ''Other'' END as Transaction_Usage_Type
                                		, CASE WHEN ISSR_ISO_CTRY_CD IN (''840'', ''850'', ''630'', ''316'', ''16'', ''016'') THEN ISSR_ISO_CTRY_CD ELSE ''000'' END as Merchant_Country_Code
                                		, Cast(null as varchar(1)) AS Merchant_Cond_Code -----
                                		, Cast(Merch_Desc_MCC as varchar(5)) as Merchant_Category_Code -----------
                                		, Cast(null as varchar(10)) As MRCH_VRFCN_VAL -----------
                                		, SYS_SRC_CD as SYS_SRC_CD ---------------
                                		, Cast(null as varchar(6)) as ARN_BIN
                                		, Cast(null as varchar(6)) as MRCH_DBA_ID
                                		, null AS [SUM_ACQR_US_FEE_AMT]
                                		, null AS [SUM_ACQR_FEE_CNT]
                                		, null AS [SUM_ISSR_US_FEE_AMT]
                                		, null AS [SUM_ISSR_FEE_CNT]
                                		, null AS [SUM_DRF_US_TRAN_AMT]
                                		, SUM([Tran_Cnt]) AS [SUM_DRF_TRAN_CN]
                                		, SUM([DEST_FEE_AMT]) AS [SUM_DEST_FEE_AMT]
                                		, SUM([CSHBK_AMT]) AS [SUM_DRF_CSHBK_AMT_R]
                                		, SUM([CASHBK_CNT]) AS [SUM_DRF_CSHBK_CNT]
                                		, null AS [SUM_DRF_ELAPSE_DAYS]
                                		, null AS [SUM_DRF_INTRCH_FEE_AMT]
                                		, null AS [SUM_DRF_NATL_REIMBM_FEE_AMT]
                                		, null AS [SUM_DRF_SRCHG_AMT]
                                		, null AS [SUM_LCL_SLS_TAX_AMT]
                                		, SUM([SRCE_FEE_AMT]) AS [SUM_SRCE_FEE_AMT]
                                		, null AS [SUM_DRF_TRAN_AMT]
                                		, null AS [SUM_CCC_ISC_AMT]
                                		, SUM([SRC_AMT]) AS [SUM_ACQR_TRAN_AMT]
                                		, SUM([DEST_AMT]) AS [SUM_ISSR_TRAN_AMT]
                                		, null AS [SUM_CSHBK_AMT]
                                		, SUM([US_AMT]) AS [SUM_DRF_US_TRAN_AMT_NR]
                                		, COUNT(*) as TotalRows '

Declare @GroupBy VarChar(Max) = ' substring(cast(ACQ_BIN as varchar(25)), 1, 1)
                                 , SYS_SRC_CD
                                 , Cast(Merch_Desc_MCC as varchar(5))	
                                 , YYYYMM	
                                 , case when TRAN_CD = ''05'' THEN ''Sale'' ELSE ''Other'' END	
                                 , case when tran_USAGE_CD = ''1'' THEN ''Original'' ELSE ''Other'' END 	
                                 , CASE WHEN ISSR_ISO_CTRY_CD  IN (''840'', ''850'', ''630'', ''316'', ''16'', ''016'') THEN ISSR_ISO_CTRY_CD ELSE ''000'' END'	


Select 
  (Table_Catalog  + '.' 
   + Table_Schema + '.' 
   + Table_Name) as TableName
Into #RecordsToProcess  
from STEP_1.INFORMATION_SCHEMA.Tables where (Table_Name like '%txn_2004%'
                                                or Table_Name like '%txn_2005%'
												or Table_Name like '%txn_2006%'
											 )
											 and Table_Name not like '%Interchange%'
											 and Table_Schema = 'dbo'





While Exists (select top(1) * from #RecordsToProcess)
Begin	
    Set @SourceTableName = (select top 1 * from #RecordsToProcess)

	Set @SQL =    'Insert Into ' 
	           +  @TargetTableName  + Char(10) 
			   +  'Select '         + '''' + Substring(@SourceTableName, 16, 7) + ''''
			   +  @SelectBody       + Char(10) +
			   + 'From '            + Char(10)
			   +  @SourceTableName  + ' ' + Char(10) +
			   +  'Group By '       +
			   +  @GroupBy


	Exec (@SQL)
	--Print @SQL
	
	Delete top(1) from #RecordsToProcess where tableName = @SourceTableName	
End

Drop Table #RecordsToProcess




