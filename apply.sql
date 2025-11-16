SELECT P.ProductID, P.ProductName, S.CompanyName 
FROM Products P JOIN Suppliers S 
ON P.SupplierID = S.SupplierID 
ORDER BY ProductID 

SELECT P.ProductID, P.ProductName, C.CompanyName 
FROM Products P  
OUTER APPLY 
( 
  SELECT S2.CompanyName FROM Suppliers S2 
  WHERE P.SupplierID = S2.SupplierID 
) C 

----- 3.

CREATE OR ALTER FUNCTION customerInfo(@OrderID INT) 
RETURNS TABLE 
AS 
RETURN ( 
	SELECT O.OrderID, C.CompanyName, C.ContactName, C.Address
	FROM Orders O 
	JOIN Customers C ON O.CustomerID = C.CustomerID
	WHERE O.OrderID = @OrderID
)
GO

CREATE OR ALTER FUNCTION employeeInfo(@OrderID INT)  
RETURNS TABLE  
AS  
RETURN (  
	SELECT O.OrderID, E.FirstName, E.LastName, E.Address   
	FROM Orders O  
	JOIN Employees E ON O.EmployeeID = E.EmployeeID 
	WHERE O.OrderID = @OrderID
) 
GO 


SELECT 
	O.OrderID, 
	O.CustomerID, 
	O.OrderDate,  
	C1.FirstName, 
	C1.LastName, 
	C.CompanyName, 
	C.ContactName, 
	C.Address 
FROM Orders O
OUTER APPLY
(
	SELECT CI.CompanyName, CI.ContactName, CI.Address FROM customerInfo(O.OrderID) CI
	WHERE CI.OrderID = O.OrderID
) C
OUTER APPLY 
(
	SELECT EI.FirstName, EI.LastName FROM employeeInfo(O.OrderID) EI 
	WHERE EI.OrderID = O.OrderID 
) C1
ORDER BY O.OrderID

 
