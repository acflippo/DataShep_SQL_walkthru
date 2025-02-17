/* Identify returning active users by finding users who made a 
second purchase within 7 days of any previous purchase. 
Output a list of these user_ids */

CREATE TABLE txns
(id int,
user_id int,
txn_date date,
item text,
revenue float
);

insert into txns values (1, 101, '2024-07-01', 'tape', 3.99);
insert into txns values (2, 102, '2024-07-01', 'beans', 4.75);
insert into txns values (3, 105, '2024-07-02', 'apples', 1.99);
insert into txns values (4, 104, '2024-07-03', 'kale', 4.50);
insert into txns values (5, 103, '2024-07-04', 'beer', 11.99);
insert into txns values (6, 106, '2024-07-04', 'chips', 4.50);
insert into txns values (7, 110, '2024-07-04', 'diapers', 11.78);
insert into txns values (8, 109, '2024-07-04', 'pizzas', 25.75);
insert into txns values (9, 107, '2024-07-04', 'banana', 2.99);
insert into txns values (10, 108, '2024-07-05', 'eggs', 6.99);
insert into txns values (11, 102, '2024-07-07', 'crackers', 4.70);
insert into txns values (12, 105, '2024-07-09', 'cookies', 6.75);
insert into txns values (13, 104, '2024-07-10', 'tape', 4.25);
insert into txns values (14, 105, '2024-07-11', 'kale', 4.50);
insert into txns values (15, 103, '2024-07-11', 'beer', 11.99);
insert into txns values (16, 106, '2024-07-11', 'chips', 4.50);
insert into txns values (17, 109, '2024-07-11', 'pizzas', 25.75);
insert into txns values (18, 110, '2024-07-12', 'cheese', 5.80);
insert into txns values (19, 107, '2024-07-13', 'banana', 2.99);
insert into txns values (20, 108, '2024-07-14', 'cookies', 6.99);
insert into txns values (21, 101, '2024-07-14', 'crackers', 4.70);
insert into txns values (22, 105, '2024-07-14', 'carrots', 3.25);
insert into txns values (23, 106, '2024-07-15', 'tape', 4.25);
insert into txns values (24, 109, '2024-07-15', 'kale', 4.50);
insert into txns values (25, 102, '2024-07-15', 'beer', 11.99);
insert into txns values (26, 109, '2024-07-16', 'chips', 4.50);
insert into txns values (27, 110, '2024-07-17', 'pizzas', 21.75);
insert into txns values (28, 107, '2024-07-21', 'cheese', 5.80);
insert into txns values (29, 108, '2024-07-22', 'banana', 2.99);
insert into txns values (30, 101, '2024-07-28', 'cookies', 6.99);

/* Solution 1 - self join */

select distinct user_id
from
(select t1.user_id, t1.txn_date, t2.txn_date,
       t1.txn_date - t2.txn_date as day_diff
from txns t1
join txns t2
on t1.user_id = t2.user_id
and t1.txn_date != t2.txn_date
where abs(t1.txn_date - t2.txn_date) <= 7
) 

/* Solution 2 - Using a lag() window function */

WITH user_ordered_txns
as
(select t1.user_id, t1.txn_date, 
  lag(t1.txn_date) over (partition by user_id order by txn_date) as prev_txn_date,
  t1.txn_date - lag(t1.txn_date) over (partition by user_id order by txn_date) as day_diff
from txns t1
)

select distinct user_id
from user_ordered_txns
where day_diff <= 7
