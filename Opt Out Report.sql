/***********************************************************************
*** Name:            RetreivePossibleOptOutMatches.sql               
*** Purpose:         Identify opt outs based on the original document, it's associated claimant record
					 and EIN or AddressName.
*** Test:            CA016-DVSQL01\CADEV
*** Production:      CASQL02v01.amer.epiqcorp.com,8881\CA01                                                                                                                          
*** Created by:      Craig Johnson                                          
*** Created Date:    01/13/2013                                                                                                           
*** SR#:                                                               
***********************************************************************/
Use CA4719_v2
Go

open symmetric key dboSymKeyAsym_CMx
decryption by asymmetric key dboAsymKey_CMx


/******************************************************
*  Create the list of Claimants to Opt Out based on TIN
*******************************************************/

--Insert TINs into table for lookup
if object_id('tempdb..#OptOutByTin') is not null 
	drop table #OptOutByTin;

--7,582 
select cast(oom.DocID as varchar) as DocID
      ,c.[Tracking_Number] as TrackingNumber
	  ,[CA_Common].[dbo].RegexReplace( isNull( convert( char(16), DecryptByKey( c.[EIN_Encrypted] )), '' ), '[^0-9]', '' ) as Tin
into #OptOutByTin
from ##OptOutsFromXLS oom 
inner join dbo.Claimant c 
on c.Tracking_Number  = oom.Tracking_Number



--Grab list of alternate TIN's for each claimant record as well.
--18,678
Insert Into #OptOutByTin
Select distinct
       DocID, 
	   aad.Tracking_Number, 
       CA_Common.dbo.RegexReplace(aad.Text02, '[^0-9]', '')
    from #OptOutByTin oot inner join dbo.AltAddress aa                 
                             on aa.Tracking_Number = oot.TrackingNumber
						       and AddressType = 'Opt Out Location'
						 inner join AltAddressData aad
							 on aad.fk_AltAddressID = aa.pk_AltAddressID
where isnull(CA_Common.dbo.RegexReplace(aad.Text02, '[^0-9]', ''), '') 
        <> ''
  


--Dedup the results
if object_id('tempdb..#DistinctOptOutByTin') is not null 
	drop table #DistinctOptOutByTin;
--18,683
select distinct DocID, TrackingNumber, TIN 
into #DistinctOptOutByTIN
from #OptOutByTIN



--Match by TIN
if object_id('tempdb..#MatchedClaimantsByTIN') is not null 
	drop table #MatchedClaimantsByTIN;

--565,786
Select distinct
       oot.DocID as DocID
      ,cast('MATCHED ON TIN' as varchar(255)) as MatchType
	  ,c.[Tracking_Number] as TrackingNumber
into #MatchedClaimantsByTIN
from #DistinctOptOutByTin oot	  
inner join dbo.Claimant c
on oot.Tin
		= [CA_Common].[dbo].RegexReplace( isNull( convert( char(16), DecryptByKey( c.[EIN_Encrypted] )), '' ), '[^0-9]', '' )                          



--Kill original records.  For consistency we only want 'matches' in our result set.
--7,582
Delete m from #MatchedClaimantsByTIN m where exists (select 1 from ##OptOutsFromXLS oom 
                                                              where m.TrackingNumber = oom.Tracking_Number 
															  and m.DocID = oom.DocID ) 




/******************************************************
*  Create the list of Claimants to Opt Out based on 
*  address
******************************************************/
Declare @AddressSubstringSize  int = 12;
Declare @BusinessSubstringSize int = 9;


--insert the claimants and associated abbreviated claimant addresses for lookup
if object_id('tempdb..#ClaimantData') is not null 
	drop table #ClaimantData;
