-- Подсчет Total Sales, Total Profit, Profit Ratio, Profit per Order, Sales per Customer, Avg. Discount

with t1 as (select round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit)/sum(sales),2) as profit_ratio,
round(avg(discount),2) as avg_discount,
count(distinct order_id) as order_count,
count(distinct customer_id) as customer_count
from public.orders)

select total_sales, total_profit, profit_ratio, avg_discount,
round(total_profit/order_count, 2) as profit_per_order, 
round(total_sales/customer_count, 2) as sales_per_customer 
from t1;


-- Monthly Sales and Profit by Segment 

with ms as (select to_char(order_date, 'YYYY-MM') as month, segment, sales, profit
from public.orders
order by month asc)

select distinct segment, month, round(sum(sales) over (partition by segment, month)) as total_sale,
round(sum(profit) over (partition by segment, month)) as total_profit
from ms
order by month, segment asc


-- Monthly Sales and Profit by Product Category and Subcategory

with pc as (select to_char(order_date, 'YYYY-MM') as month, category, subcategory, sales, profit
from public.orders
order by month asc)

select distinct category, subcategory, month, round(sum(sales) over (partition by category, subcategory, month)) as total_sale,
round(sum(profit) over (partition by category, subcategory, month)) as total_profit
from pc
order by month, category, subcategory asc

-- Sales and Profit by Customer
select distinct customer_id, customer_name, round(sum(sales) over (partition by customer_id)) as sales_customer,
round(sum(profit) over (partition by customer_id)) as profit_customer
from orders
order by customer_name asc

-- Sales and Profit by Region

select distinct region, round(sum(sales) over (partition by region)) as sales_region,
round(sum(profit) over (partition by region)) as profit_region
from orders
order by sales_region desc

-- Sales and Profit by State

select distinct state, round(sum(profit) over (partition by state)) as profit_state,
round(sum(sales) over (partition by state)) as sales_state
from orders
order by profit_state desc, sales_state desc

-- Sales and Profit by Manager

select distinct person as manager, round(sum(profit) over (partition by person)) as profit_manager,
round(sum(sales) over (partition by person)) as sales_manager
from orders
inner join people on orders.region = people.region
order by profit_manager desc, sales_manager desc

-- Returns by %

with r1 as (select distinct (select count(distinct orders.order_id)
from orders
left join returns on orders.order_id = returns.order_id
where returns is not null) as s1,
(select count(distinct orders.order_id) as s2
from orders
left join returns on orders.order_id = returns.order_id
where returns is null) as s2
from orders)

select round(((cast(s1 as numeric)/cast(s2 as numeric))*100),2) as returns
from r1

-- Customer Ranking based on Sales

with rk1 as (select distinct customer_id, customer_name, round(sum(sales) over (partition by customer_id)) as sales_customer
from orders
order by customer_name asc)

select customer_id, customer_name, dense_rank() over (order by sales_customer desc), sales_customer
from rk1



