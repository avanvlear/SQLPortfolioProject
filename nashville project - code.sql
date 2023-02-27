CREATE TABLE nashville (
	UniqueID INT PRIMARY KEY,
	ParcelID VARCHAR(20),
	LandUse VARCHAR(50),
	PropertyAddress VARCHAR(50),
	SaleDate VARCHAR(50),
	SalePrice VARCHAR(50),
	LegalReference VARCHAR(50),
	SoldAsVacant VARCHAR(10),
	OwnerName VARCHAR(75),
	OwnerAddress VARCHAR(50),
	Acerage FLOAT(2),
	TaxDistrict VARCHAR(50),
	LandValue INT,
	BuildingValue INT,
	TotalValue INT,
	YearBuilt INT,
	Bedrooms INT,
	FullBath INT,
	HalfBath INT
);

-- Clean date --

UPDATE nashville
SET saledate = CAST(SaleDate AS Date);

-- Populate Property Address --

/* populate nulls with address from matching parcelID */

UPDATE housingdata AS a
SET PropertyAddress = COALESCE(b.propertyaddress, a.propertyaddress)
FROM housingdata b 
WHERE a.parcelid = b.parcelid 
AND a.uniqueid <> b.uniqueid 
AND a.propertyaddress IS NULL;

/* Breaking out address into individual columns (Address, City, State) */

/* Property */

SELECT SPLIT_PART(propertyaddress, ',', 1) AS address, 
SPLIT_PART(propertyaddress, ',', 2) AS city
FROM nashville


ALTER TABLE nashville
add propertysplitaddress VARCHAR(255);

UPDATE nashville
SET propertysplitaddress = SPLIT_PART(propertyaddress, ',', 1);


ALTER TABLE nashville
add propertysplitcity VARCHAR(255);

UPDATE nashville
SET propertysplitcity = SPLIT_PART(propertyaddress, ',', 2);


/* Owner */

SELECT SPLIT_PART(owneraddress, ',', 1) AS ownersplitaddress, 
SPLIT_PART(owneraddress, ',', 2) AS ownersplitcity,
SPLIT_PART(owneraddress, ',', 3) AS ownersplitstate
FROM nashville


ALTER TABLE nashville
add ownersplitaddress VARCHAR(255);

UPDATE nashville
SET ownersplitaddress = SPLIT_PART(owneraddress, ',', 1);


ALTER TABLE nashville
add ownersplitcity VARCHAR(255);

UPDATE nashville
SET ownersplitcity = SPLIT_PART(owneraddress, ',', 2);

ALTER TABLE nashville
add ownersplitstate VARCHAR(255);

UPDATE nashville
SET ownersplitstate = SPLIT_PART(owneraddress, ',', 3);

/* Change Y and N to Yes and No in "Sold as Vacant" field */

UPDATE nashville
SET soldasvacant = 
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END

/* Remove Duplicates */


WITH rownumCTE AS(
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

FROM nashville
	)
	
SELECT * FROM rownumCTE
WHERE row_num > 1
ORDER by propertyaddress



/* Delete Unused Columns */

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


