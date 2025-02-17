/* Here is our social media user accounts, answer the questions below.  

1. Find share of active voice for USA.

2. In one query, find the share of active voice for every country

Share of voice is the total active accounts divided by total accounts for that country
*/

CREATE table users
(user_id int,
name varchar(40),
status varchar(10),
country varchar(20));

insert into users values (10, 'Brad Pitt', 'open', 'USA');
insert into users values (11, 'Nicole Kidman', 'closed', 'Australia');
insert into users values (12, 'Mike Myers', 'open', 'Canada');
insert into users values (13, 'Chris Hemsworth', 'open', 'Australia');
insert into users values (14, 'Morgan Freman', 'closed', 'USA');
insert into users values (15, 'Keanu Reeves', 'open', 'USA');
insert into users values (16, 'Winona Ryder', 'open', 'USA');
insert into users values (17, 'Jackie Chan', 'open', 'China');
insert into users values (18, 'Dwayne Johnsn', 'closed', 'USA');
insert into users values (19, 'Hugh Jackman', 'open', 'Australia');
insert into users values (20, 'Jimin', 'open', 'South Korea');
insert into users values (21, 'Song Kan', 'closed', 'South Korea');
insert into users values (22, 'Lee Kang-in', 'open', 'South Korea');
insert into users values (23, 'Takeshi Kitano', 'closed', 'Japan');
insert into users values (24, 'Yoko Ono', 'closed', 'Japan');
insert into users values (25, 'Ken Watanabe', 'open', 'Japan');
insert into users values (26, 'Emma Stone', 'open', 'USA');
insert into users values (27, 'Meg Ryan', 'closed', 'USA');
insert into users values (28, 'Jason Momoa', 'open', 'USA');
insert into users values (29, 'Harrison Ford', 'closed', 'USA');
insert into users values (30, 'Anna Kendrick', 'open', 'USA');
insert into users values (31, 'Matt Damon', 'closed', 'USA');
insert into users values (32, 'Kristen Bell', 'closed', 'USA');
insert into users values (35, 'Chris Pratt', 'open', 'USA');
insert into users values (36, 'Zoe Saldana', 'closed', 'USA');
insert into users values (37, 'Chadwick Boseman', 'open', 'USA');
insert into users values (38, 'Damon Wayans Jr.', 'open', 'USA');
insert into users values (39, 'Mark Ruffalo', 'closed', 'USA');
insert into users values (40, 'Keith Urban', 'open', 'Australia');
insert into users values (41, 'Eric Bana', 'closed', 'Australia');
insert into users values (42, 'Bae Suzy', 'open', 'South Korea');
insert into users values (43, 'Lee Min-ho', 'open', 'South Korea');
insert into users values (44, 'Bai Ling', 'open', 'China');
insert into users values (45, 'Michelle Yeoh', 'open', 'Malaysia');
insert into users values (46, 'Henry Golding', 'open', 'Malaysia');
insert into users values (47, 'Amber Chia', 'closed', 'Malaysia');
insert into users values (48, 'Drake', 'open', 'Canada');
insert into users values (49, 'Celine Dion', 'closed', 'Canada');
insert into users values (50, 'Ray Gosling', 'open', 'Canada');
insert into users values (51, 'Jet Li', 'open', 'China');
insert into users values (52, 'William Chan', 'closed', 'China');


/* Solution 1 - many lines of code */

WITH all_users
as
(select count(*) as all_users
from users
where country = 'USA'
),

active_users
as
(select count(*) as active_users
from users
where country = 'USA'
  and status = 'open'
)

select active_users, all_users, active_users::float / all_users
from active_users x
cross join all_users a;



/* Solution 2 - share of active voice for the USA */

SELECT num_active_users::float / total_users
FROM 
(select SUM(CASE when status = 'open' THEN 1 ELSE 0 END) as num_active_users,
       count(*) as total_users
from users
where country='USA')



/* Solution 3 - share of active voice for all countries */

SELECT country, (num_active_users::float / total_users)::decimal(9,4)
FROM 
(select country, SUM(CASE when status = 'open' THEN 1 ELSE 0 END) as num_active_users,
       count(*) as total_users
from users
group by country
)
order by 2 desc;

