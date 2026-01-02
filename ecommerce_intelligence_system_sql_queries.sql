CREATE TABLE fact_sales (
    order_id VARCHAR PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR,
    product_category VARCHAR,
    region VARCHAR,
    payment_method VARCHAR,
    product_price NUMERIC(10,2),
    quantity INT,
    discount_percent NUMERIC(5,2),
    order_value NUMERIC(12,2),
    net_order_value NUMERIC(12,2),
    delivery_days INT,
    customer_rating NUMERIC(3,1),
    is_returned INT
);

CREATE TABLE monthly_kpi (
    month VARCHAR(7),
    total_orders INT,
    total_revenue NUMERIC(14,2),
    avg_order_value NUMERIC(12,2),
    return_rate NUMERIC(5,4),
    avg_delivery_days NUMERIC(6,2)
);

CREATE TABLE risk_table (
    order_id VARCHAR,
    customer_id VARCHAR,
    product_category VARCHAR,
    region VARCHAR,
    net_order_value NUMERIC(12,2),
    risk_score INT,
    risk_level VARCHAR
);

CREATE TABLE customer_kpi (
    customer_id VARCHAR,
    total_orders INT,
    total_spend NUMERIC(14,2),
    avg_rating NUMERIC(3,2),
    return_rate NUMERIC(5,4),
    avg_delivery_days NUMERIC(6,2),
    customer_segment VARCHAR
);

CREATE TABLE customer_kpi (
    customer_id VARCHAR,
    total_orders INT,
    total_spend NUMERIC(14,2),
    avg_rating NUMERIC(3,2),
    return_rate NUMERIC(5,4),
    avg_delivery_days NUMERIC(6,2),
    customer_segment VARCHAR
);

select * from fact_sales;
select * from monthly_kpi
select * from category_kpi
select * from risk_table
select * from customer_kpi



--1.Month-over-month Revenue Growth--
SELECT
    month,
    total_revenue,
    total_revenue
      - LAG(total_revenue) OVER (ORDER BY month) AS revenue_growth,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY month))
        / LAG(total_revenue) OVER (ORDER BY month) * 100, 2
    ) AS growth_percent
From monthly_kpi;
		
--2.Top 5 revenue generating categories--
SELECT 
      product_category,
	  total_revenue
FROM category_kpi
ORDER BY total_revenue DESC
LIMIT 5;

--3.Categories with high Revenue but high return risk--
SELECT 
      product_category,
	  total_revenue,
	  return_rate
FROM category_kpi
WHERE return_rate>0.25
ORDER BY total_revenue DESC;

--Emerging risk
SELECT 
      product_category,
	  total_revenue,
	  return_rate
FROM category_kpi
WHERE return_rate>0.07
ORDER BY total_revenue DESC;

     
--4.Orders contributing most to risk--
SELECT
      order_id,
	  customer_id,
	  product_category,
	  net_order_value,
	  risk_score,
	  risk_level
FROM risk_table
WHERE risk_level = 'HIGH'
ORDER BY risk_score DESC, net_order_value DESC;

--5.% of orders at high risk--
SELECT
      ROUND(
            COUNT(*)FILTER(WHERE risk_level='HIGH')*100.0/COUNT(*),
			2
			)AS high_risk_percentage
FROM risk_table

select risk_level,count(*)
from risk_table
group by risk_level;

select  distinct risk_level from risk_table where upper(risk_level)='high'

--6.Top 10 customers by lifetime value--
SELECT
      customer_id,
	  total_spend,
	  total_orders
FROM customer_kpi
ORDER BY total_spend DESC
LIMIT 10;

--7.Customers with high spend but poor experience(customer churn risk detection)
SELECT
      customer_id,
	  total_spend,
	  avg_rating,
	  return_rate
FROM customer_kpi
WHERE avg_rating <3
ORDER BY total_spend DESC;

--8.Revenue contribution by region--
SELECT
      region,
	  SUM(net_order_value) AS total_revenue
FROM fact_sales
GROUP BY region
ORDER BY total_revenue DESC;

--9.Average delivery days by region(SLA Monitoring)
SELECT
     region,
	 ROUND(AVG(delivery_days),2) AS avg_delivery_days
FROM fact_sales
GROUP BY region
ORDER BY avg_delivery_days DESC;

--10.Return rate by payment method(Fraud/payment behavior analysis)
SELECT 
      payment_method,
	  ROUND(AVG(is_returned)*100,2) AS return_rate_percent
FROM fact_sales
GROUP BY payment_method
ORDER BY return_rate_percent DESC;

--11.Revenue leakage due to returns--
SELECT
     SUM(net_order_value) as revenue_lost
FROM fact_sales
WHERE is_returned = 1;

--12.Orders with Heavy discounts(>30%)
SELECT
      order_id,
	  product_category,
	  discount_percent,
	  net_order_value
FROM fact_sales
WHERE discount_percent >=20
ORDER BY discount_percent DESC;


SELECT
      order_id,
	  product_category,
	  discount_percent,
	  net_order_value,
      case 
          when discount_percent >=20 then 'high'
          else 'low'
end as discount_risk
from fact_sales;

--13.Category wise risk concentration
SELECT
      product_category,
	  COUNT(*) AS high_risk_orders
FROM risk_table
WHERE risk_level = 'HIGH'
GROUP BY product_category
ORDER BY high_risk_orders DESC;

--14.Repeat vs one time customers
SELECT
    CASE
	    WHEN total_orders = 1 THEN 'one-Time'
		ELSE 'Repeat'
	END AS customer_type,
	COUNT(*) AS customers
FROM customer_kpi
GROUP BY customer_type;

--15.Revenue share by customer segment--
SELECT
     customer_segment,
	 SUM(total_spend) AS revenue
FROM customer_kpi
GROUP BY customer_segment
ORDER BY revenue DESC;