--20,926,627
select c.[Tracking_Number] as TrackingNumber
	  ,Left(CA_Common.dbo.RegexReplace(
	            CA_Common.dbo.RegexReplace(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(isnull(c.Business_Name, ''), 'AND', ''), '&', ''), 'CORP', ''), 'CORPORATION', ''), 'DEPT', ''), 'DEPARTMANT', ''), 'INC', ''), 'INCORPORATED', ''), 'LLC', ''), 'LIMITED', ''), 'LTD', ''), 
	            '(?<=.{3,})#.*',''), 
		   '[^a-zA-Z0-9]',''), 
	   @BusinessSubstringSize) as EpiqBusinessName
	  ,Left(CA_Common.dbo.RegexReplace(
										REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											isnull(c.Address_1,'')+isnull(c.address_2,'')+isnull(c.Address_3,'')+isnull(c.Address_4,'')+isnull(c.Address_5,'')
										,'SOUTH', 'S'), 'NORTH', 'N'), 'EAST', 'E'), 'WEST', 'W'), 'FIRST', '1ST'), 'SECOND', '2ND'), 'THIRD', '3RD'), 'FOURTH', '4TH'), 'APARTMENT', 'APT'), 'AVENUE', 'AVE'), 'BOULEVARD', 'BLVD'), 'BUILDING', 'BLDG'), 'CENTER', 'CTR'), 'CIRCLE', 'CIR'), 'COURT', 'CT'), 'DEPARTMENT', 'DEPT'), 'DRIVE', 'DR'), 'FLOOR', 'FL'), 'FREEWAY', 'FWY'), 'HIGHWAY', 'HWY'), 'JUNCTION', 'JCT'), 'LANE', 'LN'), 'PARKWAY', 'PKWY'), 'ROAD', 'RD'), 'SQUARE', 'SQ'), 'STREET', 'ST'), 'SUITE', 'STE'), 'TURNPIKE', 'TPKE')
	                                  ,'[^a-zA-Z0-9]', ''),
									  @AddressSubstringSize) as EpiqAddress
	  ,Left(c.ZipCode,3) as EpiqZip
	  ,cast(CA_Common.dbo.RegexReplace(isnull(c.Business_Name, ''), 
	                                    '[^a-zA-Z0-9]', '') as varchar(255)) as FullBusinessName
	  ,cast(CA_Common.dbo.RegexReplace(
										REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											isnull(c.Address_1,'')+isnull(c.address_2,'')+isnull(c.Address_3,'')+isnull(c.Address_4,'')+isnull(c.Address_5,'')
										,'SOUTH', 'S'), 'NORTH', 'N'), 'EAST', 'E'), 'WEST', 'W'), 'FIRST', '1ST'), 'SECOND', '2ND'), 'THIRD', '3RD'), 'FOURTH', '4TH'), 'APARTMENT', 'APT'), 'AVENUE', 'AVE'), 'BOULEVARD', 'BLVD'), 'BUILDING', 'BLDG'), 'CENTER', 'CTR'), 'CIRCLE', 'CIR'), 'COURT', 'CT'), 'DEPARTMENT', 'DEPT'), 'DRIVE', 'DR'), 'FLOOR', 'FL'), 'FREEWAY', 'FWY'), 'HIGHWAY', 'HWY'), 'JUNCTION', 'JCT'), 'LANE', 'LN'), 'PARKWAY', 'PKWY'), 'ROAD', 'RD'), 'SQUARE', 'SQ'), 'STREET', 'ST'), 'SUITE', 'STE'), 'TURNPIKE', 'TPKE')
	                                    ,'[^a-zA-Z0-9]', '') as varchar(255)) as FullAddress
	  ,Left(c.ZipCode,5) as FullZip	  
into #ClaimantData
from dbo.Claimant c 


--insert the opted out claimants and associated claimant addresses
if object_id('tempdb..#OptOutByAddress') is not null 
	drop table #OptOutByAddress;
