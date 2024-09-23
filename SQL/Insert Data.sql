
-- Encryption Data
create master key encryption 
by password ='Examination@12345$'
create certificate certificate_student_instructor
with subject ='Student password encryption certificate'
create symmetric key symmetrickey_student_instructor
with algorithm=AES_256 encryption
by certificate certificate_student_instructor

-- Insert Department
declare @xml xml;
select @xml = BulkColumn
from openrowset(BULK 'D:\ITI\Projects\SQL\Data\department.xml',single_blob) as x;
insert into Departments (Department_Name)
select 
      x.value('(Department_Name/text())[1]','nvarchar (50)')
from @xml.nodes('/Departments/Department') as tbl(x)
select * from Departments

-- Insert Track
declare @xml xml;
select @xml = BulkColumn
from openrowset(BULK 'D:\ITI\Projects\SQL\Data\tracks.xml',single_blob) as x;
insert into Tracks (Track_Name, Department_ID)
select 
      x.value('(Track_Name/text())[1]','nvarchar (50)'),
	  x.value('(Department_ID/text())[1]','nvarchar (50)')
from @xml.nodes('/Tracks/Track') as tbl(x)
select * from Tracks

-- Insert Courses
declare @xml xml;
select @xml = BulkColumn
from openrowset(BULK 'D:\ITI\Projects\SQL\Data\courses.xml',single_blob) as x;
insert into Courses (Course_Name,Descriptions,Max_Degree,Min_Degree, Track_ID)
select 
      x.value('(Course_Name/text())[1]','nvarchar (50)'),
      x.value('(Descriptions/text())[1]','nvarchar (500)'),
      x.value('(Max_Degree/text())[1]','int'),
      x.value('(Min_Degree/text())[1]','int'),
	  x.value('(Track_ID/text())[1]','int')
from @xml.nodes('/Courses/Course') as tbl(x)
select * from Courses

-- Insert Questions
INSERT INTO Questions (Question_Type, Course_ID) VALUES 
('TF', 1), ('TF', 2), ('TF', 3), ('TF', 4), ('TF', 5), 
('TF', 6), ('TF', 7), ('TF', 8), ('TF', 9), ('TF', 10), 
('TF', 11), ('TF', 12), ('TF', 13), ('TF', 14), ('TF', 15), 
('TF', 16), ('TF', 17), ('TF', 18), ('TF', 19), ('TF', 20), 
('TF', 21), ('TF', 22), ('TF', 23), ('TF', 24), ('TF', 25), 
('TF', 26), ('TF', 27), ('TF', 28), ('TF', 29), ('TF', 30), 
('TF', 31), ('TF', 32), ('TF', 33), ('TF', 34), ('TF', 35), 
('TF', 36), ('TF', 37), ('TF', 38), ('TF', 39), ('TF', 40), 
('TF', 41), ('TF', 42), ('TF', 43), ('TF', 44), ('TF', 45), 
('TF', 46), ('TF', 47), ('TF', 48), ('TF', 49), ('TF', 50), 
('Text Question', 1), ('Text Question', 2), ('Text Question', 3), ('Text Question', 4), ('Text Question', 5), 
('Text Question', 6), ('Text Question', 7), ('Text Question', 8), ('Text Question', 9), ('Text Question', 10), 
('Text Question', 11), ('Text Question', 12), ('Text Question', 13), ('Text Question', 14), ('Text Question', 15), 
('Text Question', 16), ('Text Question', 17), ('Text Question', 18), ('Text Question', 19), ('Text Question', 20), 
('Text Question', 21), ('Text Question', 22), ('Text Question', 23), ('Text Question', 24), ('Text Question', 25), 
('Text Question', 26), ('Text Question', 27), ('Text Question', 28), ('Text Question', 29), ('Text Question', 30), 
('Text Question', 31), ('Text Question', 32), ('Text Question', 33), ('Text Question', 34), ('Text Question', 35), 
('Text Question', 36), ('Text Question', 37), ('Text Question', 38), ('Text Question', 39), ('Text Question', 40), 
('Text Question', 41), ('Text Question', 42), ('Text Question', 43), ('Text Question', 44), ('Text Question', 45), 
('Text Question', 46), ('Text Question', 47), ('Text Question', 48), ('Text Question', 49), ('Text Question', 50), 
('Choose', 1), ('Choose', 2), ('Choose', 3), ('Choose', 4), ('Choose', 5), 
('Choose', 6), ('Choose', 7), ('Choose', 8), ('Choose', 9), ('Choose', 10), 
('Choose', 11), ('Choose', 12), ('Choose', 13), ('Choose', 14), ('Choose', 15), 
('Choose', 16), ('Choose', 17), ('Choose', 18), ('Choose', 19), ('Choose', 20), 
('Choose', 21), ('Choose', 22), ('Choose', 23), ('Choose', 24), ('Choose', 25), 
('Choose', 26), ('Choose', 27), ('Choose', 28), ('Choose', 29), ('Choose', 30), 
('Choose', 31), ('Choose', 32), ('Choose', 33), ('Choose', 34), ('Choose', 35), 
('Choose', 36), ('Choose', 37), ('Choose', 38), ('Choose', 39), ('Choose', 40), 
('Choose', 41), ('Choose', 42), ('Choose', 43), ('Choose', 44), ('Choose', 45), 
('Choose', 46), ('Choose', 47), ('Choose', 48), ('Choose', 49), ('Choose', 50);
select * from Questions

