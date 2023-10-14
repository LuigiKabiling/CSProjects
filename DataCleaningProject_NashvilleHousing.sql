/*

Data Cleaning Using SQL

*/

SELECT *
FROM CSPROJECT..NashvilleHousing

--------------------------------------------------------------
-- Standardizing Date Formats

SELECT SaleDateConverted, CONVERT (DATE, SaleDate)
FROM CSPROJECT..NashvilleHousing

-- use ALTER TABLE to affect the table columns
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT (DATE,SaleDate)

--------------------------------------------------------------
--Populate Blank Property Address

SELECT *
FROM CSPROJECT..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--Used self JOIN to validate if the similar ParcelId has similar PropertyAddress
--Used ISNULL to copy PropertyAddress from b.PropertyAddress to a.PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS PropAddressPopulated
FROM CSPROJECT..NashvilleHousing AS a
JOIN CSPROJECT..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND	a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CSPROJECT..NashvilleHousing AS a
JOIN CSPROJECT..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND	a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------
--Breaking PropertyAddress into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM CSPROJECT..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1 ) AS address,
SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) AS city
FROM CSPROJECT..NashvilleHousing

--Updating the table

ALTER TABLE CSPROJECT..NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255);

UPDATE CSPROJECT..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1 )

ALTER TABLE CSPROJECT..NashvilleHousing
ADD PropertySplitCity NVARCHAR (255);

UPDATE CSPROJECT..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM CSPROJECT..NashvilleHousing

--Breaking OwnerAddress into Individual Columns (Address, City, State)

SELECT
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM CSPROJECT..NashvilleHousing

--Updating the Table

ALTER TABLE CSPROJECT..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE CSPROJECT..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE CSPROJECT..NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255);

UPDATE CSPROJECT..NashvilleHousing 
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE CSPROJECT..NashvilleHousing
ADD OwnerSplitState NVARCHAR (255);

UPDATE CSPROJECT..NashvilleHousing 
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM CSPROJECT..NashvilleHousing

--------------------------------------------------------------
--Standardizing data in SoldAsVacant column

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM CSPROJECT..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Changing 'Y' & 'N' to 'Yes' & 'No' format

SELECT SoldAsVacant,
	CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END AS FormattedColumn
FROM CSPROJECT..NashvilleHousing
--WHERE SoldAsVacant = 'N'

--Updating Table

UPDATE CSPROJECT..NashvilleHousing 
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--------------------------------------------------------------
--Removing Duplicates

-- Spotting duplicates using ROW_NUMBER
WITH RowNumCte AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueId
					) row_num
FROM CSPROJECT..NashvilleHousing
)

SELECT *
FROM RowNumCte
WHERE row_num > 1
ORDER BY PropertyAddress

--Deleting duplicates
WITH RowNumCte AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueId
					) row_num
FROM CSPROJECT..NashvilleHousing
)

DELETE
FROM RowNumCte
WHERE row_num > 1

--------------------------------------------------------------
--Deleting unused columns

SELECT *
FROM CSPROJECT..NashvilleHousing

ALTER TABLE CSPROJECT..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, TaxDistrict