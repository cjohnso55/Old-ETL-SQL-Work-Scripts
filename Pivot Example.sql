use [CA4719_snap]
go

if object_id( 'tempdb..##DocsWithRC' ) is not null drop table ##DocsWithRC;
WITH r AS (
		select [DocId], Tracking_number, Business_name, document_status, postmark, received,
		  case when document_status = 'Cured' then 'X' else '' end as [Cured],
		  case when [MAD] = 0 then '' else 'X' end as [MerchantAddress],
		  case when [MNA] = 0 then '' else 'X' end as [MerchantName], 
		  case when [OTH] = 0 then '' else 'X' end as [Other],
		  case when [SIG] = 0 then '' else 'X' end as [Signature],
		  case when [SNA] = 0 then '' else 'X' end as [SubmitterName],
		  case when [SPO] = 0 then '' else 'X' end as [SubmitterPosition],
		  case when [TMI] = 0 then '' else 'X' end as [TINMissingOrInvalid], 
		  case when [TPN] = 0 then '' else 'X' end as [TelephoneNumber], 
		  case when [LAT] = 0 then '' else 'X' end as [Late],
		  case when [CLT] = 0 then '' else 'X' end as CuredLate	  
		from (
		  select  c.Business_name, d.[DocId], d.[Tracking_Number], l.[Code], d.document_status, cast(d.postmark as date) as postmark, cast(d.received as date) as received
			from dbo.claimant c inner join [dbo].[Documents] d 
				on c.Tracking_Number = d.tracking_number
			left join [dbo].[Reason] r
			  on d.[pk_DocumentsId] = r.[SourceId]
		  	    and r.reasonStatus='Open'
			full outer join [dbo].[lkp_Reason] l
			   on l.[pk_lkpReasonId] = r.[fk_lkpReasonID]
			where d.[document_type] = 'Opt Out'
		) p
		pivot (
		  count( [Code] )
			for [Code] in ( [MAD], [MNA], [OTH], [SIG], [SNA], [SPO], [TFO], [TMI], [TPN], [LAT], [CLT])
		) as pvt )	
select Tracking_Number,
       DocId, 
       Business_name, 
	   postmark, 
	   received, 
	   Cured, 
	   MerchantAddress, 
	   MerchantName, 
	   Other, 
	   Signature, 
	   SubmitterName, 
	   SubmitterPosition, 
	   TINMissingOrInvalid, 
	   TelephoneNumber, 
	   Late, 
	   CuredLate
into ##DocsWithRC
from r
where document_status not in ('Void', 'duplicate', 'withdrawn')
	and ('X' in ([MerchantAddress],
		   [MerchantName], 
		   [Other],
		   [Signature],
		   [SubmitterName],
		   [SubmitterPosition],
		   [TINMissingOrInvalid], 
		   [TelephoneNumber], 
		   [Late],
		   CuredLate) OR document_status in ('Cured', 'Complete'))
order by 2


if object_id( 'tempdb..#optoutmaster') is not null drop table #optoutmaster
select d.Tracking_Number as Tracking_Number, 
       d.DocID as DocID, 
	   c.Business_Name as Business_Name,
	   d.Postmark as Postmark,
	   d.Received as Received,
	   d.Document_Status as Document_Status,
	   isnull(rc.Cured, '') as Cured,
	   isnull(rc.CuredLate, '') as CuredLate,
	   isnull(rc.Late, '') as Late,
	   Case when (rc.MerchantAddress = 'X' or 
	              rc.MerchantName = 'X' or 
				  rc.Other = 'X' or 
				  rc.Signature = 'X' or 
				  rc.SubmitterName = 'X' or 
				  rc.SubmitterPosition = 'X' or 
				  rc.TINMissingOrInvalid = 'X' or 
				  rc.TelephoneNumber = 'X')
	        Then 'X'
			Else ''
	   End as IncompleteDocument
	   into #OptOutMaster
	   from dbo.Documents d 
	     inner join dbo.Claimant c on d.Tracking_Number = c.Tracking_Number 
		 left join ##DocsWithRC rc on d.DocID = rc.DocID
	   where document_type = 'Opt Out' 
	     and document_status in ('Complete', 'Cured')


