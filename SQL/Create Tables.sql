-- Create DB
 create database Examination
-- Add File Group
alter database Examination
add filegroup FirstFG
alter database Examination
add filegroup SecondFG
alter database Examination
add filegroup ThirdFG
alter database Examination
add filegroup ForthFG
-- Add Files To File Group
alter database Examination
ADD FILE
(
    NAME = 'FirstFG_Data',
    FILENAME = 'D:\iti\db\projact\Examination System\SQL\File Group/FirstFG_Data.ndf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
) TO FILEGROUP FirstFG;
alter database Examination
ADD FILE
(
    NAME = 'SecondFG_Data',
    FILENAME = 'D:\iti\db\projact\Examination System\SQL\File Group/SecondFG_Data.ndf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
) TO FILEGROUP SecondFG;
alter database Examination
ADD FILE
(
    NAME = 'ThirdFG_Data',
    FILENAME = 'D:\iti\db\projact\Examination System\SQL\File Group/ThirdFG_Data.ndf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
) TO FILEGROUP ThirdFG;
alter database Examination
ADD FILE
(
    NAME = 'ForthFG_Data',
    FILENAME = 'D:\iti\db\projact\Examination System\SQL\File Group/ForthFG_Data.ndf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
) TO FILEGROUP ForthFG;

-- Branche Table
create table Branches
(
   Branch_ID int identity(1,1),
   Branch_Name nvarchar(55) not null,
   City nvarchar(50) not null,
   constraint PK_Branch_ID PRIMARY KEY(Branch_ID)
) on FirstFG;

-- Intake Table  
create table Intakes
(
   Intake_ID int identity(1,1),
   Intake_Name nvarchar(50) NOT NULL,
   Date_Start DATE NOT NULL,
   Date_End DATE NOT NULL,
   Branch_ID INT null,
   constraint PK_Intake_ID primary key(Intake_ID),
   constraint FK_Branch_Intake foreign key (Branch_ID) references Branches(Branch_ID) on update cascade
) on FirstFG;

-- Department Table 
create table Departments
(
   Department_ID int identity(1,1),
   Department_Name nvarchar(50) not null,
   constraint PK_Department_ID primary key(Department_ID)
) on FirstFG;
 
-- Track Table
create table Tracks
(
   Track_ID int identity(1,1),
   Track_Name nvarchar(50) not null,
   Department_ID int null,
   constraint PK_Track_ID primary key (Track_ID),
   constraint FK_Track_Department foreign key (Department_ID) references Departments(Department_ID)	 on update cascade
) on FirstFG;
 
-- Student Table
create table Students
(
   Student_ID int identity (1,1),
   Student_Name nvarchar(80) not null,
   Faculty_Name nvarchar(40) not null,
   Student_Email nvarchar(25) not null unique,
   Student_Password nvarchar(225) not null,
   Student_Phone nvarchar(11) not null,
   Branch_ID int null,
   Track_ID int null,
   Intake_ID int null,
   constraint PK_Student_ID primary key(Student_ID),
   constraint FK_Student_Branch foreign key (Branch_ID) references Branches(Branch_ID) on update cascade,
   constraint FK_Student_Intake foreign key (Intake_ID) references Intakes(Intake_ID),
   constraint FK_Student_Track foreign key (Track_ID) references Tracks(Track_ID),
   constraint CK_Phone_Student check (len(Student_Phone) = 11)
) on ThirdFG;

-- Intakes Trackes Table
create table Intakes_Trackes
( 
   Track_ID int,
   Intake_ID int,
   constraint PK_Track_Intake PRIMARY KEY (Track_ID, Intake_ID),
   constraint FK_PK_Track FOREIGN KEY (Track_ID) REFERENCES Tracks (Track_ID)  on update cascade,
   constraint FK_PK_Intake FOREIGN KEY (Intake_ID) REFERENCES Intakes (Intake_ID)  on update cascade
) on FirstFG;

-- Instructor Table
create table Instructors 
(
   Instructor_ID int identity(1,1),
   Instructor_Name nvarchar(50) not null,
   Instructor_Email nvarchar(50) not null unique,
   Instructor_Password nvarchar(255) not null,
   Instructor_Phone nvarchar(11) not null,
   Traning_Manager_ID int null,
   constraint PK_Instructor_ID primary key (Instructor_ID),
   constraint FK_Instructor FOREIGN KEY (Traning_Manager_ID) REFERENCES Instructors (Instructor_ID),
   constraint CK_Phone_Instructor check (len(Instructor_Phone) = 11)
) on SecondFG;

-- Course Table
create table Courses
( 
   Course_ID int identity(1,1),
   Course_Name nvarchar (50) not null,
   Descriptions nvarchar (500) not null,
   Max_Degree int not null,
   Min_Degree int not null,
   Track_ID int null,
   constraint PK_Course_ID primary key (Course_ID),
   constraint FK_Track_Course foreign key (Track_ID) references Tracks(Track_ID) on update cascade,
   constraint CK_Degree check (Max_Degree > 0 and Min_Degree > 0 and Min_Degree < Max_Degree)
) on SecondFG;

