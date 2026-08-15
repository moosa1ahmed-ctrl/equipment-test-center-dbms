USE EquipmentTestCenterDB;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Booking_Equipment;
TRUNCATE TABLE TestSession_Equipment;
TRUNCATE TABLE Maintenance_Record;
TRUNCATE TABLE Invoice;
TRUNCATE TABLE Report;
TRUNCATE TABLE Test_Session;
TRUNCATE TABLE Booking;
TRUNCATE TABLE Lab;
TRUNCATE TABLE Test;
TRUNCATE TABLE Technician;
TRUNCATE TABLE Client;
TRUNCATE TABLE Equipment;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------- Equipment ----------
INSERT INTO Equipment (Name, Model_Number, Manufacturer, Status) VALUES
('Centrifuge', 'CF-200', 'LabTech', 'Available'),
('Spectrometer', 'SP-900', 'SpecCorp', 'Under Maintenance'),
('Microscope', 'MS-1000', 'Optix', 'In Use');

-- ---------- Client ----------
INSERT INTO Client (First_Name, Last_Name, Contact_Email, Phone_Number, Organization) VALUES
('Aisha','Khan','aisha.khan@biotech.ca','416-555-1010','BioNova Labs'),
('Michael','Osei','m.osei@chemcore.com','416-555-1020','ChemCore Analytics'),
('Sophia','Martinez','s.martinez@greenearth.org','416-555-1030','GreenEarth Research');

-- ---------- Technician ----------
INSERT INTO Technician (First_Name, Last_Name, Certification, Contact_Email, Phone_Number) VALUES
('Liam','Chen','ISO-15189','liam.chen@labtech.ca','647-555-1001'),
('Fatima','Rahman','ASTM-Cert','fatima.r@qualitylabs.com','647-555-1002'),
('Ethan','Brown','ISO-9001','ethan.brown@microlabs.ca','647-555-1003');

-- ---------- Test ----------
INSERT INTO Test (Test_Name, Description) VALUES
('Water Purity','Chemical and biological analysis of water samples'),
('Microbial Culture','Culture and count of microorganisms'),
('Material Strength','Tensile and compression strength test');

-- ---------- Lab ----------
INSERT INTO Lab (Lab_Name, Location, Capacity) VALUES
('Main Lab','Building A - Floor 1',10),
('Microbiology Lab','Building C - Floor 3',8),
('Materials Lab','Building B - Floor 2',6);

-- ---------- Booking ----------
INSERT INTO Booking (Booking_Date, Client_ID, Lab_ID, Start_Time, End_Time, Status) VALUES
('2025-10-05', 1, 1, '09:00:00','11:00:00','Confirmed'),
('2025-10-06', 2, 2, '13:00:00','15:30:00','Pending'),
('2025-10-07', 3, 3, '10:00:00','12:00:00','Cancelled');

-- ---------- Booking_Equipment ----------
INSERT INTO Booking_Equipment (Booking_ID, Equipment_ID) VALUES
(1,1),
(2,2),
(3,3);

-- ---------- Test_Session ----------
INSERT INTO Test_Session (Test_Date, Result, Duration, Technician_ID, Test_ID) VALUES
('2025-10-05','Pass','01:30:00',1,1),
('2025-10-06','Fail','02:00:00',2,2),
('2025-10-07','Pending','01:45:00',3,3);

-- ---------- TestSession_Equipment ----------
INSERT INTO TestSession_Equipment (Session_ID, Equipment_ID) VALUES
(1,1),
(2,2),
(3,3);

-- ---------- Report ----------
INSERT INTO Report (Report_Date, Findings, Approved_By, Session_ID) VALUES
('2025-10-05','Sample meets purity standards',1,1),
('2025-10-06','Microbial count exceeded limits',2,2),
('2025-10-07','Testing in progress',3,3);

-- ---------- Invoice ----------
INSERT INTO Invoice (Booking_ID, Invoice_Date, Amount, Payment_Status) VALUES
(1,'2025-10-05',250.00,'Paid'),
(2,'2025-10-06',180.00,'Unpaid'),
(3,'2025-10-07',200.00,'Unpaid');

-- ---------- Maintenance_Record ----------
INSERT INTO Maintenance_Record (Equipment_ID, Maintenance_Date, Technician_ID, Notes) VALUES
(1,'2025-09-10',1,'Rotor inspected and cleaned'),
(2,'2025-09-15',2,'Lamp replaced and calibrated'),
(3,'2025-09-20',3,'Lens alignment adjusted');

# 7 Advanced Queries:
# Advanced Query 1:
SELECT
  c.Client_ID,
  CONCAT(c.First_Name, ' ', c.Last_Name) AS Client_Name,
  COUNT(DISTINCT b.Booking_ID) AS Num_Bookings,
  COUNT(i.Invoice_ID) AS Num_Invoices,
  COALESCE(SUM(i.Amount), 0.00) AS Total_Invoiced,
  COALESCE(AVG(i.Amount), 0.00) AS Avg_Invoice,
  COALESCE(STDDEV_POP(i.Amount), 0.00) AS Invoice_StdDev
