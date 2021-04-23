/*
**********************************************************************************************************************************************
***  Object:					SQL Script		
***  Database:					CA6336
***  Production Server:			casql02v02.amer.epiqcorp.com,8882\CA02		
***  Testing Server:			etSTsqlcl01\ecafcc
***  Author: 					Craig Johnson (rewrite of previous report)
***  Creation Date:				02/26/14
***  Purpose:					YOM Report for WFFFCO												
***  Sample Call(s)				
***  Change Log
***  Change	By			            Date		    Change #	   Description
***  ------------------------------------------------------------------------------------------------
**********************************************************************************************************************************************
*/



--Use CA6336_UAT2
Use CA6336_Snap
Go

--Roll current date back to midnight to exclude mailings that have not mailed.
--This should be used instead of GetDate()
Declare @DateToday DateTime = DateAdd(dd, 0, DateDiff(dd, 0, GetDate()));
Declare @Count     Integer


/* 
  Grab valid Claims and associated Claimant data.  Populate account type based on 
  mailings, since we have incorrect data in Claimant.
*/
IF OBJECT_ID('tempdb..#ClaimantsToInclude') 
      IS NOT NULL DROP TABLE #ClaimantsToInclude
    

Select distinct
            c.*,
        	AccountType =   
				    Case When (IsNull(c.Account_Type, '') = 'Plan B' and m.pk_MailingsID IS NOT NULL)
                           Then 'Both'
                         When IsNull(c.Account_Type, '') = ''
                           Then 'Plan A'
                         Else 
						   c.Account_Type
                    End 
					 
into #ClaimantsToInclude					                                                             
From dbo.Claimant c With(NoLock)

Left Join   dbo.Mailings m WITH(NoLock)
              On    c.Tracking_Number = m.Tracking_Number
              and   m.Mailing_Type = 'Pl A Initial Notice'
              and   m.[Sent] < @DateToday
              and   IsNull(c.Account_Type, '') IN('Plan B', '')
Where  (
         c.Account_Type IN('Plan A','Plan B','Both')
           Or 
         m.pk_MailingsID IS NOT NULL
        )
     
create clustered index ix_Tracking_Number on #ClaimantsToInclude (Tracking_Number)


/*
  Populate plan completed dates.  There is a column each for A_Denied, B_Denied,
  A_Approved, B_Approved and first_check_date. If the date is populated it was Approved,
  Denied, was a check cut.  Otherwise column is left null.  
  
  At the time of implementation, it was unclear if we could tie a check back with
  a particular Plan/Loan type.  So only one column exists.  
*/          
if object_id('tempdb..#PlanCompletedDate') is not null
      drop table #PlanCompletedDate;


;With First_Check_Cut as 
         (
		     select c.Tracking_Number as Tracking_Number,
		          pd.CheckDate as [Date],
			      'Check Cut' as [Status]
                  From #ClaimantsToInclude c
                  join (
				         select Tracking_Number, 
				                MIN(CheckDate) as 'CheckDate'
                         From PaymentDetail
                         group by Tracking_Number
					   ) pd 
	               on c.Tracking_Number=pd.Tracking_Number
	               where c.Claimant_Status = 'Paid'
		),

Plan_A_Completed as 
        (
	       select c.Tracking_Number as Tracking_Number,
				  'Plan A Completed' as Decision,
				  completed.DateApproved as DateApproved
                  From #ClaimantsToInclude c 
                  inner join vwApprovedAB completed 
                    on  completed.Tracking_Number = c.Tracking_Number 
                    and completed.LoanType = 'Plan A' 
                  where c.AccountType IN ('Plan A', 'Both')
	    ),

Plan_B_Completed as
        (
	       select c.Tracking_Number as Tracking_Number,
				  'Plan B Completed' as Decision,
				  completed.DateApproved as DateApproved
                  From #ClaimantsToInclude c 
                  inner join vwApprovedAB completed 
                    on  completed.Tracking_Number = c.Tracking_Number 
                    and completed.LoanType = 'Plan B' 
                  where c.AccountType IN ('Plan B', 'Both')
		),