--7,582
select cast(oom.DocID as varchar) as DocID
      ,c.[Tracking_Number] as TrackingNumber
	  ,Left(CA_Common.dbo.RegexReplace(
	            CA_Common.dbo.RegexReplace(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(isnull(c.Business_Name, ''), 'AND', ''), '&', ''), 'CORP', ''), 'CORPORATION', ''), 'DEPT', ''), 'DEPARTMANT', ''), 'INC', ''), 'INCORPORATED', ''), 'LLC', ''), 'LIMITED', ''), 'LTD', ''), 
	            '(?<=.{3,})#.*',''), 
		   '[^a-zA-Z0-9]',''), 
	   @BusinessSubstringSize) as EpiqBusinessName
	  ,Left(CA_Common.dbo.RegexReplace(
							        	 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											isnull(c.Address_1,'')+isnull(c.address_2,'')+isnull(c.Address_3,'')+isnull(c.Address_4,'')+isnull(c.Address_5,'')
										,'SOUTH', 'S'), 'NORTH', 'N'), 'EAST', 'E'), 'WEST', 'W'), 'FIRST', '1ST'), 'SECOND', '2ND'), 'THIRD', '3RD'), 'FOURTH', '4TH'), 'APARTMENT', 'APT'), 'AVENUE', 'AVE'), 'BOULEVARD', 'BLVD'), 'BUILDING', 'BLDG'), 'CENTER', 'CTR'), 'CIRCLE', 'CIR'), 'COURT', 'CT'), 'DEPARTMENT', 'DEPT'), 'DRIVE', 'DR'), 'FLOOR', 'FL'), 'FREEWAY', 'FWY'), 'HIGHWAY', 'HWY'), 'JUNCTION', 'JCT'), 'LANE', 'LN'), 'PARKWAY', 'PKWY'), 'ROAD', 'RD'), 'SQUARE', 'SQ'), 'STREET', 'ST'), 'SUITE', 'STE'), 'TURNPIKE', 'TPKE')
	                                  ,'[^a-zA-Z0-9]', ''),
									  @AddressSubstringSize) as EpiqAddress
	  ,Left(c.ZipCode,3) as EpiqZip
	  ,cast(CA_Common.dbo.RegexReplace(isnull(c.Business_Name, ''), 
	                                    '[^a-zA-Z0-9]', '') as varchar(255)) as FullBusinessName
	  ,cast(CA_Common.dbo.RegexReplace(
							            	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											isnull(c.Address_1,'')+isnull(c.address_2,'')+isnull(c.Address_3,'')+isnull(c.Address_4,'')+isnull(c.Address_5,'')
										,'SOUTH', 'S'), 'NORTH', 'N'), 'EAST', 'E'), 'WEST', 'W'), 'FIRST', '1ST'), 'SECOND', '2ND'), 'THIRD', '3RD'), 'FOURTH', '4TH'), 'APARTMENT', 'APT'), 'AVENUE', 'AVE'), 'BOULEVARD', 'BLVD'), 'BUILDING', 'BLDG'), 'CENTER', 'CTR'), 'CIRCLE', 'CIR'), 'COURT', 'CT'), 'DEPARTMENT', 'DEPT'), 'DRIVE', 'DR'), 'FLOOR', 'FL'), 'FREEWAY', 'FWY'), 'HIGHWAY', 'HWY'), 'JUNCTION', 'JCT'), 'LANE', 'LN'), 'PARKWAY', 'PKWY'), 'ROAD', 'RD'), 'SQUARE', 'SQ'), 'STREET', 'ST'), 'SUITE', 'STE'), 'TURNPIKE', 'TPKE')

	                                    ,'[^a-zA-Z0-9]', '') as varchar(255)) as FullAddress
	  ,Left(c.ZipCode,5) as FullZip
into #OptOutByAddress
from ##OptOutsFromXLS oom 
inner join dbo.Claimant c 
on c.Tracking_Number  = oom.Tracking_Number

/*
Select top 100 *
into ##SampleFromAltAddress 
from #OptOutByAddress 
order by newID()

Select top 100 *
from ##SampleFromAltAddress  
order by newID()

Select TrackingNumber, 
       Business_Name, 
	   Address_1, 
	   Address_2, 
	   Address_3, 
	   City, 
	   State, 
	   ZipCode  
from ##SampleFromAltAddress s 
inner join dbo.Claimant c 
  on c.Tracking_Number = s.TrackingNumber
*/

