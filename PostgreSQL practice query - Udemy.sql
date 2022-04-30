select * from students;

-- Write a query to display the names of those students that are between the ages of 18 and 20.
select
	student_name,
	age
from students
where age between 18 and 20;


-- Write a query to display all of those students that contain the letters "ch" in their name or their name ends with the letters "nd".
select *
from students
where student_name like '%ch%'
	or student_name like '%nd';

-- Write a query to display the name of those students that have the letters "ae" or "ph" in their name and are NOT 19 years old.
select *
from students
where (student_name like '%ae%' or student_name like '%ph%')
	and age != 19;

-- Write a query that lists the names of students sorted by their age from largest to smallest.
select *
from students
order by age desc;

-- Write a query that displays the names and ages of the top 4 oldest students.
select *
from students
order by age desc
limit 4;

-- Write a query that returns students based on the following criteria:
-- The student must not be older than age 20 if their student_no is either between 3 and 5 or their student_no is 7.
-- Your query should also return students older than age 20 but in that case they must have a student_no that is at least 4.
select *
from students
where age <= 20
	and (student_no between 3 and 5 or student_no = 7)
	or (age > 20 and student_no >= 4);

-- Write a query against the professors table that can output the following in the result: "Chong works in the Science department"
select
	last_name||' works in the '||department||' department'
from professors;

-- Write a SQL query against the professors table that would return the following result:
# "It is false that professor Chong is highly paid"
# "It is true that professor Brown is highly paid"
# "It is false that professor Jones is highly paid"
# "It is true that professor Wilson is highly paid"
# "It is false that professor Miller is highly paid"
# "It is true that professor Williams is highly paid"
-- NOTE: A professor is highly paid if they make greater than 95000.
select
	'it is '||(salary > 95000)||' that professor '||last_name||' is highly paid'
from professors;

-- Write a query that returns all of the records and columns from the professors table but shortens the department names to only the first three characters in upper case.
select
	last_name,
	upper(substring(department, 1, 3)) as department,
	salary,
	hire_date
from professors;

-- Write a query that returns the highest and lowest salary from the professors table excluding the professor named 'Wilson'.
select
	max(salary) as  highest_salary,
	min(salary) as lowest_salary
from professors
where last_name != 'Wilson';

-- Write a query that will display the hire date of the professor that has been teaching the longest.
-- solution 1
select
	min(hire_date)
from professors;
-- solution 2
select
	last_name,
	hire_date
from professors
group by 1, 2
order by 2;

-- fruit_imports assignment.
select * from fruit_imports;

-- Write a query that displays only the state with the largest amount of fruit supply.
select
	state,
	sum(supply) as total_supply
from fruit_imports
group by 1
order by 2 desc;

-- Write a query that returns the most expensive cost_per_unit of every season. The query should display 2 columns, the season and the cost_per_unit
select
	season,
	max(cost_per_unit)
from fruit_imports
group by 1
order by 2 desc;

-- Write a query that returns the state that has more than 1 import of the same fruit.
select 
	state,
	name,
	count(name)
from fruit_imports
group by 1,2
having count(name) > 1;

-- Write a query that returns the seasons that produce either 3 fruits or 4 fruits.
select
	season,
	count(name)
from fruit_imports
group by 1
having count(name) >= 3;

-- Write a query that takes into consideration the supply and cost_per_unit columns for determining the total cost and returns the most expensive state with the total cost.
select
	state,
	round(sum(supply*cost_per_unit)) as total_cost
from fruit_imports
group by 1
order by 2 desc;

-- Write a query that returns the count of 4. You'll need to count on the column fruit_name and not use COUNT(*)
select count(coalesce(fruit_name, 'None'))
from fruits;

-- Using subqueries only, write a SQL statement that returns the names of those students that are taking the courses Physics and US History.
select
	student_name
from students
where student_no = any (select student_no
						from student_enrollment
						where course_no = any (select course_no 
					  							from courses 
					  							where course_title in ('Physics', 'US History')));
												
-- Using subqueries only, write a query that returns the name of the student that is taking the highest number of courses.
select
	*
from students
where student_no = (select student_no 
					from student_enrollment 
					group by 1 
					order by count(*) desc 
					limit 1);

-- Write a query to find the student that is the oldest. You are not allowed to use LIMIT or the ORDER BY clause to solve this problem.
select
	*
from students
where age = (select max(age) from students);

