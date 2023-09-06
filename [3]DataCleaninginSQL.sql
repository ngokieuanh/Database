/* Cleaning Data in SQL Queries
*/
-----------------------------------------------------
--[1] Standardize Date Format

ALTER TABLE Housing
ADD SaleDateConvert date

UPDATE KIUANH_PORTFOLIO..Housing
SET SaleDateConvert = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

--[2] Populate Property Address data
 
/*SELECT a.ParcelID, a.PropertyAddress, b. ParcelID, b.PropertyAddress ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM KIUANH_PORTFOLIO..Housing as a 
	JOIN KIUANH_PORTFOLIO..Housing as b
	ON a.ParcelID = b. ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null*/

UPDATE a
SET PropertyAddress= ISNULL (a.PropertyAddress,'No Address')
FROM Housing AS a 
	JOIN Housing AS b
	ON a.ParcelID = b. ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

--[3] Breaking out PropertyAddress into Individual Columns (Address, City)

/*
SELECT
    SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM KIUANH_PORTFOLIO..Housing
*/

ALTER TABLE Housing
ADD PropertySplitAddress nvarchar(255)

UPDATE Housing
SET PropertySplitAddress =  
		CASE
			WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
				SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
			ELSE
				PropertyAddress  -- If there's no comma, return the entire PropertyAddress
		END

ALTER TABLE Housing
ADD PropertySplitCity nvarchar(255)

UPDATE Housing
SET PropertySplitCity = 
		CASE
			WHEN CHARINDEX(',', PropertyAddress) > 0 THEN
				SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
			ELSE
				PropertyAddress
		END

ALTER TABLE Housing
DROP COLUMN PropertyAddress

--[4] Breaking OwnerAddress into Individual Columns (Address, City, State)
/*
SELECT OwnerAddress
From KIUANH_PORTFOLIO..Housing


SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM KIUANH_PORTFOLIO..Housing
*/
ALTER TABLE Housing
ADD Owner_Address nvarchar (255), OwnerCity nvarchar (255), OwnerState nvarchar (255)

UPDATE KIUANH_PORTFOLIO..Housing
SET Owner_Address = PARSENAME (REPLACE(OwnerAddress,',','.'),3),
	OwnerCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

---[5] Replace Y and N with Yes and No in the column SoldAsVacant

/*
select distinct(SoldAsVacant), Count(SoldAsVacant)
from KIUANH_PORTFOLIO..Housing
group by SoldAsVacant

select SoldAsVacant,
CASE	
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
from KIUANH_PORTFOLIO..Housing
*/
UPDATE KIUANH_PORTFOLIO..Housing
SET SoldAsVacant= CASE	
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

---[6] Remove Duplicate
--Use CTE to check for duplicate values, row_num shows the value > 1, it is a duplicate value
WITH ROWNUM AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY 
	ParcelID,
	PropertySplitAddress,
	SalePrice,
	SaleDateConvert,
	LegalReference
	ORDER BY UniqueID) Rownum
FROM Housing
)
--- Use the DELETE function to remove duplicate values
DELETE FROM ROWNUM
WHERE Rownum > 1 
