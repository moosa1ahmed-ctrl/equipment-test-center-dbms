# Equipment Test Center — DBMS Project

CP363 (Database Systems, Wilfrid Laurier University) term project. A full database lifecycle project — from ER modeling through a normalized relational schema to a working desktop application — for managing an equipment testing center: clients, lab bookings, equipment, technicians, test sessions, reports, and invoicing.

**Team 26**
- Moosa Ahmed
- Muhammad Saim Bin Asif

## Stack
- MySQL (schema design, queries, views)
- Python — `mysql-connector-python`, Tkinter (GUI)

## What this project covers
Built across six assignments spanning the full database design lifecycle:
1. **ER/EER Modeling** — 11 entities, weak entities, multivalued attributes, cardinality constraints
2. **Schema Design** — relational schema in MySQL Workbench, with PK/FK constraints enforcing referential integrity
3. **Construction & Basic Queries** — populated tables, 10+ queries including subqueries, correlated subqueries, and window functions; 3 views
4. **Advanced Queries** — joins, set operations, grouped/statistical queries, execution plan analysis, and 3 advanced views (subqueries in SELECT/FROM/WHERE); a CLI menu app in Python
5. **Normalization** — verified/decomposed to 3NF and BCNF using functional dependency analysis
6. **Application Demonstration** — a full Tkinter GUI over the normalized schema, plus final documentation with relational algebra notation

## Database schema

11 tables, including two junction tables for many-to-many relationships:

| Table | Purpose |
|---|---|
| `Client` | Customers who book lab time and equipment |
| `Technician` | Staff who run test sessions and approve reports |
| `Equipment` | Testable equipment, with status (`Available` / `In Use` / `Under Maintenance`) |
| `Lab` | Physical lab spaces with capacity |
| `Test` | Catalog of test types |
| `Booking` | A client's reservation of a lab, with status tracking |
| `Test_Session` | A specific test run by a technician, with result and duration |
| `Report` | Findings from a test session, approved by a technician |
| `Invoice` | Billing tied to a booking |
| `Maintenance_Record` | Equipment maintenance history |
| `Booking_Equipment` / `TestSession_Equipment` | Junction tables linking equipment to bookings and test sessions (many-to-many) |

Full `CREATE TABLE` statements with constraints are in [`src/Table definitions.sql`](src/Table%20definitions.sql).

## Repo structure
```
├── src/
│   ├── Table definitions.sql
│   ├── Sample data population.sql
│   ├── Queries.sql
│   ├── Views.sql
│   ├── Advanced Queries.sql
│   ├── Advanced Views.sql
│   ├── Menu-Queries.sql       # queries used by the CLI app
│   ├── cli_menu_app.py        # Assignment 4 — CLI query menu
│   └── gui_app.py             # Assignment 6 — Tkinter GUI application
├── docs/
│   ├── Assignment-01-ER-Modelling.pdf
│   ├── Assignment-02-Schema-Design.pdf
│   ├── Assignment-03-Construction-Queries.pdf
│   ├── Assignment-04-Advanced-Queries.pdf
│   ├── Assignment-05-Normalization.pdf
│   └── Final-Documentation.pdf
├── requirements.txt
└── .gitignore
```

## Environment Configuration

Database credentials are read from environment variables — never hardcoded in source.

| Variable | Description | Default |
|---|---|---|
| `DB_HOST` | MySQL host | `localhost` |
| `DB_PORT` | MySQL port | `3306` |
| `DB_USER` | MySQL username | `root` |
| `DB_PASSWORD` | MySQL password | *(none — set your own)* |
| `DB_NAME` | Database name | `EquipmentTestCenterDB` |

## Running it
```bash
pip install -r requirements.txt

# 1. Create and populate the database
mysql -u root -p < "src/Table definitions.sql"
mysql -u root -p EquipmentTestCenterDB < "src/Sample data population.sql"

# 2. Run either interface
DB_PASSWORD=your_password python src/cli_menu_app.py
# or
DB_PASSWORD=your_password python src/gui_app.py
```

## Full documentation
See [`docs/Final-Documentation.pdf`](docs/Final-Documentation.pdf) for the complete project writeup, including relational algebra notation for all queries and design retrospective.
