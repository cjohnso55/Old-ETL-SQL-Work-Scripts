/*
  Build Step_1 from INCH, years prior to 2007.
*/
USE STEP_1

INSERT INTO STEP_1.dbo.AllRolledUpMonths2006 (month) SELECT 'start'

Declare @month                 VarChar(Max)
Declare @CreateStatement       VarChar(Max) 
Declare @LogStatement          VarChar(Max)    
Declare @DropTmpStatement      VarChar(Max) 
Declare @DropStatement         VarChar(Max)       
Declare @TargetTableName       VarChar(Max) 
Declare @CTEName               VarChar(Max) = ' txn_SummaryData '
Declare @CTEHead               VarChar(Max) = ';With ' + @CTEName + ' As' 
Declare @From                  VarChar(Max) = ' From '
Declare @HeaderStatement       VarChar(Max) = 'USE Step_1' + Char(10) + '' + Char(10)
Declare @SourceTableName       VarChar(Max) 
Declare @CreateTargetIndex     VarChar(Max) = char(10) + 'CREATE CLUSTERED INDEX [PK_CRD_ACPTR_ID_SRCE_FEE_CTRY_ACQ_BIN] ON ' 
Declare @CTEBody               VarChar(Max) 
Declare @OrderBy               VarChar(Max) =  'Order By Merch_Desc_ID'
Declare @CreateTmpIndex        VarChar(Max) = 'CREATE INDEX IX_Merch_Desc_ID on '
Declare @CreateTmpTable        VarChar(Max)
Declare @CreateTargetTable     VarChar(Max)
Declare @InsertIntoTmpTable    VarChar(Max)
Declare @InsertIntoTargetTable VarChar(Max)
Declare @SQL                   VarChar(Max)
Declare @LogError              VarChar(Max)
Declare @programName           varchar(Max) = 'AutoGenerateRollup Pre 2007:  '
Declare @errorMessage          varchar(Max)
Declare @severityLevel         int = 16
Declare @state                 int = 1



Declare @BaseCTEPart VarChar(Max) = ' UNION ALL SELECT [YYYYMM],[Merch_Desc_ID],[ISSR_ISO_CTRY_CD],[TRAN_CD],[TRAN_USAGE_CD]' + char(10) +
	'    ,[SRC_CURR_CD],[DEST_CURR_CD],[SRCE_FEE_CTRY],[DEST_FEE_CTRY],[SYS_SRC_CD]'                                              + char(10) + 
	'    ,[TRAN_CNT],[US_AMT],[SRC_AMT],[DEST_AMT],[SRCE_FEE_AMT]'                                                                + char(10) +
	'    ,[DEST_FEE_AMT],[MERCH_VOL_RESV_FEE_AMT],[CASHBK_CNT],[CSHBK_AMT]'                                                       + char(10) + 
  'FROM '

Declare @InsertBody VarChar(Max) =
    '[YYYYMM],[Merch_Desc_ID],[ISSR_ISO_CTRY_CD],[TRAN_CD],[TRAN_USAGE_CD] '     + char(10) +
	'    ,[SRC_CURR_CD],[DEST_CURR_CD],[SRCE_FEE_CTRY],[DEST_FEE_CTRY],[SYS_SRC_CD]' + char(10) + 
	'    ,sum([TRAN_CNT]) [TRAN_CNT]'                                                + char(10) +                                      
	'    ,sum([US_AMT]) [US_AMT]'                                                    + char(10) +
	'    ,sum([SRC_AMT]) [SRC_AMT]'                                                  + char(10) +
	'    ,sum([DEST_AMT]) [DEST_AMT]'                                                + char(10) +
	'    ,sum([SRCE_FEE_AMT]) [SRCE_FEE_AMT]'                                        + char(10) +
	'    ,sum([DEST_FEE_AMT]) [DEST_FEE_AMT]'                                        + char(10) +
	'    ,sum([MERCH_VOL_RESV_FEE_AMT]) [MERCH_VOL_RESV_FEE_AMT]'                    + char(10) +
	'    ,sum([CASHBK_CNT]) [CASHBK_CNT]'                                            + char(10) +
	'    ,sum([CSHBK_AMT]) [CSHBK_AMT]'                                              + char(10) +
	'    ,COUNT(*) Row_Count' 
  
  
Declare @GroupBy VarChar(Max) = char(10) + 'group by [Merch_Desc_ID],[YYYYMM],[ISSR_ISO_CTRY_CD],[TRAN_CD],[TRAN_USAGE_CD] ' + char(10) +
',[SRC_CURR_CD],[DEST_CURR_CD],[SRCE_FEE_CTRY],[DEST_FEE_CTRY],[SYS_SRC_CD]'                                                 + char(10)  

