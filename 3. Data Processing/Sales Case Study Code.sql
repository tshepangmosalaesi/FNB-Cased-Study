-- Databricks notebook source
--Loading the data and viewing the first 10 rows
SELECT *
FROM sales.case.study_2021
LIMIT 10;

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
---Therefore there are no Null values in all the columns, all data clean

-------------------------------------------
--BIG CODE
-------------------------------------------
WITH
---------------------------------------------------
--Capturing the original dataset, to set it as base
---------------------------------------------------
source_data AS (
    SELECT                                                      
        TO_DATE(`Date`) AS Sales_Date,
        TRY_CAST(`Sales` AS DOUBLE) AS Sales,
        TRY_CAST(`Cost Of Sales` AS DOUBLE) AS Cost_Of_Sales,
        TRY_CAST(`Quantity Sold` AS DOUBLE) AS Quantity_Sold
FROM sales.case.study_2021
),

---------------------------------------------------------------------------------------------------
--Aggregating the relevant quantitative columnmms to get the totals while grouping by date of sales
---------------------------------------------------------------------------------------------------
daily_data AS (
    SELECT                                      
        Sales_Date,
        SUM(Sales) AS Total_Sales,
        SUM(Cost_Of_Sales) AS Total_Cost,
        SUM(Quantity_Sold) AS Total_Quantity
    FROM source_data
    GROUP BY Sales_Date
),
-------------------------------------
--Calculating daily financial metrics
-------------------------------------
financial_metrics AS (
    SELECT                                            
        *,
        (Total_Sales - Total_Cost)                          AS Gross_Profit,

        Total_Sales / Total_Quantity                        AS Selling_Price_Per_Unit,

        Total_Cost / Total_Quantity                         AS Cost_Per_Unit,

        (Total_Sales - Total_Cost) / Total_Quantity         AS Gross_Profit_Per_Unit,

        100 * (Total_Sales - Total_Cost) / Total_Sales      AS Gross_Profit_Pct,

        100 * (
            (Total_Sales / Total_Quantity)
            -
            (Total_Cost / Total_Quantity)
               )
            / 
            Total_Sales / Total_Quantity
                                                            AS Gross_Profit_Per_Unit_Pct,

        100 * Total_Cost / Total_Sales                      AS Cost_To_Sales_Pct

    FROM daily_data
),
-------------------------------------------------
--Calendar Metrics with all the Financial Metrics
-------------------------------------------------
calendar_metrics AS (
    SELECT                                            
        *,
        YEAR(Sales_Date)                                    AS Sales_Year,
        QUARTER(Sales_Date)                                 AS Sales_Quarter,
        MONTH(Sales_Date)                                   AS Month_Number,
        DATE_FORMAT(Sales_Date, 'MMMM')                     AS Month_Name,
        DATE_FORMAT(Sales_Date, 'MMM')                      AS Month_Short,
        DATE_FORMAT(Sales_Date, 'yyyy-MM')                  AS Year_Month,
        WEEKOFYEAR(Sales_Date)                              AS Week_Number,
        DAYOFMONTH(Sales_Date)                              AS Day_Number,
        DATE_FORMAT(Sales_Date, 'EEEE')                     AS Day_Name,

        CASE
            WHEN DAYOFWEEK(Sales_Date) IN (1, 7)
                THEN 'Weekend'
            ELSE 'Weekday'
        END AS Week_Type,

        CASE
            WHEN Gross_Profit > 0 THEN 'Profit'
            WHEN Gross_Profit < 0 THEN 'Loss'
            ELSE 'Break Even'
        END AS Profitability_Status

    FROM financial_metrics
),
-------------------------------------
--Calculating Sales and pricing tends
-------------------------------------
trend_metrics AS (
    SELECT
        *,

        LAG(Total_Sales) OVER (
            ORDER BY Sales_Date
        )                                                   AS Previous_Day_Sales,

        LAG(Total_Quantity) OVER (
            ORDER BY Sales_Date
        )                                                   AS Previous_Day_Quantity,

        LAG(Selling_Price_Per_Unit) OVER (
            ORDER BY Sales_Date
        )                                                   AS Previous_Day_Price,

        AVG(Total_Sales) OVER (
            ORDER BY Sales_Date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )                                                   AS Sales_MA_7D,

        AVG(Total_Sales) OVER (
            ORDER BY Sales_Date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        )                                                   AS Sales_MA_30D,

        AVG(Total_Quantity) OVER (
            ORDER BY Sales_Date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        )                                                   AS Quantity_MA_7D,

        AVG(Selling_Price_Per_Unit) OVER (
            ORDER BY Sales_Date
            ROWS BETWEEN 27 PRECEDING AND CURRENT ROW
        )                                                   AS Price_MA_28D,

        -- Historical reference excluding current day, while we now include it
        AVG(Selling_Price_Per_Unit) OVER (
            ORDER BY Sales_Date
            ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING
        )                                                   AS Baseline_Price,

        AVG(Total_Quantity) OVER (
            ORDER BY Sales_Date
            ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING
        )                                                   AS Baseline_Quantity,

        COUNT(*) OVER (
            ORDER BY Sales_Date
            ROWS BETWEEN 28 PRECEDING AND 1 PRECEDING
        )                                                   AS Baseline_Observations

    FROM calendar_metrics
),
----------------------------------------------
--Estimating the day of promotion
--We assume the following:
-- Rule: at least 5% below the previous 28-day
-- average price, with 14 before observations
----------------------------------------------

