/* Customer Daily Spend

Find the customer with the highest daily total order cost between 2024-12-01 to 2024-12-25. 
If customer had more than one order on a certain day, sum the order costs on daily basis.  

Q1. Which customer had the maximum daily spend amongst all the customers within this period?
    Output customer's id, first name, total cost of their items, and the transaction date (result is one row)

Q2. Output each customer's date and the transaction date of their highest daily spend 
    Results are multiple rows, one for each customer if they've purchased anything within this period
*/

CREATE TABLE customers
(id int,
 first_name varchar(10),
 last_name varchar(10),
 city varchar(20)
 );

insert into customers values (10, 'Avril', 'Bean',  'Phoenix');
insert into customers values (11, 'Bonnie', 'Cecil', 'Austin');
insert into customers values (12, 'Bill', 'Johnson', 'Miami');
insert into customers values (13, 'Troy', 'Pitt', 'New York');
insert into customers values (14, 'Freida', 'Scott', 'San Diego');
insert into customers values (15, 'Mary', 'William', 'Dallas');

CREATE TABLE orders
(id int,
cust_id int,
txn_date date,
txn_details varchar(20),
txn_cost float
);

insert into orders values (1, 11, '2024-12-02', 'TV', 399.50);
insert into orders values (2, 12, '2024-12-04', 'Lounger', 275.00);
insert into orders values (3, 11, '2024-12-05', 'Chargers', 25.00);
insert into orders values (4, 11, '2024-12-05', 'Cables', 65.00);
insert into orders values (5, 14, '2024-12-09', 'Towels', 45.75);
insert into orders values (6, 13, '2024-12-10', 'Luggage', 219.00);
insert into orders values (7, 10, '2024-12-10', 'Books', 69.50);
insert into orders values (8, 14, '2024-12-11', 'Sheets', 99.99);
insert into orders values (9, 14, '2024-12-11', 'Pillows', 89.00);
insert into orders values (10, 14, '2024-12-12', 'Speakers', 350.79);
insert into orders values (11, 10, '2024-12-15', 'Coats', 139.99);
insert into orders values (12, 13, '2024-12-17', 'Dresses', 190.00);
insert into orders values (13, 13, '2024-12-17', 'Skiis', 230.50);
insert into orders values (14, 10, '2024-12-19', 'Shirts', 45.00);
insert into orders values (15, 14, '2024-11-20', 'Heater', 628.00);
insert into orders values (16, 12, '2024-12-24', 'Gifts', 409.20);
insert into orders values (17, 15, '2024-12-28', 'Sofa', 1250.85);
insert into orders values (18, 10, '2024-12-26', 'Bed', 525.90);
insert into orders values (19, 12, '2024-12-29', 'Swing Set', 867.59);


/* Answer to Question 1 */

select c.id, c.first_name, o.txn_date, 
       count(*) as txn_cnt,
       sum(txn_cost) as total_txn_cost
from customers c
join orders o
on c.id = o.cust_id
where o.txn_date between '2024-12-01' and '2024-12-25'
group by 1, 2, 3
order by total_txn_cost desc
limit 1;


/* Answer to Question 2 */

WITH daily_spend
as
(select o.order_date, c.id, c.first_name, c.last_name,
       sum(o.total_order_cost) as total_daily_cost
from customers c
join orders o
on c.id = cust_id
where order_date between '2019-02-01' and '2019-05-02'
group by 1, 2, 3, 4
),

spend_and_rank
as
(
select id, first_name, last_name, total_daily_cost, order_date, 
   rank() over (order by total_daily_cost desc) as customer_spend_rank
from daily_spend
group by 1, 2, 3, 4, 5
order by 1, 2, 3, 4
)

select first_name, order_date, total_daily_cost as max_cost
from spend_and_rank
where customer_spend_rank = 1;
