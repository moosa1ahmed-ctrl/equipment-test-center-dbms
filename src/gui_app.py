"""
------------------------------------------------------------------------
CP 363 Assignment 6 — GUI Application
Equipment Test Center DBMS
------------------------------------------------------------------------
Author: Moosa Ahmed
__updated__ = Nov. 15, 2025
------------------------------------------------------------------------
"""

import os
import mysql.connector
import tkinter as tk
from tkinter import ttk, messagebox

# Database Connection
# Credentials are read from environment variables — never hardcoded.
# Set these locally before running, e.g.:
#   DB_HOST=localhost DB_USER=root DB_PASSWORD=your_password python gui_app.py
conn = mysql.connector.connect(
    host=os.environ.get("DB_HOST", "localhost"),
    user=os.environ.get("DB_USER", "root"),
    password=os.environ.get("DB_PASSWORD", ""),
    database=os.environ.get("DB_NAME", "EquipmentTestCenterDB")
)
cursor = conn.cursor()

# Main Window
root = tk.Tk()
root.title("Equipment Test Center Management")
root.geometry("1000x600")
root.resizable(True, True)

# Main Frame 
main_frame = tk.Frame(root)
main_frame.pack(fill="both", expand=True)

# Helper Functions 
def create_treeview(parent, columns, headers):
    """Creates a scrollable Treeview inside the parent frame for displaying tabular data."""
    for widget in parent.winfo_children():
        widget.destroy()  # Clear previous content
    tree_frame = tk.Frame(parent)
    tree_frame.pack(fill="both", expand=True)
    tree_scroll = tk.Scrollbar(tree_frame)
    tree_scroll.pack(side=tk.RIGHT, fill=tk.Y)

    # Treeview setup
    tree = ttk.Treeview(tree_frame, columns=columns, show="headings", yscrollcommand=tree_scroll.set)
    tree.pack(fill="both", expand=True)
    tree_scroll.config(command=tree.yview)

    for col, head in zip(columns, headers):
        tree.heading(col, text=head)
        tree.column(col, width=120)  # Default column width
    return tree

def clear_frame():
    """Clears all widgets from the main frame for new content display."""
    for widget in main_frame.winfo_children():
        widget.destroy()

# Back Button 
def back_button(return_func=None):
    """
    Adds a Back button.
    If 'return_func' is provided, navigates there; otherwise returns to main menu.
    """
    if return_func is None:
        return_func = main_menu
    tk.Button(main_frame, text="Back", command=return_func, bg="grey", fg="white").pack(pady=10)

# Display Functions 
def show_equipment():
    """Displays all equipment in the database."""
    clear_frame()
    tk.Label(main_frame, text="Equipment Records", font=("Arial", 16, "bold")).pack(pady=10)
    cursor.execute("SELECT * FROM Equipment;")
    rows = cursor.fetchall()
    columns = ("Equipment_ID","Name","Model_Number","Manufacturer","Status")
    headers = ["ID","Name","Model","Manufacturer","Status"]
    tree = create_treeview(main_frame, columns, headers)
    for row in rows:
        tree.insert("", "end", values=row)
    back_button()

def show_clients():
    """Displays all clients in the database."""
    clear_frame()
    tk.Label(main_frame, text="Client Records", font=("Arial", 16, "bold")).pack(pady=10)
    cursor.execute("SELECT * FROM Client;")
    rows = cursor.fetchall()
    columns = ("Client_ID","First_Name","Last_Name","Email","Phone","Organization")
    headers = ["ID","First Name","Last Name","Email","Phone","Organization"]
    tree = create_treeview(main_frame, columns, headers)
    for row in rows:
        tree.insert("", "end", values=row)
    back_button()

def show_bookings():
    """Displays all bookings with client and lab info."""
    clear_frame()
    tk.Label(main_frame, text="Booking Records", font=("Arial", 16, "bold")).pack(pady=10)
    cursor.execute("""
        SELECT b.Booking_ID, c.First_Name, c.Last_Name, l.Lab_Name, b.Booking_Date, b.Start_Time, b.End_Time, b.Status
        FROM Booking b
        JOIN Client c ON b.Client_ID = c.Client_ID
        JOIN Lab l ON b.Lab_ID = l.Lab_ID;
    """)
    rows = cursor.fetchall()
    columns = ("Booking_ID","Client_First","Client_Last","Lab","Booking_Date","Start","End","Status")
    headers = ["ID","First Name","Last Name","Lab","Date","Start","End","Status"]
    tree = create_treeview(main_frame, columns, headers)
    for row in rows:
        tree.insert("", "end", values=row)
    back_button()