--Add the alternate locations.  Since we are matching on address fields only insert only if one of the fields is non blank/null
--decided a valid zip code is a requirement here.
--343,054
Insert Into #OptOutByAddress
Select distinct
       ooa.DocID, 
	   aad.Tracking_Number,
	   Left(CA_Common.dbo.RegexReplace(
	            CA_Common.dbo.RegexReplace(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(isnull(aad.Text01, ''), 'AND', ''), '&', ''), 'CORP', ''), 'CORPORATION', ''), 'DEPT', ''), 'DEPARTMANT', ''), 'INC', ''), 'INCORPORATED', ''), 'LLC', ''), 'LIMITED', ''), 'LTD', ''), 
	            '(?<=.{3,})#.*',''), 
		   '[^a-zA-Z0-9]',''), 
	   @BusinessSubstringSize) as EpiqBusinessName,
	   Left(CA_Common.dbo.RegexReplace(
										REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											isnull(aad.Text03,'')+isnull(aad.Text04,'')+isnull(aad.Text05,'')+isnull(aad.Text06,'')+isnull(aad.Text07,'')
									    ,'SOUTH', 'S'), 'NORTH', 'N'), 'EAST', 'E'), 'WEST', 'W'), 'FIRST', '1ST'), 'SECOND', '2ND'), 'THIRD', '3RD'), 'FOURTH', '4TH'), 'APARTMENT', 'APT'), 'AVENUE', 'AVE'), 'BOULEVARD', 'BLVD'), 'BUILDING', 'BLDG'), 'CENTER', 'CTR'), 'CIRCLE', 'CIR'), 'COURT', 'CT'), 'DEPARTMENT', 'DEPT'), 'DRIVE', 'DR'), 'FLOOR', 'FL'), 'FREEWAY', 'FWY'), 'HIGHWAY', 'HWY'), 'JUNCTION', 'JCT'), 'LANE', 'LN'), 'PARKWAY', 'PKWY'), 'ROAD', 'RD'), 'SQUARE', 'SQ'), 'STREET', 'ST'), 'SUITE', 'STE'), 'TURNPIKE', 'TPKE')

	                                   ,'[^a-zA-Z0-9]', ''),
		                               @AddressSubstringSize),
	   Left(aad.Text10,3),
	   Left(CA_Common.dbo.RegexReplace(isnull(aad.Text01, ''), 
	                                   '[^a-zA-Z0-9]', ''), 
									  255),
	   Left(CA_Common.dbo.RegexReplace(
										REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
											isnull(aad.Text03,'')+isnull(aad.Text04,'')+isnull(aad.Text05,'')+isnull(aad.Text06,'')+isnull(aad.Text07,'')
									    ,'SOUTH', 'S'), 'NORTH', 'N'), 'EAST', 'E'), 'WEST', 'W'), 'FIRST', '1ST'), 'SECOND', '2ND'), 'THIRD', '3RD'), 'FOURTH', '4TH'), 'APARTMENT', 'APT'), 'AVENUE', 'AVE'), 'BOULEVARD', 'BLVD'), 'BUILDING', 'BLDG'), 'CENTER', 'CTR'), 'CIRCLE', 'CIR'), 'COURT', 'CT'), 'DEPARTMENT', 'DEPT'), 'DRIVE', 'DR'), 'FLOOR', 'FL'), 'FREEWAY', 'FWY'), 'HIGHWAY', 'HWY'), 'JUNCTION', 'JCT'), 'LANE', 'LN'), 'PARKWAY', 'PKWY'), 'ROAD', 'RD'), 'SQUARE', 'SQ'), 'STREET', 'ST'), 'SUITE', 'STE'), 'TURNPIKE', 'TPKE')

	                                    ,'[^a-zA-Z0-9]', ''), 
									   255),
	   Left(aad.Text10,5)	     
    from #OptOutByAddress ooa inner join dbo.AltAddress aa                 
                                on aa.Tracking_Number = ooa.TrackingNumber
						        and AddressType = 'Opt Out Location'
						      inner join AltAddressData aad
						        on aad.fk_AltAddressID = aa.pk_AltAddressID
where 
(
   Len(Left(CA_Common.dbo.RegexReplace(isnull(aad.Text01, ''), '[^a-zA-Z0-9]', ''),@BusinessSubstringSize))
     > 3
 or 
   Len(Left(CA_Common.dbo.RegexReplace(isnull(aad.Text03,'')+
                                       isnull(aad.Text04,'')+
									   isnull(aad.Text05,'')+
									   isnull(aad.Text06,'')+
									   isnull(aad.Text07,''), 
	                                  '[^a-zA-Z0-9]', ''),@AddressSubstringSize))
	  > 5
)
and
   len(aad.Text10) >= 5



--Dedup the results.  Split 'full' addresses into seperate table.  Will be useed later to flag 'full' matches downstream.
if object_id('tempdb..#DistinctOptOutByAddress') is not null 
	drop table #DistinctOptOutByAddress;
--335,348
Select distinct DocID, 
                TrackingNumber, 
				EpiqBusinessName, 
				EpiqAddress, 
				EpiqZip
into #DistinctOptOutByAddress
from #OptOutByAddress

if object_id('tempdb..#DistinctOptOutByFullAddress') is not null 
	drop table #DistinctOptOutByFullAddress;
--343,398
Select distinct DocID, 
                TrackingNumber, 
				FullAddress, 
				FullBusinessName, 
				FullZip 
into #DistinctOptOutByFullAddress
from #OptOutByAddress


--We already know to opt these records out.  This will keep later joins from blowing up.
--7,582
delete c from #ClaimantData c where exists (select 1 from #OptOutByAddress ooa where ooa.TrackingNumber = c.TrackingNumber )


--Match by partial Address, Business Name, Zip 
if object_id('tempdb..#MatchedClaimantsByAddress') is not null 
	drop table #MatchedClaimantsByAddress;

--503,775 (511,358)
Select distinct
        ooa.DocID as DocID
      ,'ADDRESS/ZIP/NAME' as MatchType
	  , c.TrackingNumber as TrackingNumber 
