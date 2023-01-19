select *
from PortfolioProject.dbo.NashvilleHousing


--standarize data format

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDate2 date

update PortfolioProject.dbo.NashvilleHousing
set SaleDate2 = convert(date, SaleDate)

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate



--populate property address data

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null



--1) Breaking out PropertyAddress

--select
--substring(PropertyAddress, 1, charindex (',', PropertyAddress)-1) as SplitAddress, substring (PropertyAddress, charindex (',', PropertyAddress)+1, len(PropertyAddress)) as SplitCity
--from dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex (',', PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity = substring (PropertyAddress, charindex (',', PropertyAddress)+1, len(PropertyAddress))


--2) Breaking out OwnerAddress

--select
--parsename(replace(OwnerAddress, ',', '.'),3) as OwnerSplitAdress,
--parsename(replace(OwnerAddress, ',', '.'),2) as OwnerCity,
--parsename(replace(OwnerAddress, ',', '.'),1) as OwnerState
--from dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress= parsename(replace(OwnerAddress, ',', '.'),3)

alter table PortfolioProject.dbo.NashvilleHousing
add Ownercity Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerCity= parsename(replace(OwnerAddress, ',', '.'),2)

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerState Nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerState= parsename(replace(OwnerAddress, ',', '.'),1)


--Change Y and N to Yes and No in "SoldAsVacant" field
select SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
end


--Remove Duplicates
with RowNumCTE as(
select *, row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate2, OwnerName, OwnerAddress, LegalReference order by UniqueID) AS row_number
from PortfolioProject.dbo.NashvilleHousing)
delete
from RowNumCTE
where row_number > 1


--delete unsued columns
alter table PortfolioProject.dbo.NashvilleHousing
drop column TaxDistrict
