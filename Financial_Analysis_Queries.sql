USE COMPANY_FINANCE;

-- Project: Corporate Financial Performance & Budget Variance Analysis | SQL + Power BI
-- Database: company_finance


-- Query 1: Department-wise Budget vs Actual Expense (Variance Analysis)
SELECT 
    b.Department,
    SUM(b.Budgeted_Amount_INR) AS Total_Budget,
    SUM(e.Amount_INR) AS Total_Actual_Expense,
    (SUM(b.Budgeted_Amount_INR) - SUM(e.Amount_INR)) AS Variance,
    CASE 
        WHEN SUM(e.Amount_INR) > SUM(b.Budgeted_Amount_INR) THEN 'Over Budget'
        ELSE 'Within Budget'
    END AS Budget_Status
FROM dept_budget b
LEFT JOIN expenses e 
    ON b.Department = e.Department 
    AND b.Month = e.Month
GROUP BY b.Department
ORDER BY Total_Actual_Expense DESC;


-- Query 2: Monthly Net Profit & Profit Margin Percentage
WITH Monthly_Expenses AS (
    SELECT 
        Month,
        SUM(Amount_INR) AS Total_Expense
    FROM expenses
    GROUP BY Month
)
SELECT 
    r.Month,
    r.Actual_Revenue_INR,
    COALESCE(e.Total_Expense, 0) AS Total_Expense,
    (r.Actual_Revenue_INR - COALESCE(e.Total_Expense, 0)) AS Net_Profit,
    ROUND(((r.Actual_Revenue_INR - COALESCE(e.Total_Expense, 0)) / r.Actual_Revenue_INR) * 100, 2) AS Profit_Margin_Pct
FROM revenue r
LEFT JOIN Monthly_Expenses e 
    ON r.Month = e.Month
ORDER BY r.Month;


-- Query 3: Budgeted vs Actual Revenue & Target Achievement Percentage
SELECT 
    Month,
    Budgeted_Revenue_INR,
    Actual_Revenue_INR,
    (Actual_Revenue_INR - Budgeted_Revenue_INR) AS Revenue_Variance,
    ROUND(((Actual_Revenue_INR - Budgeted_Revenue_INR) / Budgeted_Revenue_INR) * 100, 2) AS Target_Achievement_Pct
FROM revenue
ORDER BY Month;


-- Query 4: Top Spending Categories (Cost Driver Breakdown)
SELECT 
    Expense_Category,
    SUM(Amount_INR) AS Total_Spent,
    ROUND((SUM(Amount_INR) / (SELECT SUM(Amount_INR) FROM expenses)) * 100, 2) AS Spend_Percentage
FROM expenses
GROUP BY Expense_Category
ORDER BY Total_Spent DESC;


-- Query 5: Top 5 Vendors by Total Spend
WITH Vendor_Spending AS (
    SELECT 
        Vendor,
        Expense_Category,
        SUM(Amount_INR) AS Total_Paid,
        DENSE_RANK() OVER (ORDER BY SUM(Amount_INR) DESC) AS Spend_Rank
    FROM expenses
    GROUP BY Vendor, Expense_Category
)
SELECT 
    Spend_Rank,
    Vendor,
    Expense_Category,
    Total_Paid
FROM Vendor_Spending
WHERE Spend_Rank <= 5;