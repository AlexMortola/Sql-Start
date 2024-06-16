-----------------------------------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                                                      -
--               https://www.sqlstart.it/2022                                                       -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                                                 -
-- Demo:         Question n° 4 - Is it possible to use more than one Aggregation Function 			-
--               on the same column or to use the same Aggregation Function on different columns?   -
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
	Income decimal(10,2) null,
	Expenses decimal(10,2) null
);
go

insert into dbo.Transactions values 
	('COMP_A', '20220110', 1045.25, 589),
	('COMP_A', '20220110', 534.98, 0),
	('COMP_A', '20220201', 150, 100.5),
	('COMP_A', '20220201', 1511.55, 506.2),
	('COMP_A', '20220208', 0, 234),
	('COMP_A', '20220320', 704.9, 490.9),
	('COMP_A', '20220320', 2507.77, 710.3),

	('COMP_B', '20220110', 0, 90.5),
	('COMP_B', '20220131', 1234.45, 948.12),
	('COMP_B', '20220201', 789.87, 123),
	('COMP_B', '20220208', 350.43, 209),
	('COMP_B', '20220321', 1050.6, 90);
go

select * from dbo.Transactions;
go

--Standard SQL statement
select Company, 
		sum(case when TransactionDate between '20220101' and '20220131' then Income end) as [SUM Income - Jan],
		avg(case when TransactionDate between '20220101' and '20220131' then Income end) as [AVG Income - Jan],
		sum(case when TransactionDate between '20220101' and '20220131' then Expenses end) as [SUM Expenses - Jan],
		avg(case when TransactionDate between '20220101' and '20220131' then Expenses end) as [AVG Expenses - Jan],
		sum(case when TransactionDate between '20220201' and '20220228' then Income end) as [SUM Income - Feb],
		avg(case when TransactionDate between '20220201' and '20220228' then Income end) as [AVG Income - Feb],
		sum(case when TransactionDate between '20220201' and '20220228' then Expenses end) as [SUM Expenses - Feb],
		avg(case when TransactionDate between '20220201' and '20220228' then Expenses end) as [AVG Expenses - Feb],
		sum(case when TransactionDate between '20220301' and '20220331' then Income end) as [SUM Income - Mar],
		avg(case when TransactionDate between '20220301' and '20220331' then Income end) as [AVG Income - Mar],
		sum(case when TransactionDate between '20220301' and '20220331' then Expenses end) as [SUM Expenses - Mar],
		avg(case when TransactionDate between '20220301' and '20220331' then Expenses end) as [AVG Expenses - Mar]
from dbo.Transactions
group by Company;
go


--What about Pivot ?

select *
from dbo.Transactions
PIVOT (SUM(Income) FOR TransactionDate in (/*TODO*/));



--Is this a good solution?
with 
SumIncome as (select Company, [January] as [SUM Income - Jan], [February] as [SUM Income - Feb], [March] as [SUM Income - Mar]
				from (select Company, Income, DATENAME(MONTH, TransactionDate) as MonthTransactionDate
					  from dbo.Transactions) te
					  pivot (SUM(Income) for MonthTransactionDate in ([January], [February], [March])) as p),

AvgIncome as (select Company, [January] as [AVG Income - Jan], [February] as [AVG Income - Feb], [March] as [AVG Income - Mar]
				from (select Company, Income, DATENAME(MONTH, TransactionDate) as MonthTransactionDate
					  from dbo.Transactions) te
				      pivot (AVG(Income) for MonthTransactionDate in ([January], [February], [March])) as p),

SumExpenses as (select Company, [January] as [SUM Expenses - Jan], [February] as [SUM Expenses - Feb], [March] as [SUM Expenses - Mar]
				from (select Company, Expenses, DATENAME(MONTH, TransactionDate) as MonthTransactionDate
					  from dbo.Transactions) te
				      pivot (SUM(Expenses) for MonthTransactionDate in ([January], [February], [March])) as p),

AvgExpenses as (select Company, [January] as [AVG Expenses - Jan], [February] as [AVG Expenses - Feb], [March] as [AVG Expenses - Mar]
				from (select Company, Expenses, DATENAME(MONTH, TransactionDate) as MonthTransactionDate
					  from dbo.Transactions) te
				      pivot (AVG(Expenses) for MonthTransactionDate in ([January], [February], [March])) as p)

select si.Company, 
		si.[SUM Income - Jan], ai.[AVG Income - Jan], so.[SUM Expenses - Jan], ao.[AVG Expenses - Jan], 
		si.[SUM Income - Feb], ai.[AVG Income - Feb], so.[SUM Expenses - Feb], ao.[AVG Expenses - Feb],
		si.[SUM Income - Mar], ai.[AVG Income - Mar], so.[SUM Expenses - Mar], ao.[AVG Expenses - Mar]
from SumIncome si
inner join AvgIncome ai on ai.Company = si.Company
inner join SumExpenses so on so.Company = si.Company
inner join AvgExpenses ao on ao.Company = si.Company;
go




--Alternative solution using Standard SQL statement - Shorter code
drop table if exists Matrix;
go

create table Matrix(
	transactionMonth varchar(20),
	mJanuary int,
	mFebruary int,
	mMarch int);
go

insert into Matrix (transactionMonth, mJanuary) values ('January', 1);
insert into Matrix (transactionMonth, mFebruary) values ('February', 1);
insert into Matrix (transactionMonth, mMarch) values ('March', 1);

select * from Matrix;

--Compute SUM per month
select tr.Company,
	SUM(tr.Income * m.mJanuary) as [SUM Income - Jan],
	SUM(tr.Income * m.mFebruary) as [SUM Income - Feb],
	SUM(tr.Income * m.mMarch) as [SUM Income - Mar]
from (select Company, DATENAME(month, TransactionDate) transactionMonth, Income, Expenses
      from Transactions) tr
inner join Matrix m on tr.transactionMonth = m.transactionMonth
group by tr.Company;


--The complete solution
select tr.Company,
	SUM(tr.Income * m.mJanuary) as [SUM Income - Jan],
	AVG(tr.Income * m.mJanuary) as [AVG Income - Jan],
	SUM(tr.Expenses * m.mJanuary) as [SUM Expenses - Jan],
	AVG(tr.Expenses * m.mJanuary) as [AVG Expenses - Jan],

	SUM(tr.Income * m.mFebruary) as [SUM Income - Feb],
	AVG(tr.Income * m.mFebruary) as [AVG Income - Feb],
	SUM(tr.Expenses * m.mFebruary) as [SUM Expenses - Feb],
	AVG(tr.Expenses * m.mFebruary) as [AVG Expenses - Feb],

	SUM(tr.Income * m.mMarch) as [SUM Income - Mar],
	AVG(tr.Income * m.mMarch) as [AVG Income - Mar],
	SUM(tr.Expenses * m.mMarch) as [SUM Expenses - Mar],
	AVG(tr.Expenses * m.mMarch) as [AVG Expenses - Mar]
from (select Company, DATENAME(month, TransactionDate) transactionMonth, Income, Expenses
      from Transactions) tr
inner join Matrix m on tr.transactionMonth = m.transactionMonth
group by tr.Company;







