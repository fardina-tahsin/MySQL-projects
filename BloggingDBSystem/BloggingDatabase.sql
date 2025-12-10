-- A Blogging Platform Database Schema

CREATE DATABASE BloggingPlatform;
USE BloggingPlatform;

-- Table to store users

CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table to store blog posts

CREATE TABLE Posts (
    PostID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    Title VARCHAR(200) NOT NULL,
    Content TEXT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Table to store comments on blog posts

CREATE TABLE Comments (
    CommentID INT PRIMARY KEY AUTO_INCREMENT,
    PostID INT,
    UserID INT,
    Content TEXT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE SET NULL
);

-- Table to store tags for blog posts

CREATE TABLE Tags (
    TagID INT PRIMARY KEY AUTO_INCREMENT,
    TagName VARCHAR(50) NOT NULL UNIQUE
);

-- Junction table to associate tags with posts

CREATE TABLE PostTags (
    PostID INT,
    TagID INT,
    PRIMARY KEY (PostID, TagID),
    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    FOREIGN KEY (TagID) REFERENCES Tags(TagID) ON DELETE CASCADE
);

-- Table to store likes on posts

CREATE TABLE PostLikes (
    LikeID INT PRIMARY KEY AUTO_INCREMENT,
    PostID INT,
    UserID INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    UNIQUE (PostID, UserID)
);

-- table to store categories for blog posts

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

-- Junction table to associate categories with posts

CREATE TABLE PostCategories (
    PostID INT,
    CategoryID INT,
    PRIMARY KEY (PostID, CategoryID),
    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE CASCADE
);

-- insert data into user table

INSERT INTO Users (Username, Email, PasswordHash) VALUES
('john_doe', 'john@example.com', 'hhgg765839847');
INSERT INTO Users (Username, Email, PasswordHash) VALUES
('jane_smith', 'jane@example.com', 'hgfds534245524');
INSERT INTO Users (Username, Email, PasswordHash) VALUES
('alice_jones', 'alice@example.com', 'kiuty423253424');
INSERT INTO Users (Username, Email, PasswordHash) VALUES
('bob_brown', 'bob@example.com', 'liliytu42455242434');
INSERT INTO Users (Username, Email, PasswordHash) VALUES
('charlie_black', 'charlie@example.com', 'degrftyu32456755432');

SELECT * FROM Users;

-- insert data into categories table

INSERT INTO Categories (CategoryName) VALUES
('Technology'),
('Health'),
('Travel'),
('Food'),
('Lifestyle');

SELECT * FROM Categories;

-- insert data into tags table

INSERT INTO Tags (TagName) VALUES
('SQL'),
('Database'),
('Web Development'),
('Programming'),
('Tutorial');

SELECT * FROM Tags;

-- insert data into posts table

INSERT INTO Posts (UserID, Title, Content) VALUES
(1, 'Introduction to SQL', 'This is a beginner''s guide to SQL.'),
(2, 'Top 10 Travel Destinations', 'Explore the best travel destinations around the world.'),
(3, 'Healthy Eating Tips', 'Tips for maintaining a healthy diet.'),
(4, 'Web Development Basics', 'Getting started with web development.'),
(5, 'Delicious Food Recipes', 'Try out these easy and delicious recipes.');

SELECT * FROM Posts;

-- insert data into postcategories table

INSERT INTO PostCategories (PostID, CategoryID) VALUES
(1, 1),
(2, 3),
(3, 2),
(4, 1),
(5, 4);

SELECT * FROM PostCategories;

-- insert data into posttags table

INSERT INTO PostTags (PostID, TagID) VALUES
(1, 1),
(1, 2),
(4, 3),
(4, 4),
(1, 5);

SELECT * FROM PostTags;

-- insert data into comments table

INSERT INTO Comments (PostID, UserID, Content) VALUES
(1, 2, 'Great introduction to SQL!'),
(2, 3, 'I love traveling to new places.'),
(3, 4, 'These healthy eating tips are very useful.'),
(4, 5, 'Web development is an exciting field!'),
(5, 1, 'I can''t wait to try these recipes.');

SELECT * FROM Comments;

-- insert data into postlikes table

INSERT INTO PostLikes (PostID, UserID) VALUES
(1, 3),
(2, 4),
(3, 5),
(4, 1),
(5, 2);

SELECT * FROM PostLikes;

-- track likes per post

SELECT P.PostID, P.Title, COUNT(PL.LikeID) AS LikeCount
FROM Posts P
LEFT JOIN PostLikes PL ON P.PostID = PL.PostID
GROUP BY P.PostID, P.Title;

-- view posts with their categories and tags

SELECT P.PostID, P.Title, C.CategoryName, T.TagName
FROM Posts P
LEFT JOIN PostCategories PC ON P.PostID = PC.PostID
LEFT JOIN Categories C ON PC.CategoryID = C.CategoryID
LEFT JOIN PostTags PT ON P.PostID = PT.PostID
LEFT JOIN Tags T ON PT.TagID = T.TagID;

-- trigger to update UpdatedAt timestamp on post update

DELIMITER //
CREATE TRIGGER UpdatePostTimestamp
BEFORE UPDATE ON Posts
FOR EACH ROW
BEGIN
    SET NEW.UpdatedAt = CURRENT_TIMESTAMP;
END;//
DELIMITER ;

-- test the trigger by updating a post

UPDATE Posts
SET Content = 'This is an updated content for the SQL guide.'
WHERE PostID = 1;

SELECT * FROM Posts WHERE PostID = 1;

-- update posts table with status column

ALTER TABLE Posts
ADD COLUMN Status ENUM('Draft', 'Published', 'Archived') DEFAULT 'Draft';

-- set some posts to published

UPDATE Posts
SET Status = 'Published'
WHERE PostID IN (1, 2, 4);

SELECT * FROM Posts;

-- full text search on posts content

ALTER TABLE Posts ENGINE=InnoDB;

ALTER TABLE Posts
ADD FULLTEXT INDEX idx_fulltext_content (Title, Content);

-- slug column for posts

ALTER TABLE Posts
ADD Slug VARCHAR(255) AS (LEFT(Title, 50)) STORED;

SELECT PostID, Title, Slug FROM Posts;

-- table to store post revisions

CREATE TABLE PostRevisions (
    RevisionID INT PRIMARY KEY AUTO_INCREMENT,
    PostID INT NOT NULL,
    UserID INT,
    Title VARCHAR(200),
    Content TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PostID) REFERENCES Posts(PostID) ON DELETE CASCADE
);

