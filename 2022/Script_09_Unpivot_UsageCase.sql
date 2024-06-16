-----------------------------------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                                                      -
--               https://www.sqlstart.it/2022                                                       -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                                                 -
-- Demo:         Unpivot - A usage case                                                                           -
-- Author:       Alessandro Mortola                                                                 -
-- Notes:        --                                                                                 -
-----------------------------------------------------------------------------------------------------

use TestDb;
go

select * from dbo.pTransactions;
go


--How to compute the lowest and the highest values for each company?







--Using the T-SQL UNPIVOT operator
select Company, MIN(Val) MinValue, MAX(Val) MaxValue
from dbo.pTransactions t
unpivot (Val for Interval in ([2022 - Jan], [2022 - Feb], [2022 - Mar], [2022 - Dec])) as u
group by Company;








--Using only CROSS APPLY
select t.Company, MIN(intervalValue.Val) MinValue, MAX(intervalValue.Val) MaxValue
from dbo.pTransactions t
cross apply (values (t.[2022 - Jan]), (t.[2022 - Feb]), (t.[2022 - Mar]), (t.[2022 - Dec])) as intervalValue(Val)
group by t.Company;
						










--STARTING FROM SQL Server 2022 
select t.Company, 
		LEAST(t.[2022 - Jan], t.[2022 - Feb], t.[2022 - Mar], t.[2022 - Dec]) as MinValue,
		GREATEST(t.[2022 - Jan], t.[2022 - Feb], t.[2022 - Mar], t.[2022 - Dec]) as MaxValue
from dbo.pTransactions t;
				
