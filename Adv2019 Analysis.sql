-- Using AdventureWorks2019, do the following exploration;

-- Question 1: Display the business entity, territory and sales details. Also categories Bonus using the following
-- criteria; If Bonus<1000 then that is a lowbonus, If Bonus is between 1000 and 2000 inclusive then that is a midbonus
-- and finally if Bonus > 2000 that is a high bonus

USE AdventureWorks2019
GO
SELECT  BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear,
		CASE
			WHEN Bonus < 1000 THEN 'Lowbonus'
			WHEN Bonus BETWEEN 1000 AND 2000 THEN 'Midbonus'
  			ELSE 'Highbonus'
		END AS	Bonus_category
		FROM  [Sales].[SalesPerson]
GO


-- Question 2: Find the TotalSales of each bonus category defined in question 1. HINT: Use SELECT INTO and Subquery.

DROP TABLE IF EXISTS Bonus_category_Sales
GO
SELECT Bonus_category, SUM(Bonus) AS TotalSales INTO Bonus_category_Sales
	FROM ( SELECT * , CASE
				WHEN Bonus < 1000 THEN 'Lowbonus'
				WHEN Bonus BETWEEN 1000 AND 2000 THEN 'Midbonus'
  				ELSE 'Highbonus'
				END AS	Bonus_category
				FROM  [Sales].[SalesPerson]
		 ) AS SubQuery
	GROUP BY Bonus_category;

SELECT * FROM Bonus_category_Sales
GO

-- Question 3: Create a function such that if a user passes in a store id it returns the each product id, name of
-- the product and the line total of that product.

DROP FUNCTION IF EXISTS SalesByStore
GO
CREATE FUNCTION SalesByStore (@store_id INT)
	RETURNS TABLE
	AS
	RETURN
	(
		SELECT P.ProductID, P.Name, SUM(SD.LineTotal) AS 'Total'
			FROM Production.Product AS P
			JOIN Sales.SalesOrderDetail AS SD ON SD.ProductID = P.ProductID
			JOIN Sales.SalesOrderHeader AS SH ON SH.SalesOrderID = SD.SalesOrderID
			JOIN Sales.Customer AS C ON SH.CustomerID = C.CustomerID
			WHERE C.StoreID = @store_id
			GROUP BY P.ProductID, P.Name
	)
GO

SELECT * FROM SalesByStore(602)
GO


-- Question 4: For each Job title show the number of employees, mean age and mean rate. Use a temp table
-- inside a stored procedure

DROP PROCEDURE IF EXISTS JobtitleDist
GO
CREATE PROCEDURE JobtitleDist
	AS
	CREATE TABLE #temp_employee(
		JobTitle varchar(50),
		EmployeesPerJob INT,
		AvgAge INT,
		AvgRate INT
		)

	INSERT INTO #temp_employee
		SELECT JobTitle, COUNT(JobTitle), AVG(YEAR(CURRENT_TIMESTAMP)-YEAR(BirthDate)), AVG(Rate)
			FROM [HumanResources].[Employee] Hre
			JOIN [HumanResources].[EmployeePayHistory] Hreph ON Hre.BusinessEntityID = Hreph.BusinessEntityID
			GROUP BY JobTitle;

	SELECT * FROM #temp_employee
GO
EXEC JobtitleDist;