def show_reports():
    """Displays all reports with technician approval and test session info."""
    clear_frame()
    tk.Label(main_frame, text="Reports", font=("Arial", 16, "bold")).pack(pady=10)
    cursor.execute("""
        SELECT r.Report_ID, r.Findings, t.First_Name, t.Last_Name, ts.Test_Date
        FROM Report r
        JOIN Technician t ON r.Approved_By = t.Technician_ID
        JOIN Test_Session ts ON r.Session_ID = ts.Session_ID;
    """)
    rows = cursor.fetchall()
    columns = ("Report_ID","Findings","Tech_First","Tech_Last","Test_Date")
    headers = ["ID","Findings","Technician First","Technician Last","Test Date"]
    tree = create_treeview(main_frame, columns, headers)
    for row in rows:
        tree.insert("", "end", values=row)

    # Advanced report: Total revenue from invoices
    tk.Button(main_frame, text="View Total Revenue", command=show_total_revenue, bg="#f44336", fg="white").pack(pady=10)
    back_button()

def show_total_revenue():
    """Calculates and displays total revenue from all invoices. Handles NULL by defaulting to 0."""
    cursor.execute("SELECT SUM(Amount) FROM Invoice;")
    total = cursor.fetchone()[0] or 0  # NULL safe
    messagebox.showinfo("Total Revenue", f"Total Revenue: ${total:.2f}")

# Advanced Queries 
def show_advanced_queries():
    """Shows the advanced queries menu."""
    clear_frame()
    tk.Label(main_frame, text="Advanced Queries", font=("Arial", 16, "bold")).pack(pady=10)

    # Special case: Advanced reports
    tk.Button(main_frame, text="Tests Never Failed", command=show_tests_never_failed, bg="#3F51B5", fg="white").pack(pady=5)
    tk.Button(main_frame, text="Client Booking Ranking", command=show_client_ranking, bg="#795548", fg="white").pack(pady=5)
    back_button()  # Back to main menu

def show_tests_never_failed():
    """
    Advanced query: List tests that never failed.
    Uses a subquery in WHERE clause to exclude tests with any 'Fail' result.
    """
    clear_frame()
    tk.Label(main_frame, text="Tests Never Failed", font=("Arial", 16, "bold")).pack(pady=10)
    cursor.execute("""
        SELECT Test_Name
        FROM Test
        WHERE Test_ID NOT IN (
            SELECT Test_ID
            FROM Test_Session
            WHERE Result = 'Fail'
        );
    """)
    rows = cursor.fetchall()
    columns = ("Test_Name",)
    headers = ["Test Name"]
    tree = create_treeview(main_frame, columns, headers)
    for row in rows:
        tree.insert("", "end", values=row)

    # Special case: Back returns to Advanced Queries menu
    back_button(return_func=show_advanced_queries)

def show_client_ranking():
    """
    Advanced query: Rank clients by number of bookings.
    Demonstrates aggregation and ordering for reporting purposes.
    """
    clear_frame()
    tk.Label(main_frame, text="Client Booking Ranking", font=("Arial", 16, "bold")).pack(pady=10)
    cursor.execute("""
        SELECT c.First_Name, c.Last_Name, COUNT(b.Booking_ID) AS Total_Bookings
        FROM Client c
        LEFT JOIN Booking b ON c.Client_ID = b.Client_ID
        GROUP BY c.Client_ID
        ORDER BY Total_Bookings DESC;
    """)
    rows = cursor.fetchall()
    columns = ("First_Name","Last_Name","Total_Bookings")
    headers = ["First Name","Last Name","Bookings"]
    tree = create_treeview(main_frame, columns, headers)
    for row in rows:
        tree.insert("", "end", values=row)

    # Back returns to Advanced Queries menu
    back_button(return_func=show_advanced_queries)

# Main Menu
def main_menu():
    """Displays the main menu with all options."""
    clear_frame()
    tk.Label(main_frame, text="Equipment Test Center", font=("Arial", 20, "bold")).pack(pady=20)
    tk.Button(main_frame, text="View Equipment", width=25, command=show_equipment, bg="#4CAF50", fg="white").pack(pady=5)
    tk.Button(main_frame, text="View Clients", width=25, command=show_clients, bg="#2196F3", fg="white").pack(pady=5)
    tk.Button(main_frame, text="View Bookings", width=25, command=show_bookings, bg="#FF9800", fg="white").pack(pady=5)
    tk.Button(main_frame, text="View Reports", width=25, command=show_reports, bg="#9C27B0", fg="white").pack(pady=5)
    tk.Button(main_frame, text="Advanced Queries", width=25, command=show_advanced_queries, bg="#795548", fg="white").pack(pady=5)
    tk.Button(main_frame, text="Exit", width=25, command=root.quit, bg="grey", fg="white").pack(pady=20)

# Start 
main_menu()
root.mainloop()

# Close connection after GUI closes
cursor.close()
conn.close()