into #MatchedClaimantsByAddress	  
from #DistinctOptOutByAddress ooa	  
inner join #ClaimantData c
on       
        ooa.EpiqBusinessName = c.EpiqBusinessName
    and ooa.EpiqAddress      = c.EpiqAddress
    and ooa.EpiqZip          = c.EpiqZip
where   
	    isnull(ooa.EpiqZip, '')          <> ''
	and isnull(ooa.EpiqAddress, '')      <> '' 
	and isnull(ooa.EpiqBusinessName, '') <> '' 

	         
--Match by Address and Zip
--8,814,959 (8,814,959)
Insert into #MatchedClaimantsByAddress
Select distinct
       ooa.DocID as DocID
      ,'ADDRESS/ZIP' as MatchType
	  , c.[TrackingNumber] as TrackingNumber	 	   
from #DistinctOptOutByAddress ooa	  
inner join #ClaimantData c
on       
        ooa.EpiqAddress      = c.EpiqAddress
    and ooa.EpiqZip          = c.EpiqZip

where   
	    isnull(ooa.EpiqZip, '') <> ''
	and isnull(ooa.EpiqAddress, '') <> ''


--Match by Business Name and Zip 
--2,348,475 (2,308,535)
Insert into #MatchedClaimantsByAddress
Select distinct
       ooa.DocID as DocID
      ,'NAME/ZIP' as MatchType
	  , c.TrackingNumber as TrackingNumber 
from #DistinctOptOutByAddress ooa	  
inner join #ClaimantData c
on       
        ooa.EpiqBusinessName = c.EpiqBusinessName
    and ooa.EpiqZip          = c.EpiqZip
where   
        isnull(ooa.EpiqZip, '')          <> ''
	and isnull(ooa.EpiqBusinessName, '') <> ''  

--Match by Business Name, create iff there is also a match on TIN OR Address/Zip
--938,843
Insert into #MatchedClaimantsByAddress
Select distinct
       ooa.DocID as DocID
      ,'NAME' as MatchType
	  , c.TrackingNumber as TrackingNumber 
from #DistinctOptOutByAddress ooa	  
inner join #ClaimantData c
on       ooa.EpiqBusinessName = c.EpiqBusinessName
where   isnull(ooa.EpiqBusinessName, '') <> '' 
and (   
          exists (select 1 from #MatchedClaimantsByTIN t 
					  where ooa.DocID = t.DocID 
					  and c.TrackingNumber = t.TrackingNumber)
	   or exists (select 1 from #MatchedClaimantsByAddress a1
					  where ooa.DocID = a1.DocID
					  and c.TrackingNumber = a1.TrackingNumber
					  and a1.MatchType = 'ADDRESS/ZIP')
	)


Create clustered index ix_TN_DocID on #MatchedClaimantsByAddress (TrackingNumber, DocID)
Create index ix_MatchType on #MatchedClaimantsByAddress (MatchType)

--Remove records for which we already have a more inclusive match
--503,775 (511,358)
Delete mba from #MatchedClaimantsByAddress mba 
                where exists(select 1 from #MatchedClaimantsByAddress mba2
                                      where mba.TrackingNumber = mba2.TrackingNumber 
									  and   mba.DocID = mba2.DocID
									  and   mba2.MatchType = 'ADDRESS/ZIP/NAME')
				and mba.MatchType = 'NAME'


--503,775 (511,358)
delete mba from #MatchedClaimantsByAddress mba 
                where exists(select 1 from #MatchedClaimantsByAddress mba2
                                      where mba.TrackingNumber = mba2.TrackingNumber 
									  and   mba.DocID = mba2.DocID
									  and   mba2.MatchType = 'ADDRESS/ZIP/NAME')
				and mba.MatchType = 'NAME/ZIP'

--503,775 (511,358)
Delete mba from #MatchedClaimantsByAddress mba 
                where exists(select 1 from #MatchedClaimantsByAddress mba2
                                      where mba.TrackingNumber = mba2.TrackingNumber 
									  and   mba.DocID = mba2.DocID
									  and   mba2.MatchType = 'ADDRESS/ZIP/NAME')
				and mba.MatchType = 'ADDRESS/ZIP'

--~30,000  (55,092)
Delete mba from #MatchedClaimantsByAddress mba 
                where exists(select 1 from #MatchedClaimantsByAddress mba2
                                      where mba.TrackingNumber = mba2.TrackingNumber 
									  and   mba.DocID = mba2.DocID
									  and   mba2.MatchType = 'NAME/ZIP')
				and mba.MatchType = 'NAME'


