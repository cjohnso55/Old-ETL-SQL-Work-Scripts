/*
   Build STEP_1 from INCH
*/

Use STEP_1
Go

Declare @CreateIndex         VarChar(Max) = Char(10) + Char(10) + 'CREATE CLUSTERED INDEX PK_CRD_ACPTR_ID_ACQR_CTRY_CD_ACQR_BIN on '
Declare @OrderBy             VarChar(Max) = Char(10) + 'ORDER BY CRD_ACPTR_ID, ACQR_CTRY_CD, ACQR_BIN'   
Declare @From                VarChar(Max) = 'From ' + Char(10)
Declare @CTEName             VarChar(Max) = ' txn_SummaryData '
Declare @CTEHead             VarChar(Max) = ';With ' + @CTEName + ' As' 
Declare @InsertHead          VarChar(Max) = 'Insert Into '
Declare @SelectHead          VarCHar(Max) = Char(10) + 'Select top(0) '
Declare @HeaderStatement     VarChar(Max) = 'USE Step_1' + Char(10) + '' + Char(10) 
Declare @InsertIntoStatement VarChar(Max)
Declare @LogStatement        VarChar(Max)
Declare @DropTable           VarChar(Max)
Declare @TargetTableName     VarChar(Max)
Declare @month               VarChar(Max)
Declare @CTEBody             VarChar(Max) 
Declare @SourceTableName     VarChar(Max)
Declare @CreateTable         VarChar(Max)
Declare @sqlCreateTmpTable   VarChar(Max)
Declare @sqlDropProdTable    VarChar(Max)
Declare @sqlCreateIndex      VarChar(Max)
Declare @sqlDropTmpTable     VarChar(Max)
Declare @LogError            VarChar(Max)
Declare @programName         varchar(Max) = 'AutoGenerateRollup Post 2006:  '
Declare @errorMessage        varchar(Max)
Declare @TmpTableName        VarChar(Max)
Declare @NewTableName        VarChar(Max)
Declare @severityLevel       int = 16
Declare @state               int = 1
Declare @YearToProcess       varchar(Max) = '%2009%'



Declare @BaseCTEPart VarChar(Max) = Char(10) + ' UNION ALL Select ACQR_BIN, ACQR_CTRY_CD, ISSR_BIN_CTRY_CD, MRCH_NM_GLBL,' + Char(10) +
    '   MRCH_CTRY_CD, USAGE_CD, TRAN_CD, MRCH_ST_CD, MRCH_CITY, ARN_BIN, MRCH_DBA_ID, '                                    + Char(10) +
	'   MRCH_ZIP_CD, ACQR_CIB_CTRY_CD, ISSR_CIB_CTRY_CD, CRD_ACPTR_ID, MRCH_NM_RAW, CPD_MONTH_ID, FEE_SIGN,'               + Char(10) +
	'   SUM_ACQR_US_FEE_AMT, SUM_ACQR_FEE_CNT, SUM_ISSR_US_FEE_AMT, SUM_ISSR_FEE_CNT, SUM_DRF_US_TRAN_AMT,'                + Char(10) +
	'   SUM_DRF_TRAN_CNT,SUM_DEST_FEE_AMT, SUM_DRF_CSHBK_AMT_R, SUM_DRF_CSHBK_CNT, SUM_DRF_ELAPSE_DAYS,'                   + Char(10) +
	'   SUM_DRF_INTRCH_FEE_AMT, SUM_DRF_NATL_REIMBM_FEE_AMT, SUM_DRF_SRCHG_AMT, SUM_LCL_SLS_TAX_AMT,'                      + Char(10) +
	'   SUM_SRCE_FEE_AMT, SUM_DRF_TRAN_AMT, SUM_CCC_ISC_AMT, SUM_ACQR_TRAN_AMT, SUM_ISSR_TRAN_AMT,'                        + Char(10) +
	'   SUM_CSHBK_AMT, SUM_DRF_US_TRAN_AMT_NR, MRCH_COND_CD, MRCH_CATG_CD, MRCH_VRFCN_VAL, SYS_SRC_CD '                    + Char(10) + 
	' From '