-- Write a query that displays 3 columns. The query should display the fruit and it's total supply along
-- with a category of either LOW, ENOUGH or FULL.
-- Low category means that the total supply of the fruit is less than 20,000.
-- The enough category means that the total supply is between 20,000 and 50,000.
-- If the total supply is greater than 50,000 then that fruit falls in the full category.
select
	a.name,
	a.total_supply,
	case
		when a.total_supply < 20000 then 'LOW'
		when a.total_supply between 20000 and 50000 then 'ENOUGH'
		when a.total_supply > 50000 then 'FULL'
	end as category
from
(select
	name,
	sum(supply) as total_supply
from fruit_imports
group by 1) as a;

-- Taking into consideration the supply column and the cost_per_unit column,
-- you should be able to tabulate the total cost to import fruits by each season.
select
	sum(case when a.season = 'Winter' then total_cost end) as winter_total,
	sum(case when a.season = 'Summer' then total_cost end) as summer_total,
	sum(case when a.season = 'Spring' then total_cost end) as spring_total,
	sum(case when a.season = 'Fall' then total_cost end) as fall_total,
	sum(case when a.season = 'All Year' then total_cost end) as allyear_total
from
(select
	season,
	round(sum(supply*cost_per_unit)) as total_cost
from fruit_imports
group by 1) as a;

-- Write a query that shows the student's name, the courses the student is taking and the professors that teach that course.
select
	-- a.student_no,
	a.student_name,
	b.course_no,
	-- c.course_title,
	d.last_name
from students a
	join student_enrollment b
		on a.student_no = b.student_no
	join courses c
		on b.course_no = c.course_no
	join teach d
		on c.course_no = d.course_no
order by 1;

-- In the previous questions you discovered why there is repeating data. How can we eliminate this redundancy?
-- Let's say we only care to see a single professor teaching a course and we don't care for all the other
-- professors that teach the particular course.
-- Write a query that will accomplish this so that every record is distinct.
select
	--a.student_no,
	a.student_name,
	b.course_no,
	--c.course_title,
	d.last_name
from students a
	join student_enrollment b
		on a.student_no = b.student_no
	join courses c
		on b.course_no = c.course_no
	join	(select
				a.course_no,
				min(b.last_name) as last_name
			from courses a
			join teach b
				on a.course_no = b.course_no
			group by 1) as d
		on c.course_no = d.course_no
group by 1,2,3
order by 1;

select
	-- a.student_no,
	a.student_name,
	b.course_no,
	-- c.course_title,
	min(d.last_name) as last_name
from students a
	join student_enrollment b
		on a.student_no = b.student_no
	join courses c
		on b.course_no = c.course_no
	join teach d
		on c.course_no = d.course_no
group by 1,2
order by 1;

-- In the video lectures, we've been discussing the employees table and the departments table.
-- Considering those tables, write a query that returns employees whose salary is above average for their given department.
select
	abc.first_name,
	abc.department,
	abc.salary,
	abc.avg_salary
from (select
	a.first_name,
	a.department,
	a.salary,
	(select round(avg(b.salary)) as avg_salary 
	 from employees b 
	 where a.department = b.department)
from employees a) as abc
where abc.salary > abc.avg_salary
order by 2,3 desc;

-- Write a query that returns ALL of the students as well as any courses they may or may not be taking.
select
	-- a.student_no,
	a.student_name,
	b.course_no,
	c.course_title
from students a
	left join student_enrollment b
		on a.student_no = b.student_no
	left join courses c
		on b.course_no = c.course_no;

-- Write a query that finds students who do not take CS180.
select
	student_no,
	student_name
from students
where student_no not in (select student_no 
					 from student_enrollment 
					 where course_no = 'CS180');

-- Write a query to find students who take CS110 or CS107 but not both.
select
	*
from students
where student_no in (select student_no 
					 from student_enrollment 
					 where course_no in ('CS110', 'CS107'))
		and student_no not in (select student_no
							   from student_enrollment
							   where course_no = 'CS110'
							   and course_no = 'CS107');

-- Write a query to find students who take CS220 and no other courses.
select
	*
from students
where student_no not in (select student_no 
						 from student_enrollment 
						 where course_no != 'CS220')
	and student_no in (select student_no 
						   from student_enrollment);

-- Write a query that finds those students who take at most 2 courses. 
-- Your query should exclude students that don't take any courses as well as those that take more than 2 course.
select
	*
from students
where student_no in (select
						student_no
					 from student_enrollment
					 group by 1
					 having count(*) <= 2);

-- Write a query to find students who are older than at most two other students.
select
	a.*
from students a
where 2 >= (select count(*)
	   from students b 
	   where a.age > b.age)
order by a.age desc;