Declare @TmpIndexBody VarChar(Max) = char(10) +
'('                  + char(10) +
'	[Merch_Desc_Id]' + char(10) + 
')'                  + char(10)

Declare @InsertFromTempBody VarChar(Max) = char(10) +
    '[ACQ_BIN],[Crd_Acptr_Id],[Merch_Desc_Nm],[Merch_Desc_City],[Merch_Desc_Ctry_ISO],[Merch_Desc_Pstl_Cd],[Merch_Desc_St_Abrv] ' + char(10) +
    '    ,[YYYYMM],[ISSR_ISO_CTRY_CD],[TRAN_CD],[TRAN_USAGE_CD] '                                                                     + char(10) +
	'    ,[SRC_CURR_CD],[DEST_CURR_CD],[SRCE_FEE_CTRY],[DEST_FEE_CTRY], [SYS_SRC_CD], [Merch_Desc_MCC]'                               + char(10) + 
	'    ,sum([TRAN_CNT]) [TRAN_CNT]'                                                                                                 + char(10) +                                                                                   
	'    ,sum([US_AMT]) [US_AMT]'                                                                                                     + char(10) +
	'    ,sum([SRC_AMT]) [SRC_AMT]'                                                                                                   + char(10) +
	'    ,sum([DEST_AMT]) [DEST_AMT]'                                                                                                 + char(10) +
	'    ,sum([SRCE_FEE_AMT]) [SRCE_FEE_AMT]'                                                                                         + char(10) +
	'    ,sum([DEST_FEE_AMT]) [DEST_FEE_AMT]'                                                                                         + char(10) +
	'    ,sum([MERCH_VOL_RESV_FEE_AMT]) [MERCH_VOL_RESV_FEE_AMT]'                                                                     + char(10) +
	'    ,sum([CASHBK_CNT]) [CASHBK_CNT]'                                                                                             + char(10) +
	'    ,sum([CSHBK_AMT]) [CSHBK_AMT]'                                                                                               + char(10) +
	'    ,sum([Row_Count]) Row_Count'                                                                                                 + char(10) 

Declare @JoinBody VarChar(Max) = ' T left outer join [INCH].[dbo].[txn_AllMerchantsHeader] A '                                                        + char(10) +
	'on T.[Merch_Desc_Id] = A.[Merch_Desc_Id]'                                                                                                            + char(10) +
	'group by [ACQ_BIN],[Crd_Acptr_Id],[Merch_Desc_Nm],[Merch_Desc_City],[Merch_Desc_Ctry_ISO],[Merch_Desc_Pstl_Cd],[Merch_Desc_St_Abrv]'                 + char(10) +
	',[YYYYMM],[ISSR_ISO_CTRY_CD],[TRAN_CD],[TRAN_USAGE_CD],[SRC_CURR_CD],[DEST_CURR_CD],[SRCE_FEE_CTRY],[DEST_FEE_CTRY], [SYS_SRC_CD], [Merch_Desc_MCC]' + char(10) + 
	'order by [CRD_ACPTR_ID], [SRCE_FEE_CTRY], [ACQ_BIN]'                                                                                                 + char(10)

Declare @GroupBy2 VarChar(Max) =
	'group by [ACQ_BIN],[Crd_Acptr_Id],[Merch_Desc_Nm],[Merch_Desc_City],[Merch_Desc_Ctry_ISO],[Merch_Desc_Pstl_Cd],[Merch_Desc_St_Abrv]'                 + char(10) +
	',[YYYYMM],[ISSR_ISO_CTRY_CD],[TRAN_CD],[TRAN_USAGE_CD],[SRC_CURR_CD],[DEST_CURR_CD],[SRCE_FEE_CTRY],[DEST_FEE_CTRY], [SYS_SRC_CD], [Merch_Desc_MCC]' + char(10) + 
	'order by [CRD_ACPTR_ID], [SRCE_FEE_CTRY], [ACQ_BIN]'  

Declare @IndexBody VarChar(Max) = 
'(' + char(10) +
'	[CRD_ACPTR_ID] ASC,' + char(10) +
'	[SRCE_FEE_CTRY] ASC,' + char(10) +
'	[ACQ_BIN] ASC' + char(10) +
')'



