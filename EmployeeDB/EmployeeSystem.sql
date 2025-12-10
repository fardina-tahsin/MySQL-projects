-- Employee management system database schema

CREATE DATABASE EmployeeManagement;
USE EmployeeManagement;

-- Table to store employee details

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15),
    HireDate DATE NOT NULL,
    JobTitle VARCHAR(100),
    DepartmentID VARCHAR(10),
    Salary DECIMAL(10, 2)
);

-- Table to store department details

CREATE TABLE Departments (
    DepartmentID VARCHAR(10) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID)

);

-- Table to store project details

CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY AUTO_INCREMENT,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    Budget DECIMAL(15, 2)
);

-- Table to store employee assignments to projects

CREATE TABLE EmployeeProjects (
    EmployeeID INT,
    ProjectID INT,
    AssignmentDate DATE NOT NULL,
    Role VARCHAR(100),
    PRIMARY KEY (EmployeeID, ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

-- Table to store attendance records

CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    AttendanceDate DATE NOT NULL,
    Status ENUM('Present', 'Absent', 'Leave') NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Table to store performance reviews

CREATE TABLE PerformanceReviews (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    ReviewDate DATE NOT NULL,
    ReviewerID INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments TEXT,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ReviewerID) REFERENCES Employees(EmployeeID)
);

-- Table to store employee benefits

CREATE TABLE EmployeeBenefits (
    BenefitID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT,
    BenefitType VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    Details TEXT,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- load data into tables without stored procedures

INSERT INTO Departments (DepartmentID, DepartmentName) VALUES
('HR', 'Human Resources'),
('IT', 'Information Technology'),
('FIN', 'Finance');

INSERT INTO Employees (FirstName, LastName, DateOfBirth, Email, PhoneNumber, HireDate, JobTitle, DepartmentID, Salary) VALUES
('John', 'Doe', '1985-06-15', 'john.doe@example.com', '123-456-7890', '2010-09-01', 'Software Engineer', 'IT', 75000.00);

INSERT INTO Projects (ProjectName, StartDate, EndDate, Budget) VALUES
('Project Alpha', '2023-01-01', '2023-12-31', 1000000.00);

INSERT INTO EmployeeProjects VALUES
(1, 1, '2023-01-15', 'Developer');

INSERT INTO Attendance (EmployeeID, AttendanceDate, Status) VALUES
(1, '2023-03-01', 'Present');

INSERT INTO PerformanceReviews (EmployeeID, ReviewDate, ReviewerID, Rating, Comments) VALUES
(1, '2023-06-01', 1, 5, 'Excellent performance throughout the year.');

INSERT INTO EmployeeBenefits (EmployeeID, BenefitType, StartDate, EndDate, Details) VALUES
(1, 'Health Insurance', '2023-01-01', NULL, 'Comprehensive health insurance plan.');

-- view employee details with attributes from related tables

CREATE VIEW EmployeeDetails AS
SELECT e.EmployeeID, e.FirstName, e.LastName,
       e.JobTitle, d.DepartmentName, p.ProjectName
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN EmployeeProjects ep ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects p ON ep.ProjectID = p.ProjectID;

-- view department-wise employee count

CREATE VIEW DepartmentEmployeeCount AS
SELECT d.DepartmentName, COUNT(e.EmployeeID) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName;

-- stored procedure for inserting data into Employees table

DELIMITER //

CREATE PROCEDURE InsertEmployee(
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_DateOfBirth DATE,
    IN p_Email VARCHAR(100),
    IN p_PhoneNumber VARCHAR(15),
    IN p_HireDate DATE,
    IN p_JobTitle VARCHAR(100),
    IN p_DepartmentID VARCHAR(10),
    IN p_Salary DECIMAL(10,2)
)
BEGIN
    INSERT INTO Employees (
        FirstName, LastName, DateOfBirth, Email,
        PhoneNumber, HireDate, JobTitle, DepartmentID, Salary
    )
    VALUES (
        p_FirstName, p_LastName, p_DateOfBirth, p_Email,
        p_PhoneNumber, p_HireDate, p_JobTitle, p_DepartmentID, p_Salary
    );
END //

DELIMITER ;

-- verify stored procedure creation

SHOW PROCEDURE STATUS
WHERE Db = 'EmployeeManagement'
AND Name = 'InsertEmployee';

-- call stored procedure to insert new employee records

CALL InsertEmployee(
    'Jane', 'Smith', '1990-08-25',
    'jane.smith@example.com', '987-654-3210',
    '2020-05-15', 'Project Manager', 'HR', 85000.00
);

CALL InsertEmployee(
    'Alice', 'Johnson', '1988-11-30',
    'alice.johnson@example.com', '555-123-4567',
    '2018-07-20', 'Business Analyst', 'FIN', 70000.00
);

SELECT * FROM Employees;

-- stored procedure for updating employee salary

DELIMITER //
CREATE PROCEDURE UpdateEmployeeSalary(
    IN p_EmployeeID INT,
    IN p_NewSalary DECIMAL(10,2)
)
BEGIN
    UPDATE Employees
    SET Salary = p_NewSalary
    WHERE EmployeeID = p_EmployeeID;
END //
DELIMITER ;

-- call stored procedure to update salary

CALL UpdateEmployeeSalary(1, 80000.00);
CALL UpdateEmployeeSalary(3, 90000.00);

SELECT EmployeeID, FirstName, LastName, Salary FROM Employees;

-- stored procedure for deleting an employee record

DELIMITER //
CREATE PROCEDURE DeleteEmployee(
    IN p_EmployeeID INT
)
BEGIN
    DELETE FROM Employees
    WHERE EmployeeID = p_EmployeeID;
END //
DELIMITER ;

-- call stored procedure to delete an employee

CALL DeleteEmployee(4);

SELECT * FROM Employees;

-- count total employees after deletion

SELECT COUNT(*) AS TotalEmployees FROM Employees;

-- end of employee management system database schema