Plan_A_Denied as
        (
	       select c.Tracking_Number as Tracking_Number,
				  denied.LoanType as LoanType,
				  denied.DeniedDate as DeniedDate
                  From #ClaimantsToInclude c 
                  inner join vwDeniedAB denied
                    on  denied.Tracking_Number = c.Tracking_Number 
                    and denied.LoanType = 'Plan A' 
                  where c.AccountType IN ('Plan A', 'Both')     
		),

Plan_B_Denied as
        (
	       select c.Tracking_Number as Tracking_Number,
				  v.LoanType as LoanType,
				  v.DeniedDate as DeniedDate
				  From #ClaimantsToInclude c 
                  inner join vwDeniedAB v 
                    on  v.Tracking_Number = c.Tracking_Number 
                    and v.LoanType = 'Plan B' 
                  where c.AccountType IN ('Plan B', 'Both')
		)

select  
       claimant.Account,
       claimant.Tracking_Number as Tracking_Number,  			  	 			  
	   convert(varchar(15),pad.DeniedDate,101) as A_DeniedDate,  	      
	   convert(varchar(15),pbd.DeniedDate,101) as B_DeniedDate,  
	   convert(varchar(15),pac.DateApproved,101) as A_ApprovedDate, 
	   convert(varchar(15),pbc.DateApproved,101) as B_ApprovedDate,
	   convert(varchar(15),cc.[Date],101) as InitialCheckDate

into #PlanCompletedDate
From #ClaimantsToInclude claimant

left join Plan_A_Denied pad
  on pad.Tracking_Number = claimant.Tracking_Number
left join Plan_B_Denied pbd
  on pbd.Tracking_Number = claimant.Tracking_Number
left join First_Check_Cut cc 
  on cc.Tracking_Number = claimant.Tracking_Number 
left join Plan_A_Completed pac 
  on pac.Tracking_Number = claimant.Tracking_Number
left join Plan_B_Completed pbc 
  on pbc.Tracking_Number = claimant.Tracking_Number

create clustered index ix_Tracking_Number on #PlanCompletedDate (Tracking_Number)


/*
  Populate sent status for Plan A.  

  The only reason the left join to a subquery is here is for debugging purposes. 
  These could/should be refactored into CTEs once we are comfortable with the report.
*/    
if object_id('tempdb..#Claim_A_Sent') is not null
      drop table #Claim_A_Sent;

	select claimants.Tracking_Number,
	       case When x.Sent = 'Y'  and claimants.AccountType IN ('Plan A', 'Both') 
		          Then 'Y' 
				    else 'N' 
		   end as [Sent]
	into #Claim_A_Sent 
	From
	#claimantsToInclude claimants 
	left join 
		(
	      select distinct m.Tracking_Number as Tracking_Number, 
						    'Y' as Sent
			 From  Mailings m with(nolock)
			 where m.Mailing_Type IN ('Pl A Initial Notice', 'KF Init Notice Pack','KFNotice Bkrpt/Trust','Notice Bkrptcy/Trust')
			 and m.[Sent] < @DateToday		
	    ) x
    on x.Tracking_Number = claimants.tracking_number

create clustered index ix_Tracking_Number on #Claim_A_Sent (Tracking_Number)




/*
  Populate Started status for Plan A.

  The only reason the left join to a subquery is here is for debugging purposes. 
  These could/should be refactored into CTEs once we are comfortable with the report.
*/          
if object_id('tempdb..#Claim_A_Started') is not null
      drop table #Claim_A_Started;

Select claimants.Tracking_Number,
       IsNull(x.[Started], 'N') as Started
