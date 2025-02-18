/* Powerful Window Functions in Postgresql */

/* Reference: https://www.postgresql.org/docs/current/functions-window.html */

/* Answer the following questions using Postgresql and window functions

   1. What is the current employee list and their department name?
   2. What is the current salary for every employee?
   3. Create a list of employee and their current salary, their department average 
      salary and the company's average salary in one row for every employee. Create 
      a flag if a person's current salary is higher than the company's average salary.
   4. Create a list of employees with their starting salary and ending salary,
      and how many raises he or she has received since their initial salary.
   5. Lastly, how many days have past since their last salary change from today.
*/

CREATE TABLE employee
(
emp_id int,
fname  text,
title  text,
dept_id int,
mgr_id int);

insert into employee values (101, 'Anna', 'CEO', 100, Null);
insert into employee values (102, 'Rick', 'Accounting Manager', 400, 101);
insert into employee values (103, 'Zoey', 'Financial Analyst', 400, 102);
insert into employee values (104, 'Jane', 'Senior Manager of Engineering', 500, 101);
insert into employee values (105, 'Caleb', 'Software Engineer', 500, 104);
insert into employee values (106, 'Nelly', 'Q/A Engineer', 500, 104);
insert into employee values (107, 'Emma', 'Director of HR', 300, 101);
insert into employee values (108, 'Ian', 'HR Analyst', 300, 107);
insert into employee values (109, 'Dave', 'Financial Analyst', 400, 102);
insert into employee values (110, 'Evelyn', 'Marketing Analyst', 600, 101);

CREATE TABLE department
(dept_id int,
 dept_name text);
insert into department values (100, 'Executive');
insert into department values (300, 'Human Resources');
insert into department values (400, 'Accounting');
insert into department values (500, 'Engineering');
insert into department values (600, 'Marketing');

CREATE TABLE salary
(
emp_id int,
effective_date date,
salary real
);

insert into salary values (101, '2021-03-01', 155000.00);
insert into salary values (101, '2024-09-01', 185000.00);
insert into salary values (102, '2023-08-15', 125000.00);
insert into salary values (102, '2023-07-01', 115000.00);
insert into salary values (102, '2022-06-12', 97000.00);
insert into salary values (103, '2024-01-09', 105000.00);
insert into salary values (103, '2023-04-25', 99500.00);
insert into salary values (104, '2024-11-25', 145800.00);
insert into salary values (105, '2024-12-09', 129000.00);
insert into salary values (105, '2023-05-15', 115500.00);
insert into salary values (106, '2024-02-14', 107000.00);
insert into salary values (106, '2022-10-31', 97600.00);
insert into salary values (107, '2024-09-20', 155000.00);
insert into salary values (108, '2024-08-27', 96000.0);
insert into salary values (109, '2024-10-13', 97000.0);
insert into salary values (109, '2023-10-01', 89000.0);
insert into salary values (109, '2022-09-01', 75000.0);
insert into salary values (110, '2025-01-15', 125000.0);
insert into salary values (110, '2024-01-10', 119500.0);
insert into salary values (110, '2023-01-29', 110900.0);

/* ----------------------------------------------------------------------
1. What is the current employee list and their department name?
*/

select e.*, d.dept_name
from employee e
join department d
on e.dept_id = d.dept_id;



/* ----------------------------------------------------------------------
2. What is the current salary for every employee?
*/

WITH emp_salary_history
AS
(select e.emp_id, e.fname, e.title, s.effective_date, s.salary,
  rank() over (partition by s.emp_id order by effective_date desc) as salary_rank
from employee e
join salary s
on e.emp_id = s.emp_id
)

select emp_id, fname, title, effective_date, salary
from emp_salary_history
where salary_rank = 1;



/* ----------------------------------------------------------------------
3. Create a list of employee and their current salary, their department average 
   salary and the company's average salary in one row for every employee. Create 
   a flag if a person's current salary is higher than the company's average salary.
*/

WITH emp_salary_history
AS
(select e.emp_id, e.fname, e.title, e.dept_id,
        s.effective_date, s.salary,
  rank() over (partition by s.emp_id order by effective_date desc) 
      as most_recent_salary_rank 
from employee e
join salary s
on e.emp_id = s.emp_id
),

avg_dept_salary
as
(
  select emp_id, fname, title, effective_date, salary, dept_id,
     avg(salary) over (partition by dept_id) as avg_dept_salary,
     avg(salary) over () as avg_company_salary
  from
  (select emp_id, fname, title, effective_date, salary, dept_id
  from emp_salary_history
  where most_recent_salary_rank = 1
  ) a
)

select *,
       CASE WHEN salary > avg_company_salary THEN 'Yes'
            Else 'No'
       END as salary_greater_than_company_avg
from avg_dept_salary;



/* ----------------------------------------------------------------------
4. Create a list of employees with their starting salary and ending salary,
   and how many raises he or she has received since their initial salary

*/

WITH emp_salary_history
AS
(select e.emp_id, e.fname, e.title, e.dept_id,
        s.effective_date, s.salary,
  rank() over (partition by s.emp_id order by effective_date desc) 
      as most_recent_salary_rank,
  rank() over (partition by s.emp_id order by effective_date asc) 
      as first_salary_rank
from employee e
join salary s
on e.emp_id = s.emp_id
),

emp_first_last_salary
as
(
  select z.emp_id, z.fname, z.title, 
         z.effective_date recent_eff_date, z.salary current_salary,
         a.effective_date first_eff_date, a.salary initial_salary,
         sc.salary_count
  from
  (
    select emp_id, fname, title, effective_date, salary, dept_id
    from emp_salary_history
    where most_recent_salary_rank = 1
  ) z
  join 
  (
    select emp_id, effective_date, salary
    from emp_salary_history
    where first_salary_rank = 1
  ) a
  on a.emp_id = z.emp_id
  join
    (
    select emp_id, count(*) as salary_count
    from emp_salary_history
    group by 1
  ) sc -- salary changes
  on z.emp_id = sc.emp_id
)

select *
from emp_first_last_salary;


/* ----------------------------------------------------------------------
5. Lastly, how many days have past since their last salary change from today.
*/

WITH emp_salary_history
AS
(select e.emp_id, e.fname, e.title, e.dept_id,
        s.effective_date, s.salary,
  rank() over (partition by s.emp_id order by effective_date desc) 
      as most_recent_salary_rank,
  rank() over (partition by s.emp_id order by effective_date asc) 
      as first_salary_rank
from employee e
join salary s
on e.emp_id = s.emp_id
),

emp_first_last_salary
as
(
  select z.emp_id, z.fname, z.title, 
         z.effective_date recent_eff_date, z.salary current_salary,
         a.effective_date first_eff_date, a.salary initial_salary,
         sc.salary_count
  from
  (
    select emp_id, fname, title, effective_date, salary, dept_id
    from emp_salary_history
    where most_recent_salary_rank = 1
  ) z
  join 
  (
    select emp_id, effective_date, salary
    from emp_salary_history
    where first_salary_rank = 1
  ) a
  on a.emp_id = z.emp_id
  join
    (
    select emp_id, count(*) as salary_count
    from emp_salary_history
    group by 1
  ) sc -- salary changes
  on z.emp_id = sc.emp_id
)

select emp_id, fname, title, recent_eff_date, current_salary,
       first_eff_date, initial_salary, salary_count - 1 as number_of_raises,
       current_date - recent_eff_date as days_elapsed_since_last_salary_change
from emp_first_last_salary;
