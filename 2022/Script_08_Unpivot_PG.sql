-----------------------------------------------------------------------------------------------------
-- Event:        SQL Start! 2022, June 10 2022                                                      -
--               https://www.sqlstart.it/2022                                                       -
-- Session:      T-SQL Pivot (and Unpivot) unveiled                                                 -
-- Demo:         Unpivot - PostgreSQL                                                               -
-- Author:       Alessandro Mortola                                                                 -
-- Notes:        --                                                                                 -
-----------------------------------------------------------------------------------------------------

select version();

drop table if exists public.pTransactions;

create table public.pTransactions (
	company char(6) not null,
	"2022 - Jan" decimal(10, 2),
	"2022 - Feb" decimal(10, 2),
	"2022 - Mar" decimal(10, 2),
	"2022 - Dec" decimal(10, 2)
);

insert into public.pTransactions values
('COMP_A', 1580.23, 1661.55, 3212.67, NULL),
('COMP_B', 1234.45, 1140.30, 1050.60, 999.99);

select * from public.pTransactions;

select Company, ap.Interval, ap.Income
from public.pTransactions pt
inner join lateral (values 
					('2022 - Jan', pt."2022 - Jan"),
					('2022 - Feb', pt."2022 - Feb"), 
					('2022 - Mar', pt."2022 - Mar"),
					('2022 - Dec', pt."2022 - Dec")) ap(Interval, Income) on true;
				

