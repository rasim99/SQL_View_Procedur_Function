CREATE DATABASE MoviesApp
USE MoviesApp
CREATE TABLE Directors(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(50) NOT NULL,
Surame NVARCHAR(50) NOT NULL,
)

CREATE TABLE MovieLanguages(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Movies(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(50) NOT NULL,
[Description] NVARCHAR(50) NOT NULL,
CoverPhoto NVARCHAR (255) NOT NULL,
MovieLanguageId INT FOREIGN KEY REFERENCES MovieLanguages(Id)
)

CREATE TABLE DirectorsMovies(
Id INT PRIMARY KEY IDENTITY(1,1),
DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
MovieId INT FOREIGN KEY REFERENCES Movies(Id)
)

CREATE TABLE Actors(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(50) NOT NULL,
Surame NVARCHAR(50) NOT NULL,
)

CREATE TABLE ActorsMovies(
Id INT PRIMARY KEY IDENTITY(1,1),
ActorId INT FOREIGN KEY REFERENCES Actors(Id),
MovieId INT FOREIGN KEY REFERENCES Movies(Id)
)

CREATE TABLE Genres(
Id INT PRIMARY KEY IDENTITY(1,1),
[Name] NVARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE GenresMovies(
Id INT PRIMARY KEY IDENTITY(1,1),
GenreId INT FOREIGN KEY REFERENCES Genres(Id),
MovieId INT FOREIGN KEY REFERENCES Movies(Id)
)


INSERT INTO  Directors VALUES
('Emil','Quliyev'),
('Umit','Unal'),
('Yucel','Yolcu'),
('Omur','Atay'),
('Selim','Demirdelen'),
('Kudret','Sabanci'),
('Christopher','Nolan'),
('Sofia','Coppola'),
('Quentin','Tarantino')

INSERT INTO  MovieLanguages VALUES
('Azerbaycan'),
('Turk'),
('Rus'),
('Ingilis')

INSERT INTO  Movies VALUES
('Anlat Istanbul',' Turkish Film','photoIstanbul.png',2),
('Eqreb Movsumu','Azərbaycan serialı.','eqrebMovsumu.png',1),
('Oppenheimer','Oppenheimeris thriller drama film','Oppenheimer.png',4),
('The Godfather Part III','Dedektiv criminal film','TheGodfather.png',4)


INSERT INTO DirectorsMovies VALUES
(9,17),
(1,16),
(2,16),
(3,16),
(4,16),
(5,16),
(6,18),
(7,19)

INSERT INTO Genres VALUES
('Crime'),
('Thriller'),
('Historical'),
('Drama'),
('Dedectiv')

INSERT INTO GenresMovies VALUES
(4,16),(5,17),(2,17),
(2,18),(3,18),
(1,19),(2,19)

INSERT INTO Actors VALUES
('Altan','Erkekli'),('Mehmet','Gunsur'), ('Nejat','Isler'),('Erkan','Can'),
('Hikmet','Rehimov'),('Azer','Aydemir'),
('Cillian','Murphy'),('Florence','Pugh'),('Matt','Damon'),
('Al','Pacino'),('Sofia','Coppola'),('Andy','Garcia'),
('Test','Testov'),('Lorem','Ipsum')

INSERT INTO ActorsMovies VALUES
(1,16),(2,16),(3,16),(4,16),
(5,17),(6,17),
(7,18),(8,18),(9,18),
(10,19),(11,19),(12,19),
(13,16),(13,17),(13,18),(13,19),
(14,16),(14,17),(14,18),(14,19)


--1. Bir procedure yaradılmalıdır, hansı ki o procedure @directorId parametri gözləyir və 
--həmin proceduru execute etdikdə o həmin directorun filmlərini və o filmin hansı dildə olduğunu qaytarmalıdır. 

CREATE PROCEDURE up_GetDirectorsMoviesWithLanguage @directorid INT
AS
BEGIN
SELECT d.Name DirectorName,d.Surame DirectorSurname,
m.Name MovieName,ml.Name MovieLanguage
FROM Directors d
JOIN DirectorsMovies dm
ON d.Id=dm.DirectorId
JOIN Movies m
ON dm.MovieId=m.Id
JOIN MovieLanguages ml
ON m.MovieLanguageId=ml.Id
WHERE d.Id=@directorid
END
EXEC up_GetDirectorsMoviesWithLanguage @directorid=9
--/////
SELECT * FROM Movies

--2. Bir function yaradılmalıdır, hansı ki o function @languageId parametri gözləyir və həmin functionı çağırdıqda o həmin dildə olan
--filmlərin sayını qaytarmalıdır.
 CREATE FUNCTION ReturnMoviesCountOnLanguage (@languageId INT)
 RETURNS INT
 AS
 BEGIN
 DECLARE @moviesCount INT
 SELECT @moviesCount=COUNT(m.Id) FROM Movies m
 WHERE m.MovieLanguageId=@languageId
 RETURN @moviesCount
 END
 SELECT dbo.ReturnMoviesCountOnLanguage(4) AS MoviesCount

--3. Bir procedure yaradılmalıdır, hansı ki o procedure @genreId parametri gözləyir və həmin proceduru execute etdikdə
--o həmin janrda olan filmləri və o filmin rejissorunu qaytarmalıdır.

CREATE PROCEDURE up_GetMoviesWithGenresAndDirectorsByGenreId @genreId INT
AS
BEGIN 
SELECT m.Name Movie, g.Name Genre , d.Name DirectorName,d.Surame DirectorSurname
FROM Movies m
JOIN GenresMovies gm
ON m.Id=gm.MovieId
JOIN Genres g
ON gm.GenreId=g.Id
JOIN DirectorsMovies dm
ON  m.Id=dm.MovieId
JOIN Directors d
ON dm.DirectorId=d.Id
WHERE g.Id=@genreId
END

EXEC dbo.up_GetMoviesWithGenresAndDirectorsByGenreId @genreId=3
SELECT *FROM Genres

---4. Bir function yaradılmalıdır, hansı ki o function @actorId parametri gözləyir
--və həmin functionı çağırdıqda o aktyor 3 filmdən çox filmdə iştirak edibsə true, əks halda false qaytarmalıdır.

CREATE FUNCTION CheckMoviesCountOfActorByActorId (@actorId INT)
RETURNS BIT
AS
BEGIN
DECLARE @movieCount INT
SELECT @movieCount=COUNT(m.MovieId) FROM Actors a
JOIN ActorsMovies m
ON a.Id =m.ActorId
WHERE a.Id=@actorId;
RETURN  CASE WHEN @movieCount>3 THEN 1 ELSE 0 END
END

SELECT dbo.CheckMoviesCountOfActorByActorId(11) AS isTrue

--5. Bir trigger yaradılmalıdır, hansı ki yeni bir film insert edildikdən sonra bütün filmlər, 
--o filmlərin rejissorları və onun hansı dildə olduğu join olunmuş şəkildə göstərilməlidir.
 CREATE TRIGGER  ShowDetailsThenInsertData ON Movies
 AFTER INSERT
 AS
 BEGIN
 SELECT m.Name Movie, m.Description MovieDESC,ml.Name MovieLanguage,
 d.Name DirectorName,d.Surame DirectorSurname
 FROM  Movies m
 JOIN DirectorsMovies dm 
 ON m.Id=dm.MovieId
 JOIN Directors d
 ON d.Id=dm.DirectorId
 JOIN MovieLanguages ml
 ON ml.Id=m.MovieLanguageId
 END
 INSERT INTO Movies VALUES
 ('TestMovieNAme','desciptioon','testmovie.png',2)