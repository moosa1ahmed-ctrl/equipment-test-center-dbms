USE EquipmentTestCenterDB;

# Queries
-- 1. List all bookings with client names
SELECT b.Booking_ID, c.First_Name, c.Last_Name, b.Booking_Date, b.Status
FROM Booking b
JOIN Client c ON b.Client_ID = c.Client_ID;

-- 2. Equipment currently in use
SELECT Equipment_ID, Name, Status
FROM Equipment
WHERE Status = 'In Use';

-- 3. Clients with confirmed bookings (Subquery)
SELECT First_Name, Last_Name
FROM Client
WHERE Client_ID IN (
    SELECT Client_ID
    FROM Booking
    WHERE Status = 'Confirmed'
);

-- 4. Tests that never failed (Subquery)
SELECT Test_Name
FROM Test
WHERE Test_ID NOT IN (
    SELECT Test_ID
    FROM Test_Session
    WHERE Result = 'Fail'
);

-- 5. Clients with their latest booking date (correlated subquery)
SELECT c.First_Name, c.Last_Name,
    (SELECT MAX(b.Booking_Date)
    FROM Booking b
    WHERE b.Client_ID = c.Client_ID) AS Latest_Booking
FROM Client c;

-- 6. Client booking ranking (Window function)
SELECT c.Client_ID, c.First_Name, c.Last_Name, COUNT(b.Booking_ID) AS Total_Bookings,
       RANK() OVER (ORDER BY COUNT(b.Booking_ID) DESC) AS Booking_Rank
FROM Client c
LEFT JOIN Booking b ON c.Client_ID = b.Client_ID
GROUP BY c.Client_ID, c.First_Name, c.Last_Name;

-- 7. Technician session numbering (Window function)
SELECT Technician_ID, Session_ID, Test_Date,
    ROW_NUMBER() OVER (PARTITION BY Technician_ID ORDER BY Test_Date) AS Session_Number
FROM Test_Session;

-- 8. Booking groups using NTILE (Window function)
SELECT Booking_ID, Booking_Date, Client_ID,
    NTILE(2) OVER (ORDER BY Booking_Date) AS Booking_Group
FROM Booking;

-- 9. Reports with approving technicians
SELECT r.Report_ID, r.Findings, t.First_Name, t.Last_Name AS Technician 
FROM Report r 
JOIN Technician t ON r.Approved_By = t.Technician_ID;

-- 10. Invoices above average amount
SELECT Booking_ID, Invoice_Number, Amount, Payment_Status
FROM Invoice
WHERE Amount > (SELECT AVG(Amount) FROM Invoice);