/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  both first name and last name are in upper case, customer email id,  customer creation year and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Hint: Use CASE statement, no permanent change in the table is required. 
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
*/

## Answer 1.
show databases;

use orders;
create schema orders;
show tables;
DESCRIBE table_name;
SELECT customer_id,
CONCAT(CASE WHEN title = 'Mr' THEN 'Mr.' ELSE 'Ms.' END, ' ',
UPPER(first_name), ' ', UPPER(last_name)) AS customer_name,
email_id,
YEAR(customer_creation_date) AS customer_creation_year,
CASE
WHEN YEAR(customer_creation_date) < 2005 THEN 'A'
WHEN YEAR(customer_creation_date) >= 2005 AND YEAR(customer_creation_date) < 2011 THEN 'B'
WHEN YEAR(customer_creation_date) >= 2011 THEN 'C'
END AS customer_category
FROM ONLINE_CUSTOMER;


/* Q2. Write a query to display the following information for the products, which have not been sold: product_id, product_desc, product_quantity_avail, product_price, inventory values ( product_quantity_avail * product_price), New_Price after applying discount as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 200,000 then apply 20% discount 
ii) If Product Price > 100,000 then apply 15% discount 
iii) if Product Price =< 100,000 then apply 10% discount 
Hint: Use CASE statement, no permanent change in table required. 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] */

## Answer 2.
SELECT P.product_id, P.product_desc, P.product_quantity_avail, P.product_price, 
       P.product_quantity_avail * CASE WHEN P.product_price > 20000 THEN 
              P.product_price - (P.product_price * 0.2)
            WHEN P.product_price > 10000 THEN 
              P.product_price - (P.product_price * 0.15)
            ELSE 
              P.product_price - (P.product_price * 0.1)
       END as New_Price, 
       P.product_quantity_avail * 
       CASE WHEN P.product_price > 20000 THEN 
              P.product_price * 0.2
            WHEN P.product_price > 10000 THEN 
              P.product_price * 0.15
            ELSE 
              P.product_price * 0.1
       END as Inventory_Value
FROM PRODUCTS P
LEFT JOIN ORDER_ITEMS OI
ON P.product_id = OI.product_id
WHERE OI.order_id IS NULL
ORDER BY Inventory_Value DESC



/* Q3. Write a query to display Product_class_code, Product_class_description, 
Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price).
Information should be displayed for only those product_class_code which
 have more than 1,00,000 Inventory Value. Sort the output with respect to
 decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS] */

## Answer 3.
SELECT
pc.product_class_code,
pc.product_class_description,
COUNT(p.product_type) AS "COUNT OF PRODUCT TYPE",
SUM(p.product_quantity_avail * p.product_price) AS "INVENTORY VALUE"
FROM PRODUCT p
JOIN PRODUCT_CLASS pc ON p.product_class_code = pc.product_class_code
GROUP BY pc.product_class_code, pc.product_class_description
HAVING SUM(p.product_quantity_avail * p.product_price) > 100000
ORDER BY "INVENTORY VALUE" DESC;

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
 [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER] */
 
## Answer 4.
SELECT ONLINE_CUSTOMER.customer_id, ONLINE_CUSTOMER.full_name, ONLINE_CUSTOMER.email AS customer_email, ONLINE_CUSTOMER.phone AS customer_phone, ADDRESS.country
FROM ONLINE_CUSTOMER
JOIN ADDRESS ON ONLINE_CUSTOMER.address_id = ADDRESS.address_id
WHERE NOT EXISTS 
(
SELECT *
  FROM ORDER_HEADER
  WHERE ORDER_HEADER.customer_id = ONLINE_CUSTOMER.customer_id AND ORDER_HEADER.status != 'Cancelled'
)




/* Q5. Write a query to display Shipper name, City to which it is catering,
 num of customer catered by the shipper in the city , number of consignment
 delivered to that city for Shipper DHL 
Hint: The answer should only be based on Shipper_Name -- DHL.
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER] */

## Answer 5.  

SELECT 
    SHIPPER.NAME AS 'Shipper Name', 
    ADDRESSS.CITY AS 'City',
    COUNT(*) AS 'Number of Customers',
    COUNT(ORDER_HEADER.ID) AS 'Number of Consignments'
FROM SHIPPER 
    INNER JOIN ONLINE_CUSTOMER ON SHIPPER.ID = ONLINE_CUSTOMER.SHIPPER_ID
    INNER JOIN ADDRESSS ON ONLINE_CUSTOMER.SHIPPING_ADDRESS_ID = ADDRESSS.ID
    INNER JOIN ORDER_HEADER ON ONLINE_CUSTOMER.ID = ORDER_HEADER.ONLINE_CUSTOMER_ID
WHERE SHIPPER.NAME = 'DHL'
GROUP BY SHIPPER.NAME, ADDRESSS.CITY


/* Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show inventory Status of products as per below condition: 
a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, 
need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
  [NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] */

