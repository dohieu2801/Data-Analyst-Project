/****** Script for SelectTopNRows command from SSMS  ******/
--Standardize saledate

Alter table Nashhousing
Add Standardize_date date;

Update Nashhousing
Set Standardize_date = convert(date,SaleDate)

SELECT Standardize_date
FROM [PortfolioProject].[dbo].[Nashhousing]


--Populate Property address


Select T1.ParcelID,T2.PropertyAddress
From
(SELECT ParcelID, PropertyAddress
From [PortfolioProject].[dbo].[Nashhousing]
Where PropertyAddress is null) as T1
Join 
(SELECT ParcelID, PropertyAddress
From [PortfolioProject].[dbo].[Nashhousing]
Where PropertyAddress is not null) as T2
on T1.ParcelID = T2.ParcelID

Update [PortfolioProject].[dbo].[Nashhousing]
Set PropertyAddress = T2.PropertyAddress
From
(SELECT ParcelID, PropertyAddress
From [PortfolioProject].[dbo].[Nashhousing]
Where PropertyAddress is null) as T1
Join 
(SELECT ParcelID, PropertyAddress
From [PortfolioProject].[dbo].[Nashhousing]
Where PropertyAddress is not null) as T2
on T1.ParcelID = T2.ParcelID
Where[PortfolioProject].[dbo].[Nashhousing].PropertyAddress is null

Select *
From [PortfolioProject].[dbo].[Nashhousing]
Where PropertyAddress is null



-- Breaking out Address into individual

----First approach with substring and charindex

Select substring(PropertyAddress,1,CHARINDEX(' ',PropertyAddress)-1) as Address_number,
substring(PropertyAddress,CHARINDEX(' ',PropertyAddress)+1,CHARINDEX(',',PropertyAddress)-CHARINDEX(' ',PropertyAddress)+1) as Address_Street,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address_city, 
PropertyAddress
From [PortfolioProject].[dbo].[Nashhousing]

Alter table [PortfolioProject].[dbo].[Nashhousing]
Add Address_number nvarchar(255);
Update [PortfolioProject].[dbo].[Nashhousing]
Set Address_number = substring(PropertyAddress,1,CHARINDEX(' ',PropertyAddress)-1)

Alter table [PortfolioProject].[dbo].[Nashhousing]
Add Address_street nvarchar(255);
Update [PortfolioProject].[dbo].[Nashhousing]
Set Address_street = substring(PropertyAddress,CHARINDEX(' ',PropertyAddress)+1,CHARINDEX(',',PropertyAddress)-CHARINDEX(' ',PropertyAddress)+1)

Alter table [PortfolioProject].[dbo].[Nashhousing]
Add Address_city nvarchar(255);
Update [PortfolioProject].[dbo].[Nashhousing]
Set Address_city = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

----Second approach with parsename and replace

Select PARSENAME(Replace(OwnerAddress,',','.'),1),PARSENAME(Replace(OwnerAddress,',','.'),2),PARSENAME(Replace(OwnerAddress,',','.'),3)
From [PortfolioProject].[dbo].[Nashhousing]

Alter table [PortfolioProject].[dbo].[Nashhousing]
Add Owner_state nvarchar(255)
Update [PortfolioProject].[dbo].[Nashhousing]
Set Owner_state = PARSENAME(Replace(OwnerAddress,',','.'),1)

Alter table [PortfolioProject].[dbo].[Nashhousing]
Add Owner_city nvarchar(255)
Update [PortfolioProject].[dbo].[Nashhousing]
Set Owner_city = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table [PortfolioProject].[dbo].[Nashhousing]
Add Owner_addressnumber nvarchar(255)
Update [PortfolioProject].[dbo].[Nashhousing]
Set Owner_addressnumber = PARSENAME(Replace(OwnerAddress,',','.'),3)


--Change "Y" and "N" to "Yes" and "No" in Sold

 Select distinct Soldasvacant,count(Soldasvacant)
 From [PortfolioProject].[dbo].[Nashhousing]
 Group by Soldasvacant

Select (case 
		when Soldasvacant = 'N' then 'No'
		when Soldasvacant = 'Y' then 'Yes'
		else Soldasvacant 
		end) as adjusted_Soldasvacant
From [PortfolioProject].[dbo].[Nashhousing]

Update [PortfolioProject].[dbo].[Nashhousing]
Set Soldasvacant = (case 
		when Soldasvacant = 'N' then 'No'
		when Soldasvacant = 'Y' then 'Yes'
		else Soldasvacant 
		end)


-- Remove duplicates
		
With Row_table as 
(Select *, ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
					PropertyAddress,
					Saleprice,
					Saledate,
					LegalReference
	   Order by UniqueID) row_num
From [PortfolioProject].[dbo].[Nashhousing])

DELETE 
From Row_table
Where row_num >1


--Remove unused comlumns


Alter table [PortfolioProject].[dbo].[Nashhousing]
Drop column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

Select * from [PortfolioProject].[dbo].[Nashhousing]
