/* 
   1. Database Creation
   Creates the EmployeeManagementDB on the default SQL Server data path.
*/
USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EmployeeManagementDB')
BEGIN
    DECLARE @Data_path nvarchar(256);
    SET @Data_Path =(SELECT SUBSTRING(Physical_Name, 1, CHARINDEX(N'master.mdf',LOWER(Physical_Name))-1)
    FROM master.sys.master_files
    WHERE Database_id=1 AND file_id=1);

    EXEC ('CREATE DATABASE EmployeeManagementDB
    ON PRIMARY (Name= EmployeeManagementDB_Data, FileName=''' + @Data_path + 'EmployeeManagementDB_Data.mdf'', Size=25MB, MAXSIZE=100MB, FILEGROWTH=5%)
    LOG ON (Name= EmployeeManagementDB_Log, FileName=''' + @Data_path + 'EmployeeManagementDB_Log.ldf'', Size=2MB, MAXSIZE=25MB, FILEGROWTH=1%)');
END
GO

USE EmployeeManagementDB;
GO

/* 
   2. Table Creation
   Tables are created in order to respect Foreign Key constraints.
*/

-- Parent Table: Departments
CREATE TABLE Departments(
    DepartmentID INT PRIMARY KEY IDENTITY,
    DepartmentName VARCHAR(50) NOT NULL,
    Location VARCHAR(50)
);
GO

-- Parent Table: Jobs
CREATE TABLE Jobs (
    JobID INT PRIMARY KEY IDENTITY,
    JobTitle VARCHAR(50) NOT NULL,
    SalaryRange VARCHAR(50)
);
GO

-- Main Table: Employees
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    DateOfBirth DATE,
    DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID),
    JobID INT FOREIGN KEY REFERENCES Jobs(JobID),
    JoiningDate DATE
);
GO

-- Child Table: Salarys
CREATE TABLE Salarys (
    SalaryID INT PRIMARY KEY IDENTITY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    BasicSalary DECIMAL(10,2) NOT NULL,
    Allowances DECIMAL(10,2) DEFAULT 0,
    Deductions DECIMAL(10,2) DEFAULT 0,
    NetSalary AS (BasicSalary + Allowances - Deductions),
    PaymentDate DATE NOT NULL
);
GO

-- Child Table: Attendances
CREATE TABLE Attendances (
    AttendanceID INT PRIMARY KEY IDENTITY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    Date DATE NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Present','Absent','Late'))
);
GO

-- Child Table: LeaveTables
CREATE TABLE LeaveTables (
    LeaveID INT PRIMARY KEY IDENTITY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    LeaveType VARCHAR(20) CHECK (LeaveType IN ('Sick','Casual','Annual')),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(20) CHECK (Status IN ('Approved','Rejected','Pending'))
);
GO

-- Audit Table: EmployeeLog
CREATE TABLE EmployeeLog (
    LogID INT PRIMARY KEY IDENTITY,
    EmployeeID INT,
    ActionTaken VARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE()
);
GO

/* 
   3. Views
*/
CREATE VIEW vw_EmployeeSnapshot
AS
SELECT 
    e.EmployeeID,
    e.Name AS EmployeeName,
    d.DepartmentName,
    j.JobTitle AS Position,
    s.BasicSalary,
    s.Allowances,
    s.Deductions,
    s.NetSalary,
    e.JoiningDate AS HireDate,
    s.PaymentDate
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Jobs j ON e.JobID = j.JobID
JOIN Salarys s ON e.EmployeeID = s.EmployeeID;
GO

/* 
   4. Functions
*/

-- Scalar Function: Calculate Age
CREATE FUNCTION fn_GetEmployeeAge (@EmployeeID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    SELECT @Age = DATEDIFF(YEAR, DateOfBirth, GETDATE()) FROM Employees WHERE EmployeeID = @EmployeeID;
    RETURN @Age;
END;
GO

-- Inline Table-Valued Function: Get Employees by Dept
CREATE FUNCTION fn_GetEmployeesByDepartment (@DeptID INT)
RETURNS TABLE
AS
RETURN (SELECT EmployeeID, Name, JoiningDate FROM Employees WHERE DepartmentID = @DeptID);
GO

/* 
   5. Stored Procedure (CRUD Operations)
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
   6. Triggers
*/
CREATE TRIGGER trg_AfterEmployeeInsert
ON Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO EmployeeLog (EmployeeID, ActionTaken)
    SELECT EmployeeID, 'New Employee Added' FROM inserted;
END;
GO

/* 
   7. Indexing
*/
CREATE NONCLUSTERED INDEX IX_Employees_Name ON Employees (Name);
GO

/* 
   8. Sample Data Seeding
*/
INSERT INTO Departments VALUES ('HR', 'Dhaka'), ('IT', 'Chattogram'), ('Finance', 'Sylhet');
INSERT INTO Jobs VALUES ('Manager', '40000-60000'), ('Developer', '25000-40000'), ('Accountant', '20000-30000');

-- Insert via Stored Procedure
EXEC sp_CRUD_Employees 'CREATE', NULL, 'Syed Monirul Islam', 'Male', '1995-01-01', 2, 2, '2026-05-01';
EXEC sp_CRUD_Employees 'CREATE', NULL, 'Rahim Khan', 'Male', '1990-05-10', 1, 1, '2020-01-15';

-- Insert Salaries
INSERT INTO Salarys VALUES (1, 55000, 5000, 2000, '2026-04-30');
INSERT INTO Salarys VALUES (2, 50000, 5000, 2000, '2026-04-30');
GO

/* 
   9. Final Data Verification
*/
SELECT * FROM Departments;
SELECT * FROM Jobs;
SELECT * FROM Employees;
SELECT * FROM Salarys;
SELECT * FROM EmployeeLog;
SELECT * FROM vw_EmployeeSnapshot;
GO