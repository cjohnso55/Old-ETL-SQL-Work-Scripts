USE CA4719
go


Begin Try
Begin Transaction


--Dedup based on tracking number.
if object_id('tempdb..#ClaimantsToOptOutOriginal') is not null
	drop table #ClaimantsToOptOutOriginal;
--587,669
  select oofl.MatchedTrackingNumber as TrackingNumberToUpdate,
         c.Claimant_Status as Claimant_Status,
         cast(null as bigint)  as MasterTrackingNumber, 
         min(oofl.DocID) as DocID, 
	     cast(null as varchar(100)) as MatchedOn
    into #ClaimantsToOptOutOriginal
    from dbo.OptOutsMatchedToClaimants oofl
    inner join dbo.Claimant c  
      on c.Tracking_Number = oofl.MatchedTrackingNumber
  group by 
    c.Claimant_Status,
    oofl.MatchedTrackingNumber


--Grab the correct tracking number associated with min(DocID)
update oo set oo.MasterTrackingNumber = d.Tracking_Number 
          from #ClaimantsToOptOutOriginal oo 
		  inner join dbo.Documents d  
		    on d.DocID = oo.DocID

--Grab the correct match type based on min(DocID) and Tracking Number.
update oo set oo.MatchedOn = oofl.PartialMatchOn
          from #ClaimantsToOptOutOriginal oo
		  inner join dbo.OptOutsMatchedToClaimants oofl
		    on oo.TrackingNumberToUpdate = oofl.MatchedTrackingNumber
			and oo.DocID = oofl.DocID



--Cases where we would overwrite an opt out with a different account than initially indicated.
--These will be removed from the claimants that are going to be updated.
if object_id('tempdb..#HoldForReview') is not null
	drop table #HoldForReview;
--151
Select * into #HoldForReview from(
	select 'Opt Out' as Type,
		   c.Tracking_Number as Tracking_Number,
	       c.Account as Account,
		   oo.MasterTrackingNumber as MasterTrackingNumber
		from dbo.Claimant c
		inner join #ClaimantsToOptOutOriginal oo
		  on oo.TrackingNumberToUpdate = c.Tracking_Number
		where c.Claimant_Status = 'Opt Out'
		and isnull(c.Account, '') <> oo.MasterTrackingNumber
		and isnull(c.Account, '') <> ''
	Union All
	select 'See Master',
	       c.Tracking_Number,
	       c.Account,
		   oo.MasterTrackingNumber
		from dbo.Claimant c
		inner join #ClaimantsToOptOutOriginal oo
		  on oo.TrackingNumberToUpdate = c.Tracking_Number
		where c.Claimant_Status = 'See Master'
		and isnull(c.Account, '') <> oo.MasterTrackingNumber
		and isnull(c.Account, '') <> ''
) x
	

--Remove records where the update would change the see master account on claimant.
--151
delete oo from #ClaimantsToOptOutOriginal oo 
          where exists(select 1 from #HoldForReview h 
		                        where h.Tracking_Number = oo.TrackingNumberToUpdate)





if object_id('tempdb..#ClaimantsToOptOutNoticeSentOptOutNotMailed') is not null
	drop table #ClaimantsToOptOutNoticeSentOptOutNotMailed;
--539,288
select * into #ClaimantsToOptOutNoticeSentOptOutNotMailed
	     from #ClaimantsToOptOutOriginal 
	     where claimant_status in ('Notice Sent', 'Opt Out', 'Not Mailed')


create clustered index ix_TrackingNumberToUpdate on #ClaimantsToOptOutNoticeSentOptOutNotMailed (TrackingNumberToUpdate)

--
select 1 --Set @@RowCount = 1
--
while (@@RowCount > 0)
Begin		/*Begin While*/

  update c set  c.Claimant_Status = 'See Master', 
                c.Account = oo.MasterTrackingNumber,
				c.Category_5 = 'O'		  
  	     from #ClaimantsToOptOutNoticeSentOptOutNotMailed oo
		 inner join dbo.Claimant c  
		   on c.Tracking_Number = oo.TrackingNumberToUpdate
         where oo.TrackingNumberToUpdate in 
		    (select top(10000) oo2.TrackingNumberToUpdate 
			        from #ClaimantsToOptOutNoticeSentOptOutNotMailed oo2 
					  order by oo2.TrackingNumberToUpdate)
		   
  Insert Into dbo.Notes (Tracking_Number, Description, fk_UserID) 
         Select top(10000)
		        oo.TrackingNumberToUpdate, 
                'Claimant Opted Out.  Opt Out Document: ' + 
			    cast(oo.DocID as varchar) +
			    ' See Tracking Number: ' +
			    cast(oo.MasterTrackingNumber as varchar) + '.',
				'Sys Opt Out'
	     from  #ClaimantsToOptOutNoticeSentOptOutNotMailed oo
	     order by oo.TrackingNumberToUpdate

  delete oo from #ClaimantsToOptOutNoticeSentOptOutNotMailed oo 
            where oo.TrackingNumberToUpdate in 	
			     (select top(10000) oo2.TrackingNumberToUpdate 
			             from #ClaimantsToOptOutNoticeSentOptOutNotMailed oo2 
					       order by oo2.TrackingNumberToUpdate) 
	        
End		    /*End While*/




if object_id('tempdb..#ClaimantsToOptOutDuplicate') is not null
	drop table #ClaimantsToOptOutDuplicate;
--32,034
select * into #ClaimantsToOptOutDuplicate
	     from #ClaimantsToOptOutOriginal 
	     where claimant_status = 'Duplicate'


create clustered index ix_TrackingNumberToUpdate on #ClaimantsToOptOutDuplicate (TrackingNumberToUpdate)
--
select 1 --Set @@RowCount = 1
--
while (@@RowCount > 0)
Begin		/*Begin While*/

  update c set  
              c.Account = oo.MasterTrackingNumber,
			  c.Category_5 = 'O'			  
  	     from #ClaimantsToOptOutDuplicate oo
		 inner join dbo.Claimant c  
		   on c.Tracking_Number = oo.TrackingNumberToUpdate
         where oo.TrackingNumberToUpdate in 
		    (select top(10000) oo2.TrackingNumberToUpdate 
			        from #ClaimantsToOptOutDuplicate oo2 
					  order by oo2.TrackingNumberToUpdate)
		   
  Insert Into dbo.Notes (Tracking_Number, Description, fk_UserID) 
         Select top(10000)
		        oo.TrackingNumberToUpdate, 
                'Claimant Opted Out.  Opt Out Document: ' + 
			    cast(oo.DocID as varchar) +
			    ' See Tracking Number: ' +
			    cast(oo.MasterTrackingNumber as varchar) + '.',
				'Sys Opt Out'
	     from  #ClaimantsToOptOutDuplicate oo
	     order by oo.TrackingNumberToUpdate

  delete oo from #ClaimantsToOptOutDuplicate oo 
            where oo.TrackingNumberToUpdate in 	
			     (select top(10000) oo2.TrackingNumberToUpdate 
			             from #ClaimantsToOptOutDuplicate oo2 
					       order by oo2.TrackingNumberToUpdate) 
	        
End		   /*End While*/


Commit Transaction
End Try


Begin Catch
	 declare @error varchar(4000)
	 set @error = ERROR_MESSAGE()
     rollback transaction;
     raiserror(@error, 16, 1);    
End Catch
