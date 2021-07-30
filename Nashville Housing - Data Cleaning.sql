SELECT * 
FROM nashville_housing

---------------------------------------------------------------------------

-- Standardize Date Format

SELECT sale_date, CAST(sale_date AS date)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD c_sale_date Date;

UPDATE nashville_housing
SET c_sale_date = CAST(sale_date AS date)


-- Populate the property address column

-- getting unique parcel ids
Select DISTINCT parcel_id
FROM nashville_housing

-- can be seen that property address remains same for this parcel id
Select property_address
FROM nashville_housing
WHERE parcel_id = '093 09 0C 048.00'

Select *
FROM nashville_housing
WHERE property_address IS NULL 


SELECT A.unique_id, COALESCE(A.property_address, B.property_address) AS property_add
FROM nashville_housing A
JOIN nashville_housing B
	ON A.parcel_id = B.parcel_id
	AND A.unique_id <> B.unique_id
WHERE A.property_address IS NULL 


UPDATE nashville_housing
SET property_address = COALESCE(A.property_address,B.property_address)
FROM nashville_housing A
JOIN nashville_housing B
	ON A.parcel_id = B.parcel_id
	AND A.unique_id <> B.unique_id
WHERE A.property_address IS NULL 


---------------------------------------------------------------------------

--- BREAKING DOWN ADDRESS INTO INDIVISUAL COLUMNS (ADDRESS, CITY, STATE)


SELECT *
FROM nashville_housing

-- spliting the property address column on a comma

SELECT property_address, SUBSTRING(property_address, 1,position(',' in property_address)-1) AS Address,
	 SUBSTRING(property_address, position(',' in property_address)+1, LENGTH(property_address)) AS city
FROM nashville_housing


ALTER TABLE nashville_housing
ADD property_split_address varchar(255);
UPDATE nashville_housing
SET property_split_address = SUBSTRING(property_address, 1,position(',' in property_address)-1)


ALTER TABLE nashville_housing
ADD property_split_city varchar(255);
UPDATE nashville_housing
SET property_split_city = SUBSTRING(property_address, position(',' in property_address)+1, LENGTH(property_address))


--- splitting down the owner address column

SELECT owner_address
FROM nashville_housing

SELECT SPLIT_PART(owner_address, ',', 1) FROM nashville_housing


ALTER TABLE nashville_housing
Add OwnerSplitAddress varchar(255);
Update nashville_housing
SET OwnerSplitAddress = SPLIT_PART(owner_address, ',', 1)


ALTER TABLE nashville_housing
Add OwnerSplitCity varchar(255);
Update nashville_housing
SET OwnerSplitCity = SPLIT_PART(owner_address, ',', 2)


ALTER TABLE nashville_housing
Add OwnerSplitState varchar(255);
Update nashville_housing
SET OwnerSplitState = SPLIT_PART(owner_address, ',', 3)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field



SELECT DISTINCT sold_as_vacant, COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant



SELECT sold_as_vacant, CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
							WHEN sold_as_vacant = 'N' THEN 'No'
							ELSE sold_as_vacant
							END
FROM nashville_housing
WHERE sold_as_vacant = 'Y'


UPDATE nashville_housing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
							WHEN sold_as_vacant = 'N' THEN 'No'
							ELSE sold_as_vacant
							END


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From nashville_housing


ALTER TABLE nashville_housing
DROP COLUMN owner_address,   
DROP COLUMN tax_district,
DROP COLUMN property_address,
DROP COLUMN sale_date


----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH delete_duplicates AS(
SELECT *, 
			ROW_NUMBER() OVER (
			PARTITION BY parcel_id,legal_reference, c_sale_date, sale_price) rnk
FROM nashville_housing)

SELECT * FROM delete_duplicates
WHERE rnk = 1




















