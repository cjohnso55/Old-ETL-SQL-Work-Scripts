--Move tables from INCH to STEP_1 on the .25 server


IF OBJECT_ID('STEP_1.dbo.AllRolledUpMonths') IS NOT NULL
	DROP TABLE Step_1.dbo.AllRolledUpMonths

IF OBJECT_ID('STEP_1.dbo.AllRolledUpMonthsRound1') IS NOT NULL
	DROP TABLE Step_1.dbo.AllRolledUpMonthsRound1

IF OBJECT_ID('STEP_1.dbo.AllTables') IS NOT NULL
	DROP TABLE Step_1.dbo.AllTables
 
IF OBJECT_ID('STEP_1.dbo.AllTables2006') IS NOT NULL
	DROP TABLE Step_1.dbo.AllTables2006

IF OBJECT_ID('STEP_1.dbo.PriorityMonths') IS NOT NULL
	DROP TABLE Step_1.dbo.PriorityMonths

IF OBJECT_ID('STEP_1.dbo.PriorityYears') IS NOT NULL
	DROP TABLE Step_1.dbo.PriorityYears

select * into Step_1.dbo.AllRolledUpMonths from Inch.dbo.AllRolledUpMonths
select * into Step_1.dbo.AllRolledUpMonthsRound1 from Inch.dbo.AllRolledUpMonthsRound1
select * into Step_1.dbo.AllTables from Inch.dbo.AllTables
select * into Step_1.dbo.AllTables2006 from Inch.dbo.AllTables2006
select * into Step_1.dbo.PriorityMonths from Inch.dbo.PriorityMonths 
select * into Step_1.dbo.PriorityYears from Inch.dbo.PriorityYears 
select * into Step_1.dbo.ImportProgress from INCH.dbo.Import_Progress
select * into Step_1.dbo.Import_Progress_Archive from INCH.dbo.Import_Progress_Archive
select * into Step_1.dbo.Load_Records from INCH.dbo.Load_Records
select * into Step_1.dbo.AllMerchants_DupsRemoved from INCH.dbo.AllMerchants_DupsRemoved_NOtUsed