WHILE 1=1
BEGIN

  select top 1 @month = [month], @SourceTableName = [tablename]
  from STEP_1.dbo.AllTables2006 at
  WHERE NOT EXISTS(SELECT 1 FROM STEP_1.dbo.AllRolledUpMonths2006 rm WHERE rm.month = at.month)
  and at.[month] like '2006%'
  order by at.[month] desc

  IF @@ROWCOUNT = 0
  BEGIN
    BREAK
  End

  SELECT @CTEBody = SUBSTRING((SELECT @BaseCTEPart + tableName 
                          FROM STEP_1.dbo.AllTables2006 
                          where [month] = @month
                            order by tableName FOR XML PATH('')
                          ), 12, 20000)


  Set @CTEBody = '(' + @CTEBody + char(10) + ')'
  Set @TargetTableName = 'Step_1.dbo.txn_' + @month 

  Set @LogStatement = 'INSERT INTO STEP_1.dbo.AllRolledUpMonths2006 (month) SELECT ''' + @month + ''''  
  Set @LogError     = 'INSERT INTO STEP_1.dbo.AllRolledUpMonths2006 (month, problematic) SELECT ''' + @month + '''' + ' , 1'  

  Set @DropStatement = Char(10) + 'IF OBJECT_ID(''' + @TargetTableName + ''') IS NOT NULL DROP TABLE ' + @TargetTableName + Char(10) + ''

  --Generate individual SQL statments to be executeed 
  Set @CreateTmpTable        = Char(10) + 'Select ' 
                                        + @InsertBody + Char(10) 
										+ 'Into ' 
										+ @TargetTableName + '_Temp ' + Char(10) 
										+ 'From ' 
										+ @SourceTableName + Char(10) 
										+ 'Where 1 = 0' 
										+ @GroupBy 
										+ ''

  Set @InsertIntoTmpTable    = Char(10) + @CTEHead 
										+ @CTEBody  + char(10) 
										+ 'Insert Into ' 
										+ @TargetTableName + '_temp' + char(10) 
										+ ' Select ' 
										+ @InsertBody +  char(10) 
										+ 'From ' 
										+ @CTEName 
										+ @GroupBy 
										+ @OrderBy + char(10) 
										+''

  Set @CreateTargetTable     = Char(10) + 'Select top(0)' 
                                        + @InsertFromTempBody 
										+ 'Into ' 
										+ @TargetTableName + Char(10) 
										+ 'From ' 
										+ @TargetTableName + '_Temp'
										+ @JoinBody 
										+ '' 
  
  Set @CreateTmpIndex        = Char(10) + 'CREATE INDEX IX_Merch_Desc_ID on '
                                        + @TargetTableName + '_Temp' 
										+ @TmpIndexBody 
										+ ''


  Set @InsertIntoTargetTable = Char(10) + 'Insert Into ' 
                                        + @TargetTableName + char(10) 
										+ 'Select ' 
										+  @InsertFromTempBody 
										+ 'From ' + Char(10) 
										+ @TargetTableName + '_Temp' 
										+ @JoinBody 
										+ ''

  Set @DropTmpStatement      = char(10) + 'Drop Table ' 
                                        + @TargetTableName + '_Temp' + char(10) 
										+ ''

  Set @CreateTargetIndex     = char(10) + 'CREATE CLUSTERED INDEX [PK_CRD_ACPTR_ID_SRCE_FEE_CTRY_ACQ_BIN] ON '
                                        + @TargetTableName 
                                        + @IndexBody

  --Form SQL String
  Set @SQL = @CreateTmpTable        + char(10) +
             @InsertIntoTmpTable    + char(10) +
			 @DropStatement         + char(10) +
			 @CreateTargetTable     + char(10) + 
			 @CreateTmpIndex        + char(10) +
			 @InsertIntoTargetTable + char(10) +
			 @DropTmpStatement      + char(10) +
			 @CreateTargetIndex     + char(10) +
			 ''

    --Debug Block
    --Select Cast(@SQL as XML) 
	--print @LogStatement
	--print @LogError
	--Break
 
    Begin Try
	  Begin Transaction

	  Select Cast(@SQL as XML) 
      --Exec(@SQL)
      Exec(@LogStatement)

	  Commit Transaction
    End Try 

    Begin Catch
	  Rollback Transaction

	  Set @errorMessage = @programName + ERROR_MESSAGE()    
	  Exec(@LogError)  
      RaisError(@errorMessage, @severityLevel, @state);	  
    End Catch
	
	
End

--select * from dbo.AllRolledUpMonths2006
--delete from dbo.AllRolledUpMonths2006