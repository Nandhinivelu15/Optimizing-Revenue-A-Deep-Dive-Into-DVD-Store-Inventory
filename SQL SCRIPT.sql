USE sakila;

-- ****************************
-- EXPLORATION
-- ****************************
-- Tables related to the Films
-- ****************************
-- actor, film_actor, film, language, film_category, category, film_text

-- 200 actors
SELECT * FROM actor; 
SELECT count(*) FROM actor; 

-- 1000 films
SELECT * FROM film;
SELECT count(*) FROM film;

-- Validating film_actor
SELECT * FROM film_actor;
SELECT count(distinct actor_id) FROM film_actor; -- 200 actors, CHECKED
SELECT count(distinct film_id) FROM film_actor; -- 997 film, LESS


-- 16 categories
SELECT * FROM category;
SELECT count(*) FROM category;

SELECT * FROM film_category;
SELECT count(distinct film_id), count(distinct category_id) FROM film_category; -- 1000 films (CHECKED), 16 categories (CHECKED)

-- 6 languages
SELECT * FROM language;
SELECT COUNT(*) FROM language;

SELECT * FROM film_text;


-- How many films are released in different languages ?

-- validate the connection
SELECT count(distinct film_id) FROM language as lang inner join film as f on lang.language_id = f.language_id; -- 1000 films
-- COUNT
SELECT lang.name, count(distinct film_id) 
FROM language as lang inner join film as f on lang.language_id = f.language_id
GROUP BY 1;


-- How many films are released in different category ? 
SELECT * FROM category;

SELECT cat.name, count(distinct f_cat.film_id) 
FROM film_category as f_cat inner join category as cat on f_cat.category_id = cat.category_id GROUP BY 1;



-- *************************
-- Tables related to the Rental
-- *************************
-- inventory, rental, customer, payment

-- 4.5k inventory items
SELECT * FROM inventory;

-- 16k rentals, orders
SELECT * FROM rental;

-- 599 Total customers
SELECT * FROM customer;

-- 16k transactions
SELECT * FROM payment;

-- 67K total revenue
SELECT sum(amount) from payment;

-- Payment by Year
SELECT year(payment_date), month(payment_date),sum(amount) from payment group by 1,2 order by 1,2;


-- ****************************
-- Tables related to the Store
-- ****************************
-- store, address, city, country, staff

-- 2 Stores
SELECT * FROM store;
-- 603 address
SELECT * FROM address;
-- 600 cities
SELECT * FROM city;
-- 109 countries
SELECT * FROM country;
-- 2 staff
SELECT * FROM staff;
SELECT * FROM film;

-- *********************
-- Sample Interesting questions
-- *********************

-- 1. Calculate revenue for each actor based on the films they've been in ?

-- 2. Determine the revenue for each film category.

-- 3. Analyze the relationship between the number of rentals and revenue on a monthly basis.

-- 4. Compare revenue between two different rental stores.

-- 5.  Find the most profitable film based on revenue.

-- 6. Analyze revenue by film rating.

-- 7. Analyze revenue by staff

-- 8. Analyze revenue by country.
-- *********************

-- Rough work
SELECT * FROM film;
SELECT * FROM inventory;
SELECT * FROM rental;
SELECT * FROM payment;

-- 1.Calculate revenue for each actor based on the films they've been in ?

SELECT actor.actor_id, actor.first_name, actor.last_name, SUM(payment.amount) AS actor_revenue
FROM actor
INNER JOIN film_actor ON actor.actor_id = film_actor.actor_id
INNER JOIN film ON film_actor.film_id = film.film_id
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY actor.actor_id
ORDER BY actor_revenue DESC
LIMIT 10;

-- 2 Determine the revenue for each film category.

SELECT category.name AS category, SUM(payment.amount) AS category_revenue
FROM payment
INNER JOIN rental ON payment.rental_id = rental.rental_id
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film ON inventory.film_id = film.film_id
INNER JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY category
ORDER BY category_revenue DESC
LIMIT 10;

-- 3 Analyze the relationship between the number of rentals and revenue on a monthly basis.

SELECT DATE_FORMAT(rental.rental_date, '%Y-%m') AS month, COUNT(rental.rental_id) AS rental_count, SUM(payment.amount) AS monthly_revenue
FROM rental
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY month;
 
-- 4. Compare revenue between two different rental stores.

SELECT store.store_id, SUM(payment.amount) AS store_revenue
FROM store
INNER JOIN customer ON store.store_id = customer.store_id
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY store.store_id;

-- 5. Find the most profitable film based on revenue.

SELECT film.title, SUM(payment.amount) AS film_revenue
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY film.title
ORDER BY film_revenue DESC
LIMIT 10;

-- 6. Analyze revenue by film rating.

SELECT film.rating, SUM(payment.amount) AS rating_revenue
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY film.rating
ORDER BY rating_revenue DESC;

-- 7. Analyze revenue by staff

SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS staff_revenue
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff.staff_id;

-- 8. Analyze revenue by country.

SELECT country.country, SUM(payment.amount) AS country_revenue
FROM country
INNER JOIN city ON country.country_id=city.country_id
INNER JOIN address ON city.city_id = address.city_id
INNER JOIN customer ON address.address_id = customer.address_id
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY country.country;