-- Insert for TF Table
INSERT INTO TF (Question_Name, Correct_Answer, Question_ID) VALUES 
('HTML is used to structure web pages.', 'T', 1),
('CSS is a programming language.', 'F', 2),
('JavaScript can be used for both frontend and backend development.', 'T', 3),
('A database is used to store and manage data.', 'T', 4),
('Network security involves protecting data during transmission.', 'T', 5),
('Python is a low-level programming language.', 'F', 6),
('Machine Learning is a subset of Artificial Intelligence.', 'T', 7),
('Agile is a project management methodology.', 'T', 8),
('A compiler translates code from high-level language to machine code.', 'T', 9),
('Blockchain is used only for cryptocurrencies.', 'F', 10),
('Cloud computing eliminates the need for physical servers.', 'T', 11),
('SQL stands for Structured Query Language.', 'T', 12),
('Java is a purely object-oriented programming language.', 'F', 13),
('The primary key in a database table uniquely identifies each record.', 'T', 14),
('Ethical hacking involves testing security systems legally.', 'T', 15),
('IoT stands for Internet of Things.', 'T', 16),
('Scrum is a framework within Agile methodology.', 'T', 17),
('Data mining and data warehousing are the same.', 'F', 18),
('Front-end frameworks include React and Angular.', 'T', 19),
('RESTful APIs use HTTP methods for communication.', 'T', 20),
('VPN stands for Virtual Private Network.', 'T', 21),
('C++ is a procedural programming language.', 'F', 22),
('Operating systems manage hardware and software resources.', 'T', 23),
('ORM stands for Object Relational Mapping.', 'T', 24),
('HTML stands for HyperText Markup Language.', 'T', 25),
('CI/CD stands for Continuous Integration/Continuous Deployment.', 'T', 26),
('A firewall protects against unauthorized access.', 'T', 27),
('Linux is an open-source operating system.', 'T', 28),
('SSD stands for Solid State Drive.', 'T', 29),
('IPv6 is the latest version of the Internet Protocol.', 'T', 30),
('Python is known for its readability and simplicity.', 'T', 31),
('RDBMS stands for Relational Database Management System.', 'T', 32),
('Django is a Python web framework.', 'T', 33),
('XSS stands for Cross-Site Scripting.', 'T', 34),
('Git is a version control system.', 'T', 35),
('SQL Injection is a type of security vulnerability.', 'T', 36),
('Normalization reduces data redundancy.', 'T', 37),
('AI stands for Artificial Intelligence.', 'T', 38),
('NLP stands for Natural Language Processing.', 'T', 39),
('JSON is a data interchange format.', 'T', 40),
('HTML and XML are markup languages.', 'T', 41),
('A subnet mask is used in IP addressing.', 'T', 42),
('ORMs help in database management.', 'T', 43),
('Deep Learning is a subset of Machine Learning.', 'T', 44),
('IoT devices are interconnected over the internet.', 'T', 45),
('Big Data involves large volumes of data.', 'T', 46),
('JavaScript is interpreted at runtime.', 'T', 47),
('MVC stands for Model-View-Controller.', 'T', 48),
('SOA stands for Service-Oriented Architecture.', 'T', 49),
('API stands for Application Programming Interface.', 'T', 50);
select * from TF
 
