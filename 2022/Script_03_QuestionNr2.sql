---------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                            -
--               https://www.sqlstart.it/2022                             -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                       -
-- Demo:         Question n° 2 - Is it possible to filter by using either -
--               the aggregate Column or the spreading Column?            -
-- Author:       Alessandro Mortola                                       -
-- Notes:        --                                                       -
---------------------------------------------------------------------------

use TestDb;
go


select * from dbo.Transactions;
go

--Standard SQL statement
select Company, 
		sum(case when TransactionDate = '20220110' then Income end) as [20220110],
		sum(case when TransactionDate = '20220131' then Income end) as [20220131],
		sum(case when TransactionDate = '20220201' then Income end) as [20220201],
		sum(case when TransactionDate = '20220208' then Income end) as [20220208],
		sum(case when TransactionDate = '20220320' then Income end) as [20220320],
		sum(case when TransactionDate = '20220321' then Income end) as [20220321]
from dbo.Transactions
where TransactionDate > '20220105' and Income > 50
group by Company;
go


--What about Pivot ?
select Company, [20220110], [20220131], [20220201], [20220208], [20220320], [20220321]
from dbo.Transactions
pivot (
	SUM(Income) for TransactionDate in ([20220110], [20220131], [20220201], [20220208], [20220320], [20220321])
	) as p

;
