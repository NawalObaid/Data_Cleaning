/*
Data Cleaning Project Using SQL Queries
*/

Select * 
from PortfolioProject..NashvilleHousing

---------------- Standardize Date Format---------------------------

--right now, saleDate is in the date-time format. It will be changed to date format

select saleDate, CONVERT(Date, saleDate) --Did not work, will try something else!
from PortfolioProject..NashvilleHousing

--Will be altering the NashvilleHousing table by adding a column called ConvertedSaleDate
--Then will make an update to that column by setting it to be saleDate after converting its data type!

ALTER TABLE PortfolioProject..NashvilleHousing
add ConvertedSaleDate Date;

Update PortfolioProject..NashvilleHousing
set ConvertedSaleDate =CONVERT(Date, saleDate)

Select ConvertedSaleDate
From PortfolioProject..NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------
---------------------Populate Property Address data---------------------------

--when run this SQL query, there are some PropertyAddress with Null values
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing--29 rows where Property Address is Null!
Where PropertyAddress is null


Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Was noticed that some ParcelIDs' were duplicated with the same property address
--so if a.ParcelId = b.ParcelID, we will populate b.ParcelID from a.ParcelID 
--where they do not have the same uniqueId (WILL BE DOING SELF JOIN)


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Then will update a.PropertyAddress with b.PropertyAddress

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Check the update
Select * 
from PortfolioProject..NashvilleHousing -- 0 rows were found
Where PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------

----Breaking out the PropertyAddress into Individual Columns (Address, City)
-- ** USING SUBSTRING

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------
------ Breaking out the OwnerAddress into Individual Columns (Address, City, State)
--** USING PARSENAME
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--We need to rplace ',' with '.' since PARSENAME sperates by '.'
--Select
--PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
--From PortfolioProject.dbo.NashvilleHousing

--Create 3 columns to hold the new values
ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Check the update
Select *
From PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--Will be using CASE statement
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

--Make the update
Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE  --104 ROWS WERE DELETED
From RowNumCTE
Where row_num > 1

--Check
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------
--Delete Unused Columns (Not a good habit for raw data) but in this project for example:
--we can delete the original PropertyAddress and OwnerAdress since we got each of them
--separated in multiple columns for a better format

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--Check
Select *
From PortfolioProject.dbo.NashvilleHousing











