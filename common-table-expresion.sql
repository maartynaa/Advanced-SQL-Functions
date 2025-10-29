WITH 
AverageCategortPrice (CategoryId, AvgPrice) 
AS 
( 
  SELECT C.CategoryID, AVG(UnitPrice) FROM Products P 
  JOIN Categories C ON C.CategoryID = P.CategoryID 
  GROUP BY C.CategoryID 
) 
SELECT ProductID, ProductName FROM Products P 
JOIN AverageCategortPrice CTE ON P.CategoryID = CTE.CategoryId 
WHERE P.UnitPrice > AvgPrice 
ORDER BY UnitPrice 

-----

WITH 
AverageCategoryPrice (CategoryId, AvgPrice) 
AS 
( 
  SELECT C.CategoryID, AVG(OD.UnitPrice*OD.Quantity) FROM Products P1 
  JOIN [Order Details] OD ON P1.ProductID = OD.ProductID 
  JOIN Categories C ON P1.CategoryID = C.CategoryID 
  GROUP BY C.CategoryID 
), 
MaxProductOrderValue (ProductId, MaxOrderValue) 
AS 
( 
  SELECT P2.ProductId, MAX(OD.UnitPrice*OD.Quantity) FROM Products P2 
  JOIN [Order Details] OD ON P2.ProductID = OD.ProductID 
  GROUP BY P2.ProductId, ProductName 
) 
SELECT P.ProductID, P.ProductName FROM Products P 
JOIN AverageCategoryPrice AvgCte ON P.CategoryID = AvgCte.CategoryId 
JOIN MaxProductOrderValue MaxCte ON P.ProductID = MaxCte.ProductId 
WHERE MaxCte.MaxOrderValue < AvgCte.AvgPrice 
ORDER BY ProductID 

-----

WITH  
EmployeesWithManagers (EmployeeID, FirstName, LastName, ReportsTo, ManagerFirstName, ManagerLastName, Level) 
AS 
( 
  SELECT  
    EmployeeID,  
    FirstName,  
    LastName,  
    ReportsTo, 
    CAST(NULL AS NVARCHAR(10)) AS ManagerFirstName, 
    CAST(NULL AS NVARCHAR(20)) AS ManagerLastName,
    0 AS Level 
  FROM Employees 
  WHERE ReportsTo IS NULL 
  
  UNION ALL 
  
  SELECT E.EmployeeID, E.FirstName, E.LastName, R.EmployeeID, R.FirstName, R.LastName, Level + 1 
  FROM Employees E  
  JOIN EmployeesWithManagers R ON E.ReportsTo = R.EmployeeID 
  WHERE Level < 1 
) 
SELECT EmployeeID, FirstName, LastName, ReportsTo, ManagerFirstName, ManagerLastName, Level, 
CASE Level 
  WHEN 0 THEN 'John' 
  WHEN 1 THEN 'Tom' 
END 
FROM EmployeesWithManagers; 

-----

WITH  
EmployeesWithManagers (EmployeeID, FirstName, LastName, ReportsTo, ManagerFirstName, ManagerLastName, Level, WhoIsThis) 
AS 
( 
  SELECT  
    EmployeeID,  
    FirstName,  
    LastName,  
    ReportsTo, 
    CAST(NULL AS NVARCHAR(10)) AS ManagerFirstName, 
    CAST(NULL AS NVARCHAR(20)) AS ManagerLastName, 
    0 AS Level, 
    CAST('John' AS NVARCHAR(20)) AS WhoIsThis 
  FROM Employees 
  WHERE ReportsTo IS NULL 
  
  UNION ALL 
  
  SELECT E.EmployeeID, E.FirstName, E.LastName, R.EmployeeID, R.FirstName, R.LastName, Level + 1, 
  CASE Level + 1 
    WHEN 1 THEN CAST('Tom' AS NVARCHAR(20)) 
    WHEN 2 THEN CAST('Rick' AS NVARCHAR(20)) 
  END AS WhoIsThis 
  FROM Employees E  
  JOIN EmployeesWithManagers R ON E.ReportsTo = R.EmployeeID 
) 
SELECT  
EWM1.EmployeeID, EWM1.FirstName, EWM1.LastName, EWM1.ReportsTo, EWM2.WhoIsThis, EWM1.ManagerFirstName, EWM1.ManagerLastName, EWM1.WhoIsThis 
FROM EmployeesWithManagers EWM1 
LEFT JOIN EmployeesWithManagers EWM2 ON EWM1.ReportsTo = EWM2.EmployeeID 
