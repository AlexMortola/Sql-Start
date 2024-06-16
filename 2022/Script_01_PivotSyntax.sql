------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                         -
--               https://www.sqlstart.it/2022                          -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                    -
-- Demo:         How to pivot data with both SQL Standard syntax and   -
--               T-SQL PIVOT operator                                  -
-- Author:       Alessandro Mortola                                    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

use tempdb
go

drop database if exists TestDb;
go

create database TestDb;
go

use TestDb;
go

drop table if exists dbo.Transactions;
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
	('COMP_B', '2022 - Mar', 1050.6);
go

select * from dbo.Transactions;
go

--Standard SQL statement
select Company, 
		--Aggregation and spreading phase
		sum(case Interval when '2022 - Jan' then Income end) as '2022 - Jan',
		sum(case Interval when '2022 - Feb' then Income end) as '2022 - Feb',
		sum(case Interval when '2022 - Mar' then Income end) as '2022 - Mar'
from dbo.Transactions
--Grouping phase
group by Company;
go





--Pivot operator
select * --Company, [2022 - Jan], [2022 - Feb], [2022 - Mar]
from dbo.Transactions t
pivot (
	--Aggregation phase
	SUM(Income) 
	--Spreading phase
	for Interval in ([2022 - Jan], [2022 - Feb], [2022 - Mar])
	) as p;
go




--What if I add another field to the table?
alter table dbo.Transactions add Id int identity(1,1);
go

--What if I carried out the above statements? 


