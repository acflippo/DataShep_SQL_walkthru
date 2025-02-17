/* Popularity of the platform for video calls challenge.  The following is a social media company that offers 
video calls amongst other services on their platform. A video call events are 'video call started' and 'video call received'.

# Part 1
The goal of this query is to select the most popular client_type for the platform

# Part 2
The goal of this query is to select the most popular client_type for each user based on the usage percentage on the events of  'video call started', 'video call received'. */


create table events
(
id          int,
event_date  date,
user_id     int,
client_type text,
event_type  text
);

insert into events values (1, '2025-02-01', 801, 'watch', 'video call started');
insert into events values (2, '2025-02-01', 802, 'desktop', 'video call started');
insert into events values (3, '2025-02-01', 802, 'desktop', 'video call received');
insert into events values (4, '2025-02-02', 801, 'watch', 'video call received');
insert into events values (5, '2025-02-03', 801, 'desktop', 'file received');
insert into events values (6, '2025-02-02', 801, 'desktop', 'voice mail sent');
insert into events values (7, '2025-02-02', 805, 'desktop', 'voice call started');
insert into events values (8, '2025-02-02', 804, 'mobile', 'voice mail received');
insert into events values (9, '2025-02-02', 801, 'desktop', 'file received');
insert into events values (10, '2025-02-03', 804, 'mobile', 'file sent');
insert into events values (11, '2025-02-03', 801, 'mobile', 'voice mail received');
insert into events values (12, '2025-02-03', 801, 'desktop', 'video call started');
insert into events values (13, '2025-02-03', 802, 'mobile', 'voice mail received');
insert into events values (14, '2025-02-03', 801, 'watch', 'file sent');
insert into events values (15, '2025-02-04', 805, 'desktop', 'voice call received');
insert into events values (16, '2025-02-04', 801, 'desktop', 'api request');
insert into events values (17, '2025-02-04', 801, 'mobile', 'voice mail sent');
insert into events values (18, '2025-02-04', 802, 'watch', 'video call started');
insert into events values (19, '2025-02-04', 803, 'mobile', 'video call started');
insert into events values (20, '2025-02-06', 801, 'mobile', 'video call started');
insert into events values (21, '2025-02-03', 801, 'mobile', 'file sent');
insert into events values (22, '2025-02-03', 803, 'mobile', 'file received');
insert into events values (23, '2025-02-06', 805, 'mobile', 'voice call started');
insert into events values (24, '2025-02-07', 802, 'mobile', 'video call received');
insert into events values (25, '2025-02-07', 805, 'desktop', 'voice mail sent');
insert into events values (26, '2025-02-07', 803, 'watch', 'video call started');
insert into events values (27, '2025-02-08', 804, 'watch', 'video call received');
insert into events values (28, '2025-02-06', 805, 'mobile', 'video call started');
insert into events values (29, '2025-02-03', 805, 'mobile', 'file sent');
insert into events values (30, '2025-02-03', 801, 'watch', 'file received');
insert into events values (31, '2025-02-06', 802, 'mobile', 'video call received');
insert into events values (32, '2025-02-07', 804, 'mobile', 'video call received');
insert into events values (33, '2025-02-07', 805, 'mobile', 'video call received');
insert into events values (34, '2025-02-07', 803, 'mobile', 'voice call started');
insert into events values (35, '2025-02-08', 804, 'watch', 'video call received');



#######################################################################################
# Part 1
# The goal of this query is to select the most popular client_type for the platform
#######################################################################################

select client_type,
  SUM(CASE WHEN event_type in ('video call started', 'video call received') THEN 1 ELSE 0 END) as video_call_counts,
  count(*) n_count
from events
group by client_type
order by video_call_counts desc;



#######################################################################################
# Part 2
# The goal of this query is to select the most popular client_type for each user based on the 
# usage percentage on the events of  'video call started', 'video call received'.
#######################################################################################


WITH user_platform_usage
AS
(select user_id, client_type, 
  SUM(CASE WHEN event_type in ('video call started', 'video call received') THEN 1 ELSE 0 END) video_count,
  count(*) n_count, 
  SUM(CASE WHEN event_type in ('video call started', 'video call received') THEN 1 ELSE 0 END) * 1.0 / count(*) as platform_pct
from events
group by user_id, client_type
),

user_client_preference
as
(
select user_id, client_type, platform_pct, 
       rank() over (partition by user_id order by platform_pct desc) as order_rank
from user_platform_usage
)

select user_id, client_type
from user_client_preference
where order_rank = 1;