Select MatchType, count(*) from #MatchedClaimantsByAddress group by MatchType							                                                           		 

/******************************************************
*  Merge the address and tin matches and dedup results  
******************************************************/
if object_id('tempdb..#ClaimantsToOptOut') is not null 
	drop table #ClaimantsToOptOut;

--558,204 
select distinct docID, MatchType, TrackingNumber
	into #ClaimantsToOptOut
	FROM #MatchedClaimantsByTIN


--11,065,585 (10,984,529)
insert into #ClaimantsToOptOut 
  select distinct docID, MatchType, TrackingNumber
	from #MatchedClaimantsByAddress



create clustered index ix_TrackingNumberDocID on #ClaimantsToOptOut (TrackingNumber, DocID)
create index ix_MatchType on #ClaimantsToOptOUt (MatchType)


--Eliminate duplication based on docID/TN.  Persist columnar data in MatchType pivoted to a CSV field.
--Using STUFF to add a comma between the status fields being transposed from columns to rows.
--Without the cast Match is returned as a CLOB, which can't be indexed.
if object_id('tempdb..#ClaimantsToOptOutCombined') is not null 
	drop table #ClaimantsToOptOutCombined;

--10,981,337 (10,923,517)
select docID, TrackingNumber, CAST(STUFF((Select ',' + ltrim(rtrim(MatchType)) 
                                          from #ClaimantsToOptOut a2 
                                          where a2.DocID = a1.DocID 
									      and a2.TrackingNumber = a1.TrackingNumber 
									      order by MatchType 
									      for xml path('')),1,1,'') as varchar(255)) as Match
into #ClaimantsToOptOutCombined
from #ClaimantsToOptOut a1
group by docID, TrackingNumber



--Create a table that persists.
if object_id('tempdb..#OptOutFinalList') is not null 
	drop table #OptOutFinalList;

--10,923,517
Select oot.docID          as DocID
      ,oot.TrackingNumber as MatchedTrackingNumber
	  ,oot.Match          as PartialMatchOn
	  ,cast(null as int)  as MasterTrackingNumber
	  ,cast(null as bit)  as Omit
	  ,cast(0 as bit)     as FullMatchOnAddressZipName
	  ,cast(0 as bit)     as FullMatchOnAddressZip
	  ,cast(0 as bit)     as FullMatchOnNameZip
	  ,cast(0 as bit)     as FullMatchOnName
into #OptOutFinalList
from #ClaimantsToOptOutCombined oot


--Update the 'master' tracking number (the one used to generate the match).  It was excluded from the set upstream.
--10,923,517
update oofl set oofl.MasterTrackingNumber = d.Tracking_Number 
	from dbo.Documents d 
	inner join #OptOutFinalList oofl 
	  on d.DocID = oofl.DocID


--Will need these for the updates that happen downstream a bit.  
create clustered index ix_MatchedTrackingNumber on #OptOutFinalList (MatchedTrackingNumber, DocID)
create index ix_Match on #OptOutFinalList (PartialMatchOn)




/*******************************************************
* Flag records that had more than partial match.
*******************************************************/

--Match by Full Address, Business Name, Zip
--This could be done in one pass with single updates.  For clarity I'm splitting 
--it into an update done from the records created below...
if object_id('tempdb..#MatchedClaimantsByFullAddress') is not null 
	drop table #MatchedClaimantsByFullAddress;

--16,933
Select distinct
        ooa.DocID as DocID
      ,'MATCHED ON FULL ADDRESS/ZIP/NAME' as MatchType
	  , c.TrackingNumber as TrackingNumber
into #MatchedClaimantsByFullAddress	   
from #DistinctOptOutByFullAddress ooa	  
inner join #ClaimantData c
on       
        ooa.FullBusinessName = c.FullBusinessName
    and ooa.FullAddress      = c.FullAddress
    and ooa.FullZip          = c.FullZip
where   
	    isnull(ooa.FullZip, '')          <> ''
	and isnull(ooa.FullAddress, '')      <> '' 
	and isnull(ooa.FullBusinessName, '') <> '' 

--2,684,119
Insert Into #MatchedClaimantsByFullAddress	   
Select distinct
        ooa.DocID as DocID
      ,'MATCHED ON FULL ADDRESS/ZIP' as MatchType
	  , c.TrackingNumber as TrackingNumber
from #DistinctOptOutByFullAddress ooa	  
inner join #ClaimantData c
on       
        ooa.FullAddress      = c.FullAddress
    and ooa.FullZip          = c.FullZip
