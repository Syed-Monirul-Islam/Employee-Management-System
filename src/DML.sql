/* 
   1. Database and Environment Setup
*/
USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EmployeeManagementDB')
BEGIN
    CREATE DATABASE EmployeeManagementDB;
END
GO

USE EmployeeManagementDB;
GO

/* 
   2. Cleanup Section (To avoid "Already exists" errors)
   Always drop child tables first, then parent tables.
*/
DROP TABLE IF EXISTS Salarys;
DROP TABLE IF EXISTS Attendances;
DROP TABLE IF EXISTS LeaveTables;
DROP TABLE IF EXISTS EmployeeLog;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Jobs;
GO

/* 
   3. Table Creation (DDL)
*/
-- Parent Tables
CREATE TABLE Departments(
    DepartmentID INT PRIMARY KEY IDENTITY,
    DepartmentName VARCHAR(50) NOT NULL,
    Location VARCHAR(50)
);

CREATE TABLE Jobs (
    JobID INT PRIMARY KEY IDENTITY,
    JobTitle VARCHAR(50) NOT NULL,
    SalaryRange VARCHAR(50)
);

-- Main Employee Table
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    DateOfBirth DATE,
    DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    JobID INT FOREIGN KEY REFERENCES Jobs(JobID),
    JoiningDate DATE
);

-- Child Tables
CREATE TABLE Salarys (
    SalaryID INT PRIMARY KEY IDENTITY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    BasicSalary DECIMAL(10,2) NOT NULL,
    Allowances DECIMAL(10,2) DEFAULT 0,
    Deductions DECIMAL(10,2) DEFAULT 0,
    NetSalary AS (BasicSalary + Allowances - Deductions),
    PaymentDate DATE NOT NULL
);

CREATE TABLE Attendances (
    AttendanceID INT PRIMARY KEY IDENTITY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    Date DATE NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Present','Absent','Late'))
);

CREATE TABLE LeaveTables (
    LeaveID INT PRIMARY KEY IDENTITY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    LeaveType VARCHAR(20) CHECK (LeaveType IN ('Sick','Casual','Annual')),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(20) CHECK (Status IN ('Approved','Rejected','Pending'))
);
GO
USE EmployeeManagementDB;
GO

-- If the procedure already exists, drop it
DROP PROCEDURE IF EXISTS sp_CRUD_Employees;
GO
/* 
   4. Stored Procedure for CRUD
*/
CREATE PROCEDURE sp_CRUD_Employees
(
    @Action VARCHAR(10),
    @EmployeeID INT = NULL,
    @Name VARCHAR(100) = NULL,
    @Gender VARCHAR(10) = NULL,
    @DateOfBirth DATE = NULL,
    @DepartmentID INT = NULL,
    @JobID INT = NULL,
    @JoiningDate DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @Action = 'CREATE'
            INSERT INTO Employees (Name, Gender, DateOfBirth, DepartmentID, JobID, JoiningDate)
            VALUES (@Name, @Gender, @DateOfBirth, @DepartmentID, @JobID, @JoiningDate);
        ELSE IF @Action = 'READ'
            SELECT e.*, d.DepartmentName, j.JobTitle FROM Employees e 
            JOIN Departments d ON e.DepartmentID = d.DepartmentID
            JOIN Jobs j ON e.JobID = j.JobID
            WHERE (@EmployeeID IS NULL OR e.EmployeeID = @EmployeeID);
        ELSE IF @Action = 'UPDATE'
            UPDATE Employees SET Name = @Name, Gender = @Gender, DateOfBirth = @DateOfBirth, 
            DepartmentID = @DepartmentID, JobID = @JobID, JoiningDate = @JoiningDate WHERE EmployeeID = @EmployeeID;
        ELSE IF @Action = 'DELETE'
            DELETE FROM Employees WHERE EmployeeID = @EmployeeID;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/* 
   5. Data Seeding (DML)
*/
-- Insert Departments & Jobs
INSERT INTO Departments VALUES ('HR', 'Dhaka'), ('IT', 'Chattogram'), ('Finance', 'Sylhet');
INSERT INTO Jobs VALUES ('Manager', '40000-60000'), ('Software Engineer', '25000-40000'), ('Accountant', '20000-30000');

-- Insert Initial Employees
INSERT INTO Employees VALUES ('Rahim', 'Male', '1990-05-10', 1, 1, '2020-01-15');
INSERT INTO Employees VALUES ('Ayesha', 'Female', '1998-03-12', 3, 3, '2022-02-10');

-- Fix/Update
EXEC sp_CRUD_Employees 
    @Action = 'UPDATE', 
    @EmployeeID = 2, 
    @Name = 'Karim', 
    @Gender = 'Male', 
    @DateOfBirth = '1995-08-20', 
    @DepartmentID = 2, 
    @JobID = 2, 
    @JoiningDate = '2021-06-01';
GO

--  using Procedure
EXEC sp_CRUD_Employees 'CREATE', NULL, 'Rubel', 'Male', '1999-10-25', 1, 2, '2023-10-01';

-- Salaries, Attendance, & Leaves
INSERT INTO Salarys VALUES (1, 50000, 5000, 2000, '2023-01-31');
INSERT INTO Salarys VALUES (2, 30000, 3000, 1000, '2023-01-31');
INSERT INTO Salarys VALUES (3, 25000, 2000, 500, '2023-01-31');

INSERT INTO Attendances VALUES (1, '2023-01-01', 'Present'), (2, '2023-01-01', 'Absent');
INSERT INTO LeaveTables VALUES (1, 'Annual', '2023-02-01', '2023-02-05', 'Approved');
GO

/* 
   6. Final Verification
*/
SELECT * FROM Departments;
SELECT * FROM Jobs;
SELECT * FROM Employees;
SELECT * FROM Salarys;
GO