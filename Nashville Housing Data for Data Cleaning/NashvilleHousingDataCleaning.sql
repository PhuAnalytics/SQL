/*

Cleaning Data in SQL Queries

*/

SELECT*
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate, Convert(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

-- doesn't work, dont know why. alternative: Create new column and add data
-- edit2: UPDATE does not change data types. To change data type : ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

----------------------------------------------------------------------------------------------------

-- Populate Property Adress data

SELECT *
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
ORDER BY ParcelID

-- So there are Null values in the PropertyAddress. But there are multiple rows of the same ParcelID. And if the ParcelID is identical, the PAddress is too. Joining the same table:

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b. ParcelID
	and a.UniqueID != b.UniqueID
WHERE b.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b. ParcelID
	and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------------------
-- Breaking out Address into (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT*
FROM PortfolioProject..NashvilleHousing


-- Parsename instead of SUBSTRINGS for Splitting OwnerAddress

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing




Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant"


SELECT Distinct(SoldAsVacant), COUNT(*)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END AS SoldAsVacantNew
FROM PortfolioProject..NashvilleHousing
-- WHERE SoldAsVacant IN ('Y','N')


Update NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

----------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT*, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID




WITH RowNumCTE AS(
SELECT*, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num>1


WITH RowNumCTE AS(
SELECT*, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num>1

--> no more duplicates

----------------------------------------------------------------------------------------------------

-- Delete Unused Columns, (normally it's not a good idea to delete data)

SELECT*
FROM PortfolioProject..NashvilleHousing

ALTER TABLE  PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate