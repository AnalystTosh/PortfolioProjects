/*
Data Cleaning using SQL Queries

*/

-- Standardize Date Format
select SaleDate, SaleDateConverted, CONVERT(Date, SaleDate)
from PorfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate property Address data
select *
from PorfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out Address into individual columns (Address, City, State)

select PropertyAddress, PropertySplitAddress, PropertySplitCity
from PorfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress ) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress ) +1 , LEN(PropertyAddress)) as City
from PorfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress ) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity NVarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress ) +1 , LEN(PropertyAddress))


select OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from PorfolioProject.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
	,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
	,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PorfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVarchar(255);
update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVarchar(255);
update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVarchar(255);
update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PorfolioProject.dbo.NashVilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End
from PorfolioProject.dbo.NashVilleHousing

Update NashVilleHousing
Set SoldAsVacant =
	CASE when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
	End

-- Remove duplicates
with RownnumCTE As (
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID ) row_num				
from PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete
from RownnumCTE
where row_num > 1
--order by PropertyAddress

-- Delete unused columns

Alter Table PorfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