promotion_flags AS (
    SELECT
        *,

        CASE
            WHEN Baseline_Observations >= 14
             AND Baseline_Price > 0
             AND Selling_Price_Per_Unit
                    <= Baseline_Price * 0.95
                THEN 1
            ELSE 0
        END AS Estimated_Promotion_Flag,

        CASE
            WHEN Baseline_Observations >= 14
             AND Baseline_Price > 0
             AND Selling_Price_Per_Unit
                    <= Baseline_Price * 0.95
                THEN 'Estimated Promotion'
            ELSE 'Not Flagged'
        END AS Promotion_Status,

        CASE
            WHEN Baseline_Observations >= 14
             AND Baseline_Price > 0
             AND Selling_Price_Per_Unit
                    <= Baseline_Price * 0.95
            THEN 100.0 * (
                Baseline_Price - Selling_Price_Per_Unit
            ) / Baseline_Price
            ELSE 0
        END AS Estimated_Discount_Pct

    FROM trend_metrics
),
----------------------------------------------------------
-- Identifyiong promotional periods that follow each other
----------------------------------------------------------
promotion_boundaries AS (
    SELECT
        *,

        CASE
            WHEN Estimated_Promotion_Flag = 1
             AND COALESCE(
                 LAG(Estimated_Promotion_Flag) OVER (
                     ORDER BY Sales_Date
                 ), 0
             ) = 1
             AND DATEDIFF(
                 Sales_Date,
                 LAG(Sales_Date) OVER (
                     ORDER BY Sales_Date
                 )
             ) = 1
            THEN 0

            WHEN Estimated_Promotion_Flag = 1
            THEN 1

            ELSE 0
        END AS Promotion_Start_Flag

    FROM promotion_flags
),