where   
	    isnull(ooa.FullZip, '')          <> ''
	and isnull(ooa.FullAddress, '')      <> '' 

--52,969
Insert Into #MatchedClaimantsByFullAddress	   
Select distinct
        ooa.DocID as DocID
      ,'MATCHED ON FULL NAME/ZIP' as MatchType
	  , c.TrackingNumber as TrackingNumber
from #DistinctOptOutByFullAddress ooa	  
inner join #ClaimantData c
on 
        ooa.FullBusinessName = c.FullBusinessName      
    and ooa.FullZip          = c.FullZip
where  
	    isnull(ooa.FullZip, '')          <> ''
	and isnull(ooa.FullBusinessName, '')      <> '' 



--Match by full Business Name, create iff there is also a match on TIN OR Address/Zip
--184,502
Insert into #MatchedClaimantsByFullAddress
Select distinct
       ooa.DocID as DocID
      ,'MATCHED ON FULL NAME' as MatchType
	  , c.TrackingNumber as TrackingNumber 
from #DistinctOptOutByFullAddress ooa	  
inner join #ClaimantData c
on       ooa.FullBusinessName = c.FullBusinessName 
where   isnull(ooa.FullBusinessName, '') <> '' 
and (   
          exists (select 1 from #MatchedClaimantsByTIN t 
					  where ooa.DocID = t.DocID 
					  and c.TrackingNumber = t.TrackingNumber)
	   or exists (select 1 from #MatchedClaimantsByAddress a1
					  where ooa.DocID = a1.DocID
					  and c.TrackingNumber = a1.TrackingNumber
					  and a1.MatchType = 'ADDRESS/ZIP')
	)

--For the updates below
create clustered index ix_TrackingNumber on #MatchedClaimantsByFullAddress (TrackingNumber)
create index ix_DocID on #MatchedClaimantsByFullAddress (DocID)

--Flip the appropriate flags.
--16,933
update oofl set oofl.FullMatchOnAddressZipName = 1 
            from #OptOutFinalList oofl 
			where exists (select 1 from #MatchedClaimantsByFullAddress mbfa 
                                   where mbfa.TrackingNumber = oofl.MatchedTrackingNumber
								   and mbfa.DocID = oofl.DocID
								   and MatchType = 'MATCHED ON FULL ADDRESS/ZIP/NAME')

--2,684,115
update oofl set oofl.FullMatchOnAddressZip = 1 
            from #OptOutFinalList oofl 
			where exists (select 1 from #MatchedClaimantsByFullAddress mbfa 
                                   where mbfa.TrackingNumber = oofl.MatchedTrackingNumber
								   and mbfa.DocID = oofl.DocID
								   and MatchType = 'MATCHED ON FULL ADDRESS/ZIP')


--52,969
update oofl set oofl.FullMatchOnNameZip = 1 
            from #OptOutFinalList oofl 
			where exists (select 1 from #MatchedClaimantsByFullAddress mbfa 
                                   where mbfa.TrackingNumber = oofl.MatchedTrackingNumber
								   and mbfa.DocID = oofl.DocID
								   and MatchType = 'MATCHED ON FULL NAME/ZIP')

--184,502
update oofl set oofl.FullMatchOnName = 1 
            from #OptOutFinalList oofl 
			where exists (select 1 from #MatchedClaimantsByFullAddress mbfa 
                                   where mbfa.TrackingNumber = oofl.MatchedTrackingNumber
								   and mbfa.DocID = oofl.DocID
								   and MatchType = 'MATCHED ON FULL NAME')


--Create a table that persists w/Claimant data
if object_id('dbo.OptOutFinalListWithClaimantData2') is not null 
	drop table dbo.OptOutFinalListWithClaimantData2;

