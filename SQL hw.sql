-- * 1a. Display the first and last names of all actors from the table `actor`.
USE sakila;

SELECT first_name, last_name 
FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name,' ', last_name) AS 'Actor Name'
FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT *
FROM actor
WHERE last_name LIKE '%GEN';
-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;
-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
SELECT * FROM actor
ALTER TABLE actor
ADD COLUMN discription BLOB;
-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN discription;
-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS 'Count'
FROM actor
GROUP BY last_name;
-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Count'
FROM actor
GROUP BY last_name
HAVING Count >= 2;
-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT * FROM actor;
-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';
-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
--   * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;
-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
LEFT JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY staff.first_name,staff.last_name;
-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(actor_id) AS 'Total Actor' FROM 
film
INNER JOIN film_actor on film.film_id = film_actor.film_id
GROUP BY film.title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(film_id) from 
inventory
WHERE film_id IN
(
SELECT film_id FROM film
WHERE title ='Hunchback Impossible '
);
-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name,SUM(p.amount) AS 'Total' from 
customer c
LEFT JOIN payment p on c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title 
FROM film
WHERE title LIKE 'K%' or title LIKE 'Q%'
AND language_id = (
SELECT language_id FROM language 
WHERE name = 'English'
);
-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name,last_name
FROM actor
WHERE actor_id IN (
SELECT actor_id FROM film_actor
WHERE film_id IN (
SELECT film_id from film
WHERE title = 'Alone Trip'
));
-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- SELECT * from customer;
-- SELECT * from address;
-- SELECT * from city;
-- SELECT * from country;
SELECT country,first_name, last_name, email FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city on address.city_id = city.city_id
JOIN country on city.country_id = country.country_id
WHERE country = 'Canada';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
-- SELECT * FROM category;
-- SELECT * FROM film_category;
-- SELECT * FROM film;
SELECT title from film
JOIN film_category ON film.film_id = film_category.film_id
WHERE category_id = (SELECT category_id from category WHERE name = 'Family');

-- * 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.film_id) AS 'Count of Rented Movies'
from film f
JOIN inventory i on f.film_id = i.film_id
JOIN rental r on i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY COUNT(f.film_id) DESC;
-- * 7f. Write a query to display how much business, in dollars, each store brought in.
-- SELECT * FROM payment;
-- SELECT * FROM staff;
SELECT s.store_id, SUM(p.amount) 
FROM payment p
JOIN staff s ON p.staff_id=s.staff_id
GROUP BY store_id;
-- * 7g. Write a query to display for each store its store ID, city, and country.
-- SELECT * FROM store; store_id address_id
-- SELECT * FROM address; address_id city_id
-- SELECT * FROM city; city_id country_id
SELECT s.store_id, city, country
FROM store s
JOIN address a ON s.address_id=a.address_id
JOIN city c ON a.city_id=c.city_id
JOIN country  ON c.country_id=country.country_id;
-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- SELECT * FROM category; category_id  name
-- SELECT * FROM film_category; category_id film_id
-- SELECT * FROM inventory; film_id inventory_id
-- SELECT * FROM payment; rental_id staff_id customer_id amount
-- SELECT * FROM rental; inventory_id rental_id staff_id customer_id
SELECT c.name, SUM(p.amount) as 'Gross_Revenue'
from category c 
JOIN film_category fc ON c.category_id=fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY Gross_Revenue DESC
LIMIT 5;
-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT c.name, SUM(p.amount) as 'Gross_Revenue'
from category c 
JOIN film_category fc ON c.category_id=fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY Gross_Revenue DESC
LIMIT 5;
-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
