"""
------------------------------------------------------------------------
CP 363, Assignment 4 — CLI Query Menu
Equipment Test Center DBMS
------------------------------------------------------------------------
Author: Moosa Ahmed
__updated__ = Nov. 1, 2025
------------------------------------------------------------------------
"""

import os
import mysql.connector
from mysql.connector import errorcode

# MySQL Connection
# Credentials are read from environment variables — never hardcoded.
# Set these locally before running, e.g.:
#   DB_HOST=localhost DB_USER=root DB_PASSWORD=your_password python cli_menu_app.py
try:
    conn = mysql.connector.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=int(os.environ.get("DB_PORT", 3306)),
        user=os.environ.get("DB_USER", "root"),
        password=os.environ.get("DB_PASSWORD", ""),
        database=os.environ.get("DB_NAME", "EquipmentTestCenterDB")
    )
    cursor = conn.cursor(dictionary=True)
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist.")
    else:
        print(err)
    exit()

# menu
def menu():
    print("\n===== Equipment Test Center Menu =====")
    print("1. Show all clients")
    print("2. Show all equipment currently in use")
    print("3. Show clients with confirmed bookings")
    print("4. Show invoices above average")
    print("5. Show equipment booked but never used")
    print("6. Exit")

# Queries
def show_clients():
    cursor.execute("SELECT * FROM Client;")
    rows = cursor.fetchall()
    for row in rows:
        print(row)

def equipment_in_use():
    cursor.execute("SELECT Equipment_ID, Name, Status FROM Equipment WHERE Status='In Use';")
    rows = cursor.fetchall()
    for row in rows:
        print(row)

def clients_confirmed_bookings():
    cursor.execute("""
        SELECT First_Name, Last_Name
        FROM Client
        WHERE Client_ID IN (
            SELECT Client_ID
            FROM Booking
            WHERE Status='Confirmed'
        );
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(row)

def invoices_above_avg():
    cursor.execute("""
        SELECT i.Invoice_ID, i.Booking_ID, i.Amount
        FROM Invoice i
        JOIN (SELECT AVG(Amount) AS Avg_Amount FROM Invoice) avg_table
        ON i.Amount > avg_table.Avg_Amount;
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(row)

def equipment_booked_never_used():
    cursor.execute("""
        SELECT DISTINCT E.Equipment_ID, E.Name, E.Model_Number
        FROM Equipment E
        JOIN Booking_Equipment BE ON E.Equipment_ID = BE.Equipment_ID
        LEFT JOIN TestSession_Equipment TSE ON E.Equipment_ID = TSE.Equipment_ID
        WHERE TSE.Equipment_ID IS NULL;
    """)
    rows = cursor.fetchall()
    if not rows:
        print("All booked equipment has been used in test sessions.")
    else:
        for row in rows:
            print(row)

# Main Loop 
while True:
    menu()
    choice = input("Enter your choice (1-6): ")
    
    if choice == '1':
        show_clients()
    elif choice == '2':
        equipment_in_use()
    elif choice == '3':
        clients_confirmed_bookings()
    elif choice == '4':
        invoices_above_avg()
    elif choice == '5':
        equipment_booked_never_used()
    elif choice == '6':
        print("Exiting...")
        break
    else:
        print("Invalid choice. Try again.")

cursor.close()
conn.close()
