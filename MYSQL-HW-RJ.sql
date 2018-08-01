## Instructions


USE sakila;
SELECT * FROM actor;

## 1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name FROM actor;


## 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT UPPER(CONCAT(first_name,' ',last_name)) as ACTOR_NAME FROM Actor;


## 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT * FROM actor
WHERE first_name like "Joe";


## 2b. Find all actors whose last name contain the letters `GEN`:

SELECT * FROM actor
WHERE last_name like "%GEN%";


## 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;


## 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China' );

## 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.

ALTER TABLE actor
Add column middle_name VARCHAR(40)
AFTER first_name;


## 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.


ALTER TABLE actor
MODIFY COLUMN middle_name blob; # note: Alter column doesn't work in My SQL


## 3c. Now delete the `middle_name` column.

ALTER TABLE actor
DROP COLUMN middle_name;


## 4a. List the last names of actors, as well as how many actors have that last name.

Select last_name, count(last_name) 
FROM actor
GROUP BY last_name;



## 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(last_name) 
FROM actor
GROUP BY last_name
HAVING count(last_name) >= 2;



## 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. 
# Write a query to fix the record.

SELECT * FROM actor
WHERE first_name = 'HARPO';

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

## 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
# Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
# BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor 
SET 
    first_name = 
		CASE
        WHEN first_name = 'HARPO'
        THEN 'GROUCHO'
        ELSE 'MUCHO GROUCHO'
    END
WHERE
    actor_id = 172;



## 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?


 Describe address;
 SHOW CREATE TABLE address;
 



## 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT * from staff;
SELECT * from address;

SELECT s.first_name, s.last_name, a.address FROM address a
JOIN staff s
USING (address_id);

#or 

SELECT s.first_name, s.last_name, a.address
FROM address a
INNER JOIN staff s
ON (s.address_id = a.address_id);


## 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT * from staff;
SELECT * from payment;
SELECT month(payment_date) from payment;

SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount)
FROM staff s
INNER JOIN payment p
ON p.staff_id = s.staff_id
WHERE MONTH(p.payment_date) = 8 AND YEAR(p.payment_date) = 2005
GROUP BY s.staff_id;


## 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT * from film;
SELECT * from film_actor;

SELECT f.film_id, f.title, count(fa.actor_id) as "Number_of_Actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY fa.film_id;



## 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT * from inventory;
Select * from film;

Select f.film_id, f.title, count(i.inventory_id) AS '# of copies'
FROM film F
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title like "Hunchback Impossible"
Group By i.film_id;


SELECT title, COUNT(inventory_id) AS '# of copies'
from film
INNER JOIN inventory
USING ( film_id)
WHERE title = 'Hunchback Impossible'
GROUP BY title;


## 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT * from payment;
SELECT * from customer;

SELECT customer_id, last_name, sum(amount) AS "Total_Paid"
from customer
INNER JOIN payment
USING (customer_id)
GROUP BY customer_id
ORDER BY last_name;

		
## 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
# As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT * from film;
SELECT * from language;

Select title FROM film
Where (title like "K%" OR title like "Q%") AND language_id IN (
	Select language_id
    from language
    where name = 'English'
);

## 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT * from film;
SELECT * from actor;
SELECT * from film_actor;


SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
	FROM film_actor
	WHERE film_id =
	(
		SELECT film_id
		FROM film
		WHERE title like "Alone Trip"
	)
);



## 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.


SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

# Using Subqueries

SELECT cus.first_name, cus.last_name, cus.email
FROM customer cus
WHERE cus.address_id IN
(
	SELECT a.address_id
    FROM address a
    WHERE a.city_id IN
	(
		Select c.city_id
        FROM city c
        WHERE c.country_id =
        (
			SELECT ctr.country_id
            FROM country ctr
            WHERE ctr.country = 'canada'
		)
	)
);


# Using JOINS

SELECT first_name, last_name,email
FROM customer cus
JOIN address a
ON (cus.address_id = a.address_id)
JOIN city cit
ON (a.city_id = cit.city_id)
JOIN country ctr
ON (cit.country_id = ctr.country_id)
WHERE ctr.country = 'canada';

## 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;


# Using JOINS
SELECT title
FROM film f
JOIN film_category fc
ON (f.film_id = fc.film_id)
JOIN category c
ON (fc.category_id = c.category_id)
WHERE c.name = 'Family';

# Using Subqueries

SELECT title
FROM film f
WHERE f.film_id IN
(
	SELECT film_id
    FROM film_category fc
    WHERE fc.category_id IN
    (
		SELECT category_id
        FROM category c
        WHERE c.name = 'Family'
	)
);
    




## 7e. Display the most frequently rented movies in descending order.

SELECT * FROM rental;
SELECT * FROM film;
SELECT * FROM inventory;

SELECT title, count(i.film_id) as 'Number of times rented'
FROM film f
JOIN inventory i
ON (f.film_id = i.film_id)
JOIN rental r
ON (r.inventory_id = i.inventory_id)
GROUP BY i.film_id
ORDER BY count(i.film_id) desc;


SELECT title, count(title) as 'Number of times rented'
FROM film f
JOIN inventory i
ON (f.film_id = i.film_id)
JOIN rental r
ON (r.inventory_id = i.inventory_id)
GROUP BY title
ORDER BY count(i.film_id) desc;



## 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM store;
SELECT * FROM payment;
SELECT * FROM staff;

SELECT str.store_id, sum(p.amount) as 'total business'
FROM store str
JOIN staff stf
ON (str.store_id = stf.store_id)
JOIN payment p
ON (p.staff_id = stf.staff_id)
GROUP BY str.store_id;


SELECT s.store_id, SUM(amount) AS 'total business'
FROM payment p
JOIN rental r
ON (p.rental_id = r.rental_id)
JOIN inventory i
ON ( i.inventory_id = r.inventory_id)
JOIN store s
ON (s.store_id = i.store_id)
GROUP BY s.store_id;


SELECT 
    store.store_id, SUM(amount) AS 'total business'
FROM
    store
        INNER JOIN
    staff ON store.store_id = staff.store_id
        INNER JOIN
    payment ON payment.staff_id = staff.staff_id
GROUP BY store.store_id;



## 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country
FROM store s,
JOIN address a
ON (s.address_id = a.address_id); 


## 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT name AS Genre, concat('$',format(SUM(amount),2)) AS Gross_Revenue FROM category
JOIN film_category ON category.category_id=film_category.category_id
JOIN inventory ON film_category.film_id=inventory.film_id
JOIN rental ON inventory.inventory_id=rental.inventory_id
JOIN payment ON rental.rental_id=payment.rental_id
GROUP BY Genre
ORDER BY SUM(amount) DESC
LIMIT 5


## 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW AS top_five_genres AS
SELECT SUM(amount) AS 'TOTAL Sales', c.name AS 'GENRE'
FROM payment p
JOIN rental r
on (p.rental_id = r.rental_id)
JOIN inventory i
on (r.inventory_id = i.inventory_id)
JOIN film_category fc  
on(i.film_id = fc.film_id)
JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5


## 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres


## 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_five_genres


