-- Convert SalesDate to Date Format
select SaleDate, CONVERT(Date, SaleDate)
from training.dbo.nashville_housing

ALTER TABLE training.dbo.nashville_housing
Add SaleDateConverted Date;

UPDATE training.dbo.nashville_housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Fill Null Property Address with Values From The Same ParcelID 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from training.dbo.nashville_housing a
join training.dbo.nashville_housing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
order by a.ParcelID

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from training.dbo.nashville_housing a
join training.dbo.nashville_housing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking Out Address Into Individual Columns (Address, City, State)

select 
	PropertyAddress,
	Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from training.dbo.nashville_housing

ALTER TABLE training.dbo.nashville_housing
Add PropertySplitAddress NVarchar(255);

ALTER TABLE training.dbo.nashville_housing
Add PropertySplitCity NVarchar(255);

UPDATE training.dbo.nashville_housing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE training.dbo.nashville_housing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select 
	OwnerAddress,
	PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Address,
	PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as City,
	PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as State
from training.dbo.nashville_housing

ALTER TABLE training.dbo.nashville_housing
Add OwnerSplitAddress NVarchar(255);

ALTER TABLE training.dbo.nashville_housing
Add OwnerSplitCity NVarchar(255);

ALTER TABLE training.dbo.nashville_housing
Add OwnerSplitState NVarchar(255);

UPDATE training.dbo.nashville_housing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

UPDATE training.dbo.nashville_housing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

UPDATE training.dbo.nashville_housing
SET OwnerSplitState= PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

-- Change 'Sold As Vacant' as only Yes or No

select distinct(SoldAsVacant), count(SoldAsVacant)
from training.dbo.nashville_housing
group by SoldAsVacant

select 
	SoldAsVacant,
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from training.dbo.nashville_housing

UPDATE training.dbo.nashville_housing
SET SoldAsVacant = case 
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					end

-- Remove Duplicates

WITH CTE_CHECK AS(
	select *,
		ROW_NUMBER() over(
			partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
			order by UniqueID) row_num
	from training.dbo.nashville_housing
)
DELETE -- SELECT *
from CTE_CHECK
where row_num > 1
-- order by ParcelID

-- Delete Unused Column

alter table training.dbo.nashville_housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from training.dbo.nashville_housing