Declare @InsertBody VarChar(Max) = 
    '  ACQR_BIN, ACQR_CTRY_CD, ISSR_BIN_CTRY_CD, MRCH_NM_GLBL, MRCH_CTRY_CD, TRAN_CD, USAGE_CD, MRCH_ST_CD, MRCH_CITY, '   + Char(10) +
	'  MRCH_ZIP_CD, ACQR_CIB_CTRY_CD, ISSR_CIB_CTRY_CD, CRD_ACPTR_ID, MRCH_NM_RAW, CPD_MONTH_ID, FEE_SIGN,'                + Char(10) +
	'  MRCH_COND_CD, MRCH_CATG_CD, MRCH_VRFCN_VAL, SYS_SRC_CD, ARN_BIN, MRCH_DBA_ID, MRCH_NM_GLBL as MRCH_CrunchedName,'   + Char(10) + 
	'  SUM(SUM_ACQR_US_FEE_AMT) AS SUM_ACQR_US_FEE_AMT,'                                                                   + Char(10) +
	'  SUM(SUM_ACQR_FEE_CNT) AS SUM_ACQR_FEE_CNT,'                                                                         + Char(10) +
	'  SUM(SUM_ISSR_US_FEE_AMT) AS SUM_ISSR_US_FEE_AMT,'                                                                   + Char(10) +
	'  SUM(SUM_ISSR_FEE_CNT) AS SUM_ISSR_FEE_CNT,'                                                                         + Char(10) +
	'  SUM(SUM_DRF_US_TRAN_AMT) AS SUM_DRF_US_TRAN_AMT,'                                                                   + Char(10) +
	'  SUM(SUM_DRF_TRAN_CNT) AS SUM_DRF_TRAN_CNT,'                                                                         + Char(10) +
	'  SUM(SUM_DEST_FEE_AMT) AS SUM_DEST_FEE_AMT,'                                                                         + Char(10) +
	'  SUM(SUM_DRF_CSHBK_AMT_R) AS SUM_DRF_CSHBK_AMT_R,'                                                                   + Char(10) +
	'  SUM(SUM_DRF_CSHBK_CNT) AS SUM_DRF_CSHBK_CNT,'                                                                       + Char(10) +
	'  SUM(SUM_DRF_ELAPSE_DAYS) AS SUM_DRF_ELAPSE_DAYS,'                                                                   + Char(10) +
	'  SUM(SUM_DRF_INTRCH_FEE_AMT) AS SUM_DRF_INTRCH_FEE_AMT,'                                                             + Char(10) +
	'  SUM(SUM_DRF_NATL_REIMBM_FEE_AMT) AS SUM_DRF_NATL_REIMBM_FEE_AMT,'                                                   + Char(10) +
	'  SUM(SUM_DRF_SRCHG_AMT) AS SUM_DRF_SRCHG_AMT,'                                                                       + Char(10) +
	'  SUM(SUM_LCL_SLS_TAX_AMT) AS SUM_LCL_SLS_TAX_AMT,'                                                                   + Char(10) +
	'  SUM(SUM_SRCE_FEE_AMT) AS SUM_SRCE_FEE_AMT,'                                                                         + Char(10) +
	'  SUM(SUM_DRF_TRAN_AMT) AS SUM_DRF_TRAN_AMT,'                                                                         + Char(10) +
	'  SUM(SUM_CCC_ISC_AMT) AS SUM_CCC_ISC_AMT,'                                                                           + Char(10) +
	'  SUM(SUM_ACQR_TRAN_AMT) AS SUM_ACQR_TRAN_AMT,'                                                                       + Char(10) +
	'  SUM(SUM_ISSR_TRAN_AMT) AS SUM_ISSR_TRAN_AMT,'                                                                       + Char(10) +
	'  SUM(SUM_CSHBK_AMT) AS SUM_CSHBK_AMT,'                                                                               + Char(10) +
	'  SUM(SUM_DRF_US_TRAN_AMT_NR) AS SUM_DRF_US_TRAN_AMT_NR'                                                              + Char(10) 
 

Declare @GroupBy VarChar(Max) = Char(10) + 'Group By ACQR_BIN, ACQR_CTRY_CD, ISSR_BIN_CTRY_CD, MRCH_NM_GLBL, MRCH_CTRY_CD, USAGE_CD, TRAN_CD, MRCH_ST_CD, MRCH_CITY, ' + Char(10) +
'  MRCH_ZIP_CD, ACQR_CIB_CTRY_CD, ISSR_CIB_CTRY_CD, CRD_ACPTR_ID, MRCH_NM_RAW, CPD_MONTH_ID, FEE_SIGN,' + Char(10) +
'  MRCH_COND_CD, MRCH_CATG_CD, MRCH_VRFCN_VAL, SYS_SRC_CD, ARN_BIN, MRCH_DBA_ID'                                             
                                                     

 
Declare @IndexBody VarChar(Max) = Char(10) +
'('                                   + Char(10) +
'	CRD_ACPTR_ID,'                    + Char(10) + 
'	ACQR_CTRY_CD, '                   + Char(10) +
'	ACQR_BIN'                         + Char(10) +
')'




INSERT INTO STEP_1.dbo.AllRolledUpMonths (month) Select 'start'

