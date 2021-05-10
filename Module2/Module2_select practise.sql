/* Overview (обзор ключевых метрик)*/
-- Total Sales
select round(sum(sales), 0) as total_sales
from public.orders o;

-- Total Profit
select round(sum(profit), 0) as total_profit
from public.orders o;

-- Profit Ratio
select round(sum(profit)/sum(sales)*100, 2) as profit_ratio
from public.orders o ;

-- Sales per Order
select round(sum(sales)/count(distinct order_id), 2) as avg_sales
from public.orders o ;

-- Profit per Order
select round(sum(profit)/count(order_id), 2) as avg_profit
from public.orders o ;

-- Sales per Customer
select round(sum(sales)/count(distinct customer_id), 2) as avg_sales_customer
from public.orders o ;

-- Avg. Discount
select round(avg(discount), 2) as avg_discount
from public.orders o;

-- Monthly Sales by Segment 
select segment, extract('month' from order_date) as m
,round(sum(sales), 2) as sum_sales
from public.orders o 
group by segment, extract('month' from order_date)
order by segment, m;

-- Monthly Sales by Product Category 
select category, extract('month' from order_date) as m
,round(sum(sales), 2) as sum_sales
from public.orders o 
group by category, extract('month' from order_date)
order by category, m;

/*Product Dashboard (Продуктовые метрики)*/
-- Sales by Product Category over time
select category
,round(sum(sales), 2) as sum_sales
from public.orders o 
group by category
order by sum_sales desc;

/*Customer Analysis*/
-- Sales and Profit by Customer
select customer_name
, round(sum(sales), 0) as total_sales
, round(sum(profit), 0) as total_profit
from public.orders o 
left join public."returns" r 
on r.order_id = o.order_id 
where r.order_id is null
group by customer_name
order by total_sales desc, total_profit;

-- Customer Ranking
select customer_name
, round(sum(sales), 2) as total_sales 
from public.orders o 
left join public."returns" r 
on r.order_id = o.order_id 
where r.order_id is null
group by customer_name
order by total_sales desc 
limit 10;

-- Sales per region
select o.region 
,round(sum(sales), 2) as total_sales
from public.orders o 
left join public."returns" r 
on r.order_id = o.order_id 
left join public.people p 
on p.region = o. region 
where r.order_id is null
group by o.region
order by total_sales desc;

-- Sales per person
select p.person 
,round(sum(sales), 2) as total_sales
from public.orders o 
left join public."returns" r 
on r.order_id = o.order_id 
left join public.people p 
on p.region = o. region 
where r.order_id is null
group by p.person 
order by total_sales desc;


select *
from public.people

select *
from orders o 