-- https://github.com/rahardia79/mysql-lab2

show databases;
use instacart;
show tables;


-- Q1: Split the orders table to user_last_orders and early_orders

create temporary table user_last_orders
select orders.*
from orders join (
	select user_id, max(order_number) as last_order_number 
	from orders 
	group by user_id
) as last
on orders.user_id = last.user_id and orders.order_number = last.last_order_number;

create temporary table early_orders    
SELECT orders.* 
FROM orders LEFT OUTER JOIN user_last_orders
ON orders.order_id = user_last_orders.order_id
where user_last_orders.order_id is null;

-- Q2. Find the number of orders (excluding the last one) each user placed. 
--     Store the result to a temporary table, user_num_orders. 

create temporary table user_num_orders
select user_id, count(*) as num_orders
from early_orders 
group by user_id;

-- Q3. Find the frequency in terms of percentage a user purchased a product, excluding the latest order the user made.-- 

create temporary table user_product_freq
select 
	F.user_id,
    F.product_id,
	F.freq/num_orders * 100 as percentFreq 
from user_num_orders join (
	select 
		user_id,
		product_id,
		count(*) as freq 
	from
	early_orders join order_products
	on early_orders.order_id = order_products.order_id
	group by user_id, product_id) as F
on user_num_orders.user_id = F.user_id;

-- Q4. Find the first item each user placed in their latest order. Store the result to a temporary table, first_item

create temporary table first_item
select
	user_id,
    product_id
from user_last_orders join order_products
on user_last_orders.order_id = order_products.order_id
where add_to_cart_order = 1;


-- Q5. Extract the frequency percentage (what we found in Q3) of the first product each user placed in their last order.

select user_product_freq.* 
from user_product_freq join first_item
on (user_product_freq.user_id = first_item.user_id and
user_product_freq.product_id = first_item.product_id);

