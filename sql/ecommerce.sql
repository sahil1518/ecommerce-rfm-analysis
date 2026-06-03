
-- =============================================
-- E-Commerce RFM Analysis
-- Database: EcommerceDB

-- =============================================

USE EcommerceDB;
GO

-- =============================================
-- Query 1: Basic RFM Calculation
-- Business Question: What is the recency, frequency
-- and monetary value of each customer?
-- =============================================
WITH rfm AS (
    SELECT
        customer_id,
        MAX(invoice_date)                              AS last_purchase_date,
        DATEDIFF(day, MAX(invoice_date), '2011-12-09') AS recency_days,
        COUNT(DISTINCT invoice_no)                     AS frequency,
        SUM(quantity * unit_price)                     AS monetary
    FROM online_retail
    GROUP BY customer_id
)
SELECT
    MIN(recency_days)  AS min_recency,
    MAX(recency_days)  AS max_recency,
    MIN(frequency)     AS min_frequency,
    MAX(frequency)     AS max_frequency,
    MIN(monetary)      AS min_monetary,
    MAX(monetary)      AS max_monetary,
    AVG(monetary)      AS avg_monetary
FROM rfm;
GO

-- =============================================
-- Query 2: RFM Scoring (1 to 4 scale)
-- Business Question: How do we score each customer
-- on recency, frequency and monetary value?
-- =============================================
WITH rfm_scores AS (
    SELECT
        customer_id,
        DATEDIFF(day, MAX(invoice_date), '2011-12-09') AS recency_days,
        COUNT(DISTINCT invoice_no)                     AS frequency,
        SUM(quantity * unit_price)                     AS monetary,
        CASE
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 90  THEN 4
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 180 THEN 3
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 365 THEN 2
            ELSE 1
        END AS r_score,
        CASE
            WHEN COUNT(DISTINCT invoice_no) = 1              THEN 1
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 2 AND 5  THEN 2
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 6 AND 15 THEN 3
            ELSE 4
        END AS f_score,
        CASE
            WHEN SUM(quantity * unit_price) BETWEEN 0    AND 500   THEN 1
            WHEN SUM(quantity * unit_price) BETWEEN 501  AND 2000  THEN 2
            WHEN SUM(quantity * unit_price) BETWEEN 2001 AND 10000 THEN 3
            ELSE 4
        END AS m_score
    FROM online_retail
    GROUP BY customer_id
)
SELECT
    MAX(r_score) AS max_r_score,
    MAX(f_score) AS max_f_score,
    MAX(m_score) AS max_m_score,
    MIN(r_score) AS min_r_score,
    MIN(f_score) AS min_f_score,
    MIN(m_score) AS min_m_score
FROM rfm_scores;
GO

-- =============================================
-- Query 3: Customer Segmentation
-- Business Question: Which segment does each
-- customer belong to based on RFM scores?
-- =============================================
WITH rfm_scores AS (
    SELECT
        customer_id,
        DATEDIFF(day, MAX(invoice_date), '2011-12-09') AS recency_days,
        COUNT(DISTINCT invoice_no)                     AS frequency,
        SUM(quantity * unit_price)                     AS monetary,
        CASE
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 90  THEN 4
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 180 THEN 3
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 365 THEN 2
            ELSE 1
        END AS r_score,
        CASE
            WHEN COUNT(DISTINCT invoice_no) = 1              THEN 1
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 2 AND 5  THEN 2
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 6 AND 15 THEN 3
            ELSE 4
        END AS f_score,
        CASE
            WHEN SUM(quantity * unit_price) BETWEEN 0    AND 500   THEN 1
            WHEN SUM(quantity * unit_price) BETWEEN 501  AND 2000  THEN 2
            WHEN SUM(quantity * unit_price) BETWEEN 2001 AND 10000 THEN 3
            ELSE 4
        END AS m_score
    FROM online_retail
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CASE
            WHEN r_score = 4 AND f_score = 4   THEN 'Champions'
            WHEN f_score = 4 AND r_score >= 3  THEN 'Loyal'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score = 1 AND f_score <= 2  THEN 'Lost'
            WHEN r_score = 3 AND f_score <= 2  THEN 'Promising'
            ELSE 'Others'
        END AS segment
    FROM rfm_scores
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    segment
FROM customer_segments
ORDER BY monetary DESC;
GO

-- =============================================
-- Query 4: Segment Summary
-- Business Question: How many customers and
-- how much revenue does each segment generate?
-- =============================================
WITH rfm_scores AS (
    SELECT
        customer_id,
        DATEDIFF(day, MAX(invoice_date), '2011-12-09') AS recency_days,
        COUNT(DISTINCT invoice_no)                     AS frequency,
        SUM(quantity * unit_price)                     AS monetary,
        CASE
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 90  THEN 4
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 180 THEN 3
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 365 THEN 2
            ELSE 1
        END AS r_score,
        CASE
            WHEN COUNT(DISTINCT invoice_no) = 1              THEN 1
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 2 AND 5  THEN 2
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 6 AND 15 THEN 3
            ELSE 4
        END AS f_score,
        CASE
            WHEN SUM(quantity * unit_price) BETWEEN 0    AND 500   THEN 1
            WHEN SUM(quantity * unit_price) BETWEEN 501  AND 2000  THEN 2
            WHEN SUM(quantity * unit_price) BETWEEN 2001 AND 10000 THEN 3
            ELSE 4
        END AS m_score
    FROM online_retail
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CASE
            WHEN r_score = 4 AND f_score = 4   THEN 'Champions'
            WHEN f_score = 4 AND r_score >= 3  THEN 'Loyal'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score = 1 AND f_score <= 2  THEN 'Lost'
            WHEN r_score = 3 AND f_score <= 2  THEN 'Promising'
            ELSE 'Others'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*)                      AS customer_count,
    SUM(monetary)                 AS total_revenue,
    AVG(monetary)                 AS avg_monetary,
    AVG(recency_days)             AS avg_recency_days,
    AVG(CAST(frequency AS FLOAT)) AS avg_frequency
FROM customer_segments
GROUP BY segment
ORDER BY total_revenue DESC;
GO

-- =============================================
-- Query 5: Top 10 Champion Customers
-- Business Question: Who are our most valuable
-- customers and how much do they spend?
-- =============================================
WITH rfm_scores AS (
    SELECT
        customer_id,
        DATEDIFF(day, MAX(invoice_date), '2011-12-09') AS recency_days,
        COUNT(DISTINCT invoice_no)                     AS frequency,
        SUM(quantity * unit_price)                     AS monetary,
        CASE
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 90  THEN 4
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 180 THEN 3
            WHEN DATEDIFF(day, MAX(invoice_date), '2011-12-09') <= 365 THEN 2
            ELSE 1
        END AS r_score,
        CASE
            WHEN COUNT(DISTINCT invoice_no) = 1              THEN 1
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 2 AND 5  THEN 2
            WHEN COUNT(DISTINCT invoice_no) BETWEEN 6 AND 15 THEN 3
            ELSE 4
        END AS f_score,
        CASE
            WHEN SUM(quantity * unit_price) BETWEEN 0    AND 500   THEN 1
            WHEN SUM(quantity * unit_price) BETWEEN 501  AND 2000  THEN 2
            WHEN SUM(quantity * unit_price) BETWEEN 2001 AND 10000 THEN 3
            ELSE 4
        END AS m_score
    FROM online_retail
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CASE
            WHEN r_score = 4 AND f_score = 4   THEN 'Champions'
            WHEN f_score = 4 AND r_score >= 3  THEN 'Loyal'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score = 1 AND f_score <= 2  THEN 'Lost'
            WHEN r_score = 3 AND f_score <= 2  THEN 'Promising'
            ELSE 'Others'
        END AS segment
    FROM rfm_scores
)
SELECT TOP 10
    customer_id,
    recency_days,
    frequency,
    monetary,
    segment
FROM customer_segments
WHERE segment = 'Champions'
ORDER BY monetary DESC;
GO

-- =============================================
-- Query 6: Top 10 Countries by Revenue
-- Business Question: Which countries generate
-- the most revenue for the business?
-- =============================================
SELECT TOP 10
    country,
    SUM(quantity * unit_price)  AS total_revenue,
    COUNT(DISTINCT invoice_no)  AS transaction_count,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM online_retail
GROUP BY country
ORDER BY total_revenue DESC;
GO

-- =============================================
-- Query 7: Monthly Revenue Trend
-- Business Question: How is revenue trending
-- month by month across 2 years?
-- =============================================
SELECT
    YEAR(invoice_date)                                                    AS yr,
    MONTH(invoice_date)                                                   AS mon,
    SUM(quantity * unit_price)                                            AS monthly_revenue,
    SUM(SUM(quantity * unit_price))
        OVER (ORDER BY YEAR(invoice_date), MONTH(invoice_date))           AS cumulative_revenue
FROM online_retail
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY yr, mon;
GO

-- =============================================
-- Query 8: Top 10 Best Selling Products
-- Business Question: Which products generate
-- the most revenue and have the widest reach?
-- =============================================
SELECT TOP 10
    description,
    SUM(quantity * unit_price)  AS total_revenue,
    SUM(quantity)               AS total_quantity_sold,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM online_retail
WHERE description IS NOT NULL
GROUP BY description
ORDER BY total_revenue DESC;
GO

