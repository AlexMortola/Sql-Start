-----------------------------------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                                                      -
--               https://www.sqlstart.it/2022                                                       -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                                                 -
-- Demo:         Unpivot - Performance comparison                                                   -
-- Author:       Alessandro Mortola                                                                 -
-- Notes:        --                                                                                 -
-----------------------------------------------------------------------------------------------------

use TestDb
go

set statistics time on;
go

drop table if exists dbo.pTransactions;
go

declare @nRecs as int = 100000,
		@nComp as int = 100;

with 
Numbers (N) as (select 0 
				union all
				select N + 1
				from Numbers
				where N < @nRecs - 1)


select 	'COMP_' + cast(a.N1 % @nComp as varchar(2)) as Company, 
		CHECKSUM(NewId()) / 1000000. as spCol1,
		CHECKSUM(NewId()) / 1000000. as spCol2,
		CHECKSUM(NewId()) / 1000000. as spCol3,
		CHECKSUM(NewId()) / 1000000. as spCol4,
		CHECKSUM(NewId()) / 1000000. as spCol5,
		CHECKSUM(NewId()) / 1000000. as spCol6,
		CHECKSUM(NewId()) / 1000000. as spCol7,
		CHECKSUM(NewId()) / 1000000. as spCol8,
		CHECKSUM(NewId()) / 1000000. as spCol9,
		CHECKSUM(NewId()) / 1000000. as spCol10
into dbo.pTransactions
from Numbers
cross apply (select ABS(CHECKSUM(NewId())) N1, ABS(CHECKSUM(NewId())) N2) a
order by Company
option (maxrecursion 0);

select top 100 * from dbo.pTransactions;
select COUNT(*) from dbo.pTransactions;
go

----------------------------
--"Standard"
----------------------------
select Company, ap.ColType, ap.Value
from dbo.pTransactions pt
cross apply (values ('Col1', pt.spCol1),
					('Col2', pt.spCol2), 
					('Col3', pt.spCol3),
					('Col4', pt.spCol4),
					('Col5', pt.spCol5),
					('Col6', pt.spCol6),
					('Col7', pt.spCol7),
					('Col8', pt.spCol8),
					('Col9', pt.spCol9),
					('Col10', pt.spCol10)
					) ap(ColType, Value);


----------------------------
--T-SQL UNPIVOT Operator
----------------------------
select Company, Value, ColType
from dbo.pTransactions
unpivot (Value for ColType in ([spCol1], [spCol2], [spCol3], [spCol4], [spCol5], [spCol6], [spCol7], [spCol8], [spCol9], [spCol10])) u;