-- Insert for Text Question Table -- (reqular expression)
INSERT INTO Text_Question (Question_Name, Correct_Answer, Question_ID) VALUES 
('Describe the role of HTML in web development.', 'HTML is used to structure the content on web pages.', 51),
('What is the purpose of CSS?', 'CSS is used for styling web pages.', 52),
('Explain the difference between frontend and backend development.', 'Frontend development focuses on the client-side, while backend development focuses on the server-side.', 53),
('What is a database?', 'A database is a system for storing and managing data.', 54),
('Define network security.', 'Network security involves protecting data during transmission across networks.', 55),
('What is Python?', 'Python is a high-level programming language known for its readability.', 56),
('Explain Machine Learning.', 'Machine Learning is a subset of AI that involves training algorithms to learn from data.', 57),
('What is Agile methodology?', 'Agile is a project management methodology focused on iterative development.', 58),
('Define a compiler.', 'A compiler translates code from a high-level programming language to machine code.', 59),
('What is Blockchain?', 'Blockchain is a distributed ledger technology used for secure transactions.', 60),
('Explain cloud computing.', 'Cloud computing involves delivering computing services over the internet.', 61),
('What is SQL?', 'SQL is a language used for managing databases.', 62),
('What is the primary key in a database?', 'The primary key uniquely identifies each record in a table.', 63),
('Describe ethical hacking.', 'Ethical hacking involves legally testing systems for vulnerabilities.', 64),
('What is IoT?', 'IoT stands for Internet of Things and involves interconnecting devices over the internet.', 65),
('Explain Scrum.', 'Scrum is an Agile framework for managing complex projects.', 66),
('Differentiate between data mining and data warehousing.', 'Data mining involves analyzing data for patterns, while data warehousing involves storing large volumes of data.', 67),
('What are front-end frameworks?', 'Front-end frameworks like React and Angular are used to build interactive user interfaces.', 68),
('Describe RESTful APIs.', 'RESTful APIs use HTTP methods to perform CRUD operations.', 69),
('What is a VPN?', 'VPN stands for Virtual Private Network and is used to create a secure connection over the internet.', 70),
('Explain C++.', 'C++ is a general-purpose programming language that supports procedural, object-oriented, and generic programming.', 71),
('What is an operating system?', 'An operating system manages hardware and software resources on a computer.', 72),
('Define ORM.', 'ORM stands for Object-Relational Mapping and is used to map objects to database tables.', 73),
('What is HTML?', 'HTML stands for HyperText Markup Language and is used to create web pages.', 74),
('Explain CI/CD.', 'CI/CD stands for Continuous Integration and Continuous Deployment, which are practices in software development for frequent code changes and deployments.', 75),
('What is a firewall?', 'A firewall is a security system that monitors and controls incoming and outgoing network traffic.', 76),
('Describe Linux.', 'Linux is an open-source operating system known for its stability and security.', 77),
('What is an SSD?', 'SSD stands for Solid State Drive, which is a type of storage device.', 78),
('Explain IPv6.', 'IPv6 is the latest version of the Internet Protocol, designed to replace IPv4.', 79),
('Describe Python.', 'Python is a high-level programming language known for its readability and support for multiple programming paradigms.', 80),
('What is RDBMS?', 'RDBMS stands for Relational Database Management System, which is used to manage relational databases.', 81),
('What is Django?', 'Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design.', 82),
('Explain XSS.', 'XSS stands for Cross-Site Scripting, which is a type of security vulnerability in web applications.', 83),
('What is Git?', 'Git is a distributed version control system used for tracking changes in source code.', 84),
('Define SQL Injection.', 'SQL Injection is a type of security vulnerability that allows attackers to interfere with the queries an application makes to its database.', 85),
('What is normalization?', 'Normalization is a database design technique that reduces data redundancy and improves data integrity.', 86),
('Explain AI.', 'AI stands for Artificial Intelligence, which is the simulation of human intelligence in machines.', 87),
('What is NLP?', 'NLP stands for Natural Language Processing, which is a field of AI that focuses on the interaction between computers and humans through natural language.', 88),
('Describe JSON.', 'JSON stands for JavaScript Object Notation and is a lightweight data interchange format.', 89),
('What are markup languages?', 'Markup languages like HTML and XML are used to define the structure and presentation of text in documents.', 90),
('What is a subnet mask?', 'A subnet mask is used in IP addressing to divide a network into subnetworks.', 91),
('Explain ORMs.', 'ORMs are tools that help in database management by mapping objects to database tables.', 92),
('What is Deep Learning?', 'Deep Learning is a subset of Machine Learning that involves neural networks with many layers.', 93),
('Describe IoT devices.', 'IoT devices are interconnected over the internet and can communicate with each other.', 94),
('What is Big Data?', 'Big Data involves large volumes of data that can be analyzed for insights.', 95),
('Explain JavaScript.', 'JavaScript is a programming language that is commonly used to create interactive effects within web browsers.', 96),
('What is MVC?', 'MVC stands for Model-View-Controller, which is a software architectural pattern.', 97),
('Define SOA.', 'SOA stands for Service-Oriented Architecture, which is a design pattern where services are provided to other components by application components, through a communication protocol over a network.', 98),
('What is an API?', 'API stands for Application Programming Interface, which is a set of rules that allows one piece of software application to interact with another.', 99),
('Explain Agile.', 'Agile is a project management methodology that emphasizes incremental progress, collaboration, and flexibility.', 100);
select * from Text_Question

