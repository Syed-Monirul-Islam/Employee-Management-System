Employee Management System Database
Project Overview
This repository contains the SQL scripts and architectural design for a relational database built to manage the core operations of a corporate human resource environment. The system handles end-to-end operational workflows, including department organization, job role classification, employee lifecycle management, payroll processing (Salaries), and attendance tracking.

Database Architecture
The system is built on a fully normalized relational model to ensure data integrity and scalability. It manages several interconnected entities:

Departments & Jobs: Primary organizational structures.

Employees: Central entity connecting various HR modules.

Salaries: Features automated Net Salary calculation using computed columns.

Attendance & Leaves: Tracks daily presence and leave requests.

Technology Stack
Database Engine: MS SQL Server.

Query Language: T-SQL (Transact-SQL).

Key Architectural Implementations
Business Logic Automation: Encapsulated transactional tasks into stored procedures (e.g., sp_CRUD_Employees) to handle Create, Read, Update, and Delete operations efficiently.

Event-Driven Logging: Implemented AFTER INSERT triggers (e.g., trg_AfterEmployeeInsert) to automate administrative history tracking in an audit log independently of the application layer.

Reusable Reporting Logic: Developed Scalar (e.g., age calculation) and Table-Valued Functions to generate instant metrics and filtered employee lists.

Data Abstraction: Created views (e.g., vw_EmployeeSnapshot) to provide secure, simplified access to complex datasets by combining multiple tables.

Advanced Data Analysis: Leveraged T-SQL techniques including Aggregate Functions, CTE (Common Table Expressions), and Grouping Sets (ROLLUP/CUBE) for comprehensive reporting.

Project Outcome
This project demonstrates a practical understanding of database administration and development. It showcases the ability to design an optimized database schema that handles organizational structures, tracks employee metrics, and provides actionable business insights through complex SQL queries.

Developed by: Syed Monirul Islam