SELECT * FROM olist_geolocation where geolocation_zip_code_prefix = '01046' ;

SELECT * FROM olist_order_items LIMIT 10;

SELECT DISTINCT order_status FROM olist_orders;

SELECT *  
FROM olist_customers 
LIMIT 10;

SELECT customer_unique_id, count(customer_id) 
FROM olist_customers 
GROUP BY customer_unique_id
ORDER BY count(customer_id)  DESC
LIMIT 100;

#https://www.kaggle.com/shubham1696/predictive-recommendation-engine
SELECT o.*, y.* FROM olist_orders o
LEFT JOIN olist_customers c ON o.customer_id = c.customer_id
LEFT JOIN olist_order_items i ON o.order_id = i.order_id
LEFT JOIN olist_products p ON i.product_id = p.product_id
LEFT JOIN olist_order_payments y ON o.order_id = y.order_id
WHERE customer_unique_id = '8d50f5eadf50201ccdcedfb9e2ac8455';

SELECT product_id, count(seller_id) FROM olist_order_items
GROUP BY product_id 
ORDER BY count(seller_id)  DESC
LIMIT 100;

select count(distinct seller_id) from olist_sellers;
select count(seller_id) from olist_sellers;

select count(geolocation_zip_code_prefix) from olist_geolocation;

SELECT product_id, count(distinct seller_id) FROM olist_order_items
GROUP BY product_id 
ORDER BY count(distinct seller_id)  DESC;

SELECT order_id, count(distinct product_id) FROM olist_order_items
GROUP BY order_id 
ORDER BY count(distinct product_id)   DESC
LIMIT 100;

SELECT i.order_id, r.review_score FROM olist_order_items i
LEFT JOIN olist_order_reviews r ON i.order_id = r.order_id
WHERE product_id = 'aca2eb7d00ea1a7b8ebd4e68314663af';

SELECT * FROM olist_order_items 
WHERE order_id = 'ca3625898fbd48669d50701aba51cd5f';

SELECT * FROM olist_order_reviews LIMIT 10;

SELECT p.product_id, AVG(r.review_score) FROM olist_orders o
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
LEFT JOIN olist_order_items i ON r.order_id = i.order_id
LEFT JOIN olist_products p ON i.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_id LIMIT 1;

SELECT order_id, MAX(review_creation_date) AS MAX, review_score FROM olist_order_reviews 
GROUP BY order_id LIMIT 10;

select order_id, review_score, max(review_creation_date)
from olist_order_reviews
group by order_id, review_score;

#finalll for recommender system 
select product_id, avg(review_score) as product_review
from
(SELECT  o.order_id, o.product_id, r.review_score FROM olist_order_items o
join
(select order_id, review_score, max(review_creation_date)
from olist_order_reviews
group by order_id, review_score) r
on o.order_id = r.order_id)x
#where x.product_id = '26facbccf840188b92bcc8cb89fe1f64'
group by x.product_id;


SELECT * FROM olist_order_payments LIMIT 10;
SELECT p.product_id, avg(r.review_score)/COUNT(p.product_id) , MAX
FROM
(SELECT order_id, MAX(review_creation_date) AS MAX, review_score FROM olist_order_reviews
WHERE order_id IN ('ca3625898fbd48669d50701aba51cd5f', '92f21edc7e69a84e3e521e9adc7c83b8'
, 'e0122dcea3d741a8fd7ab4cd7f770a63', 'ac1b50b62dec654637917462ef922bb2'
, '7d8f5bfd5aff648220374a2df62e84d5','c8c7ec8563c295ba0c3ea5faff0a1b0c')
GROUP BY order_id) r
LEFT JOIN  olist_orders o ON o.order_id = r.order_id
LEFT JOIN olist_order_items i ON r.order_id = i.order_id
LEFT JOIN olist_products p ON i.product_id = p.product_id 
#LEFT JOIN olist_product_category_name n ON n.product_category_name = p.product_category_name 
WHERE p.product_category_name is not null
AND o.order_status = 'delivered'
GROUP BY p.product_id;

SELECT DISTINCT payment_type
FROM olist_order_payments;

SELECT i.order_id ,p.product_id, p.product_category_name, r.review_score
FROM
olist_order_items i 
LEFT JOIN olist_order_reviews r ON i.order_id = r.order_id
LEFT JOIN olist_products p ON i.product_id = p.product_id 
WHERE p.product_id in( '0cf2faf9749f53924cea652a09d8e327', '26facbccf840188b92bcc8cb89fe1f64');

#DIFF PAY TYPE
SELECT order_id, COUNT(order_id)
FROM olist_order_payments
GROUP BY order_id
ORDER BY  COUNT(order_id) DESC;
#CHECK
SELECT *
FROM olist_order_payments
WHERE order_id = 'ccf804e764ed5650cd8759557269dc13'
ORDER BY payment_sequential;

SELECT WEEKDAY(o.order_purchase_timestamp), o.order_purchase_timestamp
FROM olist_customers c
LEFT JOIN olist_orders o ON c.customer_id = o.customer_id
WHERE customer_unique_id = '8d50f5eadf50201ccdcedfb9e2ac8455';

SELECT o.order_id, p.product_id, WEEKDAY(o.order_purchase_timestamp), o.order_purchase_timestamp
FROM olist_products p
LEFT JOIN olist_order_items i ON i.product_id = p.product_id
LEFT JOIN olist_orders o ON i.order_id = o.order_id
WHERE p.product_id in( '0cf2faf9749f53924cea652a09d8e327', '26facbccf840188b92bcc8cb89fe1f64');


