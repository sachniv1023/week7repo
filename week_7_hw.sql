--1.Create a new column called “status” in the rental table that uses a case statement 
--to indicate if a film was returned late, early, or on time.
 WITH t1 AS (Select *, DATE_PART('day', return_date - rental_date) AS date_difference
            FROM rental),
t2 AS (SELECT rental_duration, date_difference,
              CASE
                WHEN rental_duration > date_difference THEN 'Returned early'
                WHEN rental_duration = date_difference THEN 'Returned on Time'
                ELSE 'Returned late'
              END AS Status
          FROM film f
          JOIN inventory i
          USING(film_id)
          JOIN t1
          USING (inventory_id))
SELECT status, count(*) As total_no_of_films
FROM t2
GROUP BY 1
ORDER BY 2 DESC;

--2.Show the total payment amounts for people who live in Kansas City or Saint Louis.
SELECT ci.city as cityname, sum(p.amount) AS total_payment
FROM payment as p
JOIN customer cu
USING(customer_id)
JOIN address a
USING(address_id)
JOIN city ci
USING(city_id)
WHERE ci.city = 'Saint Louis' or ci.city = 'Kansas City'
GROUP BY cityname
ORDER BY total_payment DESC;

--3.How many film categories are in each category? Why do you think there is a table for category 
--and a table for film category
SELECT c.name, COUNT(f.film_id)
FROM category AS c
JOIN film_category AS fc
ON c.category_id = fc.category_id
JOIN film as f
ON f.film_id = fc.film_id
GROUP BY c.name;
--we r using here table category and film_category because in table category category_id is a 
--primary key and
-- film_category table contains film_id is a primary key and category_id is a forign key.

--4.Show a roster for the staff that includes their email, address, city, and country (not ids)
select s.email, a.address, ci.city, co.country
from staff as s
join address a
using(address_id)
join city ci
using(city_id)
join country co
using(country_id)
order by ci.city;

--5.Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
select  f.film_id, title, length, return_date
from film as f
inner join inventory i
on f.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
where return_date between '2005/05/15' AND '2005/05/31'
order by return_date;

--6.Write a subquery to show which movies are rented below the average price for all movies.
SELECT title 
FROM film 
WHERE rental_rate< 
(SELECT Round(AVG(amount), 2)
FROM payment AS p
JOIN rental AS r
ON p.rental_id = r.rental_id
JOIN inventory AS i
ON i.inventory_id = r.inventory_id
JOIN film AS f
ON f.film_id = i.film_id);

--7.Write a join statement to show which moves are rented below the average price for all movies.
select round(AVG(p.amount),2) as avg_rental, f.title
from film as f
join inventory as i
on f.film_id = i. film_id
join rental as r
on i.inventory_id = r.inventory_id
join payment as p
on p.rental_id = r.rental_id
group by f.title

--8.Perform an explain plan on 6 and 7, and describe what you’re seeing and important ways they 
--differ.
--Joins and subqueries are both used to combine data from different tables into a single result. 
--Subqueries can be used to return  single value or a row set; whereas, joins are used to return rows.
--A common use for a subquery may be to calculate a summary value for use in a query.
--A Subquery in sql embedded within where clause.
--in question 6 we write subquery in where clause for getting the average amount. In question 7 we write the query using joins to get the average price of all movies.

--9.With a window function, write a query that shows the film, its duration, and what percentile the duration fits into. 
--This may help https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank 

select f.title,f.length as duration,
	percent_rank() over(order by f.length)
from film as f
inner join film_category as fi using (film_id)
order by percent_rank desc;

--10.In under 100 words, explain what the difference is between set-based and procedural programming. 
--Be sure to specify which sql and python are. 
---procedural approach is actually the "programattic approach" that we r used to working with in our
---daily programming life. In this we tell the system "what to do" along with how to do" it.
---we query the database to obtain the results and we write a data operational and manipulating 
---logic using loops, conditions and processing statements to produce the find results.
---	In set based approach it lets you specify "what to do" but does not let you specify "how to do" it
---That is you just specify your requirments for a processed results that has to be 
---obtained from a set of data. you never have to specify "how" the data retrival operation 
---has to be implemented internally. you never have to specify how to apply filters, how to joining operations internally, how to apply filter condition against the row.
---	sql supports procedural, "row by row" constructs in form of loops and so on.
---	python supports both object oriented and procedural programmimg languages as it is high level 
---programming language.

--Bonus:
--Find the relationship that is wrong in the data model. Explain why its wrong. 
-- store can have only one and only one address, and address tabel 
--can have zero to one store cardinality. In dvd rental data model address to store cardinality is wrong.