-- Insert for Choose Question Table
INSERT INTO Multiple_Choose (Question_Name, Correct_Answer, A, B, C, D, Question_ID) VALUES 
('Which tag is used for the largest heading in HTML?', 'A', '<h1>', '<h2>', '<h3>', '<h4>', 101),
('Which of the following is a backend language?', 'B', 'HTML', 'Python', 'CSS', 'JavaScript', 102),
('Which property is used to change the background color in CSS?', 'C', 'color', 'font-size', 'background-color', 'margin', 103),
('Which of the following is not a JavaScript data type?', 'D', 'Number', 'String', 'Boolean', 'Character', 104),
('Which tag is used to create a hyperlink in HTML?', 'A', '<a>', '<link>', '<href>', '<anchor>', 105),
('What is the correct HTML tag for inserting a line break?', 'B', '<br>', '<lb>', '<break>', '<newline>', 106),
('Which CSS property is used to change the text color?', 'A', 'color', 'font-color', 'text-color', 'font-style', 107),
('Which HTML attribute specifies an alternate text for an image, if the image cannot be displayed?', 'C', 'src', 'title', 'alt', 'href', 108),
('Which HTML element defines the title of a document?', 'A', '<title>', '<head>', '<meta>', '<style>', 109),
('Which HTML tag is used to define an internal style sheet?', 'D', '<script>', '<link>', '<meta>', '<style>', 110),
('Which is the correct CSS syntax?', 'A', 'body {color: black;}', 'body:color=black;', '{body;color:black;}', '{body:color=black;}', 111),
('Which JavaScript method is used to write HTML output?', 'B', 'document.output()', 'document.write()', 'document.print()', 'document.html()', 112),
('Which SQL statement is used to update data in a database?', 'C', 'UPDATE', 'MODIFY', 'CHANGE', 'SET', 113),
('Which of the following is a JavaScript framework?', 'D', 'Django', 'Rails', 'Laravel', 'Angular', 114),
('Which method can be used to find the length of a string in JavaScript?', 'A', 'length', 'size', 'length()', 'size()', 115),
('Which protocol is used to secure communication over the Internet?', 'B', 'FTP', 'HTTPS', 'HTTP', 'SMTP', 116),
('Which HTML tag is used to define an unordered list?', 'A', '<ul>', '<ol>', '<li>', '<list>', 117),
('Which CSS property controls the text size?', 'C', 'font-style', 'text-style', 'font-size', 'text-size', 118),
('Which HTML attribute is used to define inline styles?', 'B', 'class', 'style', 'font', 'styles', 119),
('Which JavaScript operator is used to assign a value to a variable?', 'D', '=', '==', '===', '=>', 120),
('Which of the following is used to define a block of code in Python?', 'A', 'Indentation', 'Brackets', 'Parentheses', 'Curly braces', 121),
('Which SQL statement is used to delete data from a database?', 'C', 'REMOVE', 'DELETE', 'DROP', 'CLEAR', 122),
('Which HTML tag is used to define a table?', 'A', '<table>', '<tab>', '<tbody>', '<td>', 123),
('Which CSS property is used to change the font?', 'B', 'font-family', 'font-style', 'font-size', 'font-weight', 124),
('Which SQL statement is used to insert new data in a database?', 'C', 'ADD', 'CREATE', 'INSERT INTO', 'MODIFY', 125),
('Which Python keyword is used to define a function?', 'D', 'function', 'def', 'lambda', 'define', 126),
('Which HTML attribute is used to specify a unique id for an element?', 'B', 'class', 'id', 'style', 'name', 127),
('Which of the following is not a valid JavaScript variable name?', 'A', '2names', '_first_and_last_names', 'FirstAndLast', 'first_and_last', 128),
('Which SQL keyword is used to sort the result-set?', 'B', 'SORT', 'ORDER BY', 'FILTER', 'GROUP BY', 129),
('Which method is used to add an element to the end of an array in JavaScript?', 'C', 'add()', 'insert()', 'push()', 'append()', 130),
('Which HTML tag is used to define a footer for a document or section?', 'D', '<footer>', '<bottom>', '<end>', '<foot>', 131),
('Which CSS property is used to change the left margin of an element?', 'A', 'margin-left', 'padding-left', 'indent-left', 'space-left', 132),
('Which Python function is used to get the length of a list?', 'B', 'len()', 'size()', 'length()', 'count()', 133),
('Which SQL clause is used to filter records?', 'C', 'WHERE', 'ORDER BY', 'FILTER', 'GROUP BY', 134),
('Which HTML tag is used to define a list item?', 'A', '<li>', '<item>', '<list>', '<ul>', 135),
('Which CSS property is used to set the background image of an element?', 'B', 'background-color', 'background-image', 'image', 'img', 136),
('Which JavaScript function is used to parse a string to an integer?', 'C', 'parseInt()', 'parse()', 'int()', 'Number()', 137),
('Which SQL statement is used to create a new table in a database?', 'D', 'CREATE TABLE', 'NEW TABLE', 'ADD TABLE', 'INSERT TABLE', 138),
('Which Python method is used to add an item to the end of a list?', 'A', 'append()', 'add()', 'insert()', 'push()', 139),
('Which HTML tag is used to define a paragraph?', 'B', '<p>', '<para>', '<paragraph>', '<pg>', 140),
('Which CSS property is used to change the text alignment?', 'C', 'align', 'text-align', 'alignment', 'text-style', 141),
('Which JavaScript method is used to remove the last element from an array?', 'D', 'delete()', 'remove()', 'pop()', 'shift()', 142),
('Which SQL clause is used to group records that have the same values?', 'A', 'GROUP BY', 'ORDER BY', 'SORT', 'FILTER', 143),
('Which Python method is used to remove an item from a list?', 'B', 'delete()', 'remove()', 'pop()', 'shift()', 144),
('Which HTML tag is used to define an image?', 'C', '<img>', '<image>', '<pic>', '<src>', 145),
('Which CSS property is used to change the height of an element?', 'A', 'height', 'size', 'element-height', 'block-height', 146),
('Which JavaScript method is used to join two or more arrays?', 'B', 'concat()', 'join()', 'merge()', 'combine()', 147),
('Which SQL function is used to count the number of rows in a table?', 'D', 'COUNT()', 'SUM()', 'TOTAL()', 'NUMBER()', 148),
('Which Python function is used to get the maximum value in a list?', 'A', 'max()', 'maximum()', 'largest()', 'biggest()', 149),
('Which HTML tag is used to define the body of a document?', 'B', '<body>', '<main>', '<document>', '<html>', 150);
select * from Multiple_Choose