FROM Client c
LEFT JOIN Booking b ON b.Client_ID = c.Client_ID
LEFT JOIN Invoice i ON i.Booking_ID = b.Booking_ID
GROUP BY c.Client_ID
ORDER BY Total_Invoiced DESC;

# Advanced Query 2:
SELECT e.Equipment_ID, e.Name, 'Booking' AS Source
FROM Equipment e
JOIN Booking_Equipment be ON be.Equipment_ID = e.Equipment_ID

UNION

SELECT e.Equipment_ID, e.Name, 'TestSession' AS Source
FROM Equipment e
JOIN TestSession_Equipment tse ON tse.Equipment_ID = e.Equipment_ID
ORDER BY Equipment_ID;

# Advanced Query 3:
SELECT DISTINCT E.Equipment_ID,
       E.Name,
       E.Model_Number
FROM Equipment E
JOIN Booking_Equipment BE
       ON E.Equipment_ID = BE.Equipment_ID
LEFT JOIN TestSession_Equipment TSE
       ON E.Equipment_ID = TSE.Equipment_ID
WHERE TSE.Equipment_ID IS NULL;

# Advanced Query 4:
SELECT
  t.Test_ID,
  t.Test_Name,
  COUNT(ts.Session_ID) AS Sessions,
  ROUND(AVG(TIME_TO_SEC(ts.Duration)) / 60, 2) AS Avg_Duration_Min,
  RANK() OVER (ORDER BY AVG(TIME_TO_SEC(ts.Duration)) DESC) AS Duration_Rank
FROM Test t
LEFT JOIN Test_Session ts ON ts.Test_ID = t.Test_ID
GROUP BY t.Test_ID;

# Advanced Query 5:
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
GROUP BY tech.Technician_ID
HAVING Total_Sessions > 0 AND Fail_Pct > 30
ORDER BY Fail_Pct DESC;

# Advanced Query 6:
SELECT
  e.Equipment_ID,
  e.Name,
  e.Status,
  (SELECT MAX(m.Maintenance_Date) FROM Maintenance_Record m WHERE m.Equipment_ID = e.Equipment_ID) AS Last_Maintenance_Date,
  (SELECT CONCAT(t.First_Name,' ',t.Last_Name)
   FROM Maintenance_Record m
   JOIN Technician t ON t.Technician_ID = m.Technician_ID
   WHERE m.Equipment_ID = e.Equipment_ID
   ORDER BY m.Maintenance_Date DESC
   LIMIT 1
  ) AS Last_Maintained_By
FROM Equipment e;


# Advanced Query 7:
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
  COALESCE(GROUP_CONCAT(CONCAT(b.Booking_ID,':',c.First_Name,' ',c.Last_Name) SEPARATOR '; '), '') AS Bookings_Detail
FROM calendar cal
LEFT JOIN Booking b ON b.Booking_Date = cal.cal_date
LEFT JOIN Client c ON c.Client_ID = b.Client_ID
GROUP BY cal.cal_date
ORDER BY cal.cal_date;

# 3 Advanced Views:
# Advanced View 1
CREATE OR REPLACE VIEW Client_LatestBooking AS
SELECT 
    c.Client_ID,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS Client_Name,
    (SELECT MAX(b.Booking_Date) 
     FROM Booking b 
     WHERE b.Client_ID = c.Client_ID) AS Latest_Booking_Date
FROM Client c;

SELECT * FROM Client_LatestBooking;

# Advanced View 2
CREATE OR REPLACE VIEW Client_InvoiceSummary AS
SELECT 
    ci.Client_ID,
    ci.Client_Name,
    ci.Total_Invoiced,
    ci.Num_Invoices
FROM (
    SELECT 
        c.Client_ID,
        CONCAT(c.First_Name, ' ', c.Last_Name) AS Client_Name,
        COALESCE(SUM(i.Amount), 0) AS Total_Invoiced,
        COUNT(i.Invoice_ID) AS Num_Invoices
    FROM Client c
    LEFT JOIN Booking b ON c.Client_ID = b.Client_ID
    LEFT JOIN Invoice i ON b.Booking_ID = i.Booking_ID
    GROUP BY c.Client_ID
) ci;

SELECT * FROM Client_InvoiceSummary;

# Advanced View 3
CREATE OR REPLACE VIEW TopTechnician_Sessions AS
SELECT ts.Session_ID,
       ts.Test_Date,
       ts.Result,
       ts.Technician_ID,
       CONCAT(t.First_Name,' ',t.Last_Name) AS Technician_Name
FROM Test_Session ts
JOIN Technician t ON ts.Technician_ID = t.Technician_ID
WHERE ts.Technician_ID = (
    SELECT Technician_ID
    FROM Test_Session
    GROUP BY Technician_ID
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

SELECT * FROM TopTechnician_Sessions;