-- Course Instructor Table
create table Instructor_Course
(
   Instructor_ID int,
   Course_ID int,
   constraint PK_Instructor_Course primary key (Instructor_ID,Course_ID),
   constraint FK_PK_Instructor FOREIGN KEY (Instructor_ID) REFERENCES Instructors (Instructor_ID) on update cascade,
   constraint FK_PK_Course FOREIGN KEY (Course_ID) REFERENCES Courses (Course_ID) on update cascade
) on SecondFG;
 
-- Question Table
create table Questions
(
   Question_ID int identity(1,1),
   Question_Type varchar(30) not null,
   Course_ID int null,
   constraint PK_Question_ID primary key (Question_ID),
   constraint FK_Course_Question foreign key (Course_ID) references Courses(Course_ID) on update cascade,
   constraint CK_Question_Type check (Question_Type in ('TF', 'Choose', 'Text Question'))
) on ForthFG;

-- Exams Table
create table Exams
(
    Exam_ID int identity(1,1),
	Exam_Date date not null,
	Start_Time time not null,
	End_Time time not null,
	Allowance_Option nvarchar(255),
	Exam_Type nvarchar(50) not null,
	Number_Question int not null,
	constraint PK_Exam_ID primary key (Exam_ID),
	constraint CK_Number_Question check (Number_Question > 0),
	constraint CK_Exam_Type check (Exam_Type in ('Exam', 'Corrective'))
) on ThirdFG;

-- Student Exam Answer Table
create table Student_Exam_Answer
(  
    Exam_ID int,
	Student_ID int,
	Question_ID int,
    Degree int default(0),
	Student_Answer nvarchar(500) not null,
	constraint PK_Student_Exam_Answer primary key (Exam_ID, Student_ID, Question_ID),
	constraint FK_PK_Exam_ID foreign key (Exam_ID) references Exams(Exam_ID) on update cascade,
	constraint FK_PK_Student_ID foreign key (Student_ID) references Students(Student_ID) on update cascade,
    constraint FK_Question_Student_Exam_Answer foreign key (Question_ID) references Questions(Question_ID) on update cascade,
) on ThirdFG;

-- Exam Question Table
create table Exam_Question 
(
   Question_ID int,
   Exam_ID int,
   Question_Degree int not null default(1),
   constraint PK_Exam_Question primary key (Question_ID, Exam_ID),
   constraint FK_PK_Question foreign key (Question_ID) references Questions(Question_ID) on update cascade,
   constraint FK_PK_Exam foreign key (Exam_ID) references Exams(Exam_ID) on update cascade,
   constraint CK_Question_Degree check (Question_Degree > 0),
   constraint DF_Exam_Question_Question_Degree DEFAULT 1 FOR Question_Degree
) on ThirdFG;

-- Exam Student Table
create table Exam_Student 
(
   Student_ID int,
   Exam_ID int,
   constraint PK_Exam_Student primary key (Student_ID, Exam_ID),
   constraint FK_PK_Student_Select foreign key (Student_ID) references Students(Student_ID),
   constraint FK_PK_Exam_Select foreign key (Exam_ID) references Exams(Exam_ID),
) on ThirdFG;

-- TF Question 
create table TF
(
   Question_Type_ID int identity(1,1),
   Question_Name nvarchar(500) not null,
   Correct_Answer nvarchar(1) not null,
   Question_ID int,
   constraint PK_Question_Type_TF primary key (Question_Type_ID),
   constraint FK_TF_Question foreign key (Question_ID) references Questions(Question_ID) on update cascade,
   constraint CK_Correct_Answer check (Correct_Answer in ('T', 'F'))
) on ForthFG;

-- Text Question Table
CREATE TABLE Text_Question
(
   Question_Type_ID INT Identity (1,1),
   Question_Name nvarchar(500) not null,
   Correct_Answer nvarchar(500) not null,
   Question_ID int,
   constraint PK_Question_Type_Text primary key (Question_Type_ID),
   constraint FK_Text_Question FOREIGN KEY (Question_ID) REFERENCES Questions(Question_ID) on update cascade
) on ForthFG;

-- Choose Table
CREATE TABLE Multiple_Choose
(
   Question_Type_ID INT Identity (1,1),
   Question_Name nvarchar(500) not null,
   Correct_Answer char(1) not null,
   A nvarchar(250) not null,
   B nvarchar(250) not null,
   C nvarchar(250) not null,
   D nvarchar(250) not null,
   Question_ID INT,
   constraint PK_Question_Type_Choose primary key (Question_Type_ID),
   constraint FK_Choose_Question FOREIGN KEY (Question_ID) REFERENCES Questions(Question_ID) on update cascade,
   constraint CK_Multiple_Choose check (Correct_Answer IN ('A', 'B', 'C', 'D'))
 
) on ForthFG;
