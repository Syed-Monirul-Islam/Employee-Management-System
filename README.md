# Employee Management System Database Project

## Project Overview
This repository contains the SQL scripts and architectural design for a relational database built to manage the core operations of a corporate human resource environment. The system handles end-to-end operational workflows, including department organization, job role classification, employee lifecycle management, payroll processing (Salaries), and attendance tracking.

## Database Architecture
The system is built on a fully normalized relational model to ensure data integrity and scalability. It manages several interconnected entities:

*   **Departments & Jobs:** Primary organizational structures.
*   **Employees:** Central entity connecting various HR modules.
*   **Salaries:** Features automated Net Salary calculation using computed columns.
*   **Attendance & Leaves:** Tracks daily presence and leave requests.

## Technology Stack
*   **Database Engine:** MS SQL Server.
*   **Query Language:** T-SQL (Transact-SQL).

## Key Architectural Implementations
*   **Business Logic Automation:** Encapsulated transactional tasks into stored procedures (e.g., `sp_CRUD_Employees`) to handle Create, Read, Update, and Delete operations efficiently.
*   **Event-Driven Logging:** Implemented **AFTER INSERT** triggers (e.g., `trg_AfterEmployeeInsert`) to automate administrative history tracking in an audit log.

---
**Developed by:** [Syed Monirul Islam](https://github.com/Syed-Monirul-Islam)