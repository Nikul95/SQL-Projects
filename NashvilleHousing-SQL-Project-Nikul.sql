
-- The first step in this Data Cleaning Project for the Nashville Housing Dataset is to Standardise the Date Format.

SELECT *
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing

SELECT SaleDate
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 

-- The next step in this Data Cleaning Project for the Nashville Housing Dataset is to Populate the Property Address Data.

SELECT *
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL


SELECT PropertyAddress
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing A
JOIN NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing A
JOIN NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- The next step in this Data Cleaning Project for the Nashville Housing Dataset is to seperate out into Individual Columns the Address, City & State.

SELECT PropertyAddress
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)

FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address


FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(Propertyaddress)) as Address

FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing


ALTER TABLE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255); 

UPDATE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255); 

UPDATE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(Propertyaddress))


SELECT *
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing


-- The next step in this Data Cleaning Project for the Nashville Housing Dataset is to seperate out the Owner Address into Address, City and the State.

SELECT OwnerAddress
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing




ALTER TABLE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255); 

UPDATE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255); 

UPDATE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255); 

UPDATE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)

SELECT *
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing




-- The next step in this Data Cleaning Project for the Nashville Housing Dataset is change Y and N in "Sold as Vacant" field.

SELECT DISTINCT(SoldasVacant), COUNT(SoldasVacant)
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing



UPDATE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END


-- The next step in this Data Cleaning Project for the Nashville Housing Dataset is to remove any Duplicates from the dataset.

WITH RowNumCTE AS(

SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num

FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(

SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num

FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


WITH RowNumCTE AS(

SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num

FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- 
-- The next step in this Data Cleaning Project for the Nashville Housing Dataset is to remove any unsused columns in the dataset.

SELECT *
FROM NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NikulNashvilleHousingPortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate