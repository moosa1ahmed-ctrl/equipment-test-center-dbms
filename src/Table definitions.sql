-- 1. Create database
CREATE DATABASE IF NOT EXISTS EquipmentTestCenterDB;
USE EquipmentTestCenterDB;

# Equipment table
CREATE TABLE IF NOT EXISTS Equipment (
    Equipment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Model_Number VARCHAR(50) NOT NULL,
    Manufacturer VARCHAR(100) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Available'
        CHECK (Status IN ('Available','In Use','Under Maintenance'))
);

# Client table
CREATE TABLE IF NOT EXISTS Client (
    Client_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Contact_Email VARCHAR(100) NOT NULL UNIQUE,
    Phone_Number VARCHAR(20) NOT NULL UNIQUE,
    Organization VARCHAR(100) NOT NULL
);

# Technician table
CREATE TABLE IF NOT EXISTS Technician (
    Technician_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Certification VARCHAR(100) NOT NULL,
    Contact_Email VARCHAR(100) NOT NULL UNIQUE,
    Phone_Number VARCHAR(20) NOT NULL UNIQUE
);

# Test table
CREATE TABLE IF NOT EXISTS Test (
    Test_ID INT AUTO_INCREMENT PRIMARY KEY,
    Test_Name VARCHAR(100) NOT NULL,
    Description VARCHAR(255) NOT NULL
);

# Lab table
CREATE TABLE IF NOT EXISTS Lab (
    Lab_ID INT AUTO_INCREMENT PRIMARY KEY,
    Lab_Name VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0)
);

# Booking table (Client books Lab)
CREATE TABLE IF NOT EXISTS Booking (
    Booking_ID INT AUTO_INCREMENT PRIMARY KEY,
    Booking_Date DATE NOT NULL,
    Client_ID INT NOT NULL,
    Lab_ID INT NOT NULL,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (Status IN ('Pending','Confirmed','Completed','Cancelled')),
    FOREIGN KEY (Client_ID) REFERENCES Client(Client_ID),
    FOREIGN KEY (Lab_ID) REFERENCES Lab(Lab_ID)
);

# Test_Session table (A session of a test conducted by a technician)
CREATE TABLE IF NOT EXISTS Test_Session (
    Session_ID INT AUTO_INCREMENT PRIMARY KEY,
    Test_Date DATE NOT NULL,
    Result VARCHAR(100) NOT NULL,
    Duration TIME NOT NULL,
    Technician_ID INT NOT NULL,
    Test_ID INT NOT NULL,
    FOREIGN KEY (Technician_ID) REFERENCES Technician(Technician_ID),
    FOREIGN KEY (Test_ID) REFERENCES Test(Test_ID)
);

# Report table (Test session results approved by a technician)
CREATE TABLE IF NOT EXISTS Report (
    Report_ID INT AUTO_INCREMENT PRIMARY KEY,
    Report_Date DATE NOT NULL,
    Findings VARCHAR(255) NOT NULL,
    Approved_By INT NOT NULL,
    Session_ID INT NOT NULL UNIQUE,
    FOREIGN KEY (Approved_By) REFERENCES Technician(Technician_ID),
    FOREIGN KEY (Session_ID) REFERENCES Test_Session(Session_ID)
);

# Invoice table - FIXED: Separate primary key for auto_increment
CREATE TABLE IF NOT EXISTS Invoice (
    Booking_ID INT NOT NULL,
    Invoice_Number INT NOT NULL,
    Invoice_Date DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    Payment_Status ENUM('Paid','Unpaid') NOT NULL,
    FOREIGN KEY (Booking_ID) REFERENCES Booking(Booking_ID),
    PRIMARY KEY (Booking_ID, Invoice_Number)
);

# Maintenance_Record table - FIXED: Separate primary key for auto_increment
CREATE TABLE IF NOT EXISTS Maintenance_Record (
    Equipment_ID INT NOT NULL,
    Record_Number INT NOT NULL,
    Maintenance_Date DATE NOT NULL,
    Technician_ID INT NOT NULL,
    Notes VARCHAR(255) NOT NULL,
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID),
    FOREIGN KEY (Technician_ID) REFERENCES Technician(Technician_ID),
	PRIMARY KEY (Equipment_ID, Record_Number)
);

# Booking_Equipment junction table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS Booking_Equipment (
    Booking_ID INT NOT NULL,
    Equipment_ID INT NOT NULL,
    PRIMARY KEY (Booking_ID, Equipment_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Booking(Booking_ID),
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);

# TestSession_Equipment junction table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS TestSession_Equipment (
    Session_ID INT NOT NULL,
    Equipment_ID INT NOT NULL,
    PRIMARY KEY (Session_ID, Equipment_ID),
    FOREIGN KEY (Session_ID) REFERENCES Test_Session(Session_ID),
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);
