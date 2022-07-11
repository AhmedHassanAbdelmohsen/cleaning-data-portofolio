--showing all the data 
select * from [protfolio(cleaning data)]..nationalhousing

--adjust the saledate formate 

select SaleDate from [protfolio(cleaning data)]..nationalhousing

update [protfolio(cleaning data)]..nationalhousing
set SaleDate= convert(date,SaleDate)

alter table [protfolio(cleaning data)]..nationalhousing
add converteddate date;


update [protfolio(cleaning data)]..nationalhousing
set converteddate= convert(date,SaleDate)

select converteddate from nationalhousing


--cleaning the address column


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)  
from [protfolio(cleaning data)]..nationalhousing a 
join [protfolio(cleaning data)]..nationalhousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from [protfolio(cleaning data)]..nationalhousing a 
join [protfolio(cleaning data)]..nationalhousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--check if there are null values in address
select PropertyAddress   from [protfolio(cleaning data)]..nationalhousing
where PropertyAddress is null 

-------------------------------------------------------------------------------------
--break the address into seperate columns 
select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as addressing,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) as addressing
from [protfolio(cleaning data)]..nationalhousing

alter table [protfolio(cleaning data)]..nationalhousing
add addstreet varchar(255) 

update [protfolio(cleaning data)]..nationalhousing
set addstreet= SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


alter table [protfolio(cleaning data)]..nationalhousing
add addcity varchar(255)

update [protfolio(cleaning data)]..nationalhousing
set addcity= SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress))


select PropertyAddress,addstreet,addcity from [protfolio(cleaning data)]..nationalhousing

---------------------------------------------------
--handle the null in owner address(figured out that the repeated items not inculding extra information about the blank cells)

select a.ParcelID,a.OwnerAddress,b.ParcelID,b.OwnerAddress   from [protfolio(cleaning data)]..nationalhousing a
join [protfolio(cleaning data)]..nationalhousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.OwnerAddress is null

-------------------------------------
--split owner address 

select OwnerAddress  from [protfolio(cleaning data)]..nationalhousing

select SUBSTRING(OwnerAddress ,1,CHARINDEX(',', OwnerAddress )-1) as addressing,
SUBSTRING(OwnerAddress ,CHARINDEX(',', OwnerAddress )+1,len(OwnerAddress )) as addressing
from [protfolio(cleaning data)]..nationalhousing

alter table [protfolio(cleaning data)]..nationalhousing
add ownaddstreet varchar(255) 

update [protfolio(cleaning data)]..nationalhousing
set ownaddstreet= SUBSTRING(OwnerAddress,1,CHARINDEX(',', OwnerAddress)-1)


alter table [protfolio(cleaning data)]..nationalhousing
add ownaddcity varchar(255)

update [protfolio(cleaning data)]..nationalhousing
set ownaddcity= SUBSTRING(OwnerAddress,CHARINDEX(',', OwnerAddress)+1,len(OwnerAddress))

select OwnerAddress,ownaddstreet,ownaddcity  from [protfolio(cleaning data)]..nationalhousing
---------------------------------------------------
--split using parsname 
select 
PARSENAME(replace(OwnerAddress,',','.'),3) as street,
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),1) as state


from [protfolio(cleaning data)]..nationalhousing

--------------------------------------
--change y and n to yes and no at soldasvacant

select   SoldAsVacant
from [protfolio(cleaning data)]..nationalhousing
where SoldAsVacant='y' or SoldAsVacant='n'

update [protfolio(cleaning data)]..nationalhousing
set SoldAsVacant='YES'
where SoldAsVacant='y'

update [protfolio(cleaning data)]..nationalhousing
set SoldAsVacant='NO'
where SoldAsVacant='n'

select distinct  SoldAsVacant
from [protfolio(cleaning data)]..nationalhousing

-----------------------------------------------------
select SoldAsVacant,case when SoldAsVacant='yes' then 'y'
else SoldAsVacant end
from [protfolio(cleaning data)]..nationalhousing
where SoldAsVacant='yes'

-----------------------------------------------------------------
--remove depulicates 
WITH RCt_dup as (
select * ,
ROW_NUMBER() over ( partition by parcelid,propertyaddress,saledate,saleprice,legalreference order by uniqueid) row_num  
from [protfolio(cleaning data)]..nationalhousing
order by ParcelID)
select *  from RCt_dup
where row_num > 1
order by PropertyAddress

--to delete the items  as below 
delete from RCt_dup
where row_num > 1



------------------------------------------------------------------

 --delete unused columns 

 select * from [protfolio(cleaning data)]..nationalhousing

 alter table [protfolio(cleaning data)]..nationalhousing
 drop column PropertyAddress , OwnerAddress
  


  ---------------------------------------------------------





