#orders between 6am and 6pm
SELECT o.order_id, CAST(o.order_purchase_timestamp as time), o.order_purchase_timestamp
FROM olist_customers c
LEFT JOIN olist_orders o ON c.customer_id = o.customer_id
WHERE c.customer_unique_id = '8d50f5eadf50201ccdcedfb9e2ac8455'
AND CAST(o.order_purchase_timestamp as time) >= '06:00:00'
AND CAST(o.order_purchase_timestamp as time) <= '18:00:00'  ;

SELECT * FROM olist_customers c
WHERE customer_unique_id = '8d50f5eadf50201ccdcedfb9e2ac8455';

SELECT order_id,
SUM(CASE
	WHEN payment_type = 'boleto' THEN 1
    ELSE 0
    END) AS count_boleto,
SUM(CASE
	WHEN payment_type = 'credit_card' THEN 1
    ELSE 0
    END) AS count_credit_card,
SUM(CASE
	WHEN payment_type = 'voucher' THEN 1
    ELSE 0
    END) AS count_voucher,
SUM(CASE
	WHEN payment_type = 'debit_card' THEN 1
    ELSE 0
    END) AS count_debit_card,
SUM(CASE
	WHEN payment_type = 'not_defined' THEN 1
    ELSE 0
    END) AS count_not_defined
FROM olist_order_payments
WHERE order_id IN
('dcd7bf0e4548b5a99e81cca7a7160042'
,'e22de883eaec82ecd47950dffc8e63f4'
,'ee8f5d7599c575d8f8eb1a2ea7d66686')
GROUP BY order_id
ORDER BY count_credit_card DESC;

SELECT c.customer_id, count(o.order_id)
FROM olist_customers c
LEFT JOIN olist_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY count(o.order_id) DESC;

#FINALLL COUNT THE DIFF PAY TYPES FOR EACH CUSTOMER
# TEST WITH WHERE customer_unique_id = 'c25d2fb6d22e04ce43c3652e3cacadad'
# TEST WHERE customer_unique_id = '8d50f5eadf50201ccdcedfb9e2ac8455'
SELECT first.customer_unique_id,  first.total_boleto, 
first.total_credit_card, first.total_voucher, first.total_debit_card, first.total_not_defined,
second.percentage_weekday_orders, second.percentage_daytime_orders,
second.count_weekday, second.count_day, second.count_total
FROM
(SELECT customer_unique_id,
SUM(count_boleto) AS total_boleto, SUM(count_credit_card) AS total_credit_card,
SUM(count_voucher) AS total_voucher, SUM(count_debit_card) AS total_debit_card, 
SUM(count_not_defined) AS total_not_defined
FROM olist_customers c
LEFT JOIN olist_orders o ON c.customer_id = o.customer_id
LEFT JOIN COUNT_PAYMENT b ON o.order_id = b.order_id
WHERE customer_unique_id = 'c25d2fb6d22e04ce43c3652e3cacadad'
GROUP BY customer_unique_id) first
LEFT JOIN
(SELECT c.customer_unique_id AS customer_unique_id, 
((c.count_weekday/c.count_total) * 100) AS percentage_weekday_orders,
((c.count_day/c.count_total) * 100) AS percentage_daytime_orders, 
c.count_weekday, c.count_day, c.count_total
FROM
(SELECT c.customer_unique_id AS customer_unique_id,
SUM(CASE
	WHEN WEEKDAY(order_purchase_timestamp) <= 4 THEN 1
    ELSE 0
    END) AS count_weekday,
SUM(CASE
	WHEN (CAST(o.order_purchase_timestamp as time) >= '06:00:00'
	AND CAST(o.order_purchase_timestamp as time) <= '18:00:00') THEN 1
    ELSE 0
    END) AS count_day,
COUNT(order_purchase_timestamp) AS count_total
FROM olist_customers c
LEFT JOIN olist_orders o ON o.customer_id = c.customer_id
WHERE customer_unique_id = 'c25d2fb6d22e04ce43c3652e3cacadad'
GROUP BY c.customer_unique_id) c) second ON second.customer_unique_id = first.customer_unique_id;

#FINAL FOR PRODUCT LEVEL FEATURE
#TEST USING WHERE p.product_id in( '0cf2faf9749f53924cea652a09d8e327', '26facbccf840188b92bcc8cb89fe1f64')
SELECT first.product_id,
((first.count_weekday/first.count_total) * 100) AS percentage_weekday_products,
((second.count_day/second.count_total) * 100) AS percentage_daytime_products
FROM
(SELECT p.product_id AS product_id,
SUM(CASE
	WHEN WEEKDAY(o.order_purchase_timestamp) <= 4 THEN 1
    ELSE 0
    END) AS count_weekday,
COUNT(o.order_purchase_timestamp) AS count_total
FROM olist_products p
LEFT JOIN olist_order_items i ON i.product_id = p.product_id
LEFT JOIN olist_orders o ON i.order_id = o.order_id
GROUP BY p.product_id) first
LEFT JOIN
(SELECT p.product_id AS product_id,
SUM(CASE
	WHEN (CAST(o.order_purchase_timestamp as time) >= '06:00:00'
	AND CAST(o.order_purchase_timestamp as time) <= '18:00:00') THEN 1
    ELSE 0
    END) AS count_day,
COUNT(order_purchase_timestamp) AS count_total
FROM olist_products p
LEFT JOIN olist_order_items i ON i.product_id = p.product_id
LEFT JOIN olist_orders o ON i.order_id = o.order_id
GROUP BY p.product_id) second ON first.product_id = second.product_id;


SELECT payment_type, COUNT( payment_type)
FROM olist_order_payments
GROUP BY payment_type;