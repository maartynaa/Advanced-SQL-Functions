SELECT DISTINCT 
ROUND(AVG(UnitPrice) OVER (), 2) AS AvgUnitPrice 
FROM Products 
 
----- 
 
SELECT DISTINCT 
  CategoryName, 
  ROUND(AVG(UnitPrice) OVER (PARTITION BY C.CategoryID), 2) AS AvgUnitPrice 
FROM Products P 
JOIN Categories C ON P.CategoryID = C.CategoryID 
ORDER BY CategoryName 

-----
 
SELECT 
  ProductName, 
  CategoryName, 
  ROUND(AVG(UnitPrice) OVER (), 2) AS AvgUnitPrice 
FROM Products P 
JOIN Categories C ON P.CategoryID = C.CategoryID 
WHERE CategoryName != 'Beverages' 
ORDER BY ProductName 

-----

SELECT 
  ProductName, 
  CategoryName, 
  ROUND(AVG(UnitPrice) OVER (), 2) AS AvgUnitPrice, 
  MIN(UnitPrice) OVER () AS MinUnitPrice, 
  MAX(UnitPrice) OVER () AS MaxUnitPrice 
FROM Products P 
JOIN Categories C ON P.CategoryID = C.CategoryID 
ORDER BY ProductName

-----

SELECT 
  ProductName, 
  CategoryName, 
  ROUND(AVG(UnitPrice) OVER (), 2) AS AvgUnitPrice, 
  MIN(UnitPrice) OVER () AS MinUnitPrice, 
  MAX(UnitPrice) OVER () AS MaxUnitPrice, 
  ROUND(AVG(UnitPrice) OVER (PARTITION BY C.CategoryID), 2) AS AvgUnitPriceInCategory, 
  ROUND(AVG(UnitPrice) OVER (PARTITION BY P.SupplierID), 2) AS AvgUnitPriceBySupplier, 
  COUNT(*) OVER (PARTITION BY P.CategoryID) AS NumberOfProductsInCat 
FROM Products P 
JOIN Categories C ON P.CategoryID = C.CategoryID 
ORDER BY ProductName 

-----
 
SELECT  
  O.OrderID, 
  CompanyName, 
  OrderDate, 
  ROW_NUMBER() OVER (ORDER BY OrderDate) AS rowNumber 
FROM Orders O 
JOIN Customers C ON C.CustomerID = O.CustomerID 
ORDER BY CompanyName ASC, OrderDate DESC 

-----

DECLARE 
  @pageNum AS INT = 3, 
  @pageSize AS INT = 15;
WITH ProductWithPageNumber AS 
( 
  SELECT  
    ROW_NUMBER() OVER (ORDER BY P.ProductID) as rowNum, 
    ProductID,
    ProductName,
    CategoryName,
    UnitPrice,
    ROUND(AVG(UnitPrice) OVER (PARTITION BY P.CategoryID), 2) AS AvgUnitPriceInCategory
  FROM Products P
  JOIN Categories C ON P.CategoryID = C.CategoryID
) 
SELECT  
  ProductID,
  ProductName,
  CategoryName,
  UnitPrice,
  AvgUnitPriceInCategory,
  @pageNum AS pageNum,
  rowNum
FROM ProductWithPageNumber 
WHERE rowNum BETWEEN (@pageNum-1)*@pageSize +1 AND @pageNum * @pageSize 
ORDER BY ProductName

-----  10...

SELECT 
	ProductID,
	ProductName,
	CategoryName,
	UnitPrice,
	denseRank
FROM 
(
	SELECT
	ProductID,
	ProductName,
	CategoryName,
	UnitPrice,
	ROW_NUMBER() OVER (PARTITION BY CategoryName ORDER BY UnitPrice DESC) AS rank,
	DENSE_RANK() OVER (PARTITION BY CategoryName ORDER BY UnitPrice DESC) AS denseRank
	FROM Products P
	JOIN Categories C ON P.CategoryID = C.CategoryID
) a
WHERE CASE
         WHEN rank <= 5 Then 1
		 WHEN rank > 5 AND denseRank < 5 THEN 1
         ELSE 0
      END = 1;

-----

SELECT DISTINCT s.ProductID, s.ProductName 
FROM( 
  SELECT 
    P.ProductID, 
    P.ProductName, 
    MAX(OD.UnitPrice*OD.Quantity) OVER (PARTITION BY P.ProductID) AS MaxValue, 
    AVG(OD.UnitPrice*OD.Quantity) OVER (PARTITION BY P.CategoryID) AS AvgValue 
  FROM Products P 
  JOIN [Order Details] OD ON OD.ProductID = P.ProductID 
) S 
WHERE s.MaxValue < s.AvgValue 

----- 14

SELECT
	ProductID,
	CategoryName,
	UnitPrice,
	SUM(UnitPrice) OVER(PARTITION BY CategoryName ORDER BY UnitPrice 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
          AS RunSum,
	MAX(UnitPrice) OVER(PARTITION BY CategoryName ORDER BY UnitPrice 
    ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) 
          AS MaxUnitPrice,
    ROUND(AVG(UnitPrice) OVER(PARTITION BY CategoryName ORDER BY UnitPrice 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
          AS MovAvg,
   ROUND(AVG(UnitPrice) OVER(PARTITION BY CategoryName ORDER BY UnitPrice 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
   - AVG(UnitPrice) OVER(PARTITION BY CategoryName ORDER BY UnitPrice 
    ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING), 2) AS MoveAvgDiff
    
FROM Products P
JOIN Categories C ON P.CategoryID = C.CategoryID

----- 15

WITH UniqueCategories(categoryID, rowNum)
AS (
	SELECT
		CategoryID,
		ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY CategoryID)
	FROM MyCategories
)
DELETE FROM UniqueCategories
WHERE rowNum > 1

-----

WITH luka(startDate, endDate, days)
AS
(
SELECT 
		ShippedDate,
		LEAD(ShippedDate) OVER (ORDER BY ShippedDate),
		DATEDIFF(day, ShippedDate, LEAD(ShippedDate) OVER (ORDER BY ShippedDate))
	FROM Orders
)
SELECT startDate+1, endDate-1 FROM luka 
WHERE days > 1
