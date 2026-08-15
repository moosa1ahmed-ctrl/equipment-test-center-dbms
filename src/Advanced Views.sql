USE EquipmentTestCenterDB;

-- =========================================
-- Advanced Views
-- =========================================

-- 1. View with a subquery in the SELECT clause (derived value)
-- Client Latest Booking Date
CREATE OR REPLACE VIEW Client_LatestBooking AS
SELECT
    c.Client_ID,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS Client_Name,
    -- Derived value using subquery
    (SELECT MAX(b.Booking_Date)
     FROM Booking b
     WHERE b.Client_ID = c.Client_ID) AS Latest_Booking_Date
FROM Client c
ORDER BY Latest_Booking_Date DESC;

-- 2. View using a subquery in the FROM clause
-- Client Invoice Summary
CREATE OR REPLACE VIEW Client_InvoiceSummary AS
SELECT ci.Client_ID,
       ci.Client_Name,
       ci.Total_Invoiced,
       ci.Num_Invoices,
       ROUND(ci.Avg_Invoice, 2) AS Avg_Invoice
FROM (
    SELECT
        c.Client_ID,
        CONCAT(c.First_Name, ' ', c.Last_Name) AS Client_Name,
        COALESCE(SUM(i.Amount), 0.00) AS Total_Invoiced,
        COUNT(i.Invoice_Number) AS Num_Invoices,
        COALESCE(AVG(i.Amount), 0.00) AS Avg_Invoice
    FROM Client c
    LEFT JOIN Booking b ON c.Client_ID = b.Client_ID
    LEFT JOIN Invoice i ON b.Booking_ID = i.Booking_ID
    GROUP BY c.Client_ID, c.First_Name, c.Last_Name
) AS ci
ORDER BY ci.Total_Invoiced DESC;

-- 3. View using a subquery in the WHERE clause
-- Top Technician by Number of Test Sessions
CREATE OR REPLACE VIEW TopTechnician_Sessions AS
SELECT ts.Session_ID,
       ts.Test_Date,
       ts.Result,
       ts.Technician_ID,
       CONCAT(t.First_Name, ' ', t.Last_Name) AS Technician_Name
FROM Test_Session ts
JOIN Technician t ON ts.Technician_ID = t.Technician_ID
WHERE ts.Technician_ID = (
    -- Subquery in WHERE clause to dynamically filter top technician
    SELECT Technician_ID
    FROM Test_Session
    GROUP BY Technician_ID
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
ORDER BY ts.Test_Date;

-- Test the views
SELECT * FROM Client_LatestBooking;
SELECT * FROM Client_InvoiceSummary;
SELECT * FROM TopTechnician_Sessions;