-- Insert Branch
declare @xml xml;
select @xml = BulkColumn
from openrowset(BULK 'D:\ITI\Projects\SQL\Data\branches.xml',single_blob) as x;
insert into Branches (Branch_Name, City)
select 
      x.value('(Branch_Name/text())[1]','nvarchar (55)'),
	  x.value('(City/text())[1]','nvarchar (50)')
from @xml.nodes('/Branches/Branch') as tbl(x)
select * from Branches

-- Insert Intake
declare @xml xml;
select @xml = BulkColumn
from openrowset(BULK 'D:\ITI\Projects\SQL\Data\intake.xml',single_blob) as x;
insert into Intakes (Intake_Name, Date_Start, Date_End, Branch_ID)
select 
      x.value('(Intake_Name/text())[1]','nvarchar (50)'),
	  x.value('(Date_Start/text())[1]','date'),
	  x.value('(Date_End/text())[1]','date'),
	  x.value('(Branch_ID/text())[1]','int')
from @xml.nodes('/Intakes/Intake') as tbl(x)
select * from Intakes

-- Insert Intake Track
INSERT INTO Intakes_Trackes(Intake_ID, Track_ID) VALUES 
(1, 3),
(1, 4),
(3, 9),
(3, 10),
(3, 11),
(3, 12),
(10, 33),
(10, 34),
(10, 35)
select * from Intakes_Trackes

