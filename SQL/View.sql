
------------------------------------- Fares ---------------------------------------
----View to show all students data and branchName And InatkeName and TrackName
go
create or alter view V_StudentsData as
select
    S.Student_Name as 'student name',
    S.Faculty_Name as 'faculty name',
    S.Student_Email as 'student Email',
    S.Student_Phone 'student phone',
    B.Branch_Name as 'branch name',
    I.Intake_Name as 'intake round',
    T.Track_Name as 'Track Name'
from
    Students S
  left join
    Branches B on S.Branch_ID = B.Branch_ID
 left join
    Intakes I ON S.Intake_ID = I.Intake_ID
  left join  
    Tracks T ON S.Track_ID = T.Track_ID;
go
select * from  V_StudentsData

--- view to show all branches name
go
create or alter view V_BranchesDataWithCounStudents as
select 
    B.Branch_Name as 'branch name',
    B.City as 'Location',
 COUNT(S.Student_ID) as 'Number Of Students'
FROM 
    Branches B 
 left join 
    Students S on B.Branch_ID = S.Branch_ID
 group by 
    B.Branch_ID, B.Branch_Name, B.City;
go
select * from V_BranchesDataWithCounStudents

--- Create the view to show intake data, branch name
go
create or alter view V_IntakesWithBranchName as
select 
    I.Intake_Name as 'Intake name',
    I.Date_Start as 'start date',
    I.Date_End as 'end date',
    B.Branch_Name as 'branch name'
from 
    Intakes I
left join
    Branches B on I.Branch_ID = B.Branch_ID;
go
select * from V_IntakesWithBranchName

--- Student Exam Attendance
go
create or alter view V_Students_Exam_Attendance AS
SELECT
    distinct S.Student_Name as 'Studen Name',
    E.Exam_ID as 'Exam Number',
    E.Exam_Date as 'Exam Date',
    case
        when SEA.Student_ID IS NOT NULL then 'Attend'
        else 'Absence'
    end as 'Attendance Status'
from
    Students S
 left join
    Student_Exam_Answer SEA ON S.Student_ID = SEA.Student_ID
 left join
    Exams E ON SEA.Exam_ID = E.Exam_ID
go
select * from V_Students_Exam_Attendance

------------------------------------- Abdelrahman ---------------------------------------
--- Show all Students degree in exam
go
CREATE OR ALTER PROCEDURE SP_V_Student_Degree_In_Exam
    @Exam_ID INT
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    CREATE OR ALTER VIEW V_Students_Exam AS
    SELECT
        SUM(q.Question_Degree) AS [Exam Degree],
        SUM(a.Degree) AS [Student Degree], 
        CASE
            WHEN SUM(a.Degree) >= (SUM(CAST(q.Question_Degree AS FLOAT)) / 2) THEN ''Pass''
            ELSE ''Corrective''
        END AS [Mark Student],
        s.Student_Name AS Name,
        b.Branch_Name AS Branch, 
        i.Intake_Name AS Intake,
        e.Exam_Date AS [Exam Date], 
        e.Start_Time AS [Start Time],
        e.End_Time AS [End Time]
    FROM Student_Exam_Answer a
    JOIN Students s ON s.Student_ID = a.Student_ID AND a.Exam_ID = ' + CAST(@Exam_ID AS NVARCHAR) + '
    JOIN Exam_Question q ON q.Exam_ID = a.Exam_ID AND q.Question_ID = a.Question_ID
    JOIN Branches b ON s.Branch_ID = b.Branch_ID
    JOIN Intakes i ON s.Intake_ID = i.Intake_ID
    JOIN Exams e ON e.Exam_ID = ' + CAST(@Exam_ID AS NVARCHAR) + '
    GROUP BY a.Student_ID, s.Student_Name, b.Branch_Name, i.Intake_Name, e.Exam_Date, e.Start_Time, e.End_Time;
    ';
    EXEC sp_executesql @SQL;
	SELECT * FROM V_Students_Exam;
END;

exec SP_V_Student_Degree_In_Exam 8
select * from Student_Exam_Answer
select * from Students
-----------------------------------
--- Show Exams
go
CREATE OR ALTER VIEW V_Exams AS
select Exam_Date 'Date', Start_Time 'Start Time', End_Time 'End Time',
Allowance_Option 'Options', Exam_Type 'Type', Number_Question 'Count Of Questions'
from Exams
go

