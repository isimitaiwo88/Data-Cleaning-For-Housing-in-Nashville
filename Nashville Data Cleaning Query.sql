/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM HousingData.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
--change the data format of the column SaleDate

ALTER TABLE HousingData.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM HousingData.dbo.NashvilleHousing


SELECT *
FROM HousingData.dbo.NashvilleHousing
WHERE PropertyAddress is null --check if there are address that are empty

--percelID that are similar has the same property address, so we will use a query that fill any null propetyaddress
--with the percelID with an address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is not null --Checking the propety address with similar ParcelID to see which is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] --update the sheet, copying the address with similar parcelID to the ones with Empty Propertyaddress
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM HousingData.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address2
FROM HousingData.dbo.NashvilleHousing --checking if my method of Seperating the address works

---alter the table to create new columns for the address - Street and City
--create the table street by breaking the propertyaddress and moving them to their appropirate columns
ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertyStreet, PropertyCity
FROM HousingData.dbo.NashvilleHousing --check to see if it correct

---to break down the owner address into street, city, state

SELECT owneraddress
FROM HousingData.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM HousingData.dbo.NashvilleHousing --test the break down method using PARSE

--create new columns and place the broken down address in their appropirate columns

ALTER TABLE NashvilleHousing
ADD OwnerStreet Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState =PARSENAME(REPLACE(owneraddress,',','.'),1)

SELECT OwnerStreet, OwnerCity, OwnerState
FROM HousingData.dbo.NashvilleHousing -- check if done

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant
FROM HousingData.dbo.NashvilleHousing

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM HousingData.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 --check for number of distinct data in the column SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM HousingData.dbo.NashvilleHousing

UPDATE NashvilleHousing --updating the column
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					    WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END
FROM HousingData.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
		)row_num
FROM HousingData.dbo.NashvilleHousing
)
SELECT*
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress --to check if there are duplicates using cte and using the "greater than" function



WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
		)row_num
FROM HousingData.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1 --to delete the duplicates

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns - PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE HousingData.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

SELECT *
FROM HousingData.dbo.NashvilleHousing --check the table once and for all lol



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------