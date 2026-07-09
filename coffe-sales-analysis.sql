create database coffe_sales_db;

ALTER TABLE `coffe_shop_sales`
RENAME TO coffee_shop_sales; 

select * from coffee_shop_sales;

set sql_safe_updates = 0;
update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%d/%m/%Y');

update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify transaction_date date,
modify transaction_time time;

describe coffee_shop_sales;

alter table coffee_shop_sales
rename column ï»¿transaction_id to transaction_id;

select * from coffee_shop_sales;

-- TOTAL SALES 
select 
round(sum(transaction_qty * unit_price),2) as Total_sales
from coffee_shop_sales;


-- TOTAL SALES FOR EACH MONTH
select 
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
round(sum(transaction_qty * unit_price),2)  as Total_Sales
from coffee_shop_sales
group by 
month_no,
Month_name
;

-- MOM INCREASE FOR EACH MONTH USING SUBQUERY 

select *,
lag(current_sales,1) over(order by month_no) as previous_sales,
concat(
Round((Current_sales - lag(current_sales,1) over(order by month_no))
/
lag(current_sales,1) over(order by month_no) * 100, 2),
'%')
 as MoM_Percentage,
 round(current_sales - lag(current_sales,1) over(order by month_no),2) as Mom_Sales_Diff

from
(select 
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
round(sum(transaction_qty * unit_price),2)  as Current_Sales
from coffee_shop_sales
group by 
month_no,
Month_name) t
;

-- TOTAL NUMBER OF ORDERS 
select
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
group by 
month_no,
Month_name;


-- MOM INCREASE ORDERS FOR EACH MONTH USING SUBQUERY 

select *,
lag(Current_orders,1) over(order by month_no) as previous_orders,
concat(
Round((Current_orders - lag(current_orders,1) over(order by month_no))
/
lag(current_orders,1) over(order by month_no) * 100, 2),
'%')
 as MoM_orders_Percentage,
 round(current_orders - lag(current_orders,1) over(order by month_no),2) as Mom_orders_Diff

from
(select 
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
COUNT(transaction_id) AS Current_orders
from coffee_shop_sales
group by 
month_no,
Month_name) t
;

-- TOTAL QUANTITY SOLD FOR EACH MONTH 

select 
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
sum(transaction_qty) As total_quantity
from coffee_shop_sales
group by 
month_no,
Month_name;

 
 -- MOM INCREASE quantity SOLD FOR EACH MONTH USING SUBQUERY AND MoM QTY SOLD DIFF

select *,
lag(Current_qty_sold,1) over(order by month_no) as Prev_qty_sold,
concat(
Round((Current_qty_sold - lag(Current_qty_sold,1) over(order by month_no))
/
lag(Current_qty_sold,1) over(order by month_no) * 100, 2),
'%')
 as MoM_qty_sold_Percentage,
 round(Current_qty_sold - lag(Current_qty_sold,1) over(order by month_no),2) as Mom_qty_sold_Diff

from
(select 
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
sum(transaction_qty) AS Current_qty_sold
from coffee_shop_sales
group by 
month_no,
Month_name) t
;

SELECT * FROM coffee_shop_sales;

SELECT 
 transaction_date,
month(transaction_date) month_no,
monthname(transaction_date) as month_name,
dayofmonth(transaction_date) as day_of_month,
round(sum(transaction_qty * unit_price),2) as Total_sales,
SUM(transaction_qty) AS total_qty_sold,
count(transaction_id) as total_orders
FROM coffee_shop_sales
group by 
 transaction_date,
month_no,
day_of_month,
month_name;


select * from coffee_shop_sales;

-- WEEKEND AND WEEKDAYS SALES
select 
month(transaction_date) month_no,
monthname(transaction_date) as month_name,
round(sum(transaction_qty * unit_price),2) as Total_sales,
case when dayofweek(transaction_date) in(1,7) then 'Weekends'
else 'Weekdays'
end as day_type
from coffee_shop_sales
group by 
month_no,
month_name,
day_type;

-- Sales by different store location 
select 
store_location,
round(sum(transaction_qty * unit_price),2) as total_sales
from coffee_shop_sales
group by store_location
order by total_sales;


select * from coffee_shop_sales;

