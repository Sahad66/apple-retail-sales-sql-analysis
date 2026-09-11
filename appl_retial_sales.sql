-- 1. Category Table
CREATE TABLE category (
    category_id VARCHAR(20) NOT NULL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);


-- 2. Store Table
CREATE TABLE store (
    store_id VARCHAR(15) PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);


-- 3. Products Table
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    category_id VARCHAR(10),
    launch_date DATE,
    price DECIMAL(10, 2)
);


-- 4. Sales Table
CREATE TABLE sales (
    sale_id VARCHAR(10) PRIMARY KEY,
    sale_date DATE NOT NULL,
    store_id VARCHAR(15) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0)
);


-- 5. Warranty Table
CREATE TABLE warranty (
    claim_id VARCHAR(15) PRIMARY KEY,
    claim_date DATE NOT NULL,
    sale_id VARCHAR(10) NOT NULL,
    repair_status VARCHAR(20) DEFAULT 'Pending'
);

--Products → Category
ALTER TABLE products
ADD CONSTRAINT products_category_id_fkey
FOREIGN KEY (category_id) REFERENCES category(category_id);

--Sales → Products
ALTER TABLE sales
ADD CONSTRAINT sales_product_id_fkey
FOREIGN KEY (product_id) REFERENCES products(product_id);

--Sales → Store
ALTER TABLE sales
ADD CONSTRAINT sales_store_id_fkey
FOREIGN KEY (store_id) REFERENCES store(store_id);

--Warranty → Sales
ALTER TABLE warranty
ADD CONSTRAINT warranty_sale_id_fkey
FOREIGN KEY (sale_id) REFERENCES sales(sale_id);


SELECT * FROM category;
SELECT * FROM store;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM warranty;



-- 1. Category Table
COPY category(category_id, category_name)
FROM 'E:\study\data analyst\datanalyst\SQl Project\nijer project\Project_1\dataset-of-apple-retail-sales\category.csv'
DELIMITER ','
CSV HEADER;

-- 2. Store Table
COPY store(store_id, store_name, city, country)
FROM 'E:\study\data analyst\datanalyst\SQl Project\nijer project\Project_1\dataset-of-apple-retail-sales\stores.csv'
DELIMITER ','
CSV HEADER;

-- 3. Products Table
copy products(product_id, product_name, category_id, launch_date, price)
FROM 'E:\study\data analyst\datanalyst\SQl Project\nijer project\Project_1\dataset-of-apple-retail-sales\products.csv'
DELIMITER ','
CSV HEADER;

-- 4. Sales Table
COPY sales(sale_id, sale_date, store_id, product_id, quantity)
FROM 'E:\study\data analyst\datanalyst\SQl Project\nijer project\Project_1\dataset-of-apple-retail-sales\sales.csv'
DELIMITER ','
CSV HEADER;

-- 5. Warranty Table
COPY warranty(claim_id, claim_date, sale_id, repair_status)
FROM 'E:\study\data analyst\datanalyst\SQl Project\nijer project\Project_1\dataset-of-apple-retail-sales\warranty.csv'
DELIMITER ','
CSV HEADER;

DROP TABLE IF EXISTS warranty;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS store;
DROP TABLE IF EXISTS category;



SELECT * FROM category;
SELECT * FROM store;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM warranty;

---------------------------------------------------------------------
**🟢 Basic (1–6) — SELECT, WHERE, ORDER BY, single JOIN**

1. Show all products' names and prices, sorted from highest to lowest price.
2. List all products with a price greater than $1000.
3. Find all products launched in the year 2023.
4. Show the names and cities of all stores located in the United States.
5. How many distinct countries have stores in? (COUNT DISTINCT)
6. Join each sale with its corresponding product name (sales JOIN products).

**🟡 Intermediate (7–14) — GROUP BY, HAVING, multiple JOIN, subquery, date functions**

7. How many products are there in each category? (products JOIN category, GROUP BY)
8. Find the total quantity sold per store (sales JOIN store, GROUP BY, SUM).
9. Find the total revenue per category (join sales + products + category, SUM(quantity*price)).
10. Show only the stores whose total revenue exceeds $50,000 (using HAVING).
11. Find the monthly (year-month) total sales trend (using DATE_TRUNC or TO_CHAR).
12. Find the products that have never been sold (LEFT JOIN + IS NULL).
13. Find the number of warranty claims per product (sales JOIN warranty, GROUP BY product).
14. Find the products priced above the average price (using a subquery).