## Answer 6a.
SELECT PRODUCT.product_id, PRODUCT.product_desc, PRODUCT.quantity_avail, SUM(ORDER_ITEMS.quantity) AS quantity_sold,
CASE 
WHEN SUM(ORDER_ITEMS.quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
  WHEN PRODUCT.quantity_avail < (0.1 * SUM(OpaymentinventoryRDER_ITEMS.quantity)) THEN 'Low inventory, need to add inventory'
  WHEN PRODUCT.quantity_avail < (0.5 * SUM(ORDER_ITEMS.quantity)) THEN 'Medium inventory, need to add some inventory'
  ELSE 'Sufficient inventory'
END AS inventory_status
FROM PRODUCT
JOIN ORDER_ITEMS ON PRODUCT.product_id = ORDER_ITEMS.product_id
WHERE (PRODUCT.category = 'Electronics' OR PRODUCT.category = 'Computer')
GROUP BY PRODUCT.product_id

#6B
SELECT PRODUCT.product_id, PRODUCT.product_desc, PRODUCT.quantity_avail, SUM(ORDER_ITEMS.quantity) AS quantity_sold,
CASE 
  WHEN SUM(ORDER_ITEMS.quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
  WHEN PRODUCT.quantity_avail < (0.2 * SUM(ORDER_ITEMS.quantity)) THEN 'Low inventory, need to add inventory'
  WHEN PRODUCT.quantity_avail < (0.6 * SUM(ORDER_ITEMS.quantity)) THEN 'Medium inventory, need to add some inventory'
  ELSE 'Sufficient inventory'
END AS inventory_status
FROM PRODUCT
JOIN ORDER_ITEMS ON PRODUCT.product_id = ORDER_ITEMS.product_id
WHERE (PRODUCT.category = 'Mobiles' OR PRODUCT.category = 'Watches')
GROUP BY PRODUCT.product_id

#6c.
SELECT PRODUCT.product_id, PRODUCT.product_desc, PRODUCT.quantity_avail, SUM(ORDER_ITEMS.quantity) AS quantity_sold,
CASE 
  WHEN SUM(ORDER_ITEMS.quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
  WHEN PRODUCT.quantity_avail < (0.3 * SUM(ORDER_ITEMS.quantity)) THEN 'Low inventory, need to add inventory'
  WHEN PRODUCT.quantity_avail < (0.7 * SUM(ORDER_ITEMS.quantity)) THEN 'Medium inventory, need to add some inventory'
  ELSE 'Sufficient inventory'
END AS inventory_status
FROM PRODUCT
JOIN ORDER_ITEMS ON PRODUCT.product_id = ORDER_ITEMS.product_id
WHERE (PRODUCT.category NOT IN ('Electronics', 'Computer', 'Mobiles', 'Watches'))
GROUP BY PRODUCT.product_id




/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) 
that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT] */

## Answer 7.
SELECT order_id, SUM(volume)
FROM CARTON c
INNER JOIN ORDER_ITEMS oi ON c.carton_id = oi.carton_id
INNER JOIN PRODUCT p ON p.product_id = oi.product_id
WHERE c.carton_id = 10
GROUP BY order_id
HAVING SUM(volume) = MAX(SUM(volume))




/* Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER] */

## Answer 8.

SELECT ONLINE_CUSTOMER.CUSTOMER_ID,
       CONCAT(ONLINE_CUSTOMER.FIRST_NAME, ' ', ONLINE_CUSTOMER.LAST_NAME) AS CUSTOMER_NAME,
       SUM(ORDER_ITEMS.QUANTITY) AS TOTAL_QUANTITY,
       SUM(ORDER_ITEMS.QUANTITY * PRODUCT.UNIT_PRICE) AS TOTAL_VALUE
FROM ONLINE_CUSTOMER 
INNER JOIN ORDER_HEADER
    ON ONLINE_CUSTOMER.CUSTOMER_ID = ORDER_HEADER.CUSTOMER_ID
INNER JOIN ORDER_ITEMS 
    ON ORDER_HEADER.ORDER_ID = ORDER_ITEMS.ORDER_ID
INNER JOIN PRODUCT
    ON ORDER_ITEMS.PRODUCT_ID = PRODUCT.PRODUCT_ID
WHERE ORDER_HEADER.PAYMENT_MODE = 'Cash'
      AND ONLINE_CUSTOMER.LAST_NAME like 'G%'
GROUP BY ONLINE_CUSTOMER.CUSTOMER_ID





/* Q9. Write a query to display product_id, product_desc and total quantity of products
 which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
Display the output in descending order with respect to the tot_qty. 
Expected 6 rows in final output

Hint:  (USE SUB-QUERY)
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]*/

## Answer 9.

SELECT oi.product_id, p.product_desc, SUM(oi.qty) as tot_qty
FROM order_items oi
INNER JOIN product p ON oi.product_id = p.product_id
INNER JOIN order_head oh ON oi.order_id = oh.order_id
INNER JOIN online_customer oc ON oh.customer_id = oc.customer_id
INNER JOIN address a ON oc.customer_id = a.customer_id
WHERE oh.order_id IN (
    SELECT oh.order_id
    FROM order_items oi
    INNER JOIN product p ON oi.product_id = p.product_id
    INNER JOIN order_head oh ON oi.order_id = oh.order_id
    WHERE oi.product_id = 201
)
AND a.city NOT IN ('Bangalore', 'New Delhi')
GROUP BY oi.product_id, p.product_desc
ORDER BY tot_qty DESC;


/* Q10. Write a query to display the order_id, customer_id and customer fullname,
 total quantity of products shipped for order ids which are even and shipped to
 address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS] */

## Answer 10.
SELECT oh.order_id, oc.customer_id, oc.first_name || ' ' || oc.last_name AS CustomerFullName, SUM(oi.quantity) AS TotalQuantity
FROM online_customer oc 
  JOIN order_header oh 
    ON oc.customer_id = oh.customer_id
  JOIN order_items oi
    ON oh.order_id = oi.order_id
  JOIN address a
    ON oh.address_id = a.address_id
WHERE oh.order_id % 2 = 0
  AND a.postal_code NOT LIKE '5%'
GROUP BY oh.order_id, oc.customer_id, CustomerFullName;

