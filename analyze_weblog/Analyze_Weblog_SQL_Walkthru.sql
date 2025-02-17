/* Analyze Weblogs

We are asked to calculate the user's average session time.
A session is defined as a time between a load event and an exit event.
In case if there are multiple load and exit events per day, 
use the latest load and the earliest exit event so that we ensure
that a load event happens before an exit event.

Output is the user_id and their average session time in seconds. */

create table weblog
(user_id int,
 txn_ts timestamp,
 event varchar(10));
 
insert into weblog values (101, '2025-01-02 08:05:00', 'load');
insert into weblog values (101, '2025-01-02 08:15:15', 'load');
insert into weblog values (101, '2025-01-02 08:17:07', 'scroll');
insert into weblog values (101, '2025-01-02 08:19:19', 'click');
insert into weblog values (101, '2025-01-02 08:25:33', 'exit');

insert into weblog values (101, '2025-01-05 14:45:54', 'load');
insert into weblog values (101, '2025-01-05 14:46:30', 'click');
insert into weblog values (101, '2025-01-05 14:48:45', 'scroll');
insert into weblog values (101, '2025-01-05 14:48:22', 'exit');
insert into weblog values (101, '2025-01-05 14:57:12', 'exit');

insert into weblog values (102, '2025-01-03 12:05:34', 'load');
insert into weblog values (102, '2025-01-03 12:09:58', 'load');
insert into weblog values (102, '2025-01-03 12:12:11', 'load');
insert into weblog values (102, '2025-01-03 12:18:09', 'click');
insert into weblog values (102, '2025-01-03 13:34:34', 'exit');
insert into weblog values (102, '2025-01-03 15:59:01', 'exit');

insert into weblog values (103, '2025-01-04 19:12:09', 'load');
insert into weblog values (103, '2025-01-04 19:15:38', 'load');
insert into weblog values (103, '2025-01-04 19:35:11', 'load');
insert into weblog values (103, '2025-01-04 21:07:14', 'exit');


/* Answer */

WITH user_login
as
(select user_id, date(txn_ts) as event_date, max(txn_ts) as last_login
from weblog
where event = 'load'
group by 1, 2
), 

user_logout
as
(select user_id, date(txn_ts) as event_date, min(txn_ts) as first_exit
from weblog
where event = 'exit'
group by 1, 2
),

user_session
as
(select a.user_id, a.event_date, last_login, first_exit,
   (first_exit - last_login) as duration,
   EXTRACT (EPOCH FROM (first_exit - last_login)) as duration_in_sec
from user_login a
join user_logout b
on a.user_id = b.user_id
and a.event_date = b.event_date
)

select user_id, (avg(duration_in_sec))::decimal(15,2) as avg_session_in_seconds
from user_session
group by user_id;