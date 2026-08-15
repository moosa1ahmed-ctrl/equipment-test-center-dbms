USE EquipmentTestCenterDB;

# Advanced Queries 
-- 1. Client Financial Summary (Advanced GROUP BY + Aggregates)
SELECT
    c.Client_ID,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS Client_Name,
    COUNT(DISTINCT b.Booking_ID) AS Num_Bookings,
    COUNT(i.Invoice_Number) AS Num_Invoices,
    COALESCE(SUM(i.Amount), 0.00) AS Total_Invoiced,
    COALESCE(AVG(i.Amount), 0.00) AS Avg_Invoice,
    COALESCE(STDDEV_POP(i.Amount), 0.00) AS Invoice_StdDev
FROM Client c
LEFT JOIN Booking b ON b.Client_ID = c.Client_ID
LEFT JOIN Invoice i ON i.Booking_ID = b.Booking_ID
GROUP BY c.Client_ID, c.First_Name, c.Last_Name
ORDER BY Total_Invoiced DESC;

-- 2. Equipment Usage Across Bookings and Test Sessions (UNION set operation)
SELECT e.Equipment_ID, e.Name, 'Booking' AS Source
FROM Equipment e
JOIN Booking_Equipment be ON be.Equipment_ID = e.Equipment_ID

UNION

SELECT e.Equipment_ID, e.Name, 'TestSession' AS Source
FROM Equipment e
JOIN TestSession_Equipment tse ON tse.Equipment_ID = e.Equipment_ID
ORDER BY Equipment_ID;

-- 3. Equipment Used in Bookings But Not in Test Sessions (LEFT JOIN + Filtering)
SELECT DISTINCT e.Equipment_ID,
    e.Name,
    e.Model_Number
FROM Equipment e
JOIN Booking_Equipment be ON e.Equipment_ID = be.Equipment_ID
LEFT JOIN TestSession_Equipment tse ON e.Equipment_ID = tse.Equipment_ID
WHERE tse.Equipment_ID IS NULL
ORDER BY e.Equipment_ID;

-- 4. Test Duration Analysis with RANK Window Function
SELECT
    t.Test_ID,
    t.Test_Name,
    COUNT(ts.Session_ID) AS Sessions,
    ROUND(AVG(TIME_TO_SEC(ts.Duration)) / 60, 2) AS Avg_Duration_Min,
    RANK() OVER (ORDER BY AVG(TIME_TO_SEC(ts.Duration)) DESC) AS Duration_Rank
FROM Test t
LEFT JOIN Test_Session ts ON ts.Test_ID = t.Test_ID
GROUP BY t.Test_ID, t.Test_Name
ORDER BY Duration_Rank;

-- 5. Technician Failure Rate Analysis (Grouping + Aggregates)
SELECT
    tech.Technician_ID,
    CONCAT(tech.First_Name,' ',tech.Last_Name) AS Technician,
    COUNT(ts.Session_ID) AS Total_Sessions,
    SUM(CASE WHEN ts.Result = 'Fail' THEN 1 ELSE 0 END) AS Failed_Sessions,
    ROUND(
        SUM(CASE WHEN ts.Result = 'Fail' THEN 1 ELSE 0 END) / GREATEST(COUNT(ts.Session_ID),1) * 100, 2
    ) AS Fail_Pct
FROM Technician tech
LEFT JOIN Test_Session ts ON ts.Technician_ID = tech.Technician_ID
GROUP BY tech.Technician_ID, tech.First_Name, tech.Last_Name
HAVING Total_Sessions > 0
ORDER BY Fail_Pct DESC;

-- 6. Equipment Maintenance History (Correlated Subquery + Aggregates)
SELECT
    e.Equipment_ID,
    e.Name,
    e.Status,
    (SELECT MAX(m.Maintenance_Date) 
     FROM Maintenance_Record m 
     WHERE m.Equipment_ID = e.Equipment_ID) AS Last_Maintenance_Date,
    (SELECT CONCAT(t.First_Name,' ',t.Last_Name)
     FROM Maintenance_Record m
     JOIN Technician t ON t.Technician_ID = m.Technician_ID
     WHERE m.Equipment_ID = e.Equipment_ID
     ORDER BY m.Maintenance_Date DESC
     LIMIT 1) AS Last_Maintained_By
FROM Equipment e
ORDER BY Last_Maintenance_Date DESC;

-- 7. 14-Day Booking Calendar (Recursive CTE + Aggregates)
WITH RECURSIVE calendar AS (
    SELECT CURDATE() AS cal_date, 1 AS day_num
    UNION ALL
    SELECT DATE_ADD(cal_date, INTERVAL 1 DAY), day_num + 1
    FROM calendar
    WHERE day_num < 14
)
SELECT
    cal.cal_date,
    COUNT(b.Booking_ID) AS Num_Bookings,
    COALESCE(GROUP_CONCAT(CONCAT(b.Booking_ID, ': ', c.First_Name, ' ', c.Last_Name) SEPARATOR '; '), '') AS Bookings_Detail
FROM calendar cal
LEFT JOIN Booking b ON b.Booking_Date = cal.cal_date
LEFT JOIN Client c ON c.Client_ID = b.Client_ID
GROUP BY cal.cal_date
ORDER BY cal.cal_date;
