------------------------------------------------------------------------
-- Event:        Sql Start! 2025, June 13 2025      				   -
--               https://www.sqlstart.it/                         	   -
-- Session:      Climb up towards Sql Server Statistics				   -
-- Script:       Computed Columns               	                   -
-- Author:       Alessandro Mortola                                    -
-- Notes:		                         				               -
------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?', 20, 1) with log;
go

use AdventureWorks;
go


--Number of rows currently in Sales.SalesOrderDetailEnlarged: 4852680
--
select OBJECTPROPERTYEX(object_id('Sales.SalesOrderDetailEnlarged'), 'cardinality');

--Look at the Estimated Plan
select * 
from Sales.SalesOrderDetailEnlarged
where OrderQty * UnitPrice > 25000
option (recompile);
go




alter table Sales.SalesOrderDetailEnlarged add LinePrice as (OrderQty * UnitPrice);
go



--Look at the Estimated Plan again
select * 
from Sales.SalesOrderDetailEnlarged
where OrderQty * UnitPrice > 25000
option (recompile);
go


dbcc show_statistics('Sales.SalesOrderDetailEnlarged', LinePrice);

