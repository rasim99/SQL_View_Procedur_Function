CREATE DATABASE NewCourse
USE NewCourse

CREATE TABLE Groups(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(30) NOT NULL UNIQUE,
[Limit] INT NOT NULL  CHECK([Limit] BETWEEN 1 AND 20),
BeginDate DATE DEFAULT GETDATE(),
EndDate DATE NOT NULL
)

CREATE OR ALTER TRIGGER InsertDataToGroupsIfEndDateGreaterBeginDate ON Groups
INSTEAD OF INSERT
AS
BEGIN
INSERT INTO Groups ([Name],[Limit],BeginDate,EndDate)
SELECT [Name],[Limit],BeginDate,EndDate
FROM inserted
WHERE EndDate >BeginDate
IF @@ROWCOUNT=0
BEGIN
RAISERROR('Cannot BeginDate Greater than EndDate',16,1)
END
END

INSERT INTO Groups VALUES
('Br21',1,'2024.07.13','2025.05.27')
('A2',13,'2024.06.18','2025.04.12')



CREATE TABLE Students(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(50) NOT NULL,
Surname NVARCHAR(50) NOT NULL,
Email NVARCHAR(50) NOT NULL UNIQUE,
PhoneNumber NVARCHAR(20) NOT NULL UNIQUE,
BirthDate DATE NOT NULL,
GPA DECIMAL(4,1) CHECK(GPA BETWEEN 1 AND 100)
)



CREATE TABLE StudentsGroups(
Id INT PRIMARY KEY IDENTITY(1,1),
StudentId INT FOREIGN KEY REFERENCES Students(Id),
GroupId INT FOREIGN KEY REFERENCES Groups(Id),
)


--a. Bir trigger yazilmalidir, hansi ki student elave olunan zaman qrupun limitin yoxlamalidir 
--eger qrupda limitli sayda telebe varsa elave etmemelidir, eks halda etmelidir

CREATE OR ALTER TRIGGER AddStudentToGroupIfLimitNotReached 
ON StudentsGroups
INSTEAD OF INSERT	
AS
BEGIN
DECLARE @GroupId INT
SELECT  @GroupId =i.GroupId
 FROM inserted i
IF (
SELECT COUNT(sg.StudentId) 
FROM StudentsGroups sg
WHERE sg.GroupId=@GroupId)
> (SELECT g.Limit
FROM Groups g
WHERE g.Id=@GroupId
 )
 BEGIN
 RAISERROR('Limit kecildi',16,1)
 END

 INSERT INTO StudentsGroups(StudentId,GroupId)
 SELECT StudentId,GroupId FROM inserted
END

---b. Bir trigger yazilmalidir, hansi ki o studentin yasinin 16dan cox oldugunu yoxlamalidir, eger boyukdurse elave etmelidir, eks halda ise yox
CREATE OR ALTER TRIGGER AddStudentIfAgeGreater16 ON Students
INSTEAD OF INSERT 
AS
BEGIN 
INSERT INTO Students ([Name],Surname,Email,PhoneNumber,BirthDate,GPA)
SELECT [Name],Surname,Email,PhoneNumber,BirthDate,GPA
FROM inserted
WHERE BirthDate<DATEADD(YEAR,-16,GETDATE())

IF @@ROWCOUNT = 0
BEGIN
RAISERROR('Yash 16dan boyuk olmalidir',16,1)
RETURN
END

END


INSERT INTO Students VALUES
('Lola','Frankis','lola@gmail.com','9941236647788','2000.07.01',95.4),
('Nila','Doler','nm@gmail.com','9941123449788','2006.07.01',95.4),
('Lorem','Doler','lorem@gmail.com','994123447788','2008.07.01',95.4)

INSERT INTO StudentsGroups VALUES
(2,3),
(4,3)

--c. Bir funksiya yazilmalidir, hansi ki o groupId parametr qebul edir ve qrupun ortalama gpa qaytarir

CREATE FUNCTION ShowAvarageGPAOfGroup (@groupId INT)
RETURNS INT
AS
BEGIN
DECLARE @AVGGPA DECIMAL
SELECT @AVGGPA=AVG(s.GPA) FROM Groups g
JOIN StudentsGroups sg
ON g.Id=sg.GroupId
JOIN  Students s
ON sg.StudentId=s.Id
WHERE g.Id=@groupId
RETURN @AVGGPA
END

SELECT  dbo.ShowAvarageGPAOfGroup(3) AS AVGGPA
-----------------------------
SELECT * FROM StudentsGroups
SELECT * FROM Students
SELECT * FROM Groups