if object_id( 'tempdb..#dups' )  is not null drop table #dups
if object_id( 'tempdb..#dedup')  is not null drop table #dedup

select tracking_Number trackingNumber, min(docID) docID, count(*) cnt 
into #dups 
from #OptOutMaster 
group by tracking_Number 
having count(*) > 1 

select d.TrackingNumber, 
       o.DocID, o.Business_Name, 
	   o.Postmark, o.Received, 
	   o.Document_Status, 
	   o.Cured, 
	   o.CuredLate, 
	   o.Late,
	   o.IncompleteDocument 
into #dedup 
from  #dups d inner join #OptOutMaster o 
  on o.Tracking_Number = d.TrackingNumber 
    and d.DocID = o.DocID
order by d.TrackingNumber

delete o from #OptOutMaster o where exists(select 1 from #dedup d where d.TrackingNumber = o.Tracking_Number)

insert into #OptOutMaster select * from #dedup

if object_id( 'tempdb..#FinalMaster2') is not null drop table #FinalMaster2
select identity(int, 1, 1) as RowNumber,
       Tracking_Number as Tracking_Number,
	   DocID as DocID,
	   Business_Name as Business_Name,
	   Case when Postmark is null then ''
            else convert( varchar(11), Postmark, 106 )
	   End as Postmark_Date,
	   Case when Received is null then ''
            else convert( varchar(11), Postmark, 106 )
	   End as Received_Date,
	   Case When Document_Status = 'Complete' then 'Timely and Properly Made'
	        When Document_Status = 'Cured' then 'Timely and Cured'
			Else 'Invalid Document'
	   End as Status,
	   Cured, 
	   CuredLate, 
	   Late,
	   IncompleteDocument 
into #FinalMaster2
from #OptOutMaster
where Late <> 'X' and IncompleteDocument <> 'X' and CuredLate <> 'X'
order by DocID asc

select * from #FinalMaster2


select Status, 
       count(*) 
from #FinalMaster2
Group by Status

/*
--111 Late documents (postmarked > 5/28/13)
select count(*) from #OptOutMaster where Late = 'X'
--0
select * from #OptOutMaster where Late = 'X' and isnull(Postmark, Received) < '2013-05-29'
--111
select * from #OptOutMaster where Late = 'X' and isnull(Postmark, Received) >= '2013-05-29'
--0, none of these are included on the final report.
select * from #FinalMaster f where f.DocID in(
select DocID from #OptOutMaster where Late = 'X' and isnull(Postmark, Received) >= '2013-05-29')

--No duplicate documents
select docID, count(*) from #FinalMaster group by docID having count(*) > 1
--No duplicate tracking numberws
select tracking_Number, count(*) from #optoutmaster group by tracking_number having count(*) > 1
--Duplication here, however these have different tracking numbers so are associated with different claimants
select business_name, count(*) from #FinalMaster group by business_name  having count(*) > 1 order by business_name

select * from #FinalMaster2 --where Business_Name = 'SAVIN FOODS MASS INC'
where docID in 
       (select o.DocID from #FinalMaster2 o 
        where not exists(select 1 from ##FinalMaster t 
		where o.DocID = t.DocID)) 
order by status desc

select * from ##FinalMaster
where docID in 
       (select o.DocID from ##FinalMaster o 
        where not exists(select 1 from #FinalMaster2 t 
		where o.DocID = t.DocID)) 
order by status desc
*/

