/*


cleaning data in sql

*/


Select SaleDateConverted , CONVERT(Date, SaleDate)
From Portofolio.dbo.NashvilleHousing

Update Portofolio.dbo.NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

 -------------------------------------------------

 Select PropertyAddress
From Portofolio.dbo.NashvilleHousing
where PropertyAddress is null


 Select *
From Portofolio.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID



 Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portofolio.dbo.NashvilleHousing a
JOIN Portofolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portofolio.dbo.NashvilleHousing a
JOIN Portofolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



---------------------------------------------------

--Breaking out address into Individual Columns (Address, City, State)


 Select PropertyAddress
From Portofolio.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As Address
FROM Portofolio.dbo.NashvilleHousing

Alter table Portofolio.dbo.NashvilleHousing
Add PropertySplitAdress Nvarchar(255);

Update Portofolio.dbo.NashvilleHousing
Set PropertySplitAdress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

Alter table Portofolio.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portofolio.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Portofolio.dbo.NashvilleHousing


--------------------------------------------------------




SELECT OwnerAddress
FROM Portofolio.dbo.NashvilleHousing



SELECT PARSENAME(REPLACE( OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE( OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE( OwnerAddress, ',','.'),1)
FROM Portofolio.dbo.NashvilleHousing


ALTER TABLE Portofolio.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portofolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Portofolio.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portofolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Portofolio.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portofolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Portofolio.dbo.NashvilleHousing

---------------------------------------------------------------------


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portofolio.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2




Select SoldAsVacant ,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM Portofolio.dbo.NashvilleHousing



UPDATE Portofolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------------------

-- REMOVING THE DUPLICATES

WITH RowNumCTE As(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID)
									row_num
FROM Portofolio.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT * 
FROM RowNumCTE
Where row_num > 1
--ORDER BY PropertyAddress

------------------------------------------------------------------------------

