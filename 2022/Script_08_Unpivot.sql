-----------------------------------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                                                      -
--               https://www.sqlstart.it/2022                                                       -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                                                 -
-- Demo:         Unpivot                                                                            -
-- Author:       Alessandro Mortola                                                                 -
-- Notes:        --                                                                                 -
-----------------------------------------------------------------------------------------------------

use TestDb;
go

drop table if exists dbo.Transactions;
go

drop table if exists dbo.pTransactions;
go

create table dbo.Transactions(
	Company char(6) not null,
	Interval varchar(10) not null,
	Income decimal(10,2) null
);
go

insert into dbo.Transactions values 
	('COMP_A', '2022 - Jan', 1045.25),
	('COMP_A', '2022 - Jan', 534.98),
	('COMP_A', '2022 - Feb', 150),
	('COMP_A', '2022 - Feb', 1511.55),
	('COMP_A', '2022 - Feb', 0),
	('COMP_A', '2022 - Mar', 704.9),
	('COMP_A', '2022 - Mar', 2507.77),

	('COMP_B', '2022 - Jan', 0),
	('COMP_B', '2022 - Jan', 1234.45),
	('COMP_B', '2022 - Feb', 789.87),
	('COMP_B', '2022 - Feb', 350.43),
	('COMP_B', '2022 - Mar', 1050.6),
	('COMP_B', '2022 - Dec', 999.99);
go

select * from dbo.Transactions;
go



select Company, [2022 - Jan], [2022 - Feb], [2022 - Mar], [2022 - Dec]
into dbo.pTransactions
from dbo.Transactions
pivot (
	SUM(Income) for Interval in ([2022 - Jan], [2022 - Feb], [2022 - Mar], [2022 - Dec])
	) as p;
go

select * from dbo.pTransactions;

----------------------------
--"Standard"
----------------------------
select Company, ap.Interval, ap.Income
from dbo.pTransactions pt
cross apply (values ('2022 - Jan', pt.[2022 - Jan]),
					('2022 - Feb', pt.[2022 - Feb]), 
					('2022 - Mar', pt.[2022 - Mar]),
					('2022 - Dec', pt.[2022 - Dec])) ap(Interval, Income);




----------------------------
--T-SQL UNPIVOT Operator
----------------------------

select Company, Interval, Income
from dbo.pTransactions
unpivot (Income for Interval in ([2022 - Jan], [2022 - Feb], [2022 - Mar], [2022 - Dec])) u;
go


----------------------------
--What about NULL values?
----------------------------

with
C as (select Company, 
			ISNULL([2022 - Jan], -1.0) as [2022 - Jan], 
			ISNULL([2022 - Feb], -1.0) as [2022 - Feb], 
			ISNULL([2022 - Mar], -1.0) as [2022 - Mar], 
			ISNULL([2022 - Dec], -1.0) as [2022 - Dec]
		from dbo.pTransactions)
select Company, NULLIF(Income, -1.0) as Income, Interval
from C
unpivot (Income for Interval in ([2022 - Jan], [2022 - Feb], [2022 - Mar], [2022 - Dec])) u;

