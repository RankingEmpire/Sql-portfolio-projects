--cleaning data with sql queries

select * from dbo.NashvilleHousing 

------------------------------------------------------------------------------------------------------
--standardise date format

select SaleDateConverted, CONVERT(Date,SaleDate)
from dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted  = CONVERT(Date,SaleDate)
----------------------------------------------------------------------------------------------------------------------------

--populate property address data

select * 
from NashvilleHousing
--where PropertyAddress is NULL
Order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress  is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress  is null

select PropertyAddress from NashvilleHousing

------------------------------------------------------------------------------------------------
--Breaking out address into individual columns (Address, City, state)
	
select PropertyAddress 
from NashvilleHousing

 select 
 SUBSTRING( PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address
 , SUBSTRING( PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) as Address

from NashvilleHousing

Alter TABLE NashvilleHousing
Add PropertySpltAddress NVARCHAR(255);

update NashvilleHousing
SET PropertySpltAddress  = SUBSTRING( PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) 

Alter TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

update NashvilleHousing
SET PropertySplitCity  =SUBSTRING( PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousing


select OwnerAddress
from NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
from NashvilleHousing

Alter TABLE NashvilleHousing
Add OwnerSpltAddress NVARCHAR(255);

update NashvilleHousing
SET OwnerSpltAddress  = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

Alter TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

update NashvilleHousing
SET OwnerSplitCity  =PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

Alter TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

update NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
  
  select * from NashvilleHousing
-----------------------------------------------------------------------------------------------------
--change Y AND N to yes or no in soldasvacant field
select distinct(SoldAsVacant), count(SoldAsVacant) 
from NashvilleHousing
Group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end 
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   end 
-----------------------------------------------------------------------------------------------------------
--removing Duplicates


 WITH RowNumCTE AS (
 select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

 from NashvilleHousing
 --order by ParcelID
 )
SELECT *
 FROM RowNumCTE
 where row_num > 1
order by PropertyAddress

SELECT * FROM NashvilleHousing
---------------------------------------------------------------------------
--DELETING UNUSED COLUMNS

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate