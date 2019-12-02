
/*Query 1 - query used for first insight - Sales by genre */

SELECT
  g.name AS Genre,
  COUNT(il.TrackId) Qtt_tracks_sold,
  ROUND( 100. * COUNT(il.TrackId) / SUM(COUNT(il.TrackId)) over (),2) AS percentage
  FROM invoiceline il
JOIN track t
  ON t.trackid = il.trackid
JOIN genre g
  ON g.genreid = t.genreid
GROUP BY 1
ORDER BY 2 DESC



/*Query 2 - query used for second insight - Most popular genre customers by country */

WITH t1 AS(SELECT
  g.name AS Genre,
  COUNT(il.TrackId) Qtt_tracks_sold
FROM invoiceline il
JOIN track t
  ON t.trackid = il.trackid
JOIN genre g
  ON g.genreid = t.genreid
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1)

SELECT
  i.billingcountry AS Country,
  COUNT(c.customerid) Most_popular_genre_customers
FROM invoice i
JOIN invoiceline il
ON i.invoiceid = il.invoiceid
JOIN track t
  ON t.trackid = il.trackid
JOIN genre g
  ON g.genreid = t.genreid
JOIN customer c
  ON c.customerid = i.customerid
JOIN t1
ON t1.genre = g.Name
GROUP BY 1
ORDER BY 2 DESC


/*Query 3 - query used for third insight - Sales by rock artists */

SELECT a.name AS Artist,
  SUM(il.trackid) AS total
FROM Artist a
LEFT JOIN album al
  ON a.ArtistId = al.ArtistId
JOIN track t
  ON al.albumid = t.albumid
JOIN invoiceline as il
  ON t.trackid = il.trackid
JOIN genre g
  ON g.genreid = t.GenreId
WHERE g.name = 'Rock'
GROUP BY 1
ORDER BY 2 DESC


/*Query 4 - query used for forth insight - Customers who spent more money with the most popular rock artist */


WITH table1
AS (SELECT
  a.name AS Artist,
  il.InvoiceId AS invoice_id,
  il.invoicelineid AS invoice_line,
  il.UnitPrice * il.Quantity AS total_line
FROM Artist a
JOIN album al
  ON a.ArtistId = al.ArtistId
JOIN track t
  ON al.albumid = t.albumid
JOIN invoiceline AS il
  ON t.trackid = il.trackid
ORDER BY 3)


table2
AS (SELECT
   c.CustomerId, c.FirstName || " " || c.LastName AS Client, i.InvoiceId AS invoice_id, il.invoicelineid AS invoice_line,
	 il.UnitPrice * il.Quantity AS total_line
FROM customer c
JOIN invoice i
	ON c.customerid = i.customerid
JOIN invoiceline il
	ON il.invoiceid = i.invoiceid
ORDER BY 2),

table3
AS (SELECT
   a.name AS Artist,
   SUM(il.trackid) AS total
FROM Artist a
LEFT JOIN album al
  ON a.ArtistId = al.ArtistId
JOIN track t
  ON al.albumid = t.albumid
JOIN invoiceline as il
  ON t.trackid = il.trackid
JOIN genre g
  ON g.genreid = t.GenreId
WHERE g.name = 'Rock'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1)

SELECT table2.Client,
  table1.Artist,
  SUM(table1.total_line) AS Amount_spent
FROM table2
JOIN table1
  ON table1.invoice_id = table2.invoice_id AND table1.invoice_line = table2.invoice_line
JOIN table3
  ON table1.Artist = table3.Artist
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10
