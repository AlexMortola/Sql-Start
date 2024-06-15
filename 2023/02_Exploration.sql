------------------------------------------------------------------------
-- Event:        SQL Start! 2023, June 16 2023                         -
--               https://www.sqlstart.it/2023                          -
-- Session:      Ladies and gentlemen... The Query Optimizer           -
-- Demo:         Exploration - Search phases                           -
-- Author:       Alessandro Mortola                                    -
-- Notes:        Include the Actual Execution Plan                     -
------------------------------------------------------------------------

EXEC sys.sp_configure N'cost threshold for parallelism', N'5'
GO
RECONFIGURE WITH OVERRIDE
GO


use AdventureWorks;
go

--Parallel plan - Search 1
select SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, UnitPrice
from Sales.SalesOrderDetail
order by ModifiedDate
option (recompile, querytraceon 3604, querytraceon 8675);
go

--Parallel plan - Search 2
WITH C
AS (
	SELECT p.Name
		,t1.MaxCarrierTrackingNumber
		,od2.UnitPrice
		,oh.OrderDate
		,t2.cnt AS Counter
		,ROW_NUMBER() OVER (
			PARTITION BY p.Name ORDER BY t1.MaxCarrierTrackingNumber DESC
			) AS Rn
	FROM Production.Product p
	INNER JOIN (
		SELECT od.ProductID
			,max(od.CarrierTrackingNumber) MaxCarrierTrackingNumber
		FROM Sales.SalesOrderDetailEnlarged od
		GROUP BY od.ProductID
		) t1 ON p.ProductID = t1.ProductID
	INNER JOIN Sales.SalesOrderDetailEnlarged od2 ON od2.ProductID = t1.ProductID
		AND od2.CarrierTrackingNumber = t1.MaxCarrierTrackingNumber
	INNER JOIN Sales.SalesOrderHeaderEnlarged oh ON oh.SalesOrderID = od2.SalesOrderID
	INNER JOIN (
		SELECT OrderDate
			,count(*) cnt
		FROM Sales.SalesOrderHeaderEnlarged oh2
		GROUP BY OrderDate
		) t2 ON oh.OrderDate = t2.OrderDate
	WHERE oh.OnlineOrderFlag = 1
	)
SELECT Name
	,MaxCarrierTrackingNumber
	,UnitPrice
	,Counter
FROM C
WHERE Rn = 1
OPTION (
	RECOMPILE
	,querytraceon 3604
	,querytraceon 8675
	);


