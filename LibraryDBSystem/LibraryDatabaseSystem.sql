/* Library Database System */

CREATE DATABASE LibraryDB;
USE LibraryDB;

-- Create Authors table

CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    BirthDate DATE
);

INSERT INTO Authors (FirstName, LastName, BirthDate) VALUES
('George', 'Orwell', '1903-06-25'),
('Jane', 'Austen', '1775-12-16'),
('Steve', 'Helsi', '1904-07-20'),
('Jake', 'Pette', '1773-02-13'),
('Paul', 'Hing', '1906-04-15'),
('Rita', 'Khan', '1787-02-17'),
('Mimi', 'Kanes', '1908-05-21'),
('Howk', 'Mainer', '1778-12-11'),
('Stacy', 'Star', '1837-09-07');

SELECT * FROM Authors;

-- Create Books table

CREATE TABLE Books (
    BookID VARCHAR(10) PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    AuthorID INT,
    PublishedYear INT,
    Genre VARCHAR(50),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

INSERT INTO Books (BookID, Title, AuthorID, PublishedYear, Genre) VALUES
('B1100', '1984', 1, 1949, 'Dystopian'),
('B1101', 'Pride and Prejudice', 2, 1813, 'Romance'),
('B1102', 'Animal Farm', 3, 1945, 'Political Satire'),
('B1103', 'Sense and Sensibility', 4, 1811, 'Romance'),
('B1104', 'Homage to Catalonia', 5, 1938, 'Memoir'),
('B1105', 'Emma', 6, 1815, 'Romance'),
('B1106', 'Down and Out in Paris and London', 7, 1933, 'Memoir'),
('B1107', 'Mansfield Park', 8, 1814, 'Romance'),
('B1108', 'The Road to Wigan Pier', 9, 1905, 'Sociology');

SELECT * FROM Books;

-- Create Members table

CREATE TABLE Members (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    JoinDate DATE NOT NULL
);

INSERT INTO Members (FirstName, LastName, JoinDate) VALUES
('Alice', 'Johnson', '2020-01-15'),
('Bob', 'Smith', '2019-03-22'),
('Charlie', 'Brown', '2021-07-30'),
('Diana', 'Prince', '2018-11-05'),
('Ethan', 'Hunt', '2022-02-14');

SELECT * FROM Members;

-- Create Students table

CREATE TABLE Students (
    StudentID VARCHAR(12) PRIMARY KEY,
    StudentName VARCHAR(50) NOT NULL,
    EnrollmentDate DATE NOT NULL
);


INSERT INTO Students (StudentID, StudentName, EnrollmentDate) VALUES
('S1001', 'John Doe', '2021-09-01'),
('S1002', 'Jane Smith', '2020-08-15'),
('S1003', 'Emily Davis', '2022-01-10'),
('S1004', 'Michael Brown', '2019-07-20'),
('S1005', 'Billy Beb', '2021-09-01'),
('S1006', 'Anna Smith', '2020-08-15'),
('S1007', 'Mook Dav', '2022-01-10'),
('S1008', 'Michel Bown', '2019-07-20'),
('S1009', 'Alla Ans', '2019-07-20'),
('S1010', 'Mick Bunny', '2019-07-20'),
('S1011', 'Regel Mitch', '2019-07-20'),
('S1012', 'Sarah Wilson', '2021-03-05');

SELECT * FROM Students 
ORDER BY StudentID ASC;

-- Create IssueStatus table

CREATE TABLE IssueStatus (
    IssueID VARCHAR(20) PRIMARY KEY,
    Issued_book_name VARCHAR(50),
    Issued_book_id VARCHAR(10),
    Issue_date DATE,
    Issued_student_id VARCHAR(20),
    FOREIGN KEY (Issued_student_id) REFERENCES Students(StudentID) on DELETE CASCADE,
    FOREIGN KEY (Issued_book_id) REFERENCES Books(BookID) on DELETE CASCADE
    
);

INSERT INTO IssueStatus (IssueID, Issued_book_id, Issued_book_name, Issue_date, Issued_student_id) VALUES
('I2001', 'B1100', '1984', '2023-01-10', 'S1001'),
('I2002', 'B1101', 'Pride and Prejudice', '2023-02-15', 'S1002'),
('I2003', 'B1102', 'Animal Farm', '2023-03-20', 'S1003'),
('I2004', 'B1103', 'Sense and Sensibility', '2023-04-25', 'S1004'),
('I2005', 'B1104', 'Homage to Catalonia', '2023-05-30', 'S1005');

SELECT * FROM IssueStatus;

-- Create Returns table

CREATE TABLE Returns (
    ReturnID VARCHAR(20) PRIMARY KEY,
    Returned_book_name VARCHAR(50),
    Returned_book_id VARCHAR(10),
    Return_date DATE,
    Returning_student_id VARCHAR(20),
    FOREIGN KEY (Returning_student_id) REFERENCES Students(StudentID) on DELETE CASCADE,
    FOREIGN KEY (Returned_book_id) REFERENCES Books(BookID) on DELETE CASCADE
);

INSERT INTO Returns (ReturnID, Returned_book_id, Returned_book_name, Return_date, Returning_student_id) VALUES
('R3001', 'B1100', '1984', '2023-02-10', 'S1001'),
('R3002', 'B1101', 'Pride and Prejudice', '2023-03-15', 'S1002'),
('R3003', 'B1102', 'Animal Farm', '2023-04-20', 'S1003');

SELECT * FROM Returns;

ALTER TABLE Returns
MODIFY COLUMN Returned_book_name VARCHAR(100);

ALTER TABLE Returns
CHANGE COLUMN Returned_book_name ReturnBook VARCHAR(70);

SELECT * FROM Returns;

-- returns made by a specific student for a specific book

SELECT * FROM Returns
WHERE Returning_student_id = 'S1002'
AND Returned_book_id = 'B1101';

-- books issued but not yet returned

SELECT i.Issued_book_id, i.Issue_date, Issued_book_name
FROM IssueStatus i
LEFT JOIN Returns r 
ON i.Issued_book_id = r.Returned_book_id AND i.Issued_student_id = r.Returning_student_id
WHERE i.Issued_student_id = 'S1004' 
AND r.Returned_book_id IS NULL;

-- Add status column to Books table

ALTER TABLE Books
ADD COLUMN Status VARCHAR(20) DEFAULT 'Available';

-- Update book status when issued

UPDATE Books b
SET b.Status = 'Issued'
WHERE b.BookID IN (SELECT i.Issued_book_id FROM IssueStatus i);

-- Update book status when returned

UPDATE Books b
SET b.Status = 'Returned'
WHERE b.BookID IN (SELECT r.Returned_book_id FROM Returns r);

-- View updated Books table

SELECT * FROM Books;

-- show student names with the books they returned

SELECT s.StudentName, r.ReturnBook, r.Return_date
FROM Students AS s
JOIN Returns AS r ON s.StudentID = r.Returning_student_id;

-- Update the Members table with salary column

ALTER TABLE Members
ADD COLUMN Salary DECIMAL(10,2);

UPDATE Members
SET Salary = CASE 
    WHEN MemberID = 1 THEN 50000.00
    WHEN MemberID = 2 THEN 60000.00
    WHEN MemberID = 3 THEN 55000.00
    WHEN MemberID = 4 THEN 70000.00
    WHEN MemberID = 5 THEN 65000.00
END;

SELECT * FROM Members;

-- Delete a member from Members table

DELETE FROM Members
WHERE MemberID = 3;

SELECT * FROM Members;

-- Delete a book from Books table

DELETE FROM Books
WHERE BookID = 'B1107';

SELECT * FROM Books;

-- count books by genre

SELECT Genre, COUNT(BookID) AS BookCount
FROM Books
GROUP BY Genre;

-- End of Library Database System */