into #Claim_A_Started 
From #ClaimantsToInclude claimants
left outer join	            
	(
	 select distinct c.Tracking_Number as Tracking_Number,
	                'Y' as [Started]
                  From #ClaimantsToInclude c 
                  inner join FacilitatorBatch fb 
                    on c.Tracking_Number=fb.TrackingNumber                   
                  inner join FacilitatorBatchStage fbs 
                    on fb.BatchStageId=fbs.BatchStageId
                  inner join FacilitatorBatchStageFilter fbsf 
                    on fbs.StageFilterId=fbsf.StageFilterId
                    and fbsf.StageFilter='Plan A'
				  where c.AccountType IN ('Plan A','Both')
	) x
on x.Tracking_Number = claimants.Tracking_Number

create clustered index ix_Tracking_Number on #Claim_A_Started (Tracking_Number)



/*
  Populate Suspended status for Plan A
*/    
if object_id('tempdb..#Claim_A_Suspend') is not null
      drop table #Claim_A_Suspend;

  select c.Tracking_Number,
         case When (c.AccountType in ('Plan A', 'Both') and c.Claimant_Status = '39') 
                Then 'Y' 
                else 'N' 
         end as [Suspended] 
  into #Claim_A_Suspend
  From #ClaimantsToInclude c 

create clustered index ix_Tracking_Number on #Claim_A_Suspend (Tracking_Number)



/*
  Populate Plan B started status

  The only reason the left join to a subquery is here is for debugging purposes. 
  These could/should be refactored into CTEs once we are comfortable with the report.
*/
if object_id('tempdb..#Claim_B_Started') is not null
      drop table #Claim_B_Started;
     

Select claimants.Tracking_Number,
       IsNull(x.[Started], 'N') as Started
into #Claim_B_Started 
From #ClaimantsToInclude claimants
left outer join	            
	(
	 select distinct c.Tracking_Number as Tracking_Number,
	                'Y' as [Started]
                  From #ClaimantsToInclude c 
                  inner join FacilitatorBatch fb 
                    on c.Tracking_Number=fb.TrackingNumber                   
                  inner join FacilitatorBatchStage fbs 
                    on fb.BatchStageId=fbs.BatchStageId
                  inner join FacilitatorBatchStageFilter fbsf 
                    on fbs.StageFilterId=fbsf.StageFilterId
                    and fbsf.StageFilter='Plan B'
				  where c.AccountType IN ('Plan B', 'Both')
	) x
on x.Tracking_Number = claimants.Tracking_Number

create clustered index ix_Tracking_Number on #Claim_B_Started (Tracking_Number)


      
/*
  Populate the Claim B In process status

  The only reason the left join to a subquery is here is for debugging purposes. 
  These could/should be refactored into CTEs once we are comfortable with the report.
*/
if object_id('tempdb..#Claim_B_InProcess') is not null
      drop table #Claim_B_InProcess;  
select claimants.Tracking_Number,
       IsNull(x.InProcess, 'N') as InProcess	      
into #Claim_B_InProcess
From #ClaimantsToInclude claimants
left outer join
    ( select distinct  c.Tracking_Number,
                      'Y' as InProcess
        From #ClaimantsToInclude c
        inner join FacilitatorBatch fb 
          on c.Tracking_Number = fb.TrackingNumber
        where c.AccountType IN ('Both', 'Plan B')
        and c.Claimant_Status IN ('1B','2B','3B','13B')
	) x
on claimants.Tracking_number = x.Tracking_Number

create clustered index ix_Tracking_Number on #Claim_B_InProcess (Tracking_Number)


/*
  Populate the Claim B Suspended status.
*/
if object_id('tempdb..#Claim_B_Suspend') is not null
      drop table #Claim_B_Suspend;  
      --45
      select c.Tracking_Number, 
             case When (c.AccountType in ('Plan B','Both') and c.Claimant_Status = '39') 
                  Then 'Y' 
                  else 'N' 
             end as Suspended
      into #Claim_B_Suspend
      From #ClaimantsToInclude c 

create clustered index ix_Tracking_Number on #Claim_B_Suspend (Tracking_Number)