select * from V_Exams
-------------------------------------
--- Show Student Answer
go
CREATE OR ALTER VIEW V_Student_Exam_Answer AS
select s.Student_Name 'Student Name', a.Exam_ID,
a.Degree 'Student Degree', eq.Question_Degree 'Question Degree',a.Student_Answer 'Student Answer',
CASE
      when q.Question_Type = 'TF' then t.Question_Name
	  when q.Question_Type = 'Choose' then c.Question_Name
      ELSE tq.Question_Name
END AS 'Question',
CASE
      when q.Question_Type = 'TF' then t.Correct_Answer
	  when q.Question_Type = 'Choose' then c.Correct_Answer
      ELSE tq.Correct_Answer
END AS 'Correct Answer'
from Student_Exam_Answer a
join Students s
on a.Student_ID = s.Student_ID
join Questions q
on q.Question_ID = a.Question_ID
join Exam_Question eq
on eq.Question_ID = q.Question_ID and eq.Exam_ID = a.Exam_ID
join TF t
on t.Question_ID = q.Question_ID and q.Question_Type = 'TF'
left join Multiple_Choose c
on c.Question_ID = q.Question_ID and q.Question_Type = 'Choose'
left join Text_Question tq
on tq.Question_ID = q.Question_ID and q.Question_Type = 'Text Question'
go

select * from V_Student_Exam_Answer

------------------------------------- Karem ---------------------------------------
-- create a view that selects data from the Questions table with details
go
create or alter view V_Questions_Details as
select
   -- Q.Question_ID as Question_Number,
    case
        when Q.Question_Type = 'TF' then TF.Question_Name
        when Q.Question_Type = 'Choose' then MC.Question_Name
        when Q.Question_Type = 'Text Question' then TQ.Question_Name
        else null
    end as Question_Name,
    Q.Question_Type as The_Type,
   -- Q.Course_ID as ID_Course,
    C.Course_Name as Name_Course,
    C.Descriptions as Course_Description,
    case
        when Q.Question_Type = 'TF' then TF.Correct_Answer
        when Q.Question_Type = 'Choose' then MC.Correct_Answer
        when Q.Question_Type = 'Text Question' then TQ.Correct_Answer
        else ''
    end as Correct_Answer,
    case
        when Q.Question_Type = 'Choose' then MC.A
        else ''
    end as Option_A,
    case
        when Q.Question_Type = 'Choose' then MC.B
        else ''
    end as Option_B,
    case
        when Q.Question_Type = 'Choose' then MC.C
        else ''
    end as Option_C,
    case
        when Q.Question_Type = 'Choose' then MC.D
        else ''
    end as Option_D
from
    Questions Q
    left join Courses C on Q.Course_ID = C.Course_ID
    left join TF on Q.Question_ID = TF.Question_ID and Q.Question_Type = 'TF'
    left join Multiple_Choose MC on Q.Question_ID = MC.Question_ID and Q.Question_Type = 'Choose'
    left join Text_Question TQ on Q.Question_ID = TQ.Question_ID and Q.Question_Type = 'Text Question';
go

select * from V_Questions_Details

--- exam_question table with details
go
create or alter view V_Exam_Question_Details as
select
    E.Exam_ID,
    E.Exam_Date as The_Date,
    E.Start_Time as Begin_Time,
    E.End_Time as Finish_Time,
    E.Allowance_Option as Takes_Option_Allow_It,
    E.Exam_Type as Type_Of_Exam,
    -- EQ.Question_ID as Question_Number,
    Q.Question_Type as The_Type_question,
    --Q.Course_ID as ID_Course,
    C.Course_Name as Name_Course,
    EQ.Question_Degree as Degree_Question
from
    Exam_Question EQ
    inner join Exams E on EQ.Exam_ID = E.Exam_ID
    inner join Questions Q on EQ.Question_ID = Q.Question_ID
    left join Courses C on Q.Course_ID = C.Course_ID;
go
-- Step 2: Create the stored procedure
go
create or alter procedure SP_V_Exam_Question_Details
    @Exam_ID INT
AS
BEGIN
    SELECT *
    FROM V_Exam_Question_Details
    WHERE Exam_ID = @Exam_ID;
END;


go
EXEC SP_V_Exam_Question_Details @Exam_ID = 8;

--show tf table details
go
create or alter view V_TF_Questions_Details as
select
   -- tf.question_type_id as id_question_type,
    tf.question_name as name_question,
    
    --tf.question_id as question_number,
    --q.question_type as the_type,
 tf.correct_answer as valid_answer
from
    tf
    inner join questions q on tf.question_id = q.question_id;
go

select* from V_TF_Questions_Details

