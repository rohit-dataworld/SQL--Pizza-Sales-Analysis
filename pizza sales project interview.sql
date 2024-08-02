create database pizzadb2;
use pizzadb2;

-- importing tables

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- 1.Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- 2. Calculate the total revenue generated from pizza sales.

select round(sum(price*quantity)) as revenue from 
order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id;

-- 3.Identify the highest-priced pizza.

select pizza_types.name,pizzas.price from 
pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- 4.Identify the most common pizza size ordered.

select size,count(size) as size_count from pizzas
group by size order by size_count desc limit 1;

-- 5. Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category order by quantity;


-- 6. List the top 5 most ordered pizza types along with their quantities. 

select pizza_types.name,sum(order_details.quantity) as most_ord_type
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by most_ord_type desc limit 5;


-- 7.Determine the distribution of orders by hour of the day.

select hour(time) as hours, count(order_id) as order_count
from orders group by hours order by order_count;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

select category,count(category) as category_count
from pizza_types group by category order by category_count;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(quantity_ordered) from  (select orders.date,sum(quantity) as quantity_ordered
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.date order by quantity_ordered desc) as avg_quant_ord;


-- 10. Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,sum(pizzas.price*order_details.quantity) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id= order_details.pizza_id
group by pizza_types.name order by revenue desc limit 3;

-- 11.Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.name,(sum(order_details.quantity*pizzas.price)/(select sum(order_details.quantity*pizzas.price) as rev from 
order_details join pizzas on order_details.pizza_id=pizzas.pizza_id))*100 as percent_contri

from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name order by percent_contri desc;

-- 12.Analyze the cumulative revenue generated over time.

select date,sum(revenue) over(order by date) as cumulative_rev from

(select orders.date,sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders on orders.order_id=order_details.order_id
group by orders.date) as a ;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, category,rank() over(partition by category order by revenue) as top_rev_pizzas
from
(select pizza_types.name,pizza_types.category,sum(pizzas.price*order_details.quantity) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name,pizza_types.category) as a;