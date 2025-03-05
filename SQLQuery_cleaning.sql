-- 1. Display all data in the national housing dataset
SELECT * FROM [protfolio(cleaning data)]..nationalhousing;

-- 2. Format the SaleDate column (Convert to Date)
SELECT SaleDate FROM [protfolio(cleaning data)]..nationalhousing;

UPDATE [protfolio(cleaning data)]..nationalhousing
SET SaleDate = CONVERT(DATE, SaleDate);

-- 3. Create a new column for the converted date and update it
ALTER TABLE [protfolio(cleaning data)]..nationalhousing
ADD converteddate DATE;

UPDATE [protfolio(cleaning data)]..nationalhousing
SET converteddate = CONVERT(DATE, SaleDate);

-- 4. Verify the new converted date column
SELECT converteddate FROM [protfolio(cleaning data)]..nationalhousing;


-- 5. Clean the PropertyAddress column (Filling NULL values)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress) AS CleanedAddress
FROM [protfolio(cleaning data)]..nationalhousing a
JOIN [protfolio(cleaning data)]..nationalhousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- 6. Update PropertyAddress with available values from duplicate records
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [protfolio(cleaning data)]..nationalhousing a
JOIN [protfolio(cleaning data)]..nationalhousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- 7. Check for remaining NULL values in PropertyAddress
SELECT PropertyAddress FROM [protfolio(cleaning data)]..nationalhousing
WHERE PropertyAddress IS NULL;


-- 8. Split PropertyAddress into Street and City
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS AddressStreet,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS AddressCity
FROM [protfolio(cleaning data)]..nationalhousing;

-- 9. Create new columns for street and city
ALTER TABLE [protfolio(cleaning data)]..nationalhousing
ADD addstreet VARCHAR(255);

UPDATE [protfolio(cleaning data)]..nationalhousing
SET addstreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE [protfolio(cleaning data)]..nationalhousing
ADD addcity VARCHAR(255);

UPDATE [protfolio(cleaning data)]..nationalhousing
SET addcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- 10. Verify split columns
SELECT PropertyAddress, addstreet, addcity FROM [protfolio(cleaning data)]..nationalhousing;


-- 11. Handle missing OwnerAddress values
SELECT a.ParcelID, a.OwnerAddress, b.ParcelID, b.OwnerAddress
FROM [protfolio(cleaning data)]..nationalhousing a
JOIN [protfolio(cleaning data)]..nationalhousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerAddress IS NULL;


-- 12. Split OwnerAddress into Street and City
SELECT 
    SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) AS OwnerStreet,
    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress)) AS OwnerCity
FROM [protfolio(cleaning data)]..nationalhousing;

-- 13. Create new columns for OwnerStreet and OwnerCity
ALTER TABLE [protfolio(cleaning data)]..nationalhousing
ADD ownaddstreet VARCHAR(255);

UPDATE [protfolio(cleaning data)]..nationalhousing
SET ownaddstreet = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1);

ALTER TABLE [protfolio(cleaning data)]..nationalhousing
ADD ownaddcity VARCHAR(255);

UPDATE [protfolio(cleaning data)]..nationalhousing
SET ownaddcity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress));

-- 14. Verify OwnerAddress split
SELECT OwnerAddress, ownaddstreet, ownaddcity FROM [protfolio(cleaning data)]..nationalhousing;


-- 15. Alternative split method using PARSENAME function
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreet,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM [protfolio(cleaning data)]..nationalhousing;


-- 16. Standardize values in SoldAsVacant column (Convert 'y' to 'YES' and 'n' to 'NO')
SELECT SoldAsVacant
FROM [protfolio(cleaning data)]..nationalhousing
WHERE SoldAsVacant = 'y' OR SoldAsVacant = 'n';

UPDATE [protfolio(cleaning data)]..nationalhousing
SET SoldAsVacant = 'YES'
WHERE SoldAsVacant = 'y';

UPDATE [protfolio(cleaning data)]..nationalhousing
SET SoldAsVacant = 'NO'
WHERE SoldAsVacant = 'n';

-- 17. Verify changes in SoldAsVacant column
SELECT DISTINCT SoldAsVacant FROM [protfolio(cleaning data)]..nationalhousing;


-- 18. Identify duplicate records using ROW_NUMBER()
WITH RCt_dup AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num  
    FROM [protfolio(cleaning data)]..nationalhousing
)
SELECT * FROM RCt_dup
WHERE row_num > 1
ORDER BY PropertyAddress;

-- 19. Delete duplicate records
DELETE FROM [protfolio(cleaning data)]..nationalhousing
WHERE UniqueID IN (
    SELECT UniqueID FROM (
        SELECT UniqueID, 
               ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num  
        FROM [protfolio(cleaning data)]..nationalhousing
    ) AS DupRecords
    WHERE row_num > 1
);


-- 20. Delete unused columns PropertyAddress and OwnerAddress
ALTER TABLE [protfolio(cleaning data)]..nationalhousing
DROP COLUMN PropertyAddress, OwnerAddress;

-- 21. Final verification of cleaned dataset
SELECT * FROM [protfolio(cleaning data)]..nationalhousing;
