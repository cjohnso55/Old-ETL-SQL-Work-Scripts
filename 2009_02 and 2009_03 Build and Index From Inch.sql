Use CA4719_Snap	
Go

open symmetric key dboSymKeyAsym_CMx
decryption by asymmetric key dboAsymKey_CMx



if object_id('tempdb..##PreregData') is not null
	drop table ##PreregData;

if object_id('tempdb..##ClaimantData') is not null
	drop table ##ClaimantData;

	
Select mpc.Tracking_Number, 
       CA_Common.dbo.RegexReplace(mp.TaxID, '[^0-9]', '') as TaxID, 
	   mp.MerchantName,
	   mp.FirstName,
	   mp.MiddleInitial,
	   mp.LastName,
	   left(CA_Common.dbo.RegexReplace(mp.Address1, '[^0-9a-zA-Z]', ''), 8) as cAddress, 
	   mp.Address2, 
	   mp.Address3, 
	   mp.Address4, 
	   mp.Address5,
	   mp.City,
	   mp.State,
	   left(mp.Zipcode, 3) as cZipCode,
	   mp.SubmitterType
into ##PreregData
from dbo.PreregCtlMerchantProfile mpc 
	   inner join prereg.MerchantProfile mp 
         on mpc.MerchantID = mp.MerchantID 

select         c.Tracking_Number,
               c.Business_Name,
			   Left(CA_Common.dbo.RegexReplace(c.Address_1, '[^0-9a-zA-Z]', ''), 8) as cAddress1,
			   left(c.Zipcode, 3) as cZipCode,
			   CA_Common.dbo.RegexReplace( isNull( convert( char(16), DecryptByKey(c.EIN_Encrypted)), '' ), '[^0-9]', '' ) as ClaimantTIN,
			   c.Identity_Type
into ##ClaimantData 			   
from dbo.Claimant c 

--87,199 naive matches
select count(*) from ##PreregData p where exists(select 1 from ##ClaimantData c where p.TaxID = c.ClaimantTin and p.cZipCode = c.cZipCode and p.cAddress = c.cAddress1)

--3,505
select * from ##PreregData p where not exists(select 1 from ##ClaimantData c where p.TaxID = c.ClaimantTin and p.cZipCode = c.cZipCode and p.cAddress = c.cAddress1)
                                   and p.SubmitterType not in (5)
								   and p.Tracking_Number is not null

--6,152
select * from ##PreregData p where not exists(select 1 from ##ClaimantData c where p.TaxID = c.ClaimantTin and p.cZipCode = c.cZipCode and p.cAddress = c.cAddress1)
                                   and p.SubmitterType not in (5)
								   and p.Tracking_Number is null

--19,427  likely will be the same as above
select * from ##PreregData p where not exists(select 1 from ##ClaimantData c where p.TaxID = c.ClaimantTin and p.cZipCode = c.cZipCode and p.cAddress = c.cAddress1 and c.Identity_Type <> '3RD PARTY')
								   and p.Tracking_Number is not null

--19,427  likely will be the same as above
select * from ##PreregData p where not exists(select 1 from ##ClaimantData c where p.TaxID = c.ClaimantTin and p.cZipCode = c.cZipCode and p.cAddress = c.cAddress1 and c.Identity_Type = '3RD PARTY')
								   and p.Tracking_Number is not null

--??  likely will be the same as above
select * from ##PreregData p where not exists(select 1 from ##ClaimantData c where p.TaxID = c.ClaimantTin and p.cZipCode = c.cZipCode and p.cAddress = c.cAddress1 and c.Identity_Type <> '3RD PARTY')
								   and p.Tracking_Number is null

close symmetric key dboSymKeyAsym_CMx
close master key; 

