-- SQL queries

-- Coffee shop sales project

-- Basic conversions as per the data.
create database coffee_shop_sales;
-- After creating the database, the csv file is imported using table data import wizard. 
use coffee_shop_sales;
select * from coffee_shop_sales;
describe coffee_shop_sales;
-- we observe the transaction_date and transaction_time are in text format which should be converted to date format. 

-- Changing the data type and conversions of the table:

update coffee_shop_sales set transaction_date = str_to_date(transaction_date, '%d/%m/%Y'); 
alter table coffee_shop_sales modify column transaction_date date;
-- The code first updates the transaction_date entries in the coffee_shop_sales table from a string format to a DATE format using the STR_TO_DATE function. Then, it modifies the transaction_date column to have the DATE data type, ensuring that future entries will be stored in the correct format.

update coffee_shop_sales set transaction_time = str_to_date(transaction_time, '%H:%i:%s');
alter table coffee_shop_sales modify column transaction_time time;

-- The code first updates the transaction_time entries in the coffee_shop_sales table from a string format to a TIME format using the STR_TO_DATE function. Then, it modifies the transaction_time column to have the TIME data type, ensuring that future entries will be stored in the correct format.
 

alter table coffee_shop_sales change column ï»¿transaction_id transaction_id int;
-- There are some symbols at the beginning of transaction_id name, we alter that to transaction_id using the above statement.
 


-- Sales analysis:
-- calculate the total sales for each respective month:
select month(transaction_date), round(sum(transaction_qty * unit_price),0) as total_sales 
from coffee_shop_sales group by month(transaction_date) 
order by month(transaction_date);
 

-- calculate the total sales for any particular given month:
select month(transaction_date), round(sum(transaction_qty * unit_price),0) as total_sales 
from coffee_shop_sales where month(transaction_date) = 5 group by month(transaction_date);
 


-- Determine the month-on-month sales increase or decrease in sales:
-- calculate the difference in sales between the selected month and the previous month:
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

 

-- Order analysis:
calculate the total number of orders for each respective month:
select month(transaction_date), count(transaction_id) as total_orders from coffee_shop_sales 
group by month(transaction_date) order by month(transaction_date);
 

-- calculate the total orders for any particular given month:
select month(transaction_date), count(transaction_id) as total_orders from coffee_shop_sales where month(transaction_date) = 4 
group by month(transaction_date);
 


-- Determine the month-on-month sales increase or decrease in the number of orders:
-- calculate the difference in the number of orders between the selected month and the previous month:
select month(transaction_date) as month_no, count(transaction_id) as current_month_orders,
lag(count(transaction_id)) over(order by month(transaction_date)) as previous_month_orders,
count(transaction_id) - lag(count(transaction_id)) over(order by month(transaction_date)) as difference_in_orders,
case
when count(transaction_id) > lag(count(transaction_id)) over(order by month(transaction_date)) then 'increase in orders'
when count(transaction_id) < lag(count(transaction_id)) over(order by month(transaction_date)) then 'decrease in orders'
when count(transaction_id)=lag(count(transaction_id)) over(order by month(transaction_date)) then 'same orders'
end order_distribution
from coffee_shop_sales group by month(transaction_date) order by month(transaction_date);

 



-- Total quantity sold analysis:
-- calculate the total quantity sold for each respective month:
select month(transaction_date), sum(transaction_qty) as quantity_sold from coffee_shop_sales 
group by month(transaction_date) order by month(transaction_date);
 

-- calculate the total quantity sold for any particular month
select month(transaction_date), sum(transaction_qty) as quantity_sold from coffee_shop_sales where month(transaction_date) = 4 group by month(transaction_date);
 


-- Determine the month on month increase or decrease in the total quantity sold:
-- Calculate the difference in the total quantity sold between the selected month and the previous month:

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

 


-- daily sales, quantity and total order analysis by any given date

select transaction_date, concat(round(sum(transaction_qty * unit_price)/1000,1),'K') as total_sales,
sum(transaction_qty) as total_qty_sold,
count(transaction_id) as total_orders from coffee_shop_sales where transaction_date = '2023-03-11';

 

-- Day by day SALES FOR a given month
select day(transaction_date) as day_of_month, round(sum(unit_price * transaction_qty),1) as total_sales
from coffee_shop_sales where month(transaction_date) = 5 group by day(transaction_date) order by day(transaction_date);
                      

-- SALES BY WEEKDAY / WEEKEND:
select month(transaction_date) as monthNo,
case when dayofweek(transaction_date) in (1,7) then 'weekend'
else 'weekdays'
end as day_type,
concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales from coffee_shop_sales 
group by month(transaction_date), case when dayofweek(transaction_date) in (1,7) then 'weekend'
else 'weekdays'
end;
 


-- sales by store location for all the months 
select store_location, month(transaction_date) as monthno, concat(round(sum(transaction_qty * unit_price)/1000,1),'K') as total_sales 
from coffee_shop_sales group by store_location, month(transaction_date) order by sum(transaction_qty * unit_price) desc;
 
-- sales by store location for a given month
select store_location,  concat(round(sum(transaction_qty * unit_price)/1000,1),'K') as total_sales 
from coffee_shop_sales where month(transaction_date) =5 group by store_location order by sum(transaction_qty * unit_price) desc;

 

-- Daily sales with average line:
select month(transaction_date), avg(unit_price * transaction_qty) as avereage_sales
from coffee_shop_sales group by month(transaction_date);
 


-- comparing daily sales with average sales – if greater than “above average” and lesser than “below average”
select day_of_month, total_sales, avg_sales,
case
when total_sales > avg_sales then "above average"
when total_sales < avg_sales then "below average"
else "equal to average"
end as sales_status from (
select date(transaction_date) as day_of_month, sum(transaction_qty * unit_price) as total_sales, avg(sum(transaction_qty * unit_price)) over()
as avg_sales from coffee_shop_sales where month(transaction_date) = 5 group by date(transaction_date)) as sales_data order by day_of_month
   
-- Sales analysis by product category:
select product_category, sum(transaction_qty * unit_price) as total_sales 
from coffee_shop_sales group by product_category order by sum(transaction_qty * unit_price) desc;

 

-- Top 10 products by sales:
select product_type, sum(transaction_qty * unit_price) as total_sales from coffee_shop_sales 
group by product_type order by sum(transaction_qty * unit_price) desc limit 10
 
