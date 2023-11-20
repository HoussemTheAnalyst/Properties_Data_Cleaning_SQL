                                                                  --- DATA CLEANING ---

-- Data Exploration
SELECT *
FROM Portfolio..NashvilleHousing

-- Standardize date format
SELECT SaleDate, CONVERT(DATE, SaleDate) AS SaleDateConverted
FROM Portfolio..NashvilleHousing

-- Format date to dd-mm-yyyy
SELECT SaleDate, CONVERT(VARCHAR, SaleDate, 105) AS SaleDateFormatted
FROM Portfolio..NashvilleHousing

-- Drop the existing column if it exists
ALTER TABLE NashvilleHousing
DROP COLUMN IF EXISTS SaleDateConverted;

-- Re-add the column with a different data type
ALTER TABLE NashvilleHousing
ADD SaleDateConverted VARCHAR(20);

-- Update the SaleDateConverted column
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(VARCHAR, SaleDate, 105);

-- Populate property addresses based on identical ParcelID "Same ParcelID => Same Address"
SELECT a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a 
JOIN Portfolio..NashvilleHousing b ON a.ParcelID = b.ParcelID
WHERE a.UniqueID <> b.UniqueID AND a.PropertyAddress IS NULL;

-- Update PropertyAddress where NULL based on ParcelID
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a 
JOIN Portfolio..NashvilleHousing b ON a.ParcelID = b.ParcelID
WHERE a.UniqueID <> b.UniqueID AND a.PropertyAddress IS NULL;

-- Check for NULL PropertyAddress
SELECT *
FROM Portfolio..NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Break out property address into individual columns (address, city)
SELECT PropertyAddress, 
       SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM Portfolio..NashvilleHousing;

-- Add columns for split property address and update them
ALTER TABLE NashvilleHousing
ADD PropertSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

UPDATE NashvilleHousing
SET PropertSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Check the updated table
SELECT *
FROM Portfolio..NashvilleHousing;

-- Break out owner address into individual columns (address, city, state)
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Portfolio..NashvilleHousing;

-- Add columns for split owner address and update them
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Change "Y" and "N" to "Yes" and "No" in SoldAsVacant column
SELECT COUNT(*), SoldAsVacant
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
                        WHEN SoldAsVacant = 'N' THEN 'NO'
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        ELSE SoldAsVacant
                   END;

-- Remove Duplicates using ROW_NUMBER function and CTE 
WITH RowNumCTE AS (
    SELECT UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, legalReference,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, legalReference ORDER BY UniqueID) AS Row
    FROM Portfolio..NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE Row > 1;

-- Creating a view of the cleaned data
CREATE VIEW Cleaned_Table AS 
SELECT UniqueID AS Unique_ID, ParcelID AS Parcel_ID, LandUse AS Land_Use, SalePrice AS Sale_Price, legalReference AS Legal_Reference, SaleDateConverted AS Sale_Date, PropertSplitAddress AS Property_Address, PropertSplitCity AS Property_City, Ownername AS Owner_Name, OwnerSplitAddress AS Owner_Address, OwnerSplitCity AS Owner_City, OwnerSplitState AS Owner_State, LandValue AS Land_Value, BuildingValue AS Building_Value, Bedrooms, FullBath AS Full_Bath, HalfBath AS Half_Bath
FROM Portfolio..NashvilleHousing;

SELECT * 
FROM Cleaned_Table
ORDER BY Sale_Price ASC;