/*
  Populate the Claim Received Date.

  The only reason the left join to a subquery is here is for debugging purposes. 
  These could/should be refactored into CTEs once we are comfortable with the report.
*/
if object_id('tempdb..#Claim_Received_Dt') is not null
      drop table #Claim_Received_Dt;      
  
select claimant.Tracking_Number,
       case When x.Tracking_Number Is Null 
            Then ''
            else convert(varchar(15),x.Received,101)
       end as Received
into #Claim_Received_Dt
From #ClaimantsToInclude claimant 
left outer join
   (
      select d.Tracking_Number 
             ,MIN(d.Received) as Received
      From #ClaimantsToInclude i 
      inner join Documents d
        on d.Tracking_Number=i.Tracking_Number
        and d.Document_Type IN ('Claim for Comp','Contact Information')
      group by d.Tracking_Number
   ) x 
on x.Tracking_Number = claimant.Tracking_Number

create clustered index ix_Tracking_Number on #Claim_Received_Dt (Tracking_Number)



/*
  Populate the needed Alt Address Data 'Add Fields1' fields.

  No outer join necessary as all pertinent tracking numbers should
  have associated Add Fields1 alt address data.  However two records
  are being dropped because of bad data. 
*/
if object_id('tempdb..#Account_NR_Service') is not null
      drop table #Account_NR_Service;     
	
	select c.Tracking_Number, 
		  aad.Integer03 as account_nr_service 
	into #Account_NR_Service
	From #ClaimantsToInclude c
	inner join AltAddress aa 
	  on c.Tracking_Number=aa.Tracking_Number
	  and aa.AddressType='Add Fields1'
	inner join AltAddressData aad 
	  on aa.pk_AltAddressID=aad.fk_AltAddressID

create clustered index ix_Tracking_Number on #Account_NR_Service (Tracking_Number)



/*
  Populate the needed Alt Address Data 'Add Fields3' fields.

  No outer join necessary as all pertinent tracking numbers should
  have associated Add Fields3 alt address data.  However two records
  are being dropped because of bad data. 
*/
if object_id('tempdb..#Loan_Application_Number') is not null
      drop table #Loan_Application_Number;      

select c.Tracking_Number, 
         aad1.Text14 as Loan_Application_Number,
         aad1.Date06 as EOM_as_of_dt
into #Loan_Application_Number
From #ClaimantsToInclude c
join AltAddress aa1 
  on c.Tracking_Number=aa1.Tracking_Number
  and aa1.addresstype='Add Fields3' 
join AltAddressData aad1 
  on aa1.pk_altaddressid=aad1.fk_altaddressid   

create clustered index ix_Tracking_Number on #Loan_Application_Number (Tracking_Number)


/*
  Insert the data From the various queries above into one table.
*/
if object_id('tempdb..#NewReport') is not null
      drop table #NewReport;


                           