/*
--Exists in new report but not old
--900001433, record is on the deadline 5/29 was excluded from previous report.
select * from #FinalMaster 
where docID in 
       (select o.DocID from #FinalMaster o 
        where not exists(select 1 from ##tmpResults t 
		where o.DocID = t.[Document ID])) 
order by postmark_date desc

--Exists in old report but not new.
select * from ##tmpResults
where [Document ID] in 
       (select t.[Document ID] from ##tmpResults t 
        where not exists(select 1 from #FinalMaster o 
		where o.DocID = t.[Document ID])) 

--o contains t, so this report has everything on it the first one did, plus some
select t.* from ##tmpResults t where not exists(select 1 from #FinalMaster o where o.DocID = t.[Document ID])
--112.  7,582 from other method.  7,692 from this method.
select o.* from #FinalMaster o where not exists(select 1 from ##tmpResults t where o.Business_Name = t.[Entity Name]) order by Postmark_date desc
--111
select o.* from #FinalMaster o where not exists(select 1 from ##tmpResults t where o.Business_Name = t.[Entity Name])
--112
select o.* from #FinalMaster o where not exists(select 1 from ##tmpResults t where o.Tracking_Number = t.Tracking_Number)




--0 and 0
--select docID, count(*) from #FinalMaster group by docID having count(*) > 1
--select tracking_Number, count(*) from #optoutmaster group by tracking_number having count(*) > 1
--select business_name, count(*) from #FinalMaster group by business_name  having count(*) > 1 order by business_name


--8,684
select count(*) from dbo.Documents where document_type = 'Opt Out'
--8,213
select count(*) from dbo.Documents where document_type = 'Opt Out' and document_status not in ('Void', 'Duplicate', 'Withdrawn')
--No duplication
select tracking_number, docID, count(*) from dbo.documents where document_type = 'Opt Out' group by tracking_number, docID having count(*) > 1
--981 mostly dups of 2 
select tracking_number, count(*) from dbo.documents where document_type = 'Opt Out' group by tracking_number having count(*) > 1
--0, so for all claimants we have a maximum of 2 'valid' documents on file.
select tracking_number, count(*) from dbo.documents where document_type = 'Opt Out' and document_status not in ('Void', 'Duplicate', 'Withdrawn') group by tracking_number having count(*) > 2
--271 Claimants, 542 documents
select tracking_number, count(*) from dbo.documents where document_type = 'Opt Out' and document_status not in ('Void', 'Duplicate', 'Withdrawn') group by tracking_number having count(*) = 2
--7,671 Claimants, 7,671 documents (7671+542) = 8,213 total documents in the data set.
select tracking_number, count(*) from dbo.documents where document_type = 'Opt Out' and document_status not in ('Void', 'Duplicate', 'Withdrawn') group by tracking_number having count(*) = 1

--900000001-900008684
select min(DocID), max(DocID) from dbo.Documents where Document_Type = 'Opt Out'

select tracking_number, count(*) from #tmpResults group by tracking_Number having count(*) > 1
select [document id], count(*) from #tmpResults group by [document id] having count(*) > 1

select d.Tracking_Number as Tracking_Number, 
       d.Postmark as Postmark,
	   d.Received as Received,
	   d2.Postmark as Postmark2,
	   d2.Received as Received2,
	   d.DocID as DocID,
	   d2.DocID as DocID2,
	   d.Document_Status as Document_Status,
	   d2.Document_Status as Document_Status2,
	   rc.*,
	   rc2.*
	--into #EqualSet
	   from dbo.documents d
	left join dbo.documents d2 on d.Tracking_Number = d2.Tracking_Number
	left join ##DocsWithRC rc on d.Tracking_Number = rc.tracking_Number and rc.DocID = d.DocID
	left join ##DocsWithRC rc2 on d.Tracking_Number = rc.tracking_Number and rc2.DocID = d2.DocID 
where d.Document_Type = 'Opt Out' --and d.DocID <> d2.DocID


--select Tracking_Number as tracking_number, count(*) as cnt into ##RCDups from ##DocsWithRC group by tracking_number having count(*) > 1
--select r.* into ##RCDups2 from ##RCDups d inner join ##DocsWithRC r on r.tracking_number = d.tracking_number order by d.tracking_number
--select * from ##RCDups2 where (CuredLate <> 'X' and Cured <> 'X')

*/





