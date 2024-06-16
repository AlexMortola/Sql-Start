-----------------------------------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                                                      -
--               https://www.sqlstart.it/2022                                                       -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                                                 -
-- Demo:         Question n° 5 - What if you do not know how many (and which) distinct values are   - 
--               in the spreading column?                                                           -
-- Author:       Alessandro Mortola                                                                 -
-- Notes:        --                                                                                 -
-----------------------------------------------------------------------------------------------------

use TestDb;
go

drop table if exists dbo.Transactions;
go

create table dbo.Transactions(
	Company char(6) not null,
	TransactionDate date not null,
	Income decimal(10,2) null
);
go

insert into dbo.Transactions values 
	('COMP_A', '20220110', 1045.25),
	('COMP_A', '20220115', 914.5),
	('COMP_A', '20220110', 534.98),
	('COMP_A', '20220220', 550.9),
	('COMP_A', '20220201', 123.4),
	('COMP_A', '20220225', 765.4),
	('COMP_A', '20220201', 150),
	('COMP_A', '20220201', 1511.55),
	('COMP_A', '20220208', 0),
	('COMP_A', '20220320', 704.9),
	('COMP_A', '20220301', 409.1),
	('COMP_A', '20220301', 786),
	('COMP_A', '20220320', 2507.77),

	('COMP_B', '20220110', 0),
	('COMP_B', '20220120', 1024.3),
	('COMP_B', '20220131', 1234.45),
	('COMP_B', '20220202', 352.6),
	('COMP_B', '20220201', 789.87),
	('COMP_B', '20220208', 350.43),
	('COMP_B', '20220321', 1050.6),
	('COMP_B', '20220315', 398.3);
go

select * from dbo.Transactions;
go

--SELECT *
--    FROM dbo.Transactions
--     PIVOT(SUM(Income) FOR TransactionDate IN (/*   */)) AS p;








--PIVOT operator
DECLARE @stmt AS NVARCHAR(MAX),
		@columnName AS NVARCHAR(MAX);

select @columnName = STRING_AGG(QUOTENAME(trDate), ',') within group (order by trDate)
from (select distinct CONVERT(varchar, TransactionDate, 112) trDate 
      from dbo.Transactions) t;
 
print @columnName;

 --Prepare the PIVOT query using the dynamic SQL
SET @stmt = 
  N'SELECT Company, ' + @columnName + 
   ' FROM dbo.Transactions
     PIVOT(SUM(Income) FOR TransactionDate IN (' + @columnName + ')) AS p;';

Print @stmt
--Execute the Dynamic Pivot Query
EXEC sp_executesql @stmt;
GO



--STANDARD SQL
DECLARE @stmt AS NVARCHAR(MAX),
		@caseWhenBlock AS NVARCHAR(MAX);

select @caseWhenBlock = STRING_AGG(trDate, ',') within group (order by trDate)
from (select distinct 
			CONCAT('SUM(case TransactionDate when ''', 
					CONVERT(varchar, TransactionDate, 112), 
					''' then Income end) as [', 
					CONVERT(varchar, TransactionDate, 112), ']') trDate
      from dbo.Transactions) t;
 
print @caseWhenBlock;

 --Prepare the query using the dynamic SQL
SET @stmt = 
  N'SELECT Company, ' + @caseWhenBlock + 
   ' FROM dbo.Transactions
     GROUP BY Company;';

Print @stmt;
--Execute the Dynamic SQL Query
EXEC sp_executesql @stmt;