promotion_groups AS (
    SELECT
        *,

        CASE
            WHEN Estimated_Promotion_Flag = 1
            THEN SUM(Promotion_Start_Flag) OVER (
                ORDER BY Sales_Date
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW
            )
            ELSE NULL
        END AS Promotion_Period_ID

    FROM promotion_boundaries
),
---------------------------------------
---Summarising each promotiional period
---------------------------------------
promotion_periods AS (
    SELECT
        Promotion_Period_ID,

        MIN(Sales_Date)                               AS Promotion_Start_Date,
        MAX(Sales_Date)                               AS Promotion_End_Date,
        COUNT(*)                                      AS Promotion_Days,

        SUM(Total_Sales)                              AS Promotion_Total_Sales,
        SUM(Total_Quantity)                           AS Promotion_Total_Quantity,
        SUM(Gross_Profit)                             AS Promotion_Gross_Profit,

        SUM(Total_Sales)
            / NULLIF(SUM(Total_Quantity), 0)
                                                      AS Promotion_Avg_Price,

        AVG(Baseline_Price)                           AS Period_Baseline_Price,
        AVG(Baseline_Quantity)                        AS Period_Baseline_Quantity,

        AVG(Total_Quantity)                           AS Promotion_Avg_Daily_Quantity,
        AVG(Estimated_Discount_Pct)                   AS Avg_Discount_Pct

    FROM promotion_groups
    WHERE Estimated_Promotion_Flag = 1
    GROUP BY Promotion_Period_ID
),
----------------------------------------------------
--Calculating Price Elasticity of Demand (PED)
--PED = (% change in quantity) / (% change in price)
----------------------------------------------------
elasticity_metrics AS (
    SELECT
        *,

        100 * (
            Promotion_Avg_Price - Period_Baseline_Price
        ) / Period_Baseline_Price
                                                      AS Period_Price_Change_Pct,

        100 * (
            Promotion_Avg_Daily_Quantity
                - Period_Baseline_Quantity
        ) / Period_Baseline_Quantity
                                                      AS Period_Quantity_Change_Pct,

        (
            (Promotion_Avg_Daily_Quantity
            - Period_Baseline_Quantity
            ) / Period_Baseline_Quantity
        )
        /
            (
                Promotion_Avg_Price - Period_Baseline_Price
            ) / Period_Baseline_Price
                                                      AS Price_Elasticity_Of_Demand

    FROM promotion_periods
),
----------------------------------------
--Promotional Classification Performance
----------------------------------------
promotion_insights AS (
    SELECT
        *,

        CASE
            WHEN Price_Elasticity_Of_Demand IS NULL
                THEN 'Cannot Calculate'
            WHEN ABS(Price_Elasticity_Of_Demand) > 1
                THEN 'Elastic'
            WHEN ABS(Price_Elasticity_Of_Demand) < 1
                THEN 'Inelastic'
            ELSE 'Unit Elastic'
        END AS Elasticity_Category,

        CASE
            WHEN Period_Quantity_Change_Pct > 0
                THEN 'Quantity Increased'
            WHEN Period_Quantity_Change_Pct < 0
                THEN 'Quantity Decreased'
            ELSE 'No Quantity Growth'
        END AS Promotion_Quantity_Result,

        CASE
            WHEN Promotion_Gross_Profit > 0
                THEN 'Profitable Period'
            WHEN Promotion_Gross_Profit < 0
                THEN 'Loss Making Period'
            ELSE 'Break Even Period'
        END AS Promotion_Profit_Result

    FROM elasticity_metrics
),
-------------------------------------
--Selecting Three Promotional Periods
-------------------------------------
ranked_promotions AS (
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY
                Promotion_Days DESC,
                Avg_Discount_Pct DESC,
                Promotion_Start_Date ASC
        ) AS Promotion_Rank

    FROM promotion_insights
    WHERE Promotion_Days >= 2
      AND Period_Price_Change_Pct < 0
      AND Period_Quantity_Change_Pct > 0
      AND Price_Elasticity_Of_Demand IS NOT NULL
),
-------------------------------------------------------------------
--Final Data Model, that includes all the data that I created above
-------------------------------------------------------------------
data_model AS (
    SELECT
        d.*,

        p.Promotion_Start_Date,
        p.Promotion_End_Date,
        p.Promotion_Days,
        p.Promotion_Total_Sales,
        p.Promotion_Total_Quantity,
        p.Promotion_Gross_Profit,
        p.Promotion_Avg_Price,
        p.Period_Baseline_Price,
        p.Period_Baseline_Quantity,
        p.Promotion_Avg_Daily_Quantity,
        p.Avg_Discount_Pct,
        p.Period_Price_Change_Pct,
        p.Period_Quantity_Change_Pct,
        p.Price_Elasticity_Of_Demand,
        p.Elasticity_Category,
        p.Promotion_Quantity_Result,
        p.Promotion_Profit_Result,

        r.Promotion_Rank,

        CASE
            WHEN r.Promotion_Rank = 1
                THEN 'Promotion 1'
            WHEN r.Promotion_Rank = 2
                THEN 'Promotion 2'
            WHEN r.Promotion_Rank = 3
                THEN 'Promotion 3'
            ELSE 'Other / Not Selected'
        END AS Selected_Promotion_Label

    FROM promotion_groups d

    LEFT JOIN promotion_insights p
        ON d.Promotion_Period_ID = p.Promotion_Period_ID

    LEFT JOIN ranked_promotions r
        ON d.Promotion_Period_ID = r.Promotion_Period_ID
       AND r.Promotion_Rank <= 3
)

SELECT *
FROM data_model
ORDER BY Sales_Date
;


