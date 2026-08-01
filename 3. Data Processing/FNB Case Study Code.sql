-- Databricks notebook source
SELECT *
FROM sales.case.study_2021;

---EDA
--Check Min and Max of Date
SELECT MIN(To_Date(Date)),       --30/12/2013
       MAX(To_Date(Date))        --16/11/2016
FROM sales.case.study_2021;

SELECT Date
FROM sales.case.study_2021
WHERE Date IS NULL;             --0 nulls

SELECT Sales
FROM sales.case.study_2021
WHERE Sales IS NULL;            --0 nulls

SELECT `Cost Of Sales`
FROM sales.case.study_2021
WHERE `Cost Of Sales` IS NULL;     --0 nulls

SELECT `Quantity Sold`
FROM sales.case.study_2021
WHERE `Quantity Sold` IS NULL;      --0 nulls
---Therefore there are no Nyull values in all the columns 

---New Date Columns creation 
SELECT
        YEAR(Date) AS Sales_Year,
        MONTH(Date) AS Sales_Month_Number,
        DATE_FORMAT(Date,'MMMM') AS Sales_Month,
        QUARTER(Date) AS Quarter,
        WEEKOFYEAR(Date) AS Week_Number,
        DAY(Date) AS Day_Number,
        DAYOFWEEK(Date) AS Day_of_Week_Number,
        DATE_FORMAT(Date,'EEEE') AS Day_Name,
    CASE
        WHEN DAYOFWEEK(Date) IN (1,7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type

FROM sales.case.study_2021;

---Performance of the sales
SELECT *  --------- CHECK OVERALL DATA AGAIN
FROM sales.case.study_2021;


SELECT 
        ROUND(Sales / `Quantity Sold`,2) AS Unit_Selling_Price,
        ROUND(((Sales - `Cost of Sales`)/Sales)*100,2) AS Gross_Profit_Percentage,
        ROUND((Sales - `Cost of Sales`)/`Quantity Sold`,2) AS Gross_Profit_Per_Unit,
        ROUND(`Cost of Sales`/`Quantity Sold`,2) AS Cost_Per_Unit,
        ROUND(AVG(Sales/`Quantity Sold`) OVER(),2) AS Average_Selling_Price,
        ---(Gross_Profit/Sales)*100
        ROUND(LAG(Sales) OVER(ORDER BY Date),2) AS Previous_Day_Sales,
        ROUND(Sales - LAG(Sales) OVER(ORDER BY Date),2) AS Daily_Sales_Growth,
        ROUND((Sales - LAG(Sales) OVER(ORDER BY Date) ) / LAG(Sales) OVER(ORDER BY Date) *100,2) AS Growth_Percentage
FROM sales.case.study_2021;

SELECT
        ROUND(AVG(Sales) OVER( ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS Moving_Average_7_Days,
        ROUND(AVG(Sales) OVER( ORDER BY Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),2) AS Moving_Average_30_Days
FROM sales.case.study_2021;
        
SELECT
       ROUND(AVG(Sales/`Quantity Sold`) OVER(),2) AS Average_Selling_Price
FROM sales.case.study_2021;


---BIG QUERY
SELECT 
        Date,
        YEAR(Date) AS Sales_Year,
        MONTH(Date) AS Sales_Month_Number,
        DATE_FORMAT(Date,'MMMM') AS Sales_Month,
        QUARTER(Date) AS Quarter,
        WEEKOFYEAR(Date) AS Week_Number,
        DAY(Date) AS Day_Number,
        DAYOFWEEK(Date) AS Day_of_Week_Number,
        DATE_FORMAT(Date,'EEEE') AS Day_Name,
    CASE
        WHEN DAYOFWEEK(Date) IN (1,7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
        ROUND(Sales,2),
        ROUND(`Cost Of Sales`,2),
        `Quantity Sold`,

        ROUND(Sales / `Quantity Sold`,2) AS Unit_Selling_Price,
        ROUND(((Sales - `Cost of Sales`)/Sales)*100,2) AS Gross_Profit_Percentage,
        ROUND((Sales - `Cost of Sales`)/`Quantity Sold`,2) AS Gross_Profit_Per_Unit,
        ROUND(`Cost of Sales`/`Quantity Sold`,2) AS Cost_Per_Unit,
        ROUND(AVG(Sales/`Quantity Sold`) OVER(),2) AS Average_Selling_Price,
        ---(Gross_Profit/Sales)*100
        ROUND(LAG(Sales) OVER(ORDER BY Date),2) AS Previous_Day_Sales,
        ROUND(Sales - LAG(Sales) OVER(ORDER BY Date),2) AS Daily_Sales_Growth,
        ROUND((Sales - LAG(Sales) OVER(ORDER BY Date) ) / LAG(Sales) OVER(ORDER BY Date) *100,2) AS Growth_Percentage,

        ROUND(AVG(Sales) OVER( ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS Moving_Average_7_Days,
        ROUND(AVG(Sales) OVER( ORDER BY Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW),2) AS Moving_Average_30_Days,

        --ROUND(AVG(Sales/`Quantity Sold`) OVER(),2) AS Average_Selling_Price,
        CASE
            WHEN Unit_Selling_Price < Average_Selling_Price*0.9   THEN 'Promotion'
            ELSE 'Regular'
END AS Promotion_Flag,
    DENSE_RANK() OVER (ORDER BY  Date ) AS Promotion_ID,
    ROUND(LAG(Sales / `Quantity Sold`) OVER(ORDER BY Date),2) AS Previous_Price,
    LAG(`Quantity Sold`) OVER(ORDER BY Date) AS Previous_Quantity,
    ROUND((Unit_Selling_Price - Previous_Price ) / Previous_Price,2) AS Price_Change_Percentage,
    ROUND(( `Quantity Sold` - LAG(`Quantity Sold`) OVER(ORDER BY Date) ) / Previous_Quantity,2) AS Quantity_Change_Percentage,
    RANK() OVER( ORDER BY Sales DESC) AS Rank_Highest_Sales,
    RANK() OVER( ORDER BY  ROUND(((Sales - `Cost of Sales`)/Sales),2) DESC) AS Rank_Profit,
    RANK() OVER( ORDER BY ROUND(Sales / `Quantity Sold`,2) DESC) AS Rank_Unit_Price,
    CASE
        WHEN Sales > AVG(Sales) OVER() THEN 'High'
        ELSE 'Low'
END AS High_Sales,
    CASE
        WHEN  ROUND(((Sales - `Cost of Sales`)/Sales),2) > AVG( ROUND(((Sales - `Cost of Sales`)/Sales),2)) OVER() THEN 'High Profit'
        ELSE 'Low Profit'
END AS High_Profit,
    CASE
        WHEN  ROUND(((Sales - `Cost of Sales`)/Sales),2) < 0 THEN 'Loss'
        ELSE 'Profit'
END Loss_Indicator
FROM sales.case.study_2021;