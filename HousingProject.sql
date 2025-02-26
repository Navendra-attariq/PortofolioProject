Select*
from NashvilleHousing

--convert SaleDate into short date

Select SaleDate, Convert(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate =  Convert(Date,SaleDate)

ALter table NashvilleHousing
ALter Column SaleDate Date

select SaleDate
from NashvilleHousing

--populate property address
Select *
from NashvilleHousing
--where propertyAddress is not null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--breaking out address into individual columns (address, City, State)


select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, Charindex(',',PropertyAddress) -1 ) as address
, SUBSTRING(PropertyAddress, Charindex(',',PropertyAddress) +1 , LEN(PropertyAddress)) as City
from NashvilleHousing



ALter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',',PropertyAddress) -1 )

ALter table NashvilleHousing
add PropertySplitCity nvarchar(100);

Update NashvilleHousing
Set PropertySplitCity =  SUBSTRING(PropertyAddress, Charindex(',',PropertyAddress) +1 , LEN(PropertyAddress))


select*
from NashvilleHousing

Alter table NashvilleHousing
DROP column PropertyAddress;






select OwnerAddress
from NashvilleHousing

select
parsename(Replace(OwnerAddress, ',' , '.'),3)
 ,parsename(Replace(OwnerAddress, ',' , '.'),2)
  ,parsename(Replace(OwnerAddress, ',' , '.'),1)
from NashvilleHousing






ALter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = parsename(Replace(OwnerAddress, ',' , '.'),3)

ALter table NashvilleHousing
add OwnerSplitCity nvarchar(100);

Update NashvilleHousing
Set OwnerSplitCity =  parsename(Replace(OwnerAddress, ',' , '.'),2)


ALter table NashvilleHousing
add OwnerSplitState nvarchar(100);

Update NashvilleHousing
Set OwnerSplitState = parsename(Replace(OwnerAddress, ',' , '.'),1)

Alter table NashvilleHousing
DROP column OwnerAddress;



--change Y and N to yes and no in "Sold as Vacant" Field

Select distinct(SoldAsVacant), count(SoldasVacant)
from NashvilleHousing
group by SoldasVacant
Order by SoldAsVacant


Select SoldasVacant
, Case when SoldasVacant = 'Y' Then 'Yes'
	   When SoldasVacant = 'N' Then 'NO'
	   Else SoldasVacant
	   End
From NashvilleHousing


update NashvilleHousing
SET SoldasVacant = Case when SoldasVacant = 'Y' Then 'Yes'
						When SoldasVacant = 'NO' Then 'No'
						Else SoldasVacant
						End
select SoldasVacant
From NashvilleHousing


--Remove Duplicates

With RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
Partition By ParcelID,
			 PropertySplitAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By 
			 UniqueID
			 ) row_num
From NashvilleHousing
)
--order by ParcelID

DELETE
from RowNumCTE
Where row_num > 1
--Order by PropertySplitAddress


With RowNumCTE AS(
Select *,
ROW_NUMBER() OVER(
Partition By ParcelID,
			 PropertySplitAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By 
			 UniqueID
			 ) row_num
From NashvilleHousing
)
Select *
from RowNumCTE
Where row_num > 1
Order by PropertySplitAddress



