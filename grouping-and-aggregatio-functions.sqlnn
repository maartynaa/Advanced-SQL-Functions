SELECT MAX(UnitPrice) FROM Products; 

-----  

SELECT C.CategoryName, SUM(P.UnitPrice*P.UnitsInStock) AS SumValueOfProductsInStock FROM Products P 
JOIN Categories C ON P.CategoryID = C.CategoryID 
GROUP BY C.CategoryName 
HAVING  SUM(P.UnitPrice*P.UnitsInStock) > 10000 
ORDER BY C.CategoryName 
 
-----    

WITH 
uniqueOrders (OrderId, CompanyName) 
AS  
( 
  SELECT DISTINCT OD.OrderID, S.CompanyName FROM Suppliers S  
  JOIN Products P ON S.SupplierID = P.SupplierID  
  JOIN [Order Details] OD ON P.ProductID = OD.ProductID 
) 
SELECT CompanyName, COUNT(*) FROM uniqueOrders  
GROUP BY CompanyName  
ORDER BY CompanyName

-----

WITH  
SumOrderValue (OrderId, CustomerId, SumValue) 
AS  
( 
  SELECT OD.OrderId, C.CustomerID, SUM(OD.UnitPrice*OD.Quantity) 
  FROM Orders O  
  JOIN Customers C ON O.CustomerID = C.CustomerID  
  JOIN [Order Details] OD ON OD.OrderID = O.OrderID  
  GROUP BY OD.OrderId, C.CustomerID
) 
SELECT CustomerId, AVG(SumValue), MIN(SumValue), MAX(SumValue) 
FROM SumOrderValue 
GROUP BY CustomerId 
ORDER BY AVG(SumValue) DESC 
 
-----  

SELECT CONVERT(char(10),OrderDate,126), COUNT(*) FROM Orders O 
GROUP BY OrderDate 
HAVING COUNT(*) > 1 
ORDER BY COUNT(*) DESC

-----

SELECT DATEPART(yyyy, O.OrderDate), FORMAT(O.OrderDate, 'yyyy-MM'), COUNT(*) FROM Orders O 
GROUP BY ROLLUP(DATEPART(yyyy, O.OrderDate), FORMAT(O.OrderDate, 'yyyy-MM')) 
ORDER BY FORMAT(O.OrderDate, 'yyyy-MM') DESC 

----- 
 
SELECT  
  ShipCountry, 
  CASE 
    WHEN ShipRegion IS NULL  AND GROUPING(ShipRegion) = 0 THEN 'Not Provided' 
    ELSE ShipRegion 
  END, 
  ShipCity, 
  COUNT(*) AS CNT, 
  CASE GROUPING_ID(ShipCountry, ShipRegion, ShipCity) 
    WHEN 0 THEN 'Country & Region & City' 
    WHEN 1 THEN 'Country & Region' 
    WHEN 3 THEN 'Country'  
  ELSE 'Total' 
  END AS GroupingLevel 
FROM Orders O 
GROUP BY ROLLUP (ShipCountry, ShipRegion, ShipCity) 
ORDER BY ShipCountry 

-----

SELECT YEAR(O.OrderDate), C.Country, C.Region, SUM(OD.UnitPrice*OD.Quantity) FROM Orders O 
JOIN [Order Details] OD ON O.OrderID = OD.OrderID 
JOIN Customers C ON C.CustomerID = O.CustomerID 
GROUP BY CUBE (YEAR(O.OrderDate),  (C.Country, C.Region)) 
ORDER BY 2 ASC;

-----

SELECT  
  CategoryName, 
  S.Country AS SupplierCountry, 
  C.Country AS CustomerCountry, 
  C.Region AS CustomerRegion, 
  SUM(OD.UnitPrice*OD.Quantity) AS OrderValue, 
  CASE GROUPING_ID(CategoryName, S.Country, C.Country)  
    WHEN 6 THEN 'Country & Region – Customer'  
    WHEN 5 THEN 'Country - Supplier'  
    WHEN 3 THEN 'Category'   
  END AS GroupingLevel 
FROM Orders O 
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
JOIN Customers C ON O.CustomerID = C.CustomerID 
JOIN Products P ON P.ProductID = OD.ProductID 
JOIN Suppliers S ON S.SupplierID = P.SupplierID 
JOIN Categories CA ON CA.CategoryID = P.CategoryID 
GROUP BY  
GROUPING SETS (CA.CategoryName, S.Country, (C.Country, C.Region)) 
ORDER BY GroupingLevel, OrderValue DESC 
 
-----

SELECT [ShipCountry],[Federal Shipping],[Speedy Express],[United Package] 
FROM ( 
  SELECT o.ShipCountry AS ShipCountry,s.CompanyName AS CompanyName, 1 AS one 
  FROM Orders o 
  JOIN Shippers s ON o.ShipVia=s.ShipperID ) long 
  PIVOT (SUM(one) FOR CompanyName IN ([Federal Shipping],[Speedy Express],[United Package])) AS pvt 
ORDER BY ShipCountry 