-- trigger to log post revisions before update

DELIMITER //
CREATE TRIGGER LogPostRevision
BEFORE UPDATE ON Posts
FOR EACH ROW
BEGIN
    INSERT INTO PostRevisions(PostID, UserID, Title, Content)
    VALUES (OLD.PostID, OLD.UserID, OLD.Title, OLD.Content);
END//
DELIMITER ;

-- delete implementation for posts

ALTER TABLE Posts ADD DeletedAt DATETIME NULL;

UPDATE Posts SET DeletedAt = NOW() WHERE PostID = 3;

-- user profile enhancements

ALTER TABLE Users
ADD Bio TEXT,
ADD AvatarURL VARCHAR(255),
ADD Website VARCHAR(255);

-- update data into user profile enhancements

UPDATE Users
SET Bio = 'Tech enthusiast and blogger.',
    AvatarURL = 'http://example.com/avatars/john_doe.jpg',
    Website = 'http://johndoe.com'
WHERE UserID = 1;

SELECT * FROM Users;

-- computed column for reading time estimation

ALTER TABLE Posts
ADD ReadingTime INT AS (LENGTH(Content) / 1000) STORED;

SELECT PostID, Title, ReadingTime FROM Posts;

-- indexes for performance optimization

CREATE INDEX idx_user_email ON Users(Email);
CREATE INDEX idx_post_createdat ON Posts(CreatedAt);    
CREATE INDEX idx_comment_postid ON Comments(PostID);
CREATE INDEX idx_postlike_userid ON PostLikes(UserID);
CREATE INDEX idx_postcategory_categoryid ON PostCategories(CategoryID);
CREATE INDEX idx_posttag_tagid ON PostTags(TagID);
CREATE INDEX idx_category_name ON Categories(CategoryName);
CREATE INDEX idx_tag_name ON Tags(TagName);

-- view to get user activity summary

CREATE VIEW UserActivitySummary AS
SELECT U.UserID, U.Username,
         COUNT(DISTINCT P.PostID) AS TotalPosts,
         COUNT(DISTINCT C.CommentID) AS TotalComments,
         COUNT(DISTINCT PL.LikeID) AS TotalLikes
FROM Users U
LEFT JOIN Posts P ON U.UserID = P.UserID    
LEFT JOIN Comments C ON U.UserID = C.UserID
LEFT JOIN PostLikes PL ON U.UserID = PL.UserID
GROUP BY U.UserID, U.Username;

-- query the user activity summary view

SELECT * FROM UserActivitySummary;

-- end of Blogging Platform Database Schema