-- Sales by different store location 
select 
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
store_location,
round(sum(transaction_qty * unit_price),2) as Current_sales
from coffee_shop_sales
group by
month_no,
month_name,
store_location;

-- SALES BY STORE LOCSTION INCLUDING MoM DIFF
select * ,
lag(current_sales,1) over(partition by store_location order by month_no) as Prev_sales,
round(current_sales - (lag(current_sales,1) over(partition by store_location order by month_no)),2) as MoM_sales_diff 
from 

(select 
month(transaction_date) as Month_no,
monthname(transaction_date) as Month_name,
store_location,
round(sum(transaction_qty * unit_price),2) as Current_sales
from coffee_shop_sales
group by
month_no,
month_name,
store_location)t;



/* DAILY SALES AND SEGMENT OF AVG SALES FOR EACH MONTH AND COMAPARING TOTAL DAILY SLAES WITH AVG SALES 
IF TOTAL SLAES > AVG SALES ABOVE AVERAGE, < AVG SALES "BELLOW AVG" ELSE "AVG" */

SELECT *,
    ROUND(AVG(total_sales) OVER(partition by month_no),2) AS Avg_sales,
    CASE WHEN 
   total_sales > ROUND(AVG(total_sales) OVER(partition by month_no),2) then 'Above Average'
   when total_sales < ROUND(AVG(total_sales) OVER(partition by month_no),2)  then 'Below Average'
   else 'Average'
   end as sales_status

FROM
(SELECT 
transaction_date,
MONTH(transaction_date) AS month_no,
MONTHNAME(transaction_date) AS month_name,
DAYOFMONTH(transaction_date) AS day_of_month,
ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
FROM coffee_shop_sales
GROUP BY transaction_date
) t;

-- OVERALL SALES BY PRODUCT CATEGORY
-- TO GET THE PRODUCT WITH THE HIGHEST SALES
SELECT
product_category,
round(sum(transaction_qty * unit_price),2) as Total_sales
FROM coffee_shop_sales
group by product_category
order by total_sales desc;

-- SALES ANALYSIS BY PRODUCT OVER TIME
SELECT
MONTH(transaction_date) AS month_no,
MONTHNAME(transaction_date) AS month_name,
product_category,
round(sum(transaction_qty * unit_price),2) as Total_sales
FROM coffee_shop_sales
group by 
month_no,
month_name,
product_category
order by
month_no,
total_sales desc;

-- TOP 10 PRODUCTS BY SALES

SELECT
product_type,
product_category,
round(sum(transaction_qty * unit_price),2) as Total_sales
FROM coffee_shop_sales
group by 
product_type,
product_category
order by total_sales desc
limit 10;


--  TOTAL SALES, ORDERS, QUANTITY BY DAYS AND HOURS FOR EACH MONTH
SELECT
month(transaction_date) as month_no,
monthname(transaction_date) as month_name,
dayofweek(transaction_date) as Day_of_week,
hour(transaction_time) time_hour,
sum(transaction_qty) as total_qty_sold,
count(transaction_id) as tota_orders,
round(sum(transaction_qty * unit_price),2) as Total_sales
FROM coffee_shop_sales
group by 
month_no,
day_of_week,
month_name,
time_hour
order by MONTH_NO;

--  TOTAL SALES, ORDERS, QUANTITY FOR MAY 1 IN THE 14TH HOUR
select 
round(sum(transaction_qty * unit_price),2) as Total_sales,
sum(transaction_qty) as Total_qty,
count(transaction_id) as total_orders
from coffee_shop_sales
where 
month(transaction_date) = 5
and dayofweek(transaction_date) = 1 
and hour(transaction_time) = 14;

-- sales by hours in month of may i.e month 5
SELECT 
hour(transaction_time) time_hour,
round(sum(transaction_qty * unit_price),2) as Total_sales
from coffee_shop_sales
where 
month(transaction_date) = 5
GROUP BY 
time_hour
order by time_hour;


-- SALES BY DAY OF WEEK IN THE MONTH OF MAY 
SELECT
dayofweek(transaction_date) day_no,
    DAYNAME(transaction_date) AS day_name,
    ROUND(SUM(transaction_qty * unit_price),2) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY
day_no,
day_name
ORDER BY
day_no asc;
