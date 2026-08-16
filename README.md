# Equipment Test Center — DBMS Project

CP363 – Database Systems | Fall 2025 | Full Database Lifecycle Project, Group Project

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Team Members](#team-members)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Database Setup](#database-setup)
  - [Running the Application](#running-the-application)
- [Environment Configuration](#environment-configuration)
- [Database Schema Overview](#database-schema-overview)
- [Query Catalog](#query-catalog)
- [Testing](#testing)
- [Assignment Deliverables](#assignment-deliverables)
- [Known Issues / Limitations](#known-issues--limitations)
- [Project Management](#project-management)
- [License](#license)

## Project Overview
Equipment Test Center is a full database lifecycle project for a business that books lab space and equipment for client tests, run by technicians who log results in reports and generate invoices. The project covers the complete lifecycle: ER/EER modeling, relational schema design, population and querying, formal normalization to 3NF/BCNF, and two working applications (CLI + GUI) built on top of the finished schema.

**In Scope:**
- ER/EER modeling with weak entities and multivalued attributes
- Relational schema design with enforced referential integrity
- Basic and advanced SQL (subqueries, correlated subqueries, window functions, views)
- Execution plan analysis for query optimization
- Formal normalization verification (3NF, BCNF)
- CLI and GUI applications over the schema

**Out of Scope:**
- Web-based interface
- Multi-user authentication/authorization within the applications
- Real-time booking conflict resolution
- Production deployment / hosting

## Features

**Must Have**
- 11-table normalized relational schema with PK/FK and CHECK constraints
- 10+ queries including subqueries, correlated subqueries, and window functions
- 3 basic views (`DISTINCT`, `GROUP BY`, `ORDER BY`, calculated fields)
- 3 advanced views (subqueries in `SELECT` / `FROM` / `WHERE`)
- Formal 3NF and BCNF verification with functional dependency analysis
- CLI query menu application ([`cli_menu_app.py`](src/cli_menu_app.py))
- Tkinter GUI application ([`gui_app.py`](src/gui_app.py))

**Should Have**
- Execution plan analysis with optimization suggestions for at least one query
- Relational algebra notation for all queries (in final documentation)

**Could Have (Stretch Goals)**
- Web-based front end instead of desktop-only interfaces
- Automated report generation / export
- Multi-technician scheduling conflict detection

## Technology Stack
| Layer | Technology |
|---|---|
| Database | MySQL |
| Schema Design | MySQL Workbench |
| Interfaces | Python — `mysql-connector-python`, Tkinter (GUI) |
| Version Control | Git, GitHub |

## Team Members
| Name |
|---|
| Moosa Ahmed |
| Muhammad Saim Bin Asif |

## Repository Structure
```
equipment-test-center-dbms/
├── README.md
├── requirements.txt
├── .gitignore
├── src/
│   ├── Table definitions.sql
│   ├── Sample data population.sql
│   ├── Queries.sql
│   ├── Views.sql
│   ├── Advanced Queries.sql
│   ├── Advanced Views.sql
│   ├── Menu-Queries.sql       ← queries used by the CLI app
│   ├── cli_menu_app.py        ← Assignment 4 — CLI query menu
│   └── gui_app.py             ← Assignment 6 — Tkinter GUI application
└── docs/
    ├── Assignment-01-ER-Modelling.pdf
    ├── Assignment-02-Schema-Design.pdf
    ├── Assignment-03-Construction-Queries.pdf
    ├── Assignment-04-Advanced-Queries.pdf
    ├── Assignment-05-Normalization.pdf
    └── Final-Documentation.pdf
```

## Getting Started

### Prerequisites
- [MySQL Server](https://dev.mysql.com/downloads/mysql/)
- MySQL Workbench (optional, for visual schema editing)
- Python 3

### Database Setup
1. Install MySQL Server and create a database (e.g. `EquipmentTestCenterDB`).
2. Run the schema script:
   ```bash
   mysql -u root -p < "src/Table definitions.sql"
   ```
3. Populate with sample data:
   ```bash
   mysql -u root -p EquipmentTestCenterDB < "src/Sample data population.sql"
   ```

### Running the Application
```bash
git clone https://github.com/moosa1ahmed-ctrl/equipment-test-center-dbms.git
cd equipment-test-center-dbms
pip install -r requirements.txt
```
Then run either interface:
```bash
DB_PASSWORD=your_password python src/cli_menu_app.py
# or
DB_PASSWORD=your_password python src/gui_app.py
```

## Environment Configuration
Database credentials are read from environment variables — **never hardcoded in source**.

| Variable | Description | Default |
|---|---|---|
| `DB_HOST` | MySQL host | `localhost` |
| `DB_PORT` | MySQL port | `3306` |
| `DB_USER` | MySQL username | `root` |
| `DB_PASSWORD` | MySQL password | *(none — set your own)* |
| `DB_NAME` | Database name | `EquipmentTestCenterDB` |

## Database Schema Overview
11 tables, including two junction tables for many-to-many relationships. Full `CREATE TABLE` statements with constraints are in [`src/Table definitions.sql`](src/Table%20definitions.sql).

| Table | Description |
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

**Key Relationships**

| From | To | Relationship |
|---|---|---|
| `Client` | `Booking` | One client has many bookings |
| `Technician` | `Test_Session` | One technician runs many test sessions |
| `Booking` | `Test_Session` | One booking can include many test sessions |
| `Test_Session` | `Report` | One test session has one report |
| `Booking` | `Invoice` | One booking has one invoice |
| `Equipment` | `Booking_Equipment` / `TestSession_Equipment` | Many-to-many with bookings and test sessions |

## Query Catalog
| File | Contents |
|---|---|
| [`Queries.sql`](src/Queries.sql) | Basic queries — joins, subqueries, correlated subqueries |
| [`Advanced Queries.sql`](src/Advanced%20Queries.sql) | Joins, set operations, grouped/statistical queries, window functions (`RANK`, `ROW_NUMBER`) |
| [`Views.sql`](src/Views.sql) | 3 views with `DISTINCT`, `GROUP BY`, `ORDER BY`, and calculated fields |
| [`Advanced Views.sql`](src/Advanced%20Views.sql) | 3 views with subqueries in `SELECT` / `FROM` / `WHERE` clauses |
| [`Menu-Queries.sql`](src/Menu-Queries.sql) | Queries exposed through the CLI menu app |
| [`Sample data population.sql`](src/Sample%20data%20population.sql) | Realistic dummy data for all 11 tables |

Sample query (client booking ranking, window function):
```sql
SELECT c.Client_ID, c.First_Name, c.Last_Name, COUNT(b.Booking_ID) AS Total_Bookings,
    RANK() OVER (ORDER BY COUNT(b.Booking_ID) DESC) AS Booking_Rank
FROM Client c
JOIN Booking b ON c.Client_ID = b.Client_ID
GROUP BY c.Client_ID, c.First_Name, c.Last_Name;
```

## Testing
No automated test suite is configured. Testing was manual:

| Area | Example Test Cases |
|---|---|
| Schema integrity | Insert a booking referencing a nonexistent client (expect FK violation) |
| Queries | Run each query in [`Queries.sql`](src/Queries.sql) and [`Advanced Queries.sql`](src/Advanced%20Queries.sql) against sample data, verify expected rows returned |
| Views | Query each view directly, confirm calculated fields and filters behave as designed |
| CLI / GUI apps | Manually exercised each menu option / GUI action against the populated database — see the recorded GUI demo (not included in this repo; see note below) |

A GUI demo video was recorded during development but is excluded from this repository due to file size — available on request.

## Assignment Deliverables
| Deliverable | Location |
|---|---|
| Assignment 01 — ER/EER Modeling | [`docs/Assignment-01-ER-Modelling.pdf`](docs/Assignment-01-ER-Modelling.pdf) |
| Assignment 02 — Schema Design | [`docs/Assignment-02-Schema-Design.pdf`](docs/Assignment-02-Schema-Design.pdf) |
| Assignment 03 — Construction & Basic Queries | [`docs/Assignment-03-Construction-Queries.pdf`](docs/Assignment-03-Construction-Queries.pdf) |
| Assignment 04 — Advanced Queries | [`docs/Assignment-04-Advanced-Queries.pdf`](docs/Assignment-04-Advanced-Queries.pdf) |
| Assignment 05 — Normalization | [`docs/Assignment-05-Normalization.pdf`](docs/Assignment-05-Normalization.pdf) |
| Final Documentation | [`docs/Final-Documentation.pdf`](docs/Final-Documentation.pdf) |

## Known Issues / Limitations
- No automated test suite is configured.
- The CLI and GUI apps assume a single-user, trusted local environment — no login/authentication layer.
- Booking-conflict checking (double-booking the same lab/time) is not enforced at the database level.

## Project Management
GitHub Kanban Board: *not yet set up*
Wiki: *not yet set up*

## License
This project was developed as part of the CP363 – Database Systems course at Wilfrid Laurier University (WLU), Fall 2025. It is intended solely for academic evaluation purposes.
