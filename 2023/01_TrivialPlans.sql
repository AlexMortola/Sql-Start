------------------------------------------------------------------------
-- Event:        SQL Start! 2023, June 16 2023                         -
--               https://www.sqlstart.it/2023                          -
-- Session:      Ladies and gentlemen... The Query Optimizer           -
-- Demo:         Trivial plans - Statistics, caching and Aggregations  -
-- Author:       Alessandro Mortola                                    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

use AdventureWorks;
go
 

--Statistics for relevant columns are created or updated as required
drop table if exists dbo.oh;
go
 
select *
into dbo.oh
from Sales.SalesOrderHeader;
 
select *
from sys.stats
where OBJECT_NAME(object_id) = 'oh';
 
--Show the estimated plan
select *
from dbo.oh
where SalesOrderID = 69000;

select *
from sys.stats
where OBJECT_NAME(object_id) = 'oh';
go



--Caching 
dbcc freeproccache;
go

select *
from Production.Product
where ProductID = 1 --and 1 = 1
;
go

select
    cp.plan_handle,
	qt.text as QueryText,
	qp.query_plan as QueryPlan,
	cp.usecounts as ExecCount,
	cp.cacheobjtype as CacheObjType,
	cp.objtype as ObjType,
	cp.size_in_bytes / 1024. as SizeKB
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_query_plan(cp.plan_handle) qp
cross apply sys.dm_exec_sql_text(cp.plan_handle) qt
where qt.text not like '%dm_exec_cached_plans%';
go





--Aggregations
select ProductModelID, count(*) as Cnt
from Production.Product
group by ProductModelID;


--Trivial or full?
select count(*) as Cnt
from Production.Product;

--Trivial or full?
select COUNT(ProductId) as CntProdId
from Production.Product;

--trivial or Full?
select MAX(ProductId) as MaxProdId
from Production.Product;

--trivial or Full?
select MIN(ProductId) as MinProdId
from Production.Product;

--Trivial or full?
select AVG(ProductId) as AvgProdId
from Production.Product;





