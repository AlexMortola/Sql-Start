------------------------------------------------------------------------
-- Event:        Sql Start! 2025, June 13 2025      				   -
--               https://www.sqlstart.it/                         	   -
-- Session:      Climb up towards Sql Server Statistics				   -
-- Script:       MAXDOP 1 with CXPACKET            	                   -
-- Author:       Alessandro Mortola                                    -
-- Credits:		 Fabiano Amorim	                                       -
------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?', 20, 1) with log;
go

use TestDb;
go

/*
drop table if exists t0;
go

create table t0 (
	id int primary key,
	f1 varchar(250) not null,
	f2 varchar(250) not null,
	);

--20 sec...
insert into t0
select gs.value,
		cast(newid() as varchar(250)),
		cast(newid() as varchar(250))
from generate_series(1, 5000000, 1) gs;
go
*/
go




/*
create statistics St_f1 on t0(f1) with sample 100 percent, persist_sample_percent = on;
create statistics St_f2 on t0(f2) with sample 100 percent, persist_sample_percent = on;
go



begin tran
truncate table t0;
rollback
*/

--



set statistics time on;

/*
	TF 7821 shows the duration of create/update statistics
*/
go
dbcc traceon(3604, 8721) with no_infomsgs
go



--The query !
--Activate the Actual Execution Plan
select distinct f1, f2
from t0
where f1 like 'AB%'
option (maxdop 1);

--Look at
--exec sp_whoisactive @get_task_info = 2
