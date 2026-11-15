# Sales Analytics Case Study

## 1. Overview of the Case Study

- This project analyses **1,053 daily sales records for one product at a single retail store between 2013 and 2016**, focusing on pricing, profitability, sales performance and promotional effectiveness.
- **Business Problem:** Despite generating significant sales revenue, the retailer is experiencing negative gross profit. The objective is to determine whether selling prices, product costs and promotional discounts are contributing to financial losses.
- The analysis addresses five key business questions:
  - **Pricing:** What are the daily selling price per unit and average selling price?
  - **Profitability:** What are the daily gross profit, gross profit percentage and gross profit per unit?
  - **Promotions:** How price-sensitive is customer demand during three selected promotional periods?
  - **Sales Performance:** How do sales, quantities sold and profitability change over time?
  - **Business Improvement:** Does the product perform better during promotions, and what strategies can improve profitability?
- Findings were presented through interactive dashboards and a Canva business presentation to support data-driven decision-making.

## 2. Process – How the Case Study Was Done

- **Step 1 – Business Understanding:** Reviewed the case study requirements and identified key metrics, including selling price per unit, average selling price, gross profit, gross profit percentage and Price Elasticity of Demand (PED).
- **Step 2 – Project Planning:** Used Miro to organise the project workflow, analysis objectives, timeline and deliverables.
- **Step 3 – Data Preparation:** Imported the daily sales dataset into Excel and Databricks, reviewed data types, checked data quality and prepared sales, cost and quantity fields for analysis.
- **Step 4 – Data Transformation:** Used Databricks SQL to calculate daily unit selling prices, gross profit, gross profit margins, unit costs and calendar fields for daily, monthly, quarterly and yearly analysis.
- **Step 5 – Promotional Analysis:** Identified promotional periods, compared promotional and non-promotional performance, and calculated PED for three selected campaigns using percentage changes in price and quantity sold.
- **Step 6 – Dashboard Development:** Used Excel, Power BI and Google Looker Studio to analyse pricing, profitability, promotions and sales trends through interactive dashboards and visualisations.
- **Step 7 – Insights and Presentation:** Interpreted the results, identified profitability challenges and presented evidence-based recommendations using Canva.

## 3. Tools Used

- **Databricks SQL / SQL:** Data preparation, transformation, calculations and promotional analysis.
- **Microsoft Excel:** Data validation, PivotTables, calculations and exploratory analysis.
- **Microsoft Power BI:** Interactive dashboards and business performance visualisation.
- **Google Looker Studio:** Interactive reporting and sales analytics dashboards.
- **Lovable:** Dashboard development and visual presentation.
- **Miro:** Project planning and workflow organisation.
- **Canva:** Final business presentation and visual communication of findings.
- **Git & GitHub:** Version control, project documentation and organisation of deliverables.

## 4. Summary of What Was Done and Found (Insights)

### 4.1 Overall Sales Performance

- The product generated approximately **R186.9 million in sales** from **5,279,872 units sold**.
- Despite strong revenue, total gross profit was approximately **-R7.1 million**, representing a **-3.8% weighted gross profit margin**.
- **Key Insight:** High sales revenue did not translate into profitability, indicating that pricing and cost management require improvement.

### 4.2 Pricing and Profitability

- The weighted average selling price was **R35.40 per unit**, compared with a simple average daily selling price of **R37.07**.
- Approximately **57.6% of trading days were loss-making**, indicating persistent profitability challenges.
- **Key Insight:** Selling prices were frequently insufficient to cover product costs, resulting in negative gross profit.

### 4.3 Sales Trends and Performance

- **2014** recorded the highest annual sales at approximately **R75.4 million**.
- **2015** recorded the weakest annual gross profit margin at **-6.09%**.
- Sales declined by **26.7% in 2016 compared with 2015**, although the gross profit margin improved to **-2.00%**.
- **Key Insight:** Sales performance fluctuated across years, while profitability remained negative throughout the analysed period.

### 4.4 Promotional Effectiveness and Price Elasticity

- Three promotional periods recorded PED values of **-7.18, -6.73 and -6.70**, averaging **-6.87**, indicating highly elastic demand.
- Promotional periods achieved approximately **7,402 units sold per day**, compared with **4,430 units** on non-promotional days.
- Average daily revenue increased from approximately **R158,649 to R254,556** during promotional periods.
- However, promotional gross profit margins declined to **-8.01%**, compared with **-2.16%** outside promotions.
- **Key Insight:** Promotions successfully increased sales volume and revenue but worsened profitability, demonstrating that higher demand does not necessarily translate into higher profits.

### 4.5 Peak Sales Periods

- Weekend sales activity was approximately **27.1% higher** in order count than weekday activity.
- Quarter 2 was identified as a stronger sales period in the analysis.
- **Key Insight:** Higher-demand periods present opportunities for targeted marketing, stock planning and controlled promotional testing.

## 5. Business Recommendations

### 5.1 Optimise Promotional Pricing

- **Evidence:** The three promotional campaigns recorded highly elastic demand, averaging **PED = -6.87**, but promotional margins declined to **-8.01%**.
- **Recommendation:** Introduce smaller, targeted discounts and evaluate their profitability before expanding promotional campaigns.
- **Expected Benefit:** Maintain customer demand while reducing losses associated with excessive discounting.

### 5.2 Prioritise Profitability Over Sales Volume

- **Evidence:** Total sales reached **R186.9 million**, but gross profit remained negative at approximately **-R7.1 million**.
- **Recommendation:** Evaluate promotional success using gross profit and contribution rather than sales revenue or units sold alone.
- **Expected Benefit:** Support sustainable revenue growth and improve financial performance.

### 5.3 Improve Cost and Pricing Management

- **Evidence:** Approximately **57.6% of trading days were loss-making**, with an overall gross profit margin of **-3.8%**.
- **Recommendation:** Review cost of sales, negotiate better supplier pricing and establish minimum selling prices that cover product costs.
- **Expected Benefit:** Reduce loss-making transactions and improve gross profit margins.

### 5.4 Use Peak Sales Periods Strategically

- **Evidence:** Weekend order counts were approximately **27.1% higher**, indicating stronger demand.
- **Recommendation:** Prioritise stock availability during high-demand periods and conduct controlled promotional tests without excessive discounting.
- **Expected Benefit:** Capture additional demand while protecting profitability.

### 5.5 Monitor Promotional Performance Continuously

- **Evidence:** Promotional periods increased daily sales volume but generated worse gross profit margins than non-promotional periods.
- **Recommendation:** Compare promotional results against normal trading periods using PED, sales volume, gross profit and gross profit percentage.
- **Expected Benefit:** Identify profitable promotional strategies and support better pricing decisions through continuous dashboard monitoring.

### Conclusion

- The analysis revealed that although the product generated substantial revenue, **high costs and aggressive promotional pricing contributed to persistent losses**.
- Promotions increased customer demand but reduced profitability, highlighting the importance of balancing price reductions with profit margins.
- The recommended approach focuses on **cost optimisation, controlled discounts, profitability monitoring and data-driven pricing decisions** to improve long-term business performance.