--- Exam Question With Details
go
create or alter view V_Exam_Questions_With_All_Details as
select
    E.Exam_ID,
    E.Exam_Date as The_Date,
    E.Start_Time as Begin_Time,
    E.End_Time as Finish_Time,
    E.Allowance_Option as Takes_Option_Allow_It,
    E.Exam_Type as Type_Of_Exam,
   -- EQ.Question_ID as Question_Number,
    Q.Question_Type as The_Type,
    --Q.Course_ID as ID_Course,
    C.Course_Name as Name_Course,
    case
        when Q.Question_Type = 'TF' then TF.Question_Name
        when Q.Question_Type = 'Choose' then MC.Question_Name
        when Q.Question_Type = 'Text Question' then TQ.Question_Name
        else ''
    end as Question_Name,
    case
        when Q.Question_Type = 'TF' then TF.Correct_Answer
        when Q.Question_Type = 'Choose' then MC.Correct_Answer
        when Q.Question_Type = 'Text Question' then TQ.Correct_Answer
        else ''
    end AS Correct_Answer,
    case
        when Q.Question_Type = 'Choose' then MC.A
        else ''
    end as Option_A,
    case
        when Q.Question_Type = 'Choose' then MC.B
        else ''
    end as Option_B,
    case
        when Q.Question_Type = 'Choose' then MC.C
        else ''
    end as Option_C,
    case
        when Q.Question_Type = 'Choose' then MC.D
        else ''
    end as Option_D,
    EQ.Question_Degree
from
    Exams E
    inner join Exam_Question EQ on E.Exam_ID = EQ.Exam_ID
    inner join Questions Q on EQ.Question_ID = Q.Question_ID
    left join Courses C on Q.Course_ID = C.Course_ID
    left join TF on Q.Question_ID = TF.Question_ID and Q.Question_Type = 'TF'
    left join Multiple_Choose MC on Q.Question_ID = MC.Question_ID and Q.Question_Type = 'Choose'
    left join Text_Question TQ on Q.Question_ID = TQ.Question_ID and Q.Question_Type = 'Text Question';
go

select * from V_Exam_Questions_With_All_Details

go
create or alter procedure SP_V_Exam_Questions_With_All_Details
@Exam_ID int
as
begin
 select * from V_Exam_Questions_With_All_Details
 where Exam_ID = @Exam_ID;
end

exec SP_V_Exam_Questions_With_All_Details @Exam_ID = 1;

------------------------------------- Eman ---------------------------------------
-- get training manger and count of employee are being managed by him 
go
create or alter view V_Show_Training_Manager_Instructor_Count
as
select
        TM.Instructor_Name as Training_Manager_Name,
		count(I.Instructor_ID) as Instructor_Count
from Instructors TM inner join Instructors I 
     on TM.Instructor_ID = I.Traning_Manager_ID
where TM.Instructor_ID IS NOT NULL  and I.Traning_Manager_ID is not null
group by TM.Instructor_ID, TM.Instructor_Name;
go
select * from V_Show_Training_Manager_Instructor_Count

--get all instructors who do not have manager 
go
create or alter view V_InstructorWithoutManager
as
select Instructor_Name 'Name',Instructor_Email 'Email',Instructor_Phone 'Phone Number'
from Instructors
where Traning_Manager_ID is null
go

select * from V_InstructorWithoutManager

--- instructor
go
create or alter view V_instructors
as
select
       i.Instructor_Name 'Name',
	   i.Instructor_Email 'Email',
	   m.Instructor_Name 'Manager' 
from Instructors i , Instructors m
where i.Traning_Manager_ID = m.Instructor_ID
go

select * from V_instructors

--course
go
create or alter view V_courses
as
select
       Course_Name 'Titel', 
	   Descriptions 'Course Description',
	   Max_Degree 'High Degree' ,
	   Min_Degree 'Low Degree' ,
	   Track_ID 'Track Number'
from Courses
go

select * from V_courses

--- instructor_course
go
create or alter view V_instructorForEachCourse
as
select
       c.Course_Name as NameOfCourse,
	   I.Instructor_Name as NameOfInstructor
from Courses C , Instructor_Course IC , Instructors I
where c.Course_ID=IC.Course_ID and IC.Instructor_ID=I.Instructor_ID
go
select * from V_instructorForEachCourse

------------------------------------- Omar ---------------------------------------
---get all courses in track and instructor
go
create or alter view V_Courses_In_Track_With_Instructors as
select
    C.Course_Name,
    T.Track_Name,
    I.Instructor_Name
