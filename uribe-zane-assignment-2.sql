/*
Zane Uribe
Databases
Assignment 2
*/

/* #1
	List each customer’s customer id, first and last name, sorted alphabetically by last name and 
    the total amount spent on rentals. The name of the total amount column should be TOTAL SPENT.
*/
select customer.customer_id, customer.first_name, customer.last_name, sum(payment.amount) as "TOTAL SPENT"
from customer
join payment
	on payment.customer_id = customer.customer_id
group by customer.customer_id
order by customer.last_name asc, sum(payment.amount) asc;

/* #2
	List the unique (no duplicates) District and city name where the postal code is null or empty.
*/
select distinct address.district, city.city
from city
join address
	on address.city_id = city.city_id
where address.postal_code is null 
	or address.postal_code = '';
    
/* #3
	List all the films have the words DOCTOR or FIRE in their title?
*/
select film_id, title
from film
where title like '%DOCTOR%' 
	or title like '%FIRE%';

/* #4
	List each actor’s actor id, first and last name, sorted alphabetically by last name and the 
    total number of films they have been in. There should be no duplicates. You should have one 
    row per actor. The name of the number of films column should be NUMBER OF MOVIES.
*/
select distinct a.actor_id, a.first_name, a.last_name, count(fa.actor_id) as "NUMBER OF MOVIES"
from actor a
join film_actor fa
	on fa.actor_id = a.actor_id
group by a.actor_id
order by a.last_name asc, count(fa.actor_id) asc;

/* #5
	What is the average run time of each film by category? Order the results by the average run 
    time lowest to highest.
*/
select category.name, avg(film.length) as "AVG LENGTH"
from film
join film_category
	on film_category.film_id = film.film_id
join category
	on category.category_id = film_category.category_id
group by category.category_id
order by avg(film.length) asc;

/* #6
	How much business (in dollars) did each store bring in? There should be no duplicates. Just 
    list of each store id and the total dollar amount. Order the result by dollar amount greatest 
    to lowest.
*/
select store.store_id, sum(payment.amount) as "TOTAL REVENUE"
from store
join customer
	on customer.store_id = store.store_id
join payment
	on payment.customer_id = customer.customer_id
group by store.store_id
order by sum(payment.amount) desc;

/* #7
	What is the first and last name, email and total amount spent on movies by customers in Canada?
    Order alphabetically by their last name.
*/
select c.first_name, c.last_name, c.email, sum(p.amount) as "TOTAL SPENT"
from customer c
join address a
	on a.address_id = c.address_id
join city 
	on city.city_id = a.city_id
join country co
	on co.country_id = city.country_id
join payment p
	on p.customer_id = c.customer_id
where co.country = 'CANADA'
group by c.customer_id
order by c.last_name asc;

/* #8
	MATHEW BOLIN would like to rent the movie HUNGER ROOF from staff JON STEPHENS at store 2 today.
    The rental fee is 2.99. Insert this rental and payment into the database.
*/
start transaction;
savepoint beforeQ8;

insert into rental(rental_date,inventory_id,customer_id,staff_id)
values(now(),
		(select inventory.inventory_id
		 from inventory
		 join film
			on film.film_id = inventory.store
		 where film.title = "HUNGER ROOF" and inventory.store_id = 2),
		(select customer_id
		 from cutomer
		 where first_name = "MATHEW" and last_name = "BOLIN"),
		(select staff_id
		 from staff
		 where first_name = "JON" and last_name = "STEPHENS")
		);
        
insert into payment(customer_id, staff_id, rental_id, amount, payment_date)
select customer_id, staff_id, rental_id, 2.99, rental_date
from rental 
where last_update = now();

#rollback to beforeQ8;
#commit;

/* #9
	TRACY COLE would like to return the movie ALI FOREVER. Update the rental table to reflect this.
    You can write multiple queries to get the IDs before writing the update statement. You can also 
    do it in a single update statement using joins or sub queries.
*/
start transaction;
savepoint beforeQ9;

update rental
join inventory 
	on rental.inventory_id = inventory.inventory_id
join film 
	on inventory.film_id = film.film_id
join customer 
	on rental.customer_id = customer.customer_id
set rental.return_date = now()
where customer.first_name = "TRACY" 
	and customer.last_name = "COLE" 
    and film.title = "ALI FOREVER";

#rollback to beforeQ9;
#commit;

/* #10
	Change the original language id for all films in the category ANIMATION to JAPANESE.
*/
start transaction;
savepoint beforeQ10;

#The below query shows me the ID for JAPANESE is 3.
select language_id
from language
where name = "JAPANESE";

#The below query shows me the ID for ANIMATION is 2.
select category_id
from category
where name = "ANIMATION";

update film
join film_category
	on film_category.film_id = film.film_id
set original_language_id = 3
where film_category.category_id = 2;

#rollback to beforeQ10;
#commit;