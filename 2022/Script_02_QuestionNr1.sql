----------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                             -
--               https://www.sqlstart.it/2022                              -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                        -
-- Demo:         Question n° 1 - Is it possible to use column expressions  -
-- 	             with either the aggregate Column or the spreading Column? -
-- Author:       Alessandro Mortola                                        -
-- Notes:        --                                                        -
----------------------------------------------------------------------------

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
	('COMP_A', '20220110', 534.98),
	('COMP_A', '20220201', 150),
	('COMP_A', '20220201', 1511.55),
	('COMP_A', '20220208', 0),
	('COMP_A', '20220320', 704.9),
	('COMP_A', '20220320', 2507.77),

	('COMP_B', '20220110', 0),
	('COMP_B', '20220131', 1234.45),
	('COMP_B', '20220201', 789.87),
	('COMP_B', '20220208', 350.43),
	('COMP_B', '20220321', 1050.6);
go

select * from dbo.Transactions;
go

--Standard SQL statement
select Company, 
		--Aggregation and spreading phase
		sum(case when TransactionDate between '20220101' and '20220131' then round(Income, 1) end) as [2022 - Jan],
		sum(case when TransactionDate between '20220201' and '20220228' then round(Income, 1) end) as [2022 - Feb],
		sum(case when TransactionDate between '20220301' and '20220331' then round(Income, 1) end) as [2022 - Mar]
from dbo.Transactions
--Grouping phase
group by Company;
go


--What about Pivot ?
select Company, [20220110], [20220131], [20220201], [20220208], [20220320], [20220321]
from dbo.Transactions
pivot (
	SUM(Income) for TransactionDate in ([20220110], [20220131], [20220201], [20220208], [20220320], [20220321])
	) as p;


