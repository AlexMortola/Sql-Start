---------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                            -
--               https://www.sqlstart.it/2022                             -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                       -
-- Demo:         Question n° 3 - Is it possible to pivot for more than    -
--               one column? (e.g.  Month + Region)                       -
-- Author:       Alessandro Mortola                                       -
-- Notes:        --                                                       -
---------------------------------------------------------------------------

use TestDb;
go

drop table if exists dbo.Transactions;
go

create table dbo.Transactions(
	Company char(6) not null,
	Region char(3) not null,
	TransactionDate date not null,
	Income decimal(10,2) null
);
go

insert into dbo.Transactions values 
	('COMP_A', 'ITA', '20220110', 1045.25),
	('COMP_A', 'GB',  '20220115', 914.5),
	('COMP_A', 'ITA', '20220110', 534.98),
	('COMP_A', 'GB',  '20220220', 550.9),
	('COMP_A', 'FRA', '20220201', 123.4),
	('COMP_A', 'FRA', '20220225', 765.4),
	('COMP_A', 'ITA', '20220201', 150),
	('COMP_A', 'ITA', '20220201', 1511.55),
	('COMP_A', 'ITA', '20220208', 0),
	('COMP_A', 'ITA', '20220320', 704.9),
	('COMP_A', 'FRA', '20220301', 409.1),
	('COMP_A', 'GB',  '20220301', 786),
	('COMP_A', 'ITA', '20220320', 2507.77),

	('COMP_B', 'ITA', '20220110', 0),
	('COMP_B', 'FRA', '20220120', 1024.3),
	('COMP_B', 'ITA', '20220131', 1234.45),
	('COMP_B', 'GB',  '20220202', 352.6),
	('COMP_B', 'ITA', '20220201', 789.87),
	('COMP_B', 'ITA', '20220208', 350.43),
	('COMP_B', 'ITA', '20220321', 1050.6),
	('COMP_B', 'FRA', '20220315', 398.3);
go

select * from dbo.Transactions;
go

--Standard SQL statement
select Company, 
		--Aggregation and spreading phase
		SUM(case when TransactionDate between '20220101' and '20220131' and Region = 'ITA' then Income end) as [January - ITA],
		SUM(case when TransactionDate between '20220101' and '20220131' and Region = 'GB' then Income end) as [January - GB],
		SUM(case when TransactionDate between '20220101' and '20220131' and Region = 'FRA' then Income end) as [January - FRA],
		SUM(case when TransactionDate between '20220201' and '20220228' and Region = 'ITA' then Income end) as [February - ITA],
		SUM(case when TransactionDate between '20220201' and '20220228' and Region = 'GB' then Income end) as [February - GB],
		SUM(case when TransactionDate between '20220201' and '20220228' and Region = 'FRA' then Income end) as [February - FRA],
		SUM(case when TransactionDate between '20220301' and '20220331' and Region = 'ITA' then Income end) as [March - ITA],
		SUM(case when TransactionDate between '20220301' and '20220331' and Region = 'GB' then Income end) as [March - GB],
		SUM(case when TransactionDate between '20220301' and '20220331' and Region = 'FRA' then Income end) as [March - FRA]
from dbo.Transactions
--Grouping phase
group by Company;
go


--What about Pivot ?
select Company, [January - ITA], [January - GB], [January - FRA], 
				[February - ITA], [February - GB], [February - FRA],
				[March - ITA], [March - GB], [March - FRA]
from dbo.Transactions
pivot (
	SUM(Income) for ???  in ([January - ITA], [January - GB], [January - FRA], 
										[February - ITA], [February - GB], [February - FRA],
										[March - ITA], [March - GB], [March - FRA])
	) as p;










select Company, [January - ITA], [January - GB], [January - FRA], 
				[February - ITA], [February - GB], [February - FRA],
				[March - ITA], [March - GB], [March - FRA]
from (select Company, Income, CONCAT_WS(' ', DATENAME(month, TransactionDate), '-', Region) as MonthRegion
	  from dbo.Transactions) te
pivot (
	SUM(Income) for MonthRegion in ([January - ITA], [January - GB], [January - FRA], 
									[February - ITA], [February - GB], [February - FRA],
									[March - ITA], [March - GB], [March - FRA])
	) as p;



