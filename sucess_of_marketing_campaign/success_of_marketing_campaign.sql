/* Your marketing department ran a campaign to entice users to make more in-app 
   purchases after they've made their first in-app purchase. The campaign starts 
   a day after their initial purchase with the following considerations: 

1. Don't count any additional purchases on the same initial purchase date 
2. Don't count users that over time purchase only the products they've purchased 
   from their first purchase date.

Find the number of users that made more in-app purchases given these conditions.
*/ 


CREATE TABLE campaigns
(
user_id      int,
purchased_at date,
product_id   int,
price        float,
quantity     int
)


insert into campaigns values (1001, '2025-01-15', 120, 1, 4.99);
insert into campaigns values (1299, '2025-01-15', 105, 3, 9.99);
insert into campaigns values (1039, '2025-01-16', 120, 5, 1.99);
insert into campaigns values (1502, '2025-01-16', 141, 3, 8.00);
insert into campaigns values (1873, '2025-01-16', 156, 4, 7.50);
insert into campaigns values (1627, '2025-01-17', 120, 3, 4.99);
insert into campaigns values (1627, '2025-01-17', 180, 3, 9.00);
insert into campaigns values (1001, '2025-01-18', 120, 3, 5.00);
insert into campaigns values (1873, '2025-01-18', 180, 8, 8.99);
insert into campaigns values (1299, '2025-01-18', 165, 5, 6.50);
insert into campaigns values (1039, '2025-01-18', 130, 4, 2.99);
insert into campaigns values (1099, '2025-01-20', 125, 2, 2.50);
insert into campaigns values (1031, '2025-01-22', 121, 1, 1.99);
insert into campaigns values (1873, '2025-01-22', 129, 1, 1.99);
insert into campaigns values (1031, '2025-01-23', 141, 1, 1.99);
insert into campaigns values (1502, '2025-01-23', 140, 3, 3.00);
insert into campaigns values (1299, '2025-01-23', 139, 4, 6.50);
insert into campaigns values (1627, '2025-01-24', 180, 2, 8.00);
insert into campaigns values (1099, '2025-01-24', 120, 4, 4.99);
insert into campaigns values (1178, '2025-01-25', 101, 5, 9.99);
insert into campaigns values (1031, '2025-01-25', 116, 2, 8.99);
insert into campaigns values (1031, '2025-01-26', 49, 1, 4.99);
insert into campaigns values (1873, '2025-01-26', 46, 1, 6.50);
insert into campaigns values (1099, '2025-01-27', 120, 1, 1.98);
insert into campaigns values (1299, '2025-01-28', 105, 2, 4.98);
insert into campaigns values (1502, '2025-01-28', 127, 5, 12.99);
insert into campaigns values (1299, '2025-01-29', 143, 5, 8.95);
insert into campaigns values (1627, '2025-01-29', 45, 6, 12.00);
insert into campaigns values (1099, '2025-01-30', 88, 2, 6.50);
insert into campaigns values (1509, '2025-01-30', 88, 4, 6.35);
insert into campaigns values (1032, '2025-01-31', 141, 9, 7.99);
insert into campaigns values (1032, '2025-02-01', 120, 8, 6.25);


WITH user_purchase_rank
AS
(
  select user_id, purchased_at, product_id,
    rank() over (partition by user_id order by purchased_at) order_rank
  from campaigns
  order by user_id, purchased_at
),

user_first_date_purchase
as
(
  select user_id, purchased_at, product_id
  from user_purchase_rank
  where order_rank = 1
),

valid_campaign_purchases_after_initial_purchase
as
( 
  select u.user_id, u.purchased_at, u.product_id,
         f.purchased_at first_purchased_at, f.product_id first_product_id
  from user_purchase_rank u
  join user_first_date_purchase f
  on u.user_id = f.user_id
  where f.purchased_at < u.purchased_at
  and f.product_id != u.product_id
)

select user_id
from valid_campaign_purchases_after_initial_purchase;

select distinct(user_id)
from valid_campaign_purchases_after_initial_purchase;

select count(distinct(user_id))
from valid_campaign_purchases_after_initial_purchase;
