-- Q1: Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

--Q2:Which countries have the most invoice?

select count(billing_country)as c,billing_country from invoice
group by billing_country
order by c desc;

--Q3:What are top 3 values of total invoive?

select total from invoice
order by total desc
limit 3;

/*Q4:Which city has the best csutomers? We would like to throw a 
promotional music festival in the city we made the most money. 
write a query that returns one city that has the highest sum of invoice totals. 
return both the city naem &sum of all invoice table?*/
select sum(total) as invoice_total, billing_city from invoice
group by billing_city
order by invoice_total desc;

/*Q5: who is the best customer? The customer who has spent the most money 
will be declared the best customer.Write a query that returns the person 
who has spent the most money?*/

select customer.customer_id,customer.first_name,customer.last_name, 
sum(invoice.total)as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

/*M1: Write query to return the email,fname,lname& genre of all rock 
music listners. Return your list ordered alphabetically 
by email starrting with A. */

select distinct email,first_name,last_name from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id=genre.genre_id
	where genre.name like 'Rock'
)
order by email;

/* M2: Let's invite the artists who have written the most rock 
music in our dataset, Write a query that return the artist name
and total track count of the top 10 rock bands*/

select artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs 
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

/* M3: return all the track names that have a song length longer
than the average song length. Return the name and milliseconds for
each track. Order by the song length with the longest songs listed first.*/

select name , milliseconds from track
where milliseconds > (
	select avg(milliseconds) 
	from track
) 
order by milliseconds desc;

/*A1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent*/

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_invoice
	from invoice_line
	join track on invoice_line.track_id=track.track_id
	join album on track.album_id=album.album_id
	join artist on album.artist_id=artist.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name,c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spend from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;

/*A2:Write a query that determines the customer that has spent the most
on music for each country. Write a query that returns the country along 
with the top customer and how much they spent. For countries where the 
top amount spent is shared, provide all customers who spent this amount?*/

with recursive
customer_with_country as(
	select c.customer_id,first_name,last_name,billing_country,
	sum(total) as total_spending from invoice i
	join customer c on c.customer_id=i.customer_id
	group by 1,2,3,4
	order by 1,5 desc),
	

	country_max_spending as (
	select billing_country,max(total_spending) as max_spending
	from customer_with_country
	group by billing_country)

select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name 
from customer_with_country cc
join country_max_spending ms 
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;
	








