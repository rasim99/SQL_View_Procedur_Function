CREATE DATABASE Company
USE Company

CREATE TABLE Departments(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(155) NOT NULL UNIQUE
)

CREATE TABLE Positions(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(155) NOT NULL UNIQUE,
Limit INT NOT NULL CHECK(Limit>0),
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Workers(
 Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(55) NOT NULL ,
Surname NVARCHAR(55) NOT NULL ,
PhoneNumber NVARCHAR(15) NOT NULL UNIQUE ,
Salary DECIMAL(8,2)  NOT NULL CHECK(Salary>=345),
BirthDate DATE NOT NULL,
PositionId INT FOREIGN KEY REFERENCES Positions(Id)
 )

 INSERT INTO Departments VALUES
 ('IT ve Proqramlasdirma'),
 ('Insan Resurslari'),
 ('Muhasibatliq'),
 ('Satish')

 INSERT INTO Positions VALUES
('Junior Developer',1,1),
('Middle Developer',1,1),
('Senior Developer',1,1),
('Help Desk',2,1),
(' Bash IR mutexesisi',1,2),
('Senedlesme mutexesisi',2,1),
('Kicik Emeliyyatchi',3,3),
('Aparici  Mutexesis',1,3),
(' Satici',6,4),
(' Bash Satici',4,4)

 INSERT INTO Workers VALUES
('Anar','Selimov','99411122334455',2340.34,'2000.01.01',1),
('Sahib','Xelilov','99412233445566',3050.25,'2002.11.01',2),
('Ekber','Memmedli','99415522274508',4500.49,'1999.12.25',3),
('Guler','Ezimzade','99410123455698',1200.04,'1998.03.01',4),
('Nezrin','Qulamova','99411922334475',1285.84,'2003.01.15',4),
('Sebuhi','Aydinov','9941002224477',2285.34,'2001.05.27',5),
('Letafet','Sebuhizade','9941777779845',850.54,'1999.01.19',6),
('Sefa','Sefayev','99415122334455',755.45,'1997.08.28',7),
('Islam','Sabirli','99409122334455',2744.34,'1999.03.17',8),
('Amil','Eliyev','99401122334455',455.74,'2001.11.22',9),
('Tahir','Isgenderov','994077122334455',455.74,'2003.02.23',9),
('Elvin','Nurlanli','99417002334455',455.74,'1995.05.30',9),
('Elnur','Musayev','99418122334455',900.14,'1996.06.06',10),
('Ayaz','Abbasov','99417122334455',900.14,'2004.04.04',10)


 SELECT * FROM Departments
 SELECT * FROM Positions
 SELECT * FROM Workers



-- a. Departamente gore iscilerin orta emek haqqisini getiren bir function yazilmalidir
CREATE OR ALTER FUNCTION WorkerAvarageSalaryOfDeparment (@DepartmentId INT)
RETURNS DECIMAL
AS
BEGIN
DECLARE @AvarageSalary DECIMAL
 SELECT @AvarageSalary=AVG(w.Salary) FROM Departments d
 JOIN Positions p
 ON d.Id=p.DepartmentId
 JOIN Workers w
 ON p.Id=w.PositionId
 WHERE d.Id=@DepartmentId
 RETURN @AvarageSalary
END
SELECT dbo.WorkerAvarageSalaryOfDeparment(1)
SELECT * from Workers

--b. Isci elave olunarken yasi check olunmalidir, 18den kicikdirse elave olunmamalidir, eks halda ise olunmalidir
--CREATE TRIGGER AddWorkerByGreater18 ON Workers
--INSTEAD OF INSERT
--AS
--BEGIN
--INSERT INTO Workers ([Name],Surname,PhoneNumber,Salary,BirthDate,PositionId)
--SELECT [Name],Surname,PhoneNumber,Salary ,BirthDate,PositionId FROM inserted
--WHERE BirthDate<DATEADD(YEAR,-18,GETDATE())
--IF @@ROWCOUNT=0
--BEGIN 
--RAISERROR('Yash 18den boyuk olmalidir',16,1)
--END
--END

---c. Position-a isci elave olunanda limit yoxlanilmalidir, limitden azdirsa elave olunmalidir, eks halda ise yox + --b. Isci elave olunarken yasi check olunmalidir, 
--18den kicikdirse elave olunmamalidir, eks halda ise olunmalidir

CREATE OR ALTER TRIGGER AddWorkerByPositionLimit ON  Workers
INSTEAD OF INSERT
AS
BEGIN
 DECLARE @PositionId INT
 DECLARE @Limit INT
 DECLARE @WorkerCount INT
 DECLARE @WorkerAge DATE

 SELECT @WorkerAge= i.BirthDate FROM inserted i

  SELECT @PositionId=i.PositionId
  FROM inserted i

  SELECT  @Limit=p.Limit
  FROM Positions p
  WHERE p.Id=@PositionId

  IF @WorkerAge > DATEADD(YEAR,-18,GETDATE())
  BEGIN 
 RAISERROR('Yash 18den boyuk olmalidir',16,1)
 END

   SELECT @WorkerCount=COUNT(*)  FROM Workers w
   WHERE  w.PositionId=@PositionId

    INSERT INTO Workers (Name,Surname,PhoneNumber,Salary,BirthDate,PositionId)
        SELECT Name,Surname,PhoneNumber,Salary,BirthDate,PositionId
        FROM inserted
		WHERE @WorkerCount<@Limit

		IF @@ROWCOUNT=0
		BEGIN
		RAISERROR('Limit kecildi!!',16,1)
		END
END
SELECT * from Workers