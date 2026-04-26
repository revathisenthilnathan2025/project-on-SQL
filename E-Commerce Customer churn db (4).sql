

UPDATE customer_churn
SET HourSpendOnApp = (
    SELECT ROUND(avg_val)
    FROM (
        SELECT AVG(HourSpendOnApp) AS avg_val
        FROM customer_churn
        WHERE HourSpendOnApp IS NOT NULL
    ) t
)
WHERE HourSpendOnApp IS NULL;
UPDATE customer_churn
SET DaySinceLastOrder = (
    SELECT ROUND(avg_val)
    FROM (
        SELECT AVG(DaySinceLastOrder) AS avg_val
        FROM customer_churn
        WHERE DaySinceLastOrder IS NOT NULL
    ) t
)
WHERE DaySinceLastOrder IS NULL;
UPDATE customer_churn
SET Tenure = (
    SELECT tenure_mode
    FROM (
        SELECT Tenure AS tenure_mode
        FROM customer_churn
        WHERE Tenure IS NOT NULL
        GROUP BY Tenure
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) t
)
WHERE Tenure IS NULL;
DELETE FROM customer_churn
WHERE WarehouseToHome > 100;
UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';
SELECT DISTINCT PreferredPaymentMode
FROM customer_churn;
ALTER TABLE customer_churn
CHANGE PreferedOrderCat PreferredOrderCat VARCHAR(50);
DESC customer_churn;
ALTER TABLE customer_churn
CHANGE HourSpendOnApp HoursSpentOnApp INT;
ALTER TABLE customer_churn
ADD ComplaintReceived VARCHAR(5);
UPDATE customer_churn
SET ComplaintReceived = 
CASE 
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END;
SET SQL_SAFE_UPDATES = 0;
UPDATE customer_churn
SET ComplaintReceived =
CASE
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END;
SELECT ComplaintReceived, COUNT(*)
FROM customer_churn
GROUP BY ComplaintReceived;
ALTER TABLE customer_churn
ADD ChurnStatus VARCHAR(10);
UPDATE customer_churn
SET ChurnStatus =
CASE
    WHEN Churn = 1 THEN 'Churned'
    ELSE 'Active'
END;
SELECT ChurnStatus, COUNT(*)
FROM customer_churn
GROUP BY ChurnStatus;
DESC customer_churn;

SELECT 
    AVG(Tenure) AS AvgTenure,
    SUM(CashbackAmount) AS TotalCashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';
SELECT 
    (COUNT(CASE WHEN ComplaintReceived = 'Yes' THEN 1 END) * 100.0 
     / COUNT(*)) AS ComplaintPercentage
FROM customer_churn
WHERE ChurnStatus = 'Churned';
SELECT 
    CityTier,
    COUNT(CASE WHEN ChurnStatus = 'Churned' THEN 1 END) * 100.0 
    / COUNT(*) AS ChurnRate
FROM customer_churn
GROUP BY CityTier
ORDER BY ChurnRate DESC
LIMIT 3;
SELECT
    PreferredOrderCat,
    COUNT(*) AS CustomerCount,
    MAX(HoursSpentOnApp) AS MaxHoursSpent
FROM customer_churn
GROUP BY PreferredOrderCat;
SELECT MAX(SatisfactionScore) 
FROM customer_churn;
SELECT 
    SUM(OrderCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (
        SELECT MAX(SatisfactionScore)
        FROM customer_churn
  );
SELECT 
    AVG(SatisfactionScore) AS AvgSatisfactionScore
FROM customer_churn
WHERE ComplaintReceived = 'Yes';
SELECT 
    PreferredOrderCat,
    COUNT(*) AS CustomerCount
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY CustomerCount DESC;
SELECT 
    PreferredPaymentMode
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING AVG(Tenure) = 10
   AND SUM(OrderCount) > 500;

SELECT
    CASE
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;
SELECT
    CustomerID,
    CityTier,
    MaritalStatus,
    OrderCount,
    PreferredOrderCat,
    PreferredPaymentMode
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (
        SELECT AVG(OrderCount)
        FROM customer_churn
  );
USE ecomm;

CREATE TABLE customer_returns (
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount INT
);
INSERT INTO customer_returns (ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
SELECT * FROM customer_returns;
SELECT
    r.ReturnID,
    r.CustomerID,
    r.ReturnDate,
    r.RefundAmount,
    c.CityTier,
    c.Gender,
    c.MaritalStatus,
    c.PreferredOrderCat,
    c.PreferredPaymentMode,
    c.ChurnStatus,
    c.ComplaintReceived
FROM customer_returns r
JOIN customer_churn c
    ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes';