While 1=1
Begin
  
  --Process months in the priority months table first.  Grab first source table to create target table with select into.
  Select top 1 @Month = [month], @SourceTableName = [tablename]
  From STEP_1.dbo.AllTables at 
    Where Not Exists(Select 1 From STEP_1.dbo.AllRolledUpMonths rm where rm.month = at.month)
      And Exists(Select 1 From STEP_1.dbo.PriorityMonths pm Where at.month = pm.month)
	  And month like @YearToProcess
    order by 1 desc
  
  --Process remaining tables in dbo.AllTables
  If @@ROWCOUNT = 0 
  Begin
    Select top 1 @month = [month], @SourceTableName = [tablename]
    From STEP_1.dbo.AllTables at 
      Where NOT EXISTS(Select 1 From STEP_1.dbo.AllRolledUpMonths rm Where rm.month = at.month)
        AND NOT EXISTS(Select 1 From STEP_1.dbo.AllTables rm Where rm.month = at.month and rm.problematic = 1)
        And month like @YearToProcess
      order by 1 desc
    
	  If @@ROWCOUNT = 0
	  Begin
		Break
	  End
  End

  Set   @TargetTableName = 'Step_1.dbo.txn_' + @month
  Set   @TmpTableName    = @TargetTableName + '_Temp' 

  --Build the create table statement
  Set @CreateTable = 'Select ' + @InsertBody 
	               + ' Into '  + @TmpTableName  
		           + ' From '  + @SourceTableName 
                   + Char(10)  + ' where 1 = 0' 
		           + @GroupBy  + Char(10)
				   + Char(10) 
				   + Char(10) 

  --Grab union of all tables created for YYYY_MM (ie YYYY_MMx)
  Select @CTEBody = SUBSTRING((Select @BaseCTEPart + tableName 
                          From STEP_1.dbo.AllTables 
                          Where [month] = @month
                            AND duplicate = 0 FOR XML PATH('')
                          ), 12, 8000)
   
  Set   @CTEBody = '(' + @CTEBody + ')'

  --Create Insert Into Statement
  Set   @InsertIntoStatement = @CTEHead      + 
                           @CTEBody          + Char(10) + 
						   @InsertHead       + 
					 	   @TmpTableName     +
						   @SelectHead       + Char(10) + 
						   @InsertBody       + 
						   @From             + 
						   @CTEName          +
						   @GroupBy          + 
						   @OrderBy          
						  

  Set   @LogStatement    =  Char(10) + 'INSERT INTO STEP_1.dbo.AllRolledUpMonths (month) Select ''' + @month + ''''
  Set   @LogError        = 'INSERT INTO STEP_1.dbo.AllRolledUpMonths (month, problematic) SELECT ''' + @month + '''' + ' , 1'  
  Set   @DropTable       = 'If OBJECT_ID(''' + @TargetTableName + ''') IS NOT NULL DROP TABLE ' + @TargetTableName + Char(10) + '' + Char(10)
  Set   @sqlDropTmpTable    = 'If OBJECT_ID(''' + @TmpTableName    + ''') IS NOT NULL DROP TABLE ' + @TmpTableName 
  
  --Generate script to run
  Set   @sqlCreateTmpTable = @HeaderStatement     + 
			                 @CreateTable         + 
			                 @InsertIntoStatement  

  Set   @sqlDropProdTable = @HeaderStatement +
                            @DropTable       + Char(10) 

  Set   @sqlCreateIndex  = @HeaderStatement  +
                           @CreateIndex      +
			               @TargetTableName  +
				           @IndexBody        
						  
	
 

  Print @sqlDropTmpTable
  Print @sqlCreateTmpTable
  Print @sqlDropProdTable
  Print 'SP_Rename @TmpTableName, @TargetTableName'
  Print @sqlCreateIndex
  Print @LogStatement	
  Break

  
 
	
			
  Set @NewTableName = Substring(@TargetTableName, 12, 11)			   

  Exec(@sqlDropTmpTable)
  Exec(@sqlCreateTmpTable)

  Begin Try
    Begin Tran
      Exec(@sqlDropProdTable)
      Exec SP_Rename @TmpTableName, @NewTableName
      Exec(@sqlCreateIndex)
      Exec(@LogStatement)
    Commit Tran	
  End Try

  Begin Catch
    RollBack Tran
    Set @errorMessage = @programName + ERROR_MESSAGE()    
	Exec(@LogError)  
    RaisError(@errorMessage, @severityLevel, @state);	  
  End Catch

End

--delete from step_1.dbo.AllRolledUpMonths

--select top 1 * from Step_1.dbo.txn_2007_10

--select * from step_1.dbo.allrolledupmonths