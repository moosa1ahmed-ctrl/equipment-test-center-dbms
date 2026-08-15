USE EquipmentTestCenterDB;

-- 1. Client Booking Summary View
CREATE OR REPLACE VIEW Client_Booking_Summary AS
SELECT
    c.Client_ID,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS Client_Name,
    COUNT(b.Booking_ID) AS Total_Bookings,                 -- Calculated field
    SUM(CASE WHEN b.Status = 'Confirmed' THEN 1 ELSE 0 END) AS Confirmed_Bookings
FROM Client c
LEFT JOIN Booking b ON c.Client_ID = b.Client_ID
GROUP BY c.Client_ID, c.First_Name, c.Last_Name
ORDER BY Total_Bookings DESC;

-- 2. Equipment Status Summary View
CREATE OR REPLACE VIEW Equipment_Status_Summary AS
SELECT
    Name AS Equipment_Name,
    Status,
    COUNT(*) AS Count_By_Status                                 -- Calculated field
FROM Equipment
GROUP BY Name, Status
ORDER BY Name, Status;

-- 3. Test Session Details View
CREATE OR REPLACE VIEW Test_Session_Details AS
SELECT DISTINCT
    ts.Session_ID,
    t.Test_Name,
    CONCAT(tech.First_Name, ' ', tech.Last_Name) AS Technician_Name,
    ts.Test_Date,
    TIME_TO_SEC(ts.Duration)/60 AS Duration_Minutes,            -- Calculated field
    ts.Result
FROM Test_Session ts
JOIN Test t ON ts.Test_ID = t.Test_ID
JOIN Technician tech ON ts.Technician_ID = tech.Technician_ID
ORDER BY ts.Test_Date, ts.Session_ID;

select* from Client_Booking_Summary;
select* from Equipment_Status_Summary;
select* from Test_Session_Details;