from
    Courses C
JOIN
    Tracks T on C.Track_ID = T.Track_ID
JOIN
    Instructor_Course IC on  C.Course_ID = IC.Course_ID
JOIN
    Instructors I on IC.Instructor_ID = I.Instructor_ID;
go

select * from V_Courses_In_Track_With_Instructors;

---get all students data who are being teach by instructors
go
create or alter PROCEDURE SP_Get_Students_By_Instructor_ID
    @InstructorID INT
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    CREATE OR ALTER VIEW V_Students_With_Instructors AS
    SELECT
        S.Student_Name [Name],
        S.Faculty_Name [Faculty],
        S.Student_Email [Email],
        S.Student_Phone [Phone],
        T.Track_Name [Track],
        C.Course_Name [Course],
        I.Instructor_Name [Instructor]
    FROM 
        Students S
    JOIN 
        Tracks T ON S.Track_ID = T.Track_ID
    JOIN 
        Courses C ON T.Track_ID = C.Track_ID
    JOIN 
        Instructor_Course IC ON C.Course_ID = IC.Course_ID
    JOIN 
        Instructors I ON IC.Instructor_ID = I.Instructor_ID
    WHERE 
        I.Instructor_ID = ' + CAST(@InstructorID AS NVARCHAR(10)) + ';
    ';
    EXEC sp_executesql @SQL;
    SELECT *FROM  V_Students_With_Instructors
    END;
go
EXEC SP_Get_Students_By_Instructor_ID @InstructorID = 18; -- 7,18,19,2

go
create view V_Choose_Questions_Details as
select
   -- tf.question_type_id as id_question_type,
    mc.question_name as name_question,
    
    --tf.question_id as question_number,
    --q.question_type as the_type,
 mc.correct_answer as valid_answer
from
    Multiple_Choose mc
    inner join Questions q on mc.question_id = q.question_id;
go

select* from V_Choose_Questions_Details

--show text question table details
go
create view V_Text_Questions_Details as
select
   -- tf.question_type_id as id_question_type,
    tq.question_name as name_question,
    
    --tf.question_id as question_number,
    --q.question_type as the_type,
 tq.correct_answer as valid_answer
from
    Text_Question tq
    inner join Questions q on tq.question_id = q.question_id;
go

select* from V_Text_Questions_Details
------------------------------------- Abdelhafez ---------------------------------------

----show data Student and Branch and Track and Intake
go
create or alter view V_ShowStudentBanchIntakeTrackIntake as
select
    S.Student_Name as 'Student Name',
    B.Branch_Name as 'Student Branch',
    I.Intake_Name as 'Student Intake',
    T.Track_Name as 'Student Track',
    D.Department_Name as 'Student Department'
from
    Students S
left join
    Branches B on S.Branch_ID = B.Branch_ID
left join
    Intakes I on S.Intake_ID = I.Intake_ID
left join
    Tracks T on S.Track_ID = T.Track_ID
left join
    Departments D on T.Department_ID = D.Department_ID;
go

select * from V_ShowStudentBanchIntakeTrackIntake

--- view table Track and Departements
go
create or alter view V_Tracks_Department AS
SELECT 

    t.Track_Name as 'Track Name',
    d.Department_Name as 'Departement Name'
FROM 
    Tracks t
LEFT JOIN 
    Departments d ON t.Department_ID = d.Department_ID;
go

select * from V_Tracks_Department

---  view table departments
go
create or alter view V_Departments AS
SELECT 
    Department_Name as 'Departement Name'
FROM 
    Departments;
go
select * from V_Departments

--- Instructor in Branch
go
CREATE or alter VIEW V_InstructorsInBranch AS
SELECT 
    I.Instructor_Name 'Name',
    I.Instructor_Email 'Email',
    I.Instructor_Phone 'Phone',
    B.Branch_Name 'Branch',
    B.City 'City'
FROM 
     Instructors I
     JOIN Instructor_Course IC ON I.Instructor_ID = IC.Instructor_ID
     JOIN Courses C ON IC.Course_ID = C.Course_ID
     JOIN Tracks T ON C.Track_ID = T.Track_ID
     JOIN Intakes_Trackes IT ON T.Track_ID = IT.Track_ID
     JOIN Intakes n ON IT.Intake_ID = n.Intake_ID
     JOIN Branches B ON n.Branch_ID = B.Branch_ID;
go

 SELECT * FROM V_InstructorsInBranch;
 select * from Intakes_Trackes
 select * from Instructor_Course