-- Insert Student
DECLARE @xmlData XML;
SELECT @xmlData = BulkColumn
FROM OPENROWSET(BULK 'D:\ITI\Projects\SQL\Data\student.xml', SINGLE_BLOB) AS x;
INSERT INTO Students (Student_Name, Faculty_Name, Student_Email, Student_Password, Student_Phone, Branch_ID, Track_ID)
SELECT 
    x.value('(Student_Name)[1]', 'nvarchar(80)'),
    x.value('(Faculty_Name)[1]', 'nvarchar(40)'),
    x.value('(Student_Email)[1]', 'nvarchar(25)'),
    x.value('(Student_Password)[1]', 'nvarchar(40)'),
    x.value('(Student_Phone)[1]', 'nvarchar(11)'),
    x.value('(Branch_ID)[1]', 'int'),
    x.value('(Track_ID)[1]', 'int')
FROM @xmlData.nodes('/Students/Student') AS tbl(x);
select * from Students

insert into Students
(Student_Name, Faculty_Name, Student_Email, Student_Password, Student_Phone, Branch_ID, Track_ID)
values ('Tom', 'FCI', 'tom@yahoo.com', HASHBYTES('SHA2_512', '1234567'), '12345678910', 1, 1)

-- Insert Instructor
DECLARE @xmlData XML;
SELECT @xmlData = BulkColumn
FROM OPENROWSET(BULK 'D:\ITI\Projects\SQL\Data\instructor.xml', SINGLE_BLOB) AS x;
INSERT INTO Instructors (Instructor_Name, Instructor_Email, Instructor_Password, Instructor_Phone)
SELECT 
    x.value('(Instructor_Name)[1]', 'nvarchar(50)'),
    x.value('(Instructor_Email)[1]', 'nvarchar(50)'),
    x.value('(Instructor_Password)[1]', 'nvarchar(15)'),
    x.value('(Instructor_Phone)[1]', 'nvarchar(11)')
