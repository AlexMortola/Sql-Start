-----------------------------------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                                                      -
--               https://www.sqlstart.it/2022                                                       -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                                                 -
-- Demo:         Pivot - Performace comparison                                                      -
-- Author:       Alessandro Mortola                                                                 -
-- Notes:        --                                                                                 -
-----------------------------------------------------------------------------------------------------

use TestDb;
go

set statistics time on;
go

drop table if exists dbo.Transactions;
go

create table dbo.Transactions(
	Id int identity (1,1) primary key,
	Company varchar(10) not null,
	TransactionDate date not null,
	Income decimal(10,2) null
);
go

declare @nRecs as int = 500000,
		@nComp as int = 100;

with 
Numbers (N) as (select 0 
				union all
				select N + 1
				from Numbers
				where N < @nRecs - 1)

insert into dbo.Transactions 
select 	'COMP_' + cast(a.N1 % @nComp as varchar(2)) as Company, 
		DATEADD(DAY, -1 * (a.N2 % 10), '20220425'),
		CHECKSUM(NewId()) / 1000000.
from Numbers
cross apply (select ABS(CHECKSUM(NewId())) N1, ABS(CHECKSUM(NewId())) N2) a
order by Company
option (maxrecursion 0);

select COUNT(*) from dbo.Transactions;


--Standard
select Company,
	sum(case when TransactionDate = '20220425' then Income end) as [20220425],
	sum(case when TransactionDate = '20220424' then Income end) as [20220424],
	sum(case when TransactionDate = '20220423' then Income end) as [20220423],
	sum(case when TransactionDate = '20220421' then Income end) as [20220422],
	sum(case when TransactionDate = '20220421' then Income end) as [20220421],
	sum(case when TransactionDate = '20220420' then Income end) as [20220420],
	sum(case when TransactionDate = '20220419' then Income end) as [20220419],
	sum(case when TransactionDate = '20220418' then Income end) as [20220418],
	sum(case when TransactionDate = '20220417' then Income end) as [20220417],
	sum(case when TransactionDate = '20220416' then Income end) as [20220416]
from dbo.Transactions
group by Company
order by Company;


--PIVOT
select *
from (select Company, Income, TransactionDate from dbo.Transactions) t
pivot (sum(Income) for TransactionDate in ([20220425],
										   [20220424], 
										   [20220423],
										   [20220422],
										   [20220421],
										   [20220420],
										   [20220419],
										   [20220418],
										   [20220417],
										   [20220416]
										   )
										  ) as p
order by Company;




