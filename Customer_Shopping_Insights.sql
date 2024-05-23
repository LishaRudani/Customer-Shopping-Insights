

--1. Get the customer ID, age, gender, and location for all customers.
SELECT [Customer ID], Age, Gender, Location FROM dbo.shopping_trends$;

--2. Find the total purchase amount (in USD) for each customer.
SELECT [Customer ID], SUM([Purchase Amount (USD)]) AS 'Total Purchase Amount' FROM dbo.shopping_trends$
GROUP BY [Customer ID];

--3. Determine the category of items that customers purchase the most.
SELECT Category, COUNT(Category) AS 'Purchase Count' FROM dbo.shopping_trends$ GROUP BY Category ORDER BY 'Purchase Count' DESC;

--4. Calculate the average review rating given by customers.
SELECT AVG([Review Rating]) AS 'Average Review Rating' FROM dbo.shopping_trends$;

--5. Count the number of customers with and without a subscription.
SELECT [Subscription Status], COUNT([Customer ID]) AS CustomerCount FROM dbo.shopping_trends$ GROUP BY [Subscription Status];

--6. Find the payment method preferred by the majority of customers.
SELECT [Payment Method], COUNT([Customer ID]) AS 'Customer Count' FROM dbo.shopping_trends$ GROUP BY [Payment Method] ORDER BY 'Customer Count' DESC;

--7. Determine the average purchase amount for male and female customers.
SELECT Gender, AVG([Purchase Amount (USD)]) AS 'Average Purchase Amount' FROM dbo.shopping_trends$ GROUP BY Gender;

--8. Find the most frequently purchased item size and color.
SELECT Size, Color, COUNT(*) AS PurchaseCount FROM dbo.shopping_trends$ GROUP BY Size, Color ORDER BY PurchaseCount DESC;

--9. Compare the average review rating for purchases with and without applied discounts.
SELECT [Discount Applied], AVG([Review Rating]) AS AverageReviewRating FROM dbo.shopping_trends$ GROUP BY [Discount Applied];

--10. Calculate the average frequency of purchases for customers with and without subscriptions.
SELECT [Subscription Status], AVG(CASE WHEN [Frequency of Purchases] = 'Weekly' THEN 1 ELSE 0 END) AS AvgWeeklyPurchases
FROM dbo.shopping_trends$
GROUP BY [Subscription Status];

--11. List the top 5 customers based on their total purchase amount.
SELECT TOP 5 [Customer ID], SUM([Purchase Amount (USD)]) AS 'Total Purchase Amount'
FROM dbo.shopping_trends$
GROUP BY [Customer ID]
ORDER BY 'Total Purchase Amount' DESC;

--12. Find the most and least popular seasons for shopping.
SELECT Season, COUNT(*) AS PurchaseCount FROM dbo.shopping_trends$ GROUP BY Season ORDER BY PurchaseCount DESC;

--13. Check if the usage of promo codes influences the preferred payment methods.
SELECT [Promo Code Used], [Payment Method], COUNT(*) AS PaymentMethodCount FROM dbo.shopping_trends$ GROUP BY [Promo Code Used], [Payment Method] 
ORDER BY PaymentMethodCount DESC;

--14. Create segments of customers based on their average purchase amount, age, and frequency of purchases.
SELECT
    CASE
        WHEN AVG(CAST([Purchase Amount (USD)] AS DECIMAL(10, 2))) >= 100 THEN 'High Spenders'
        WHEN AVG(CAST([Purchase Amount (USD)] AS DECIMAL(10, 2))) >= 50 THEN 'Medium Spenders'
        ELSE 'Low Spenders'
    END AS SpendingSegment,
    CASE
        WHEN AVG(CAST([Age] AS DECIMAL(10, 2))) >= 40 THEN 'Older Age Group'
        WHEN AVG(CAST([Age] AS DECIMAL(10, 2))) >= 30 THEN 'Middle Age Group'
        ELSE 'Younger Age Group'
    END AS AgeSegment,
    CASE
        WHEN AVG(CASE [Frequency of Purchases] WHEN 'Weekly' THEN 1 ELSE 0 END) >= 0.5 THEN 'Frequent Shoppers'
        WHEN AVG(CASE [Frequency of Purchases] WHEN 'Fortnightly' THEN 1 ELSE 0 END) >= 0.5 THEN 'Regular Shoppers'
        ELSE 'Occasional Shoppers'
    END AS PurchaseFrequencySegment,
    COUNT(*) AS CustomerCount
FROM dbo.shopping_trends$
GROUP BY [Customer ID];

--15. Calculate the percentage of customers who made repeat purchases within a certain period (e.g., monthly).
SELECT
    COUNT(DISTINCT [Customer ID]) AS TotalCustomers,
    COUNT(CASE WHEN [Previous Purchases] > 1 THEN [Customer ID] END) AS RepeatCustomers,
    (COUNT(CASE WHEN [Previous Purchases] > 1 THEN [Customer ID] END) * 100.0) / COUNT(DISTINCT [Customer ID]) AS RepeatCustomerPercentage
FROM dbo.shopping_trends$;

--16. Identify the most popular items in each location based on purchase frequency.
WITH RankedItems AS (
    SELECT
        [Item Purchased],
        Location,
        DENSE_RANK() OVER (PARTITION BY Location ORDER BY COUNT(*) DESC) AS PurchaseRank
    FROM dbo.shopping_trends$
    GROUP BY [Item Purchased], Location
)
SELECT
    [Item Purchased],
    Location,
    PurchaseRank
FROM RankedItems
WHERE PurchaseRank = 1;

--17. Compare the average purchase amount and frequency of purchases for subscribed and non-subscribed customers.
SELECT
    [Subscription Status],
    AVG([Purchase Amount (USD)]) AS AveragePurchaseAmount,
    AVG(CASE WHEN [Frequency of Purchases] = 'Weekly' THEN 1 ELSE 0 END) AS AvgWeeklyPurchases
FROM dbo.shopping_trends$
GROUP BY [Subscription Status];

--18. Calculate the Customer Lifetime Value for each customer, considering their total purchases and average purchase amount.
SELECT
    [Customer ID],
    SUM([Purchase Amount (USD)]) AS TotalPurchaseAmount,
    COUNT(*) AS TotalPurchases,
    AVG([Purchase Amount (USD)]) AS AvgPurchaseAmount,
    (SUM([Purchase Amount (USD)]) * COUNT(*)) / COUNT(DISTINCT [Customer ID]) AS CLV
FROM dbo.shopping_trends$
GROUP BY [Customer ID];

--19. Analyze the preferred payment methods for different age groups.
SELECT CASE
WHEN Age < 30 THEN 'Younger Age Group'
WHEN Age < 40 THEN 'Middle Age Group'
ELSE 'Older Age Group'
END AS AgeGroup,[Payment Method], COUNT(*) AS PaymentCount
FROM dbo.shopping_trends$
GROUP BY CASE
WHEN Age < 30 THEN 'Younger Age Group'
WHEN Age < 40 THEN 'Middle Age Group'
ELSE 'Older Age Group'
END, [Payment Method]
ORDER BY AgeGroup, PaymentCount DESC;