select  
          c.Account                                  as acct_nr_orig
         ,Account_NR_Service.Account_NR_Service      as acct_nr_service
         ,convert(varchar(15),c.Date_of_Birth_1,101) as Acct_open_dt
         ,Claim_A_Sent.[Sent]                        as Claim_A_Sent
         ,Claim_A_Started.[Started]                  as Claim_A_Started
         ,Claim_A_Suspend.Suspended                  as Claim_A_Suspend

		  --Giving Approved Date Precedence in case of an appeal
		 ,Case When isnull(ccd.A_ApprovedDate, '') <> ''
		         Then 'Completed'
			   When isnull(ccd.A_DeniedDate, '') <> ''
			     Then 'Denied'
			   Else
			     'N' 
		  End                                        as Claim_A_Ended

         ,Claim_B_Started.[Started]                  as Claim_B_Started
         ,Claim_B_InProcess.InProcess                as Claim_B_InProcess
         ,Claim_B_Suspend.Suspended                  as Claim_B_Suspend

		  --Giving Approved Date precedence in case of an appeal
		  --If the date exists we have approval or denial
		 ,Case When isnull(ccd.B_ApprovedDate, '') <> ''
		         Then 'Completed'
			   When isnull(ccd.B_DeniedDate, '') <> ''
			     Then 'Denied'
			   Else
			     'N' 
		  End                                        as Claim_B_Ended

		  --Grab the maximum approved or denied date from the virtual table
		  --I wish nulls were handled differently with money, date etc. datatypes...
		 ,isnull(convert(varchar(15),   
		            (select Max(Completed_Date) 
		             from (Values 
					         (cast(ccd.A_ApprovedDate as Date)), 
				             (cast(ccd.B_ApprovedDate as Date)), 
					  		 (cast(ccd.A_DeniedDate as Date)), 
							 (cast(ccd.B_DeniedDate as Date)),
							 (cast(ccd.InitialCheckDate as Date)))
					      as Value(Completed_Date)),
				 101), 
		  '') as Claim_Completed_dt 


		 /*----------- Per client request specific dates are
		   ----------- excluded from the report.
         ,isnull(ccd.A_ApprovedDate, '') as newPlanA_Approved_Date
		 ,isnull(ccd.B_ApprovedDate, '') as newPlanB_Approved_Date
		 ,isnull(ccd.A_DeniedDate, '') as newPlanA_Denied_Date
		 ,isnull(ccd.B_DeniedDate, '') as newPlanB_Denied_Date
		 ,isnull(ccd.InitialCheckDate, '') as newFirstCheckSentDate
         -----------*/

         ,Claim_Received_Dt.Received as Claim_Received_dt
         ,Convert(varchar(15),Loan_Application_Number.EOM_as_of_dt,101) as EOM_as_of_dt
         ,Loan_Application_Number.Loan_Application_Number as Loan_Application_Number
         ,c.Tracking_Number as EPIQ_tracking_number

into #NewReport
From #ClaimantsToInclude c

      inner join #Loan_Application_Number Loan_Application_Number 
       on Loan_Application_Number.Tracking_Number = c.Tracking_Number
      inner join #Account_NR_Service Account_NR_Service 
         on Account_NR_Service.Tracking_Number = c.Tracking_Number
      inner join #Claim_A_Sent Claim_A_Sent    
         on Claim_A_Sent.Tracking_Number = c.Tracking_Number
      inner join #Claim_A_Started Claim_A_Started 
         on Claim_A_Started.Tracking_Number = c.Tracking_Number
      inner join #Claim_A_Suspend Claim_A_Suspend
         on Claim_A_Suspend.Tracking_Number = c.Tracking_Number
      inner join #Claim_B_Started Claim_B_Started
         on Claim_B_Started.Tracking_Number = c.Tracking_Number
      inner join #Claim_B_InProcess Claim_B_InProcess
         on Claim_B_InProcess.Tracking_Number = c.Tracking_Number
      inner join #Claim_B_Suspend Claim_B_Suspend
         on Claim_B_Suspend.Tracking_Number = c.Tracking_Number
      inner join #PlanCompletedDate ccd 
         on ccd.Tracking_Number=c.Tracking_Number
      inner join #Claim_Received_Dt Claim_Received_Dt
         on Claim_Received_Dt.Tracking_Number = c.Tracking_Number
Order by c.Tracking_Number

 
 
--return results           
select * from #NewReport order by Epiq_Tracking_Number


--get metadata
SET @Count = @@ROWCOUNT

select 'File Name,Record Count,Date'
UNION
select 'YOM_flag_'+CONVERT(CHAR(4), DATEPART(YEAR, GETDATE()))+RIGHT('00'+CONVERT(NVARCHAR(2), DATEPART(MONTH, GETDATE())),2)+RIGHT('00'+CONVERT(NVARCHAR(2), DATEPART(DAY, GETDATE())),2)+'.txt'
		+','+CONVERT(VARCHAR(20), @Count)+','+CONVERT(VARCHAR(20), GETDATE(), 101)


