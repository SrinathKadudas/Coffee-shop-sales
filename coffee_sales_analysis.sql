create database coffee_shop_sales;
use coffee_shop_sales;
select * from coffee_shop_sales;
describe coffee_shop_sales;
update coffee_shop_sales set transaction_date = str_to_date(transaction_date, '%d/%m/%Y');
alter table coffee_shop_sales 
modify column transaction_date date;
update coffee_shop_sales set transaction_time = str_to_date(transaction_time, '%H:%i:%s');
alter table coffee_shop_sales modify column transaction_time time;
alter table coffee_shop_sales change column ï»¿transaction_id transaction_id int;


-- Sales analysis
-- 1. calculate the total sales for each respective month
select month(transaction_date), round(sum(transaction_qty * unit_price),0) as total_sales 
from coffee_shop_sales where month(transaction_date) group by month(transaction_date) 
order by month(transaction_date);

-- 2. determine the month on month sales increase or decrease in sales
-- calculate the difference in sales between the selected month and the previous month

select month(transaction_date) as month, 
sum(transaction_qty * unit_price) as total_sales, 
lag(sum(transaction_qty * unit_price)) over (order by month(transaction_date)) as previous_sales,
sum(transaction_qty * unit_price) - lag(sum(transaction_qty * unit_price)) over (order by month(transaction_date)) as difference_in_sales,
case 
when sum(transaction_qty * unit_price) > lag(sum(transaction_qty * unit_price)) over(order by month(transaction_date)) then ' increase in sales'
when sum(transaction_qty * unit_price) < lag(sum(transaction_qty * unit_price)) over(order by month(transaction_date)) then 'decrease in sales'
when sum(transaction_qty * unit_price) = lag(sum(transaction_qty * unit_price)) over(order by month(transaction_date)) then 'no profit no loss'
end sales_distribution
from coffee_shop_sales where month(transaction_date)
group by month(transaction_date) 
order by month(transaction_date);


-- order analysis
-- calculate the total number of orders for each respective month
select month(transaction_date), count(transaction_id) as total_orders from coffee_shop_sales 
group by month(transaction_date) order by month(transaction_date);

-- 2. determine the month on month sales increase or decrease in the number of orders
-- calculate the difference in the number of orders between the selected month and the previous month
select month(transaction_date) as month_no, count(transaction_id) as current_month_orders,
lag(count(transaction_id)) over(order by month(transaction_date)) as previous_month_orders,
count(transaction_id) - lag(count(transaction_id)) over(order by month(transaction_date)) as difference_in_orders,
case
when count(transaction_id) > lag(count(transaction_id)) over(order by month(transaction_date)) then 'increase in orders'
when count(transaction_id) < lag(count(transaction_id)) over(order by month(transaction_date)) then 'decrease in orders'
when count(transaction_id)=lag(count(transaction_id)) over(order by month(transaction_date)) then 'same orders'
end order_distribution
from coffee_shop_sales group by month(transaction_date) order by month(transaction_date);

-- total quantity sold analysis
-- calculate the total quantity sold for each respective month
select month(transaction_date), sum(transaction_qty) as quantity_sold from coffee_shop_sales 
group by month(transaction_date) order by month(transaction_date);

-- determine the month on month  increase or decrease in the total quantity sold
-- calculate the difference in the total quantity sold between the selected month and the previous month

select month(transaction_date), sum(transaction_qty) as quantity_sold_current_month, 
lag(sum(transaction_qty)) over(order by month(transaction_date)) as previous_month_quantity,
sum(transaction_qty) - lag(sum(transaction_qty)) over(order by month(transaction_date)) as difference_in_qty_sold,
case
when sum(transaction_qty) > lag(sum(transaction_qty)) over(order by month(transaction_date)) then 'increse in qty sold'
when sum(transaction_qty) < lag(sum(transaction_qty)) over(order by month(transaction_date)) then 'decrease in qty sold'
when sum(transaction_qty) = lag(sum(transaction_qty)) over(order by month(transaction_date)) then 'no change in qty sold'
end as qty_sold_distribution
from coffee_shop_sales 
group by month(transaction_date) order by month(transaction_date);


select concat(round(sum(transaction_qty * unit_price)/1000,1),'K') as total_sales,
sum(transaction_qty) as total_qty_sold,
count(transaction_id) as total_orders from coffee_shop_sales where transaction_date = '2023-03-27';


select month(transaction_date) as monthNo,
case when dayofweek(transaction_date) in (1,7) then 'weekend'
else 'weekdays'
end as day_type,
concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales from coffee_shop_sales 
group by month(transaction_date), case when dayofweek(transaction_date) in (1,7) then 'weekend'
else 'weekdays'
end;



select store_location, month(transaction_date) as monthno, concat(round(sum(transaction_qty * unit_price)/1000,1),'K') as total_sales 
from coffee_shop_sales
group by store_location, month(transaction_date) order by sum(transaction_qty * unit_price) desc;

-- sales by store location
select store_location,  concat(round(sum(transaction_qty * unit_price)/1000,1),'K') as total_sales 
from coffee_shop_sales where month(transaction_date) =5
group by store_location order by sum(transaction_qty * unit_price) desc;

-- daily sales with average line
select month(transaction_date), avg(unit_price * transaction_qty) as avereage_sales
from coffee_shop_sales group by month(transaction_date);




-- sales analysis by product category
select product_category, sum(transaction_qty * unit_price) as total_sales 
from coffee_shop_sales group by product_category order by sum(transaction_qty * unit_price) desc;


-- top 10 products by sales
select product_type, sum(transaction_qty * unit_price) as total_sales from coffee_shop_sales 
group by product_type order by sum(transaction_qty * unit_price) desc limit 10