**🔴 Advanced (15–20) — Window functions, CTE, ranking, running total**

15. Within each category, find the top 3 best-selling products by quantity (using RANK() or ROW_NUMBER() + PARTITION BY).
16. Find the month-over-month percentage growth in revenue (using the LAG() window function).
17. Find the running total (cumulative) revenue per store over time (using SUM() OVER with ORDER BY).
18. Find which product has the highest warranty claim rate (total claims ÷ total units sold) — write a CTE that first calculates sales per product and claims per product separately, then joins them.
19. Find the top-selling category for each country — this will require multiple CTEs or subqueries (chain: country → store → sales → product → category).
20. Find the average resolution time by repair status (Pending/In Progress/Completed/Rejected) — assume the gap between claim_date and sale_date represents the delay (note: there's a data limitation here since the warranty table has no "resolved_date" field, so calculate the gap as claim_date − sale_date and group by repair_status).


---------------------------------------------------------------------

--1.Show all products' names and prices, sorted from highest to lowest price.
select 
	product_name,
	price 
from products
order by price desc

--2.List all products with a price greater than $1000.
select 
	price 
from products
where price > 1000

--3.Find all products launched in the year 2023
select 
	launch_date
from products
where launch_date between '2023-01-01' and '2023-12-31'

--other soluton 
SELECT product_name, launch_date
FROM products
WHERE EXTRACT(YEAR FROM launch_date) = 2023;


--4.Show the names and cities of all stores located in the United States.
select 
	store_name,
	city
from store
where country = 'United States'

--5.How many distinct countries have stores in? (COUNT DISTINCT)  
select 
	count(distinct(country)) as total_country
from store

--6.Join each sale with its corresponding product name (sales JOIN products).

SELECT 
	s.sale_id, 
	s.sale_date, 
	p.product_name,
	s.quantity
FROM sales s 
join products as p 
on s.product_id = p.product_id 


--7.How many products are there in each category? (products JOIN category, GROUP BY)
SELECT 
	c.category_name,
	count(p.product_id) as total_products
FROM category as c
join products as p
on p.category_id = c.category_id
group by c.category_name
order by total_products desc

--8.Find the total quantity sold per store (sales JOIN store, GROUP BY, SUM).

select 
	st.store_name,
	sum(quantity) as total_quantity
from sales as s
join store as st
on st.store_id = s.store_id
group by st.store_name
order by total_quantity desc

--9.Find the total revenue per category (join sales + products + category, SUM(quantity*price)).

SELECT 
	c.category_name,
	sum(s.quantity * p.price) as total_revenue
FROM sales as s
join products as p
on p.product_id = s.product_id
join category as c
on c.category_id = p.category_id
group by c.category_name
order by total_revenue desc

--10.Show only the stores whose total revenue exceeds $50,000 (using HAVING).

SELECT 
	st.store_name,
	sum(s.quantity * p.price) as total_revenue
FROM sales as s
join products as p
on p.product_id = s.product_id
join store as st 
on s.store_id = st.store_id
group by st.store_name
HAVING SUM(s.quantity * p.price) > 50000
ORDER BY total_revenue DESC;


--11.Find the monthly (year-month) total sales trend (using DATE_TRUNC or TO_CHAR).
select 
	date_trunc('month',sale_date) as sales_month,
	sum(s.quantity * p.price) as monthly_revenue
from sales as s
join products as p 
on p.product_id = s.product_id
group by sales_month
order by sales_month

--12.Find the products that have never been sold (LEFT JOIN + IS NULL).

SELECT 
	p.product_id ,
	p.product_name
FROM products as p
join sales as s
on s.product_id = p.product_id
where s.sale_id is null

--13.Find the number of warranty claims per product (sales JOIN warranty, GROUP BY product).

SELECT 
	p.product_name , 
	count(w.claim_id) as total_claims
FROM sales as s
join products as p on s.product_id = p.product_id
join warranty as w on s.sale_id = w.sale_id
group by p.product_name
order by total_claims desc


--14.Find the products priced above the average price (using a subquery).


select
	product_name,
	price
FROM products
where price > ( 
	select 
		avg(price)
	from products
	)
order by price desc

--15.Within each category, find the top 3 best-selling products by quantity (using RANK() or ROW_NUMBER() + PARTITION BY).


with products_sales as(
	
	SELECT 
		p.product_id,
		p.product_name,
		c.category_name,
		sum(quantity) as total_qty
	FROM sales as s
	join products as p 
	on p.product_id = s.product_id
	join category as c
	on p.category_id = c.category_id
	group by 
			 p.product_id ,
			 p.product_name,
		     c.category_name
			 
),	
ranked as (
		select *,
			rank () over (partition by category_name order by total_qty desc) as rnk
			from products_sales
 )

select 
	category_name ,
	product_name,
	total_qty,
	rnk
from ranked
order by category_name , rnk


--16.Find the month-over-month percentage growth in revenue (using the LAG() window function).

with monthly AS(
    select	
		date_trunc('month',s.sale_date) as sales_month,
		sum(s.quantity * p.price) as revenue
	from sales as s
	join products as p 
	on s.product_id = p.product_id
	group by sales_month

)
select sales_month , revenue,
	lag(revenue) over (order by sales_month) as prev_month_revenue,
	round(
		(revenue - lag(revenue)over(order by sales_month))
		/ nullif(lag(revenue)over (order by sales_month),0)*100,2
	) as pct_growth
from monthly
order by sales_month
	


--17.Find the running total (cumulative) revenue per store over time (using SUM() OVER with ORDER BY).


select
	st.store_name, 
	s.sale_date,
	sum(s.quantity * p.price) over(
		partition by st.store_id order by s.sale_date
		rows between unbounded preceding and current row
	) as running_revenue
FROM sales as s
join products as p ON s.product_id = p.product_id
join store as st ON s.store_id = st.store_id
order by st.store_name,s.sale_date


--18.Find which product has the highest warranty claim rate (total claims ÷ total units sold) — write a CTE that first calculates sales per product and claims per product separately, then joins them.
-- প্রোডাক্ট-ভিত্তিক warranty claim rate (claims ÷ units sold)




with units_aold as(
	SELECT product_id, SUM(quantity) AS total_units
    FROM sales
    GROUP BY product_id
),
claims as (
	SELECT 
		s.product_id,
		count(w.claim_id) as total_claims
	FROM sales as s
	JOIN warranty as w ON s.sale_id = w.sale_id
	group by s.product_id
		
)
select 
	p.product_name,
	u.total_units,
	collesce(c.total_claims,0) as total_claims,
	round(collesce(c.total_claims,0)::numeric / u.total_units * 100,2) as claim_rate_pct
from units_sold as u
join products as p on u.product_id = c.product_id
order by claim_rate_pct desc








--19.Find the top-selling category for each country — this will require multiple CTEs or subqueries (chain: country → store → sales → product → category).




with country_ctg_revenue as(
	SELECT 
		st.country,
		c.category_name,
		sum(s.quantity*p.price) as revenue
	FROM sales as s
	JOIN store as st ON s.store_id = st.store_id
	JOIN products as p ON s.product_id = p.product_id
	JOIN category as c ON p.category_id = c.category_id
	group by 
			st.country,
			c.category_name

	
),
ranked as (
	select *,
		rank() over (partition by country order by revenue desc) as rnk
	from country_ctg_revenue
)
select 
	country,
	category_name,
	revenue
from ranked
where rnk = 1
order by revenue desc



--20.Find the average resolution time by repair status (Pending/In Progress/Completed/Rejected) — assume the gap between claim_date and sale_date represents the delay (note: there's a data limitation here since the warranty table has no "resolved_date" field, so calculate the gap as claim_date − sale_date and group by repair_status).
--repair_status অনুযায়ী average claim delay (claim_date - sale_date)


SELECT 
	w.repair_status,
	round(avg(w.claim_date - s.sale_date),1) as avg_days_to_claim
FROM warranty as w
JOIN sales as s ON w.sale_id = s.sale_id
group by w.repair_status
order by avg_days_to_claim desc








SELECT * FROM category;
SELECT * FROM store;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM warranty;








