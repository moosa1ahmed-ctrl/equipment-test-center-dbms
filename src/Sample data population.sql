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

-- Equipment
INSERT INTO Equipment (Name, Model_Number, Manufacturer, Status) VALUES
('Centrifuge', 'CF-200', 'LabTech', 'Available'),
('Spectrometer', 'SP-900', 'SpecCorp', 'Under Maintenance'),
('Microscope', 'MS-1000', 'Optix', 'In Use');

-- Client
INSERT INTO Client (First_Name, Last_Name, Contact_Email, Phone_Number, Organization) VALUES
('Aisha','Khan','aisha.khan@biotech.ca','416-555-1010','BioNova Labs'),
('Michael','Osei','m.osei@chemcore.com','416-555-1020','ChemCore Analytics'),
('Sophia','Martinez','s.martinez@greenearth.org','416-555-1030','GreenEarth Research');

-- Technician
INSERT INTO Technician (First_Name, Last_Name, Certification, Contact_Email, Phone_Number) VALUES
('Liam','Chen','ISO-15189','liam.chen@labtech.ca','647-555-1001'),
('Fatima','Rahman','ASTM-Cert','fatima.r@qualitylabs.com','647-555-1002'),
('Ethan','Brown','ISO-9001','ethan.brown@microlabs.ca','647-555-1003');

-- Test
INSERT INTO Test (Test_Name, Description) VALUES
('Water Purity','Chemical and biological analysis of water samples'),
('Microbial Culture','Culture and count of microorganisms'),
('Material Strength','Tensile and compression strength test');

-- Lab
INSERT INTO Lab (Lab_Name, Location, Capacity) VALUES
('Main Lab','Building A - Floor 1',10),
('Microbiology Lab','Building C - Floor 3',8),
('Materials Lab','Building B - Floor 2',6);

-- Booking
INSERT INTO Booking (Booking_Date, Client_ID, Lab_ID, Start_Time, End_Time, Status) VALUES
('2025-10-05', 1, 1, '09:00','11:00','Confirmed'),
('2025-10-06', 2, 2, '13:00','15:30','Pending'),
('2025-10-07', 3, 3, '10:00','12:00','Cancelled');

-- Booking Equipment
INSERT INTO Booking_Equipment VALUES (1,1),(2,2),(3,3);

-- Test Session
INSERT INTO Test_Session (Test_Date, Result, Duration, Technician_ID, Test_ID) VALUES
('2025-10-05','Pass','01:30',1,1),
('2025-10-06','Fail','02:00',2,2),
('2025-10-07','Pending','01:45',3,3);

-- Test Session Equipment
INSERT INTO TestSession_Equipment VALUES (1,1),(2,2),(3,3);

-- Report
INSERT INTO Report (Report_Date, Findings, Approved_By, Session_ID) VALUES
('2025-10-05','Sample meets purity standards',1,1),
('2025-10-06','Microbial count exceeded limits',2,2),
('2025-10-07','Testing in progress',3,3);

-- Invoice (Fix: Add Invoice_Number)
INSERT INTO Invoice VALUES
(1,1,'2025-10-05',250.00,'Paid'),
(2,1,'2025-10-06',180.00,'Unpaid'),
(3,1,'2025-10-07',200.00,'Unpaid');

-- Maintenance Records (Fix: Add Record_Number)
INSERT INTO Maintenance_Record VALUES
(1,1,'2025-09-10',1,'Rotor inspected and cleaned'),
(2,1,'2025-09-15',2,'Lamp replaced and calibrated'),
(3,1,'2025-09-20',3,'Lens alignment adjusted');


