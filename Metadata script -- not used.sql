/*
  Craig Johnson 07-09-13
  Update crunched name - 2004-2006
*/

Use STEP_1
Set NoCount On
Go


Declare @SQL VarChar(Max)
Declare @TableName VarChar(255)

Select 'dbo.' + table_name as TableName into #InProcess from Information_Schema.Tables 
                                                        where (table_name like ('%txn_2004_%')
                                                            or table_name like ('%txn_2005_%')
										                    or table_name like ('%txn_2006_%'))
										                order by table_Name 
 


While Exists (select top(1) * from #InProcess order by TableName)
Begin	
    Set @TableName = (select top 1 * from #InProcess)

	Set @SQL = 'Update ' + @TableName + ' set MRCH_CrunchedName =  nullif(lkp.dbo.regexreplace(lkp.dbo.regexReplace(Merch_Desc_Nm, ''[&+]+'', ''AND''), ''[-/0-9]{2,}(?<=.{11})|[^a-zA-Z0-9]'', ''''), '''') '

	--Exec (@SQL)
	Print @SQL
	
	Delete top(1) from #InProcess where tableName = @TableName
End

Drop Table #InProcess
Go

Declare @SQL VarChar(Max)
Declare @TableName VarChar(255)


Select 'dbo.' + table_name as TableName into #InProcess from Information_Schema.Tables 
                                                        where (table_name like ('%txn_2007_%')
                                                            or table_name like ('%txn_2008_%')
										                    or table_name like ('%txn_2009_%')
															or table_name like ('%txn_2010_%')
										                    or table_name like ('%txn_2011_%')
															or table_name like ('%txn_2012_%'))
										                order by table_Name 



While Exists (select top(1) * from #InProcess)
Begin	
    Set @TableName = (select top 1 * from #InProcess order by table_name)

	Set @SQL = 'Update ' + @TableName + ' set MRCH_CrunchedName =  nullif(lkp.dbo.regexreplace(lkp.dbo.regexReplace(MRCH_NM_GLBL, ''[&+]+'', ''AND''), ''[-/0-9]{2,}(?<=.{11})|[^a-zA-Z0-9]'', ''''), '''') '

	--Exec (@SQL)
	Print @SQL
	
	Delete top(1) from #InProcess where tableName = @TableName
End

Drop Table #InProcess