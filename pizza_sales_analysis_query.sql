
# Creating orders table under pizza_hut database

CREATE TABLE pizza_hut.orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);
 
# Creating order details table under pizza_hut database

 CREATE TABLE pizza_hut.order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);
 
 # Validating table entries
 select * from pizza_hut.orders;
 

#1) Retrieve the total number of orders placed.

select count(*) as total_orders from pizza_hut.orders;

#2) Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_revenue
FROM
    pizza_hut.pizzas p
        JOIN
    pizza_hut.order_details o ON p.pizza_id = o.pizza_id;
    
#3) Identify the highest-priced pizza.

SELECT 
    name, price
FROM
    pizza_hut.pizza_types p1
        JOIN
    pizza_hut.pizzas p2 ON p1.pizza_type_id = p2.pizza_type_id
WHERE
    price = (SELECT 
            MAX(price)
        FROM
            pizza_hut.pizzas);

#4) Identify the most common pizza size ordered.

SELECT 
    size, COUNT(order_details_id) AS order_count
FROM
    pizza_hut.order_details o
        JOIN
    pizza_hut.pizzas p ON o.pizza_id = p.pizza_id
GROUP BY size
ORDER BY order_count DESC;

#5) List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, SUM(quantity) AS quantities
FROM
    pizza_hut.order_details o
        JOIN
    pizza_hut.pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_hut.pizza_types p1 ON p1.pizza_type_id = p.pizza_type_id
GROUP BY name
ORDER BY quantities DESC
LIMIT 5;

#6) Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    SUM(quantity) AS quantities, category
FROM
    pizza_hut.pizzas p
        JOIN
    pizza_hut.pizza_types p1 ON p.pizza_type_id = p1.pizza_type_id
        JOIN
    pizza_hut.order_details o ON o.pizza_id = p.pizza_id
GROUP BY category
ORDER BY quantities DESC;

#7) Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    pizza_hut.orders
GROUP BY HOUR(order_time);

#8) Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS pizza
FROM
    pizza_hut.pizza_types
GROUP BY category;

#9) Group the orders by date and calculate the average number of pizzas ordered per day.

with temp as (select order_date,sum(quantity) as quantities 
from pizza_hut.order_details o
join pizza_hut.orders o1 on o.order_id = o1.order_id
group by order_date)

select round(quantities,0) as avg_pizza_order_per_day from temp;

#10) Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    pizza_hut.order_details o
        JOIN
    pizza_hut.pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_hut.pizza_types p1 ON p1.pizza_type_id = p.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

#11) Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category,
    ROUND(SUM(quantity * price) / (SELECT 
                    SUM(quantity * price)
                FROM
                    pizza_hut.pizzas p
                        JOIN
                    pizza_hut.order_details o ON p.pizza_id = o.pizza_id) * 100,
            2) as revenue
FROM
    pizza_hut.pizza_types p
        JOIN
    pizza_hut.pizzas p1 ON p.pizza_type_id = p1.pizza_type_id
        JOIN
    pizza_hut.order_details o ON o.pizza_id = p1.pizza_id
GROUP BY category
ORDER BY revenue DESC;

#12 Analyze the cumulative revenue generated over time.

with temp as (select order_date,sum(quantity*price) as revenue
from pizza_hut.orders o
join pizza_hut.order_details o1 on o.order_id = o1.order_id
join pizza_hut.pizzas p on p.pizza_id = o1.pizza_id 
group by order_date)

select order_date,sum(revenue) over(order by order_date) as cum_revenue
from temp;

#13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with temp as (select category,name,sum(price*quantity) as revenue
from pizza_hut.pizza_types p
join pizza_hut.pizzas p1 on p.pizza_type_id = p1.pizza_type_id
join pizza_hut.order_details o on o.pizza_id = p1.pizza_id
group by category,name
),temp2 as

(select category,name,revenue,rank()over(partition by category order by revenue desc) as rn
from temp)

select * from temp2 where rn <4