--These matches are all likeley good
--1,113,154 (1,118,805)   select count(*) from dbo.OptOutFinalListWithClaimantData2
select '1' as MatchPriority,
       oofl.DocID, 
       oofl.MatchedTrackingNumber, 
	   oofl.MasterTrackingNumber, 
	   oofl.PartialMatchOn, 
	   oofl.FullMatchOnAddressZipName, 
	   oofl.FullMatchOnAddressZip, 
	   oofl.FullMatchOnNameZip, 
	   oofl.FullMatchOnName,
	   oofl.Omit, 
	   isnull(c1.Address_1, '')   + ' ' +
	     isnull(c1.Address_2, '') + ' ' +
		 isnull(c1.Address_3, '') + ' ' +
		 isnull(c1.Address_4, '') + ' ' +
		 isnull(c1.Address_5, '') as MatchedAddress,
	  isnull(c2.Address_1, '') +  ' ' +
	     isnull(c2.Address_2, '') + ' ' +
		 isnull(c2.Address_3, '') + ' ' +
		 isnull(c2.Address_4, '') + ' ' +
		 isnull(c2.Address_5, '') as MasterAddress,
	  c1.Business_Name as MatchedName,
	  c2.Business_Name as MasterName,
	  c1.ZipCode as MatchedZip,
	  c2.ZipCode as MasterZip,
	  isNull( convert( char(16), DecryptByKey( c1.[EIN_Encrypted] )), '' ) as MatchedTIN,
	  isNull( convert( char(16), DecryptByKey( c2.[EIN_Encrypted] )), '' ) as MasterTIN,
	  c1.Claimant_Status as MatchedStatus,
	  c2.Claimant_Status as MasterStatus
into dbo.OptOutFinalListWithClaimantData2
from #OptOutFinalList oofl
inner join dbo.Claimant c1 on oofl.MatchedTrackingNumber = c1.Tracking_Number
inner join dbo.Claimant c2 on oofl.MasterTrackingNumber  = c2.Tracking_Number
where PartialMatchOn not in ('ADDRESS/ZIP', 'NAME/ZIP')
order by DocID

--These need possibly reviewed. 
--2,090,412
Insert into dbo.OptOutFinalListWithClaimantData2
select '2',
       oofl.DocID, 
       oofl.MatchedTrackingNumber, 
	   oofl.MasterTrackingNumber, 
	   oofl.PartialMatchOn, 
	   oofl.FullMatchOnAddressZipName, 
	   oofl.FullMatchOnAddressZip, 
	   oofl.FullMatchOnNameZip, 
	   oofl.FullMatchOnName,
	   oofl.Omit, 
	   isnull(c1.Address_1, '') + 
	     isnull(c1.Address_2, '') +
		 isnull(c1.Address_3, '') +
		 isnull(c1.Address_4, '') +
		 isnull(c1.Address_5, '') as MatchedAddress,
	  isnull(c2.Address_1, '') + 
	     isnull(c2.Address_2, '') +
		 isnull(c2.Address_3, '') +
		 isnull(c2.Address_4, '') +
		 isnull(c2.Address_5, '') as MasterAddress,
	  c1.Business_Name as MatchedName,
	  c2.Business_Name as MasterName,
	  c1.ZipCode as MatchedZip,
	  c2.ZipCode as MasterZip,
	  isNull( convert( char(16), DecryptByKey( c1.[EIN_Encrypted] )), '' ) as MatchedTIN,
	  isNull( convert( char(16), DecryptByKey( c2.[EIN_Encrypted] )), '' ) as MasterTIN,
	  c1.Claimant_Status as MatchedStatus,
	  c2.Claimant_Status as MasterStatus
from #OptOutFinalList oofl
inner join dbo.Claimant c1 on oofl.MatchedTrackingNumber = c1.Tracking_Number
inner join dbo.Claimant c2 on oofl.MasterTrackingNumber = c2.Tracking_Number
where PartialMatchOn in ('ADDRESS/ZIP', 'NAME/ZIP')
and (FullMatchOnAddressZipName = 1 or FullMatchOnAddressZip = 1 or FullMatchOnNameZip = 1 or FullMatchOnName = 1)
order by DocID


create clustered index ix_TrackingNumber_DocID on dbo.OptOutFinalListWithClaimantData2 (MatchedTrackingNumber, DocID)
create index ix_MasterTrackingNumber on dbo.OptOutFinalListWithClaimantData2 (MasterTrackingNumber)
create index ix_PartialMatchOn on dbo.OptOutFinalListWithClaimantData2 (PartialMatchOn)


close symmetric key dboSymKeyAsym_CMx
close master key; 


/*
--New matches
--7,655
select *
	from dbo.OptOutFinalListWithClaimantData2 oo2 
	where not exists(select 1 from dbo.OptOutFinalListWithClaimantData oo where oo2.DocID = oo.DocID and oo2.MatchedTrackingNumber = oo.MatchedTrackingNumber and oo.MatchPriority = '1')

--Matches that were excluded
--2,004
select *
	from dbo.OptOutFinalListWithClaimantData oo 
	where not exists(select 1 from dbo.OptOutFinalListWithClaimantData2 oo2 where oo2.DocID = oo.DocID and oo2.MatchedTrackingNumber = oo.MatchedTrackingNumber)
	and oo.MatchPriority = '1'
*/