FROM @xmlData.nodes('/Instructors/Instructor') AS tbl(x);
select * from Instructors

----------------------------------------------------------------------------
select * from Students

update students 
set Intake_ID = 11
where Student_ID between 1 and 3
update students 
set Intake_ID = 2
where Student_ID = 4
update students 
set Intake_ID = 11
where Student_ID  between 5 and 13
update students 
set Intake_ID = 3
where Student_ID  between 14 and 16
update students 
set Intake_ID = 4
where Student_ID  between 17 and 20
update students 
set Intake_ID = 11
where Student_ID  between 22 and 23
update students 
set Intake_ID = 2
where Student_ID  between 24 and 27
update students 
set Intake_ID = 3
where Student_ID  between 28 and 31
update students 
set Intake_ID = 1
where Student_ID  between 32 and 33
update students 
set Intake_ID = 7
where Student_ID  between 34 and 35
update students 
set Intake_ID = 1
where Student_ID  = 37
update students 
set Intake_ID = 2
where Student_ID  =39
update students 
set Intake_ID = 7
where Student_ID  = 40
update students 
set Intake_ID = 2
where Student_ID  = 41
update students 
set Intake_ID = 1
where Student_ID  =42
update students 
set Intake_ID = 2
where Student_ID  =43
update students 
set Intake_ID = 4
where Student_ID  = 45 
update students 
set Intake_ID = 7
where Student_ID  between 50 and 56
update students 
set Intake_ID = 1
where Student_ID = 57
update students 
set Intake_ID = 4
where Student_ID  between 58 and 67
update students 
set Intake_ID = 1
where Student_ID  between 68 and 72
update students 
set Intake_ID = 11
where Student_ID  =73
update students 
set Intake_ID = 2
where Student_ID  between 74 and 76
update students 
set Intake_ID = 1
where Student_ID  between 77 and 78
update students 
set Intake_ID = 7
where Student_ID  =79
update students 
set Intake_ID = 2
where Student_ID  between 80 and 81
update students 
set Intake_ID = 7
where Student_ID  between 82 and 83
update students 
set Intake_ID = 1
where Student_ID  = 84
update students 
set Intake_ID = 2
where Student_ID  = 85
----------------------------------------------------------------------------

update Questions
set Course_ID=1
where Question_ID between 1 and 5
update Questions
set Course_ID=1
where Question_ID between 51and 55

update Questions
set Course_ID=1
where Question_ID between 101 and 105

update Questions
set Course_ID=2
where Question_ID between 6 and 11
update Questions
set Course_ID=2
where Question_ID between 56 and 61
update Questions
set Course_ID=2
where Question_ID between 106and 111

update Questions
set Course_ID=3
where Question_ID between 12 and 17

update Questions
set Course_ID=3
where Question_ID between 62 and 67

update Questions
set Course_ID=3
where Question_ID between 112 and 117

update Questions
set Course_ID=4
where Question_ID between 18 and 23

update Questions
set Course_ID=4
where Question_ID between 68 and 73

update Questions
set Course_ID=4
where Question_ID between 118 and 123

update Questions
set Course_ID=5
where Question_ID between 24 and 29

update Questions
set Course_ID=5
where Question_ID between 74 and 79

update Questions
set Course_ID=5
where Question_ID between 124and 129

update Questions
set Course_ID=6
where Question_ID between 30 and 35
update Questions
set Course_ID=6
where Question_ID between 80and 95
update Questions
set Course_ID=6
where Question_ID between 130 and 135

update Questions
set Course_ID=7
where Question_ID between 36 and 41

update Questions
set Course_ID=7
where Question_ID between 96 and 100

update Questions
set Course_ID=7
where Question_ID between 136 and 141

update Questions
set Course_ID=8
where Question_ID between 42 and 47
update Questions
set Course_ID=8
where Question_ID between 96  and 100

update Questions
set Course_ID=8
where Question_ID between 142 and 147

update Questions
set Course_ID=9
where Question_ID between 48 and 50

update Questions
set Course_ID=9
where Question_ID between 148 and 150

select * from Instructor_Course