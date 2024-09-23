
------------------------------------- (1) -----------------------------------------
--- Create Exam
create or alter proc SP_Add_Exam
(
  @Date nvarchar(50),
  @StartTime nvarchar(50),
  @EndTime nvarchar(50),
  @Option nvarchar(255),
  @Type nvarchar(50),
  @Number int
)
as 
begin
  insert into Exams(Exam_Date, Start_Time, End_Time, Allowance_Option, Exam_Type, Number_Question)
  values(@Date, @StartTime, @EndTime, @Option, @Type, @Number)
  select Exam_Date 'Date', Start_Time 'Start',
  End_Time 'End', Allowance_Option 'Option', Exam_Type 'Type', Number_Question 'Questions'
  from Exams
  where @Date = Exam_Date and Start_Time = @StartTime
end
exec SP_Add_Exam '7/18/2024', '9:00 AM', '11:00 AM', 'open book', 'Exam', 3
exec SP_Add_Exam '7/10/2024', '9:00 AM', '11:00 AM', 'No options', 'Exam', 4

------------------------------------- (2) -----------------------------------------
--- Update Training Manager
go
create or alter proc SP_Update_Training_Manager
(
   @Training_Manager_ID int,
   @Instructor_ID int
)
as
begin
   if not exists(select * from Instructors where Instructor_ID = @Training_Manager_ID)
   begin
      Print('This training manager not found');
   end
   else if not exists(select * from Instructors where Instructor_ID = @Instructor_ID)
   begin
      Print('This instructor not found');
   end
   else
   begin
      update Instructors
      set Traning_Manager_ID = @Training_Manager_ID
      where Instructor_ID = @Instructor_ID
	  
	  Print('Training manager is updated to instructor successfully');
   end
end
select * from Instructors
exec SP_Update_Training_Manager 4, 17
------------------------------------- (3) -----------------------------------------
--- Student Answer
go
CREATE or alter PROCEDURE SP_Store_StudentAnswerAndDegree
    @StudentID INT,
    @ExamID INT,
    @QuestionID INT,
    @Answer NVARCHAR(500),
    @ManualDegree INT = NULL  -- New parameter for manual degree input
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if the student is registered for the exam
        IF NOT EXISTS (SELECT 1 FROM Exam_Student WHERE Student_ID = @StudentID AND Exam_ID = @ExamID)
        BEGIN
            RAISERROR('Student is not registered for this exam.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check if the question is part of the exam
        IF NOT EXISTS (SELECT 1 FROM Exam_Question WHERE Question_ID = @QuestionID AND Exam_ID = @ExamID)
        BEGIN
            RAISERROR('Question is not part of this exam.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Get the question type and correct answer
        DECLARE @QuestionType VARCHAR(30);
        DECLARE @CorrectAnswer NVARCHAR(500);
        DECLARE @Degree INT = 0;
        DECLARE @IsValidAnswer BIT = 0;
		declare @Date date; 

        SELECT @QuestionType = Question_Type
        FROM Questions
        WHERE Question_ID = @QuestionID;

		select @Date = Exam_Date
		from Exams
		where Exam_ID = @ExamID

        -- True/False Question Handling
        IF @QuestionType = 'TF'
        BEGIN
            -- Validate the answer
            IF @Answer NOT IN ('T', 'F')
            BEGIN
                PRINT 'Warning: True/False answers must be "T" or "F" only.';
                ROLLBACK TRANSACTION;
                RETURN;
            END
            
            SELECT @CorrectAnswer = Correct_Answer FROM TF WHERE Question_ID = @QuestionID;
            IF @Answer = @CorrectAnswer
                SET @Degree = (SELECT Question_Degree FROM Exam_Question WHERE Question_ID = @QuestionID AND Exam_ID = @ExamID);
        END

        -- Multiple Choice Question Handling
        ELSE IF @QuestionType = 'Choose'
        BEGIN
            -- Validate the answer
            IF @Answer NOT IN ('A', 'B', 'C', 'D')
            BEGIN
                PRINT 'Warning: Multiple Choice answers must be "A", "B", "C", or "D" only.';
                ROLLBACK TRANSACTION;
                RETURN;
            END
            
            SELECT @CorrectAnswer = Correct_Answer FROM Multiple_Choose WHERE Question_ID = @QuestionID;
            IF @Answer = @CorrectAnswer
                SET @Degree = (SELECT Question_Degree FROM Exam_Question WHERE Question_ID = @QuestionID AND Exam_ID = @ExamID);
        END

        -- Text Question Handling
        ELSE IF @QuestionType = 'Text Question'
        BEGIN
		    -- Override degree if manual degree is provided
			IF @ManualDegree IS NOT NULL
			BEGIN
				SET @Degree = @ManualDegree;
			END
            SELECT @CorrectAnswer = Correct_Answer
            FROM Text_Question 
            WHERE Question_ID = @QuestionID;

            -- Check if the answer matches the pattern in the correct answer
            IF PATINDEX('%'+lower(@Answer)+'%',lower(@CorrectAnswer)) > 0
            BEGIN
                SET @IsValidAnswer = 1;
                PRINT 'Valid Answer';
            END
            ELSE
            BEGIN
                PRINT 'Not Valid Answer';
            END
			-- Set degree to 0 for text questions
            SET @Degree = 0;
        END

        -- Insert or update the student's answer
        IF EXISTS (SELECT 1 FROM Student_Exam_Answer WHERE Exam_ID = @ExamID AND Student_ID = @StudentID AND Question_ID = @QuestionID)
        BEGIN
		    if(@Date > GETDATE())
			begin
			    UPDATE Student_Exam_Answer
				SET Student_Answer = @Answer, Degree = @Degree
				WHERE Exam_ID = @ExamID AND Student_ID = @StudentID AND Question_ID = @QuestionID;
			end
			else
			begin
			   print('Time out of exam');
			end
        END
        ELSE
        BEGIN
			if(@Date > GETDATE())
			begin
			    INSERT INTO Student_Exam_Answer (Exam_ID, Student_ID, Question_ID, Student_Answer, Degree)
                VALUES (@ExamID, @StudentID, @QuestionID, @Answer, @Degree);
			end
			else
			begin
			   print('Time out of exam');
			end
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

EXEC SP_Store_StudentAnswerAndDegree @StudentID = 1, @ExamID = 1, @QuestionID = 1, @Answer = 'T', @ManualDegree=9;
select * from Exam_Question
select * from Student_Exam_Answer
------------------------------------- (4) -----------------------------------------
--- training manager can do add operation in instructor 
--- ADD
go
create OR alter proc SP_Add_Instructor (
    @Instructor_Name nvarchar(50),
    @Instructor_Email nvarchar(50),
    @Instructor_Password nvarchar(40),
    @Instructor_Phone nvarchar(11)
)
as
begin
 if exists (select * 
    from Instructors
    where Instructor_Email=@Instructor_Email)
 begin
  print 'Instructor is exists' 
  return;
 end
    -- Check if the email matches the pattern
    if patindex('%[^@ ]%@[^@ ]%.%', @Instructor_Email) = 0
    begin
        -- If email is invalid
        print('invalid Email')
        return;
    end
    -- If email is valid
    begin try
        insert into Instructors (Instructor_Name, Instructor_Email, Instructor_Password, Instructor_Phone)
        values (@Instructor_Name, @Instructor_Email, @Instructor_Password, @Instructor_Phone);
    end try
    begin catch
        print 'An error occurred: ' + ERROR_MESSAGE();
    end catch
end;

exec SP_Add_Instructor 
@Instructor_Name = 'Ahmed Ayman',
@Instructor_Email = 'younis@email.com',
@Instructor_Password = '012549522',
@Instructor_Phone = '01547896512'

select * from Instructors

--- Update
go
create OR alter proc SP_Edit_Instructor
(
    @Instructor_ID int,
    @Column_Name nvarchar(25),
    @New_Value nvarchar(50)
)
as
begin
    declare @SQL nvarchar(MAX);
 DECLARE @ExistingValue NVARCHAR(50);
  IF @Column_Name = 'Instructor_Email'
    begin
        if patindex('%[^@ ]%@[^@ ]%.%', @New_Value) = 0
        begin
            print 'Invalid Email'
            return;
        end
    end
 SET @SQL = N'SELECT @ExistingValue = ' + QUOTENAME(@Column_Name) + N' FROM Instructors WHERE Instructor_ID = @Instructor_ID';
    
    EXEC sp_executesql @SQL, N'@Instructor_ID INT, @ExistingValue NVARCHAR(50) OUTPUT', @Instructor_ID, @ExistingValue OUTPUT;

    if @ExistingValue = @New_Value
    begin
        print 'The data already exists';
        return;
    END
    set @SQL = N'UPDATE Instructors SET ' + QUOTENAME(@Column_Name) + N' = @New_Value WHERE Instructor_ID = @Instructor_ID';
    exec sp_executesql @SQL, N'@Instructor_ID INT, @New_Value NVARCHAR(50)', @Instructor_ID, @New_Value;
 select Instructor_Name 'Name', Instructor_Email 'Email',
 Instructor_Phone 'Phone', Traning_Manager_ID 'Manager'
 from Instructors where Instructor_ID = @Instructor_ID
end;

exec SP_Edit_Instructor
@Instructor_ID = 9,
@column_Name = 'Instructor_Name',
@New_Value = 'fares Ahmed'

select * from Instructors

--- Delete
go
create OR alter proc SP_Delete_Instructor
(
    @Instructor_ID int
)
as
begin
if  not exists (select 1 from Instructors where Instructor_ID = @Instructor_ID)
    begin
        print 'Instructor is not exist';
        RETURN;
    end
    delete from Instructors 
    where Instructor_ID = @Instructor_ID ; 
 print('Deleted Successfully');
end;

EXEC SP_Delete_Instructor 
    @Instructor_ID = 20;

 select * from Instructors
------------------------------------- (5) -----------------------------------------
-------training manager can do CRUD operation in course (add,  edit, delete) 

--- training manager add new course
go
create procedure sp_Add_Course 
	@course_name nvarchar (50), 
	@description nvarchar (500),
	@max_degree int , 
	@min_degree int, 
	@trackId int
as
begin
	if exists (select * 
				from Courses
				where Course_Name=@course_name)
	begin
		print 'course is exists' 
	end
	else
	begin
		insert into Courses(Course_Name,Descriptions,Max_Degree,Min_Degree,Track_ID)
		values(@course_name,@description,@max_degree,@min_degree,@trackId)
		print 'course added successfully'
	end
end
exec sp_Add_Course @course_name='c sharp',@description='develop desktop applications',@max_degree=100,@min_degree=55,@trackId=1

--training manager update on table courses
go
create or alter procedure sp_Update_Course 
   @course_id int,
   @course_name nvarchar (50),
   @description nvarchar (500),
   @max_degree int,
   @min_degree int,
   @track_id int
as
begin
	update dbo.Courses
	set Course_Name = @course_name,
		Descriptions = @description,
		Max_Degree = @max_degree,
		Min_Degree = @min_degree,
		Track_id = @track_id
	where Course_ID = @course_id
	print 'course updated successfully'
end

execute sp_Update_Course @course_id = 51 ,
						 @course_name = 'c++',
						 @description = 'itro to programming language',
						 @max_degree = 120,
						 @min_degree = 70,
						 @track_id = 4

--training manager deleted course
go
create or alter procedure SP_DeleteCourse @CourseID int
as
begin
    -- Start a transaction
    begin transaction
    begin try
        -- Check if the course is referenced in the question table
        if exists (select 1 from Questions where Course_ID = @CourseID)
        begin
		  -- Delete related records in other tables first
			delete from Exam_Question where Question_ID in (select Question_ID 

												 from Questions 

												 where Course_ID = @CourseID);
			delete from Student_Exam_Answer where Question_ID in (select Question_ID 

												 from Questions 

												 where Course_ID = @CourseID);
           delete from TF where Question_ID in (select Question_ID 

												 from Questions 

												 where Course_ID = @CourseID);
            delete from Multiple_Choose where Question_ID in (select Question_ID 

			                                                  from Questions 

															  where Course_ID = @CourseID);
            delete from Text_Question where Question_ID in (select Question_ID 

															from Questions 

															where Course_ID = @CourseID);
            -- Delete records from the question table
            delete from Questions where Course_ID = @CourseID;
        end
        -- Delete the course from the courses table
        delete from Courses where Course_ID = @CourseID;
    commit transaction
    end try
    begin catch
        rollback transaction;
        throw
    end catch
end
 
exec SP_DeleteCourse @CourseID=52
------------------------------------- (6) -----------------------------------------
------: training manager select instructor for course 
go
create or alter procedure sp_Add_InstructorForCourse 
   @course_id int, 
   @instructor_id int
as
begin
    if exists (
        select Instructor_ID, Course_ID
        from Instructors, Courses
        where Instructor_ID = @instructor_id and Course_ID = @course_id
    )
	begin
	   if exists (
        select Instructor_ID
        from dbo.Instructor_Course
        where Course_ID = @course_id
       )
		begin
			update dbo.Instructor_Course
			set Instructor_ID = @instructor_id
			where Course_ID = @course_id;
			print 'the instructor has been updated'
		end
		else
		begin
			insert into dbo.Instructor_Course (Instructor_ID, Course_ID)
			values(@instructor_id, @course_id)
			print 'the instructor has been added successfully'
		end
	end
	else
	begin
	   print 'Instructor or Course not found'
	end 
end
execute sp_Add_InstructorForCourse  50000, 700000
------------------------------------- (7) -----------------------------------------
--- CRUD Question
--- ADD
go
CREATE OR ALTER PROCEDURE AddQuestion
    @QuestionType NVARCHAR(30),
    @CourseID INT,
	@InstructorID int,
    @QuestionName NVARCHAR(500),
    @CorrectAnswer NVARCHAR(500),
    @A NVARCHAR(250) = NULL,
    @B NVARCHAR(250) = NULL,
    @C NVARCHAR(250) = NULL,
    @D NVARCHAR(250) = NULL
AS
BEGIN
    DECLARE @QuestionID INT;
	-- Check if InstructorID belongs to CourseID
    IF NOT EXISTS (SELECT 1 
                   FROM Instructor_Course 
                   WHERE Instructor_ID = @InstructorID AND Course_ID = @CourseID)
    BEGIN
        PRINT 'Error: Instructor does not belong to the specified Course.';
        RETURN;
    END
    -- Validate correct answers before inserting
    IF @QuestionType = 'TF' AND @CorrectAnswer NOT IN ('T', 'F')
    BEGIN
        PRINT 'Error: Correct answer for True/False questions must be T or F.';
        RETURN;
    END
    ELSE IF @QuestionType = 'Choose' AND @CorrectAnswer NOT IN ('A', 'B', 'C', 'D')
    BEGIN
        PRINT 'Error: Correct answer for Multiple Choice questions must be A, B, C, or D.';
        RETURN;
    END

    -- Insert into Questions table and get the QuestionID
    INSERT INTO Questions (Question_Type, Course_ID)
    VALUES (@QuestionType, @CourseID);
    SET @QuestionID = SCOPE_IDENTITY();

    -- Insert into the respective question type table
    IF @QuestionType = 'TF'
    BEGIN
        INSERT INTO TF (Question_Name, Correct_Answer, Question_ID)
        VALUES (@QuestionName, @CorrectAnswer, @QuestionID);
    END
    ELSE IF @QuestionType = 'Text Question'
    BEGIN
        INSERT INTO Text_Question (Question_Name, Correct_Answer, Question_ID)
        VALUES (@QuestionName, @CorrectAnswer, @QuestionID);
    END
    ELSE IF @QuestionType = 'Choose'
    BEGIN
        INSERT INTO Multiple_Choose (Question_Name, Correct_Answer, A, B, C, D, Question_ID)
        VALUES (@QuestionName, @CorrectAnswer, @A, @B, @C, @D, @QuestionID);
    END

    PRINT 'Question added successfully.';
END;

exec AddQuestion @QuestionType = 'TF', 
                 @CourseID = 8,
				 @InstructorID = 1,
                 @QuestionName = 'is c# ?', 
                 @CorrectAnswer = 'F'

--- Edit
go
CREATE OR ALTER PROCEDURE EditQuestion
    @InstructorID INT,
    @CourseID INT,
    @QuestionID INT,
    @QuestionType NVARCHAR(30),
    @QuestionName NVARCHAR(500),
    @CorrectAnswer NVARCHAR(500),
    @A NVARCHAR(250) = NULL,
    @B NVARCHAR(250) = NULL,
    @C NVARCHAR(250) = NULL,
    @D NVARCHAR(250) = NULL
AS
BEGIN
  -- Check if InstructorID belongs to CourseID
    IF NOT EXISTS (SELECT 1 
                   FROM Instructor_Course 
                   WHERE Instructor_ID = @InstructorID AND Course_ID = @CourseID)
    BEGIN
        PRINT 'Error: InstructorID does not belong to the specified CourseID.';
        RETURN;
    END
    -- Validate correct answers before updating
    IF @QuestionType = 'TF' AND @CorrectAnswer NOT IN ('T', 'F')
    BEGIN
        PRINT 'Error: Correct answer for True/False questions must be T or F.';
        RETURN;
    END
    ELSE IF @QuestionType = 'Choose' AND @CorrectAnswer NOT IN ('A', 'B', 'C', 'D')
    BEGIN
        PRINT 'Error: Correct answer for Multiple Choice questions must be A, B, C, or D.';
        RETURN;
    END

    -- Update the question in the respective question type table
    IF @QuestionType = 'TF'
    BEGIN
        UPDATE TF
        SET Question_Name = @QuestionName, Correct_Answer = @CorrectAnswer
        WHERE Question_ID = @QuestionID;

        -- Check if the question exists
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Error: Question not found.';
            RETURN;
        END
    END
    ELSE IF @QuestionType = 'Text Question'
    BEGIN
        UPDATE Text_Question
        SET Question_Name = @QuestionName, Correct_Answer = @CorrectAnswer
        WHERE Question_ID = @QuestionID;

        -- Check if the question exists
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Error: Question not found.';
            RETURN;
        END
    END
    ELSE IF @QuestionType = 'Choose'
    BEGIN
        UPDATE Multiple_Choose
        SET Question_Name = @QuestionName, Correct_Answer = @CorrectAnswer, A = @A, B = @B, C = @C, D = @D
        WHERE Question_ID = @QuestionID;

        -- Check if the question exists
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Error: Question not found.';
            RETURN;
        END
    END

    PRINT 'Question updated successfully.';
END;


exec EditQuestion
                  @InstructorID = 1,
                  @courseID = 8,
                  @QuestionID = 157, 
                  @QuestionType = 'TF', 
                  @QuestionName = 'is css programming language ?',
                  @CorrectAnswer='F'

      select * from Questions

--- Delete
go 
CREATE OR ALTER PROCEDURE DeleteQuestion
    @InstructorID INT,
    @CourseID INT,
    @QuestionID INT
AS
BEGIN
    -- Check if InstructorID belongs to CourseID
    IF NOT EXISTS (SELECT 1 
                   FROM Instructor_Course 
                   WHERE Instructor_ID = @InstructorID AND Course_ID = @CourseID)
    BEGIN
        PRINT 'Error: InstructorID does not belong to the specified CourseID.';
        RETURN;
    END

    -- Check if QuestionID belongs to CourseID
    IF NOT EXISTS (SELECT 1 
                   FROM Questions 
                   WHERE Question_ID = @QuestionID AND Course_ID = @CourseID)
    BEGIN
        PRINT 'Error: QuestionID does not belong to the specified CourseID.';
        RETURN;
    END

    -- Check if the question exists
    IF NOT EXISTS (SELECT 1 FROM Questions WHERE Question_ID = @QuestionID)
    BEGIN
        PRINT 'Question does not exist.';
        RETURN;
    END

    -- Delete related records in Exam_Question table
    DELETE FROM Exam_Question WHERE Question_ID = @QuestionID;

    -- Determine the question type
    DECLARE @QuestionType NVARCHAR(30);
    SELECT @QuestionType = Question_Type FROM Questions WHERE Question_ID = @QuestionID;

    -- Delete from the respective question type table
    IF @QuestionType = 'TF'
    BEGIN
        DELETE FROM TF WHERE Question_ID = @QuestionID;
    END
    ELSE IF @QuestionType = 'Text Question'
    BEGIN
        DELETE FROM Text_Question WHERE Question_ID = @QuestionID;
    END
    ELSE IF @QuestionType = 'Choose'
    BEGIN
        DELETE FROM Multiple_Choose WHERE Question_ID = @QuestionID;
    END

    -- Delete from Questions table
    DELETE FROM Questions WHERE Question_ID = @QuestionID;

    PRINT 'Question deleted successfully.';
END;


EXEC DeleteQuestion
@InstructorID = 1,
@CourseID = 8,
@QuestionID = 157;


select * from Questions
select * from Instructor_Course
------------------------------------- (8) -----------------------------------------
--- Add Branch
go
CREATE or alter PROCEDURE SP_Add_Branch 
   @BranchName NVARCHAR(55),
   @City NVARCHAR(50)
AS
BEGIN
    -- Check if the branch already exists
    IF EXISTS (SELECT * FROM Branches WHERE Branch_Name = @BranchName AND City = @City)
    BEGIN
        PRINT 'Branch already exists.'
        RETURN
    END
	else
	begin
	   -- Insert the new branch
       INSERT INTO Branches (Branch_Name, City)
       VALUES (@BranchName, @City)
       PRINT 'Branch added successfully.'
	end   
END

EXEC SP_Add_Branch 'Smart Village', 'Cairo';

--- Edit Branch
go
CREATE or alter PROCEDURE SP_Edit_Branch 
    @BranchID INT,
	@NewBranchName NVARCHAR(55),
	@NewCity NVARCHAR(50)
AS
BEGIN
    -- Check if the branch exists
    IF NOT EXISTS (SELECT * FROM Branches WHERE Branch_ID = @BranchID)
    BEGIN
        PRINT 'Branch does not exist.'
        RETURN
    END
	else
	begin
	   UPDATE Branches
       SET Branch_Name = @NewBranchName, City = @NewCity
       WHERE Branch_ID = @BranchID
       PRINT 'Branch updated successfully.'
	end
END
exec SP_Edit_Branch @BranchID=8 ,@NewBranchName='Smart Village', @NewCity= 'qena'

--- Add Intake
go
CREATE or alter PROCEDURE SP_Add_Intake @IntakeName NVARCHAR(50), @StartDate DATE, @EndDate DATE, @BranchID INT
AS
BEGIN
    -- Check if the intake already exists
    IF EXISTS (SELECT * FROM Intakes WHERE Intake_Name = @IntakeName AND Branch_ID = @BranchID)
    BEGIN
        PRINT 'Intake already exists in this branch.'
        RETURN
    END
	else
	begin
	   -- Insert the new intake
		INSERT INTO Intakes(Intake_Name, Date_Start, Date_End, Branch_ID)
		VALUES (@IntakeName, @StartDate, @EndDate, @BranchID)
		PRINT 'Intake added successfully.'
	end
END

EXEC SP_Add_Intake @IntakeName = 'New Capital Branch - intake 3', @StartDate = '2024-05-01', @EndDate = '2025-09-10', @BranchID = 12;
select * from Intakes
--- Edit Intake
go
create or alter proc EditIntake @IntakeID int, @NewIntakeName nvarchar(50), @NewStartDate DATE, @NewEndDate DATE, @NewBranchID INT
AS
BEGIN
    -- Check if the intake exists
    if NOT EXISTS (select 1 from Intakes where Intake_ID = @IntakeID)
    BEGIN
        PRINT 'Intake does not exist.'
        return
    END
	else
	begin
	   -- Update the intake details
		UPDATE Intakes
		set Intake_Name = @NewIntakeName, 
        Date_Start = @NewStartDate, 
        Date_End = @NewEndDate, 
        Branch_ID = @NewBranchID
		where Intake_ID = @IntakeID
		PRINT 'Intake updated successfully.'
	end
END

exec EditIntake @IntakeID = 12, @NewIntakeName = 'New Capital Branch - intake 3', @NewStartDate = '2024-05-01', @NewEndDate = '2024-09-10', @NewBranchID = 11;

--- Add Track
go
create or alter proc AddTrack @TrackName nvarchar(50), @DepartmentID int
as
BEGIN
    -- Check if the track already exists or not 
    if EXISTS (select * from Tracks where  Track_Name = @TrackName AND Department_ID = @DepartmentID)
    BEGIN
        PRINT 'Track already exists in this department.'
       return
    END
	else
	begin
	   -- Insert the new track
		insert into  Tracks(Track_Name, Department_ID)
		values (@TrackName, @DepartmentID)
		PRINT 'Track added successfully.'
	end  
END

exec AddTrack @TrackName = 'Computer Science', @DepartmentID = 1;
select * from Tracks

--- Edit
go
create or alter proc EditTrack @TrackID int, @NewTrackName nvarchar(50), @NewDepartmentID int
AS
BEGIN
    -- Check if the track exists
    IF NOT EXISTS (select * from Tracks where  Track_ID = @TrackID)
    BEGIN
        PRINT 'Track does not exist.'
        return
    END
	else
	begin
	    -- Update the track details
		UPDATE Tracks
		SET Track_Name = @NewTrackName, Department_ID = @NewDepartmentID
		where Track_ID = @TrackID
		PRINT 'Track updated successfully.'
	end  
END

exec EditTrack @TrackID = 36, @NewTrackName = 'RPA', @NewDepartmentID = 13;

--- Add Data to Track Intake
go
create or alter proc SP_Insert_Into_Track_Intake
    @TrackID int,
    @IntakeID int
as
begin
    if exists (
        select i.Intake_ID, t.Track_ID
        from Intakes i, Tracks t, Intakes_Trackes it
        where i.Intake_ID = @IntakeID and t.Track_ID = @TrackID and it.Intake_ID = i.Intake_ID and it.Track_ID = t.Track_ID
    )
	begin
	   print('Already Exist');
	end
	else 
	begin
	    insert into  Intakes_Trackes (track_id, intake_id)
		values (@TrackID, @IntakeID);
		print 'Added Successfully.';
	end
end;

EXEC SP_Insert_Into_Track_Intake  @TrackID = 1,  @IntakeID = 1;
select * from Intakes_Trackes
------------------------------------- (9) -----------------------------------------
--- Add Student
go
create or alter proc SP_Add_Student
(
	@studentname nvarchar(80),
	@facultyname nvarchar(40),
	@studentemail nvarchar(25),
	@studentpassward nvarchar(40),
	@studentphone nvarchar(11),
	@branchid int,
	@trackid int,
	@intakeid int
)
AS
BEGIN
IF EXISTS (SELECT * FROM Students WHERE Student_Email = @studentemail )
  BEGIN
        PRINT 'student already exists in this branch.'
        RETURN
  END
    -- Check if the email matches the pattern
    if patindex('%[^@ ]%@[^@ ]%.%', @studentemail) = 0
    begin
        -- If email is invalid
        print('invalid Email')
        return;
    end 
	else if(@branchid != @intakeid)
	begin
	   print ('Branch id must equal Intake id');
	end
	else
	begin	 
	    -- If email is valid
	   INSERT INTO Students(Student_Name,Faculty_Name,Student_Email,Student_Password,Student_Phone,Branch_ID,Track_ID,Intake_ID)
	   VALUES(@studentname,@facultyname,@studentemail,encryptbykey(key_guid('symmetrickey_student_instructor'), @studentpassward),@studentphone,@branchid,@trackid,@intakeid);
       PRINT 'student added successfully'
	end 
END

select * from Students

open symmetric key symmetrickey_student_instructor decryption  
by certificate certificate_student_instructor
EXEC SP_Add_Student 'Ali','Faculty of Education','karim@zagmail.com','hello','01124147718',12,3,12
close symmetric key symmetrickey_student_instructor
------------------------------------- (10) ----------------------------------------
--- Add Training Manager
go
CREATE or alter PROCEDURE SP_Create_TrainingManager
    @AdminID INT,
    @InstructorName NVARCHAR(50),
    @InstructorEmail NVARCHAR(50),
    @InstructorPassword NVARCHAR(15),
    @InstructorPhone NVARCHAR(11)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the admin exists
    IF NOT EXISTS (SELECT 1 FROM Instructors WHERE Instructor_ID = @AdminID)
    BEGIN
        RAISERROR('Admin ID does not exist.', 16, 1);
        RETURN;
    END

    -- Check if the email already exists
    IF EXISTS (SELECT 1 FROM Instructors WHERE Instructor_Email = @InstructorEmail)
    BEGIN
        RAISERROR('An instructor with this email already exists.', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insert the new training manager
        INSERT INTO Instructors (Instructor_Name, Instructor_Email, Instructor_Password, Instructor_Phone, Traning_Manager_ID)
        VALUES (@InstructorName, @InstructorEmail, @InstructorPassword, @InstructorPhone, NULL);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

EXEC SP_Create_TrainingManager 
    @AdminID = 1, -- Assuming 1 is the ID of an existing admin
    @InstructorName = 'Karim2',
    @InstructorEmail = 'Karim2@email.com',
    @InstructorPassword = 'Karim2@1234',
    @InstructorPhone = '01117657201';
------------------------------------- (11) ----------------------------------------
--- Create Random Question For Exam
go
create or alter proc SP_Select_Question_Random
(
   @Course_ID int,
   @Exam_ID int
)
as
begin
   declare @Counter int = 1
   declare @Number_Question int
   declare @Ex_Date date
   select @Number_Question = Number_Question, @Ex_Date = Exam_Date
   from Exams 
   where Exam_ID = @Exam_ID
   if(@Ex_Date > GETDATE() and exists (select * from Courses where Course_ID = @Course_ID) and exists (select * from Exams where Exam_ID = @Exam_ID))
   begin
      while(@Counter <= @Number_Question)
      begin
	  -- Get Number Of Returns Row 
	  declare @C1 int = 0
	  declare @C2 int = 0
	  declare @C3 int = 0
	  select @C1=count(tq.Question_ID)
	  from  Questions q, Text_Question tq
	  where 1 = q.Course_ID and q.Question_ID = tq.Question_ID
	  select  @C2=count(tq.Question_ID)
	  from  Questions q, Multiple_Choose tq
	  where q.Course_ID in (1,2,3) and q.Question_ID = tq.Question_ID
	  select  @C3=count(tq.Question_ID)
	  from  Questions q, TF tq
	  where 1 = q.Course_ID and q.Question_ID = tq.Question_ID
	  declare @Total int = @C1 + @C2 + @C3
	  -- Get Random Questions
	  DECLARE @QuestionID INT;
      WITH CombinedQuestions AS (
	  SELECT Question_ID, Question_Name, Correct_Answer,
	  ROW_NUMBER() OVER (ORDER BY RAND()) AS RowNum
      FROM (
           SELECT tq.Question_ID, tq.Question_Name, tq.Correct_Answer
           FROM Questions q, Text_Question tq
           WHERE @Course_ID = q.Course_ID AND q.Question_ID = tq.Question_ID
           UNION ALL
           SELECT tq.Question_ID, tq.Question_Name, tq.Correct_Answer
           FROM Questions q, TF tq
           WHERE @Course_ID = q.Course_ID AND q.Question_ID = tq.Question_ID
           UNION ALL
           SELECT t.Question_ID, t.Question_Name, t.Correct_Answer
           FROM Questions q, Multiple_Choose t
           WHERE @Course_ID = q.Course_ID AND q.Question_ID = t.Question_ID
           ) AS Combined
	  )
	  SELECT @QuestionID = Question_ID
      FROM CombinedQuestions
      WHERE RowNum = ((1 + CAST((RAND() * (@Total - 1 + 1)) AS INT)));
	  print('Before');
	  print(@QuestionID);
	  print(@Total);
	  if not exists(select Question_ID from Exam_Question where @QuestionID = Question_ID and @Exam_ID = Exam_ID)
	  begin     
	     insert into Exam_Question(Question_ID, Exam_ID, Question_Degree)
	     values(@QuestionID, @Exam_ID, 1)
		 set @Counter = @Counter + 1
	  end
      end
   end
   else
   begin
      print('==> There are 3 error may one of them happen')
	  print('(1) Time out of exam')
	  print('(2) You must enter exists course id')
	  print('(3) You must enter exists exam id')
   end
end

exec SP_Select_Question_Random 2,5
select * from Courses
select * from Exams
select * from Exam_Question
select * from TF

--- Create Question For Exam With Instructor
go
create or alter proc SP_Select_Question_Instructor
(
   @Instructor_ID int,
   @Course_ID int,
   @Exam_ID int,
   @Questions_List nvarchar(max)
)
as
begin
   begin try
       declare @Counter int = 1;
       declare @Number_Question int;
       declare @Ex_Date date;
       declare @Count_Questions int;
       declare @Count_Questions_In_Table int;

       -- Check if the Instructor_ID belongs to the Course_ID
       if not exists (select 1 from Instructor_Course where Instructor_ID = @Instructor_ID AND Course_ID = @Course_ID)
       begin
           print 'Instructor does not belong to the specified course.';
           return;
       end

       select @Count_Questions = count(value)
       from STRING_SPLIT(@Questions_List, ',');

       select @Number_Question = Number_Question, @Ex_Date = Exam_Date
       from Exams 
       where Exam_ID = @Exam_ID;

       select @Count_Questions_In_Table = COUNT(*)
       from Exam_Question 
       where Exam_ID = @Exam_ID;

       if (@Ex_Date > GETDATE() AND @Count_Questions = @Number_Question)
       begin
           begin transaction;

           declare @Ids table (Id int , Exam int , Degree int);  
           insert into @Ids (Id, Exam, Degree) 
           select CAST(value AS int) AS Id, @Exam_ID, 1
           from STRING_SPLIT(@Questions_List, ',');

           -- Check if the Question belongs to the same course
           if exists (
               select 1
               from @Ids ids
               join Questions q on ids.Id = q.Question_ID
               where q.Course_ID <> @Course_ID
           )
           begin
               declare @IdAV nvarchar(max); 
               select @IdAV = ISNULL(@IdAV + ',', '') + CAST(q.Question_ID AS NVARCHAR)
               from Questions q
               where q.Course_ID = @Course_ID;
               
               print 'One or more Question IDs do not belong to the specified Course ID';
               print 'Available Questions are:';
               print @IdAV;

               rollback transaction;
               return;
           end

           -- Delete existing Questions when the instructor updates
           delete from Exam_Question
           where Exam_ID = @Exam_ID;

           -- Insert new Questions
           insert into Exam_Question (Question_ID, Exam_ID, Question_Degree)
           select Id, Exam, Degree 
           from @Ids ids
           where not exists (
               select 1
               from Exam_Question eq
               where eq.Question_ID = ids.Id
               and eq.Exam_ID = @Exam_ID
           );

           commit transaction;
       end
       else
       begin
           print '==> There are 3 errors that may occur:';
           print '(1) Time out of exam';
           print '(2) You must enter the number of question IDs equal to the questions number in the exam';
           print '(3) You try to enter questions although the exam questions have been entered before';

           rollback transaction;
       end
   end try
   begin catch
       if @@TRANCOUNT > 0
           rollback transaction;
       print 'An error occurred. The transaction has been rolled back.';
       print ERROR_MESSAGE();
   end catch
end;

exec  SP_Select_Question_Instructor
@Instructor_ID = 1,
@Course_ID = 10,
@Exam_ID = 6,
@Questions_List = '8,58,108'

select * from Instructor_Course
select * from Exam_Question
delete from Exam_Question
where Exam_ID = 6
select * from Exams
select * from Questions

------------------------------------- (12) ----------------------------------------
go
create or alter proc SP_Update_Question_Degree
(
    @Question_ID int,
    @Exam_ID int,
    @New_Question_Degree int
)
as
begin
if exists (
        select 1
        from Exam_Question
        where Question_ID = @Question_ID AND Exam_ID = @Exam_ID
    )
begin
update Exam_Question
    set Question_Degree = @New_Question_Degree
    where Question_ID = @Question_ID AND Exam_ID = @Exam_ID;
 declare @currentDegree int;
 select @currentDegree = sum(Question_Degree) from Exam_Question
 where Exam_ID = @Exam_ID
end
  else
    begin
        print('Question ID or Exam ID does not exist in Exam_Question.');
    end
end;

exec SP_Update_Question_Degree 20,1,40

exec SP_Update_Question_Degree 20,1,60

exec SP_Update_Question_Degree 40,1,60

------------------------------------- (13) ----------------------------------------
--- Select Instructor 
go
create or alter proc SP_Get_Instructor_For_Exam
(
   @Exam_ID int
)
as
begin
   if not exists(select * from Exams where Exam_ID = @Exam_ID)
   begin
      Print('This exam not found');
   end
   else
   begin
      declare @Course_ID int
      declare @Question_ID int
	  declare @Instructor_ID int
      select top (1) @Question_ID = Question_ID
	  from Exam_Question
	  where Exam_ID =  @Exam_ID
	  select top (1) @Course_ID = Course_ID
	  from Questions
	  where Question_ID =  @Question_ID
	  select top (1) @Instructor_ID = Instructor_ID
	  from Instructor_Course
	  where Course_ID =  @Course_ID
	  select * 
	  from Instructors
	  where Instructor_ID = @Instructor_ID
   end
end

exec SP_Get_Instructor_For_Exam 1 -- 1,5

------------------------------------- (14) ----------------------------------------
--- Select Student For Exam
go
CREATE or alter PROCEDURE SP_Select_Students_For_Exam
    @InstructorID INT,
    @ExamID INT,
    @StudentIDs VARCHAR(MAX) -- Comma-separated list of Student IDs
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the instructor exists and is allowed to select students
    IF NOT EXISTS (SELECT 1 FROM Instructors WHERE Instructor_ID = @InstructorID)
    BEGIN
        RAISERROR('Instructor does not exist or is not authorized.', 16, 1);
        RETURN;
    END

    -- Check if the exam exists
    IF NOT EXISTS (SELECT 1 FROM Exams WHERE Exam_ID = @ExamID)
    BEGIN
        RAISERROR('Exam ID does not exist.', 16, 1);
        RETURN;
    END

    -- Check if @StudentIDs parameter is empty
    IF LEN(@StudentIDs) = 0
    BEGIN
        RAISERROR('No students selected.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Insert selected students for the exam using STRING_SPLIT
        INSERT INTO Exam_Student (Student_ID, Exam_ID)
        SELECT CAST(value AS INT), @ExamID
        FROM STRING_SPLIT(@StudentIDs, ',')
        WHERE ISNUMERIC(value) = 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

EXEC SP_Select_Students_For_Exam
    @InstructorID = 1, 
    @ExamID = 5, 
    @StudentIDs = '1,2,3,4,5,6';
	
select * from Exam_Student


