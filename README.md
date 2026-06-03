
# E-Commerce Customer Segmentation + CLV Analysis

## Problem Statement
Analyzed 805,549 transactions from a UK retailer to identify most valuable customers,
segment them by behavior, and calculate customer lifetime value.

## Tech Stack
- SQL Server - data storage and RFM analysis queries
- Python - EDA, CLV calculation, K-Means clustering
- Power BI - 3-page interactive dashboard

## Key Results
- Total Revenue: £17,743,429
- Unique Customers: 5,878
- Average CLV: £4,927
- Max CLV: £1,059,588
- VIP Champions: 4 customers generating £1.74M revenue
- Lost Customers: 1,999 customers identified for win-back campaign

## Customer Segments
| Segment | Customers | Revenue | Avg Spend |
|---|---|---|---|
| Active Customers | 3,840 | £11,555,748 | £3,009 |
| Lost Customers | 1,999 | £1,532,324 | £767 |
| Loyal High Value | 35 | £2,908,012 | £83,086 |
| VIP Champions | 4 | £1,747,343 | £436,835 |

## Project Structure
- /sql - RFM analysis queries
- /notebooks - EDA and clustering notebook
- /powerbi - dashboard file
- /screenshots - all project screenshots

## Dataset
Online Retail II UCI dataset
Source: https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci

## Business Recommendations
1. Assign dedicated account managers to 4 VIP Champions
2. Launch win-back campaign for 1,999 Lost Customers
3. Upsell program for 35 Loyal High Value customers
4. Increase Active Customer purchase frequency from 7 to 10 orders/year
EOF
