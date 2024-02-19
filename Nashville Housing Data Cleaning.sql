/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProjects..NashvilleHousing$

--Standardize date format

ALTER TABLE PortfolioProjects..NashvilleHousing$
ADD SaleDateConverted Date

update PortfolioProjects..NashvilleHousing$
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProjects..NashvilleHousing$
DROP COLUMN SaleDate


--Populate property address data

select *
from PortfolioProjects..NashvilleHousing$
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing$ a
join PortfolioProjects..NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing$ a
join PortfolioProjects..NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProjects..NashvilleHousing$

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) as City
from PortfolioProjects..NashvilleHousing$

ALTER TABLE PortfolioProjects..NashvilleHousing$
ADD PropertySplitAddress nvarchar(255),
	PropertySplitCity nvarchar(255)

update PortfolioProjects..NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))


--Using PARSENAME to split 

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from PortfolioProjects..NashvilleHousing$

ALTER TABLE PortfolioProjects..NashvilleHousing$
ADD OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitCountry nvarchar(255)

update PortfolioProjects..NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	OwnerSplitCountry = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


--Change Y & N to Yes & No in 'Sold as vacant' field
Select SoldAsVacant, Count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing$
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
            WHEN SoldAsVacant = 'N' THEN 'No'
            ELSE SoldAsVacant
       END
FROM PortfolioProjects..NashvilleHousing$;

Update PortfolioProjects..NashvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END


--Removing duplicates
WITH RowNUMCTE AS (
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDateConverted,
				LegalReference
				ORDER BY 
					UniqueID
				) as row_num
FROM PortfolioProjects..NashvilleHousing$
)
DELETE
from RowNUMCTE
Where row_num > 1


--Delete unused columns
ALTER TABLE PortfolioProjects..NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
From PortfolioProjects..NashvilleHousing$
