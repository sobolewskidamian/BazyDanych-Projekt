CREATE TABLE Conferences (
    ConferenceID int NOT NULL IDENTITY,
    Name varchar(100) NOT NULL,
    Place varchar(100) NOT NULL,
    DiscountForStudents float NOT NULL DEFAULT 0,
    Description varchar(200) NOT NULL,
    CONSTRAINT ProperDiscountForStudents CHECK (DiscountForStudents >= 0 AND
        DiscountForStudents <= 100),
    CONSTRAINT ProperDescription CHECK (LEN(Description) > 5),
    CONSTRAINT Conferences_pk PRIMARY KEY (ConferenceID)
);
GO

CREATE TABLE ConferenceDays (
    ConferenceDayID int NOT NULL IDENTITY,
    Conferences_ConferenceID int NOT NULL,
    Date date NOT NULL,
    NumberOfParticipants int NOT NULL,
    CONSTRAINT PositiveNumberOfConferenceParticipants CHECK (NumberOfParticipants > 0),
    CONSTRAINT ConferenceDays_pk PRIMARY KEY (ConferenceDayID)
);
GO

CREATE TABLE ConferenceCosts (
    ConferenceCostID int NOT NULL IDENTITY,
    Conferences_ConferenceID int NOT NULL,
    Cost decimal(9,2) NOT NULL,
    DateFrom date NOT NULL,
    DateTo date NOT NULL,
    CONSTRAINT ProperDayDifferance CHECK (DateFrom <= DateTo),
    CONSTRAINT NonnegativeCostConf CHECK (Cost >= 0),
    CONSTRAINT ConferenceCosts_pk PRIMARY KEY (ConferenceCostID)
);
GO

CREATE TABLE Workshops (
    WorkshopID int NOT NULL IDENTITY,
    ConferenceDays_ConferenceDayID int NOT NULL,
    Name varchar(100) NOT NULL,
    StartTime date NOT NULL,
    EndTime date NOT NULL,
    Cost decimal(9,2) NOT NULL DEFAULT 0,
    NumberOfParticipants int NOT NULL DEFAULT 10,
    CONSTRAINT NonnegativeCostWorkshop CHECK (Cost >= 0),
    CONSTRAINT ProperTimeDifferance CHECK (StartTime <= EndTime),
    CONSTRAINT PosiviteWorkshopParticipants CHECK (NumberOfParticipants > 0),
    CONSTRAINT Workshops_pk PRIMARY KEY (WorkshopID)
);
GO

CREATE TABLE ConferenceBooking (
    ConferenceBookingID int NOT NULL IDENTITY,
    Clients_ClientID int NOT NULL,
    Conferences_ConferenceID int NOT NULL,
    BookingDate date NOT NULL DEFAULT getdate(),
    IsCanceled bit NOT NULL DEFAULT 0,
    CONSTRAINT ConferenceBooking_pk PRIMARY KEY (ConferenceBookingID)
);
GO

CREATE TABLE ConferenceDayBooking (
    ConferenceDayBookingID int NOT NULL IDENTITY,
    ConferenceBooking_ConferenceBookingID int NOT NULL,
    ConferenceDays_ConferenceDayID int NOT NULL,
    BookingDate date NOT NULL DEFAULT getdate(),
    IsCancelled bit NOT NULL DEFAULT 0,
    NumberOfParticipants int NOT NULL,
    NumberOfStudents int NOT NULL DEFAULT 0,
    CONSTRAINT PositiveNumberOfParticipants CHECK (NumberOfParticipants > 0),
    CONSTRAINT NonnegativeNumberOfStudents CHECK (NumberOfStudents >= 0),
    CONSTRAINT ProperNumberOfStudents CHECK (NumberOfParticipants >= NumberOfStudents),
    CONSTRAINT ConferenceDayBooking_pk PRIMARY KEY (ConferenceDayBookingID)
);
GO

CREATE TABLE WorkshopBooking (
    WorkshopBookingID int NOT NULL IDENTITY,
    Workshops_WorkshopID int NOT NULL,
    ConferenceDayBooking_ConferenceDayBookingID int NOT NULL,
    BookingDate date NOT NULL DEFAULT getdate(),
    NumberOfParticipants int NOT NULL,
    CONSTRAINT PositiveWorkshopNumberOfParticipants CHECK (NumberOfParticipants > 0),
    CONSTRAINT WorkshopBooking_pk PRIMARY KEY (WorkshopBookingID)
);
GO

CREATE TABLE Payments (
    PaymentID int NOT NULL IDENTITY,
    ConferenceBooking_ConferenceBookingID int NOT NULL,
    Amount decimal(9,2) NOT NULL,
    PayDate date NOT NULL DEFAULT getdate(),
    CONSTRAINT PositiveValue CHECK (Amount > 0),
    CONSTRAINT Payments_pk PRIMARY KEY (PaymentID)
);
GO

CREATE TABLE Participants (
    ParticipantID int NOT NULL IDENTITY,
    FirstName varchar(40) NOT NULL,
    LastName varchar(40) NOT NULL,
    Email varchar(100) NOT NULL,
    Street varchar(40) NOT NULL,
    City varchar(40) NOT NULL,
    PostalCode varchar(10) NOT NULL,
    County varchar(40) NOT NULL,
    CONSTRAINT Participants_pk PRIMARY KEY (ParticipantID)
);
GO

CREATE TABLE DayParticipants (
    DayParticipantID int NOT NULL IDENTITY,
    ConferenceDayBooking_ConferenceDayBookingID int NOT NULL,
    Participants_ParticipantID int NOT NULL,
    StudentID varchar(6) NULL DEFAULT null,
    CONSTRAINT DayParticipants_pk PRIMARY KEY (DayParticipantID)
);
GO

CREATE TABLE WorkshopParticipants (
    WorkshopParticipantID int NOT NULL IDENTITY,
    WorkshopBooking_WorkshopBookingID int NOT NULL,
    DayParticipants_DayParticipantID int NOT NULL,
    CONSTRAINT WorkshopParticipants_pk PRIMARY KEY (WorkshopParticipantID)
);
GO

CREATE TABLE Clients (
    ClientID int NOT NULL IDENTITY,
    IsCompany bit NOT NULL,
    Name varchar(100) NOT NULL,
    Surname varchar(100) NULL,
    Email varchar(100) NOT NULL,
    CONSTRAINT Clients_pk PRIMARY KEY (ClientID)
);
GO

ALTER TABLE ConferenceDays ADD CONSTRAINT Conferences_ConferenceDays FOREIGN KEY (Conferences_ConferenceID)
    REFERENCES Conferences (ConferenceID)
GO

ALTER TABLE ConferenceCosts ADD CONSTRAINT Conferences_ConferenceDay FOREIGN KEY (Conferences_ConferenceID)
    REFERENCES Conferences (ConferenceID)
GO

ALTER TABLE Workshops ADD CONSTRAINT Workshops_ConferenceDays FOREIGN KEY (ConferenceDays_ConferenceDayID)
    REFERENCES ConferenceDays (ConferenceDayID)
GO

ALTER TABLE ConferenceBooking ADD CONSTRAINT BookingConference_Clients FOREIGN KEY (Clients_ClientID)
  REFERENCES Clients (ClientID)
GO

ALTER TABLE ConferenceBooking ADD CONSTRAINT BookingConference_Conferences FOREIGN KEY (Conferences_ConferenceID)
    REFERENCES Conferences (ConferenceID)
GO

ALTER TABLE ConferenceDayBooking ADD CONSTRAINT ConferenceDayBooking_ConferenceBooking FOREIGN KEY (ConferenceBooking_ConferenceBookingID)
    REFERENCES ConferenceBooking (ConferenceBookingID)
GO

ALTER TABLE ConferenceDayBooking ADD CONSTRAINT ConferenceDayBooking_ConferenceDays FOREIGN KEY (ConferenceDays_ConferenceDayID)
    REFERENCES ConferenceDays (ConferenceDayID)
GO

ALTER TABLE WorkshopBooking ADD CONSTRAINT WorkshopBooking_ConferenceDayBooking FOREIGN KEY (ConferenceDayBooking_ConferenceDayBookingID)
    REFERENCES ConferenceDayBooking (ConferenceDayBookingID)
GO

ALTER TABLE WorkshopBooking ADD CONSTRAINT WorkshopBooking_Workshops FOREIGN KEY (Workshops_WorkshopID)
    REFERENCES Workshops (WorkshopID)
GO

ALTER TABLE Payments ADD CONSTRAINT Payments_ConferenceBooking FOREIGN KEY (ConferenceBooking_ConferenceBookingID)
    REFERENCES ConferenceBooking (ConferenceBookingID)
GO

ALTER TABLE DayParticipants ADD CONSTRAINT DayParticipants_ConferenceDayBooking FOREIGN KEY (ConferenceDayBooking_ConferenceDayBookingID)
    REFERENCES ConferenceDayBooking (ConferenceDayBookingID)
GO

ALTER TABLE DayParticipants ADD CONSTRAINT Participants_DayParticipants FOREIGN KEY (Participants_ParticipantID)
    REFERENCES Participants (ParticipantID)
GO

ALTER TABLE WorkshopParticipants ADD CONSTRAINT DayParticipants_WorkshopParticipants FOREIGN KEY (DayParticipants_DayParticipantID)
    REFERENCES DayParticipants (DayParticipantID)
GO

ALTER TABLE WorkshopParticipants ADD CONSTRAINT WorkshopParticipants_WorkshopBooking FOREIGN KEY (WorkshopBooking_WorkshopBookingID)
    REFERENCES WorkshopBooking (WorkshopBookingID)
GO


CREATE INDEX Client on Clients (ClientID ASC)
CREATE INDEX Client_ConferenceBooking on ConferenceBooking (Clients_ClientID ASC)
CREATE INDEX ConferenceBook on ConferenceDayBooking (ConferenceDayBookingID ASC)
CREATE INDEX ConferenceDay on ConferenceDayBooking (ConferenceDays_ConferenceDayID ASC)
CREATE INDEX NumberOfParticipantsInConferenceDay on ConferenceDays (NumberOfParticipants ASC)
CREATE INDEX Conference on ConferenceDays (Conferences_ConferenceID ASC)
CREATE INDEX Participant on DayParticipants (DayParticipantID ASC)
CREATE INDEX ConferenceDayBook on WorkshopBooking (ConferenceDayBooking_ConferenceDayBookingID ASC)
CREATE INDEX DayParticipant on WorkshopParticipants (DayParticipants_DayParticipantID ASC)
CREATE INDEX NumberOfParticipantsInWorkshop on Workshops (NumberOfParticipants ASC)
CREATE INDEX ConferenceDayID on Workshops (ConferenceDays_ConferenceDayID ASC)


create view view_MostPopularWorkshops as
select top 10 conf.name as ConferenceName,w.workshopid,w.name,isnull(sum(wp.workshopparticipantid),0) as popularnosc
from Workshops as w
inner join conferencedays as cd on cd.conferencedayid=w.ConferenceDays_ConferenceDayID
inner join conferences as conf on conf.conferenceid=cd.Conferences_ConferenceID
inner join WorkshopBooking as wb on wb.Workshops_WorkshopID=w.WorkshopID
inner join WorkshopParticipants as wp on wp.WorkshopBooking_WorkshopBookingID=wb.workshopbookingid
GROUP BY w.workshopid, w.name,conf.name
ORDER BY popularnosc DESC
GO

create view view_MostPopularConferences as
select top 10 c.ConferenceID,c.Name,isnull(sum(dp.DayParticipantID),0) as popularity
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID= cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
group by c.ConferenceID,c.Name
order by popularity desc
GO

create view view_MostPopularConferencesByStudents as
select top 10 c.ConferenceID,c.Name,isnull(sum(dp.DayParticipantID),0) as popularity
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID= cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
and dp.StudentID is not null
group by c.ConferenceID,c.Name
order by popularity desc
GO

create view view_MostPopularWorkshopsByStudents as
select top 10 conf.name as ConferenceName,w.workshopid,w.name,isnull(sum(wp.workshopparticipantid),0) as popularnosc
from Workshops as w
inner join conferencedays as cd on cd.conferencedayid=w.ConferenceDays_ConferenceDayID
inner join conferences as conf on conf.conferenceid=cd.Conferences_ConferenceID
inner join WorkshopBooking as wb on wb.Workshops_WorkshopID=w.WorkshopID
inner join WorkshopParticipants as wp on wp.WorkshopBooking_WorkshopBookingID=wb.workshopbookingid
inner join DayParticipants as dp on dp.DayParticipantID=wp.DayParticipants_DayParticipantID and
        dp.StudentID is not null
GROUP BY w.workshopid, w.name,conf.name
ORDER BY popularnosc DESC
GO

create view view_MostProfitableConference as
select top 10 c.ConferenceID,c.Name,cc.Cost+a.koszt as cena
from Conferences as c
inner join ConferenceCosts as cc on cc.Conferences_ConferenceID=c.ConferenceID
inner join (select con.ConferenceID, (
    select isnull(sum(w.Cost),0) as koszta
    from conferencedays as cd
    inner join Workshops as w on w.ConferenceDays_ConferenceDayID=cd.ConferenceDayID
    where cd.Conferences_ConferenceID=con.ConferenceID) as koszt
           from Conferences as con) as a on c.ConferenceID=a.ConferenceID
order by cena
GO

create view view_MostProfitableWorkshops as
select top 10 c.name as NazwaKonferencji,w.name,w.cost
from Workshops as w
inner join ConferenceDays as cd on cd.ConferenceDayID=w.ConferenceDays_ConferenceDayID
inner join Conferences as c on c.ConferenceID=cd.Conferences_ConferenceID
order by w.cost desc
GO

CREATE VIEW view_WorkshopsFreePlaces AS
SELECT
c.name as ConferenceName,
w.workshopid,
w.name,
w.numberofparticipants as Miejsca,
isnull ( SUM(wp.WorkshopParticipantID) , 0) as Zajete,
w.numberofparticipants - isnull ( SUM(wb.NumberOfParticipants) , 0) as WolneMiejsca
FROM workshops as w
JOIN WorkshopBooking as wb
ON wb.workshops_workshopid = w.workshopid
join WorkshopParticipants as wp
    on wp.WorkshopBooking_WorkshopBookingID=wb.WorkshopBookingID
JOIN conferencedays as cd
on cd.conferencedayid = w.conferencedays_conferencedayid
JOIN conferences as c on c.conferenceid = cd.conferences_conferenceid
GROUP BY w.workshopid, w.name, w.numberofparticipants,
c.name
GO

create view view_ConferenceFreePlaces as
select c.name,cd.Date,isnull(sum(dp.DayParticipantID),0) as Zajete,
       cdb.NumberOfParticipants as Miejsca,cdb.NumberOfParticipants-isnull(sum(dp.DayParticipantID),0) as WolneMiejsca
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID=cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
group by c.Name,cd.Date,cdb.NumberOfParticipants
GO

CREATE VIEW view_AvailableConferenceDays AS
SELECT cdp.*
FROM VIEW_ConferenceFreePlaces cdp
WHERE WolneMiejsca > 0
GO

CREATE VIEW view_AvailableWorkshops AS
SELECT w.*
FROM view_WorkshopsFreePlaces w
WHERE WolneMiejsca > 0
GO

CREATE VIEW view_ClientsActivity AS
SELECT
c.*,
isnull((SELECT COUNT(*)
FROM conferencebooking as cb
WHERE cb.clients_clientid = c.ClientID), 0) as Bookings,
isnull((SELECT SUM(p.amount)
FROM conferencebooking as cb
JOIN payments as p ON cb.ConferenceBookingID =
p.ConferenceBooking_ConferenceBookingID
WHERE cb.clients_clientid = c.ClientID), 0) as Payments
FROM Clients as c
GO

CREATE view view_MostProfitableClients AS
SELECT top 10 c.*
FROM view_ClientsActivity c
ORDER BY Payments
GO

CREATE PROCEDURE PROCEDURE_AddConference(
 @Name VARCHAR(100),
 @Place VARCHAR(100),
 @DiscountForStudents FLOAT,
 @Description VARCHAR(200))
 AS
BEGIN
 INSERT INTO Conferences (Name, Place, DiscountForStudents, Description)
 VALUES (@Name, @Place, @DiscountForStudents, @Description);
END
GO

CREATE PROCEDURE PROCEDURE_AddConferenceDay(
 @ConferenceID INT,
 @Date DATE,
 @NumberOfParticipants INT)
 AS
BEGIN
 INSERT INTO ConferenceDays (Conferences_ConferenceID, Date, NumberOfParticipants)
 VALUES (@ConferenceID, @Date, @NumberOfParticipants);
END
GO


CREATE PROCEDURE PROCEDURE_AddWorkshop(
 @ConferenceDayID INT,
 @Name VARCHAR(100),
 @StartTime DATE,
 @EndTime DATE,
 @Cost DECIMAL(9,2),
 @NumberOfParticipants INT)
 AS
BEGIN
 INSERT INTO Workshops (ConferenceDays_ConferenceDayID, Name, StartTime, EndTime, Cost, NumberOfParticipants)
 VALUES (@ConferenceDayID, @Name, @StartTime, @EndTime, @Cost, @NumberOfParticipants);
END
GO


CREATE PROCEDURE PROCEDURE_AddConferenceCost(
 @ConferenceID INT,
 @Cost DECIMAL(9,2),
 @DateFrom DATE,
 @DateTo DATE)
 AS
BEGIN
 INSERT INTO ConferenceCosts (Conferences_ConferenceID, Cost, DateFrom, DateTo)
 VALUES (@ConferenceID, @Cost, @DateFrom, @DateTo);
END
GO


CREATE PROCEDURE PROCEDURE_RemoveConference(
 @ConferenceID INT)
 AS
IF NOT EXISTS(
 SELECT * FROM Conferences
 WHERE @ConferenceID = ConferenceID
)
BEGIN
 THROW 50000, 'Nie znaleziono konferencji',1
END

ELSE

BEGIN
 DELETE FROM Conferences
 WHERE Conferences.ConferenceID = @ConferenceID;
END
GO


CREATE PROCEDURE PROCEDURE_UpdateConferenceDetails(
 @ConferenceID INT,
 @Name VARCHAR(100),
 @Place VARCHAR(100),
 @DiscountForStudents FLOAT,
 @Description VARCHAR(200))
 AS
BEGIN
 IF NOT EXISTS(
  SELECT * FROM Conferences
  WHERE @ConferenceID = ConferenceID
 )
 BEGIN
  THROW 50000, 'Nie znaleziono konferencji',1
 END

 ELSE

 BEGIN
  IF @Name IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Name = @Name
   WHERE ConferenceID = @ConferenceID;
  END
  ELSE
   BEGIN
    THROW 50000, 'ConferenceID is null',1
   END
  IF @DiscountForStudents IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET DiscountForStudents = @DiscountForStudents
   WHERE ConferenceID = @ConferenceID;
  END
  ELSE
   BEGIN
    THROW 50000, 'DiscountForStudents is null',1
   END
  IF @Place IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Place = @Place
   WHERE ConferenceID = @ConferenceID;
  END
  ELSE
   BEGIN
    THROW 50000, 'Place is null',1
   END
  IF @Description IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Description = @Description
   WHERE ConferenceID = @ConferenceID;
  END
  ELSE
   BEGIN
    THROW 50000, 'Description is null',1
   END
 END
END
GO


CREATE PROCEDURE PROCEDURE_UpdateWorkshopDetails(
 @WorkshopID INT,
 @Name VARCHAR(100),
 @StartTime DATE,
 @EndTime DATE,
 @Cost DECIMAL(9,2),
 @NumberOfParticipants INT)
 AS
 BEGIN
 IF NOT EXISTS(
  SELECT * FROM Workshops
  WHERE @WorkshopID = WorkshopID
 )
  BEGIN
  THROW 50000, 'Nie znaleziono warsztatu',1
 END

 ELSE

 BEGIN
  IF @Name IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET Name = @Name
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   THROW 50000, 'WorkshopID is null',1
  END
  IF @StartTime IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET StartTime = @StartTime
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   THROW 50000, 'StartTime is null',1
  END
  IF @EndTime IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET EndTime = @EndTime
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   THROW 50000, 'EndTime is null',1
  END
  IF @Cost IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET Cost = @Cost
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   THROW 50000, 'Cost is null',1
  END
  IF @NumberOfParticipants IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET NumberOfParticipants = @NumberOfParticipants
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   THROW 50000, 'NumberOfParticipants is null',1
  END
 END
END
GO


CREATE PROCEDURE PROCEDURE_AddConferenceBooking(
 @ConferenceID INT,
 @ClientID INT,
 @BookingDate DATE)
 AS
BEGIN
 IF NOT EXISTS(
  SELECT * FROM Conferences
  WHERE @ConferenceID = ConferenceID
 )
  BEGIN
  THROW 50000, 'Nie znaleziono konferencji',1
 END

 ELSE

 BEGIN
 IF @BookingDate IS NULL
  BEGIN
   INSERT INTO ConferenceBooking (Conferences_ConferenceID, Clients_ClientID)
   VALUES (@ConferenceID, @ClientID);
  END
 ELSE
  BEGIN
   INSERT INTO ConferenceBooking (Conferences_ConferenceID, BookingDate, Clients_ClientID)
   VALUES (@ConferenceID, @BookingDate, @ClientID);
  END
 END
END
GO


CREATE PROCEDURE PROCEDURE_AddConferenceDayBooking(
 @ConferenceDayID INT,
 @ConferenceBookingID INT,
 @NumberOfParticipants INT,
 @NumberOfStudents INT)
 AS
BEGIN
 IF NOT EXISTS(
  SELECT * FROM ConferenceDays
  WHERE @ConferenceDayID = ConferenceDayID
 ) OR NOT EXISTS(
  SELECT * FROM ConferenceBooking
  WHERE @ConferenceBookingID = ConferenceBookingID
 )
  BEGIN
  THROW 50000, 'Nie znaleziono ConferenceDayID lub ConferenceBookingID',1
 END

 ELSE

 BEGIN
 IF @NumberOfStudents IS NULL
  BEGIN
   INSERT INTO ConferenceDayBooking (ConferenceDays_ConferenceDayID, ConferenceBooking_ConferenceBookingID, NumberOfParticipants)
   VALUES (@ConferenceDayID, @ConferenceBookingID, @NumberOfParticipants);
  END
 ELSE
  BEGIN
   INSERT INTO ConferenceDayBooking (ConferenceDays_ConferenceDayID, ConferenceBooking_ConferenceBookingID, NumberOfParticipants, NumberOfStudents)
   VALUES (@ConferenceDayID, @ConferenceBookingID, @NumberOfParticipants, @NumberOfStudents);
  END
 END
END
GO


CREATE PROCEDURE PROCEDURE_AddWorkshopBooking(
 @WorkshopID INT,
 @ConferenceDayBookingID INT,
 @BookingDate DATE,
 @NumberOfParticipants INT)
 AS
BEGIN
 IF NOT EXISTS(
  SELECT * FROM Workshops
  WHERE @WorkshopID = WorkshopID
 ) OR NOT EXISTS(
  SELECT * FROM ConferenceDayBooking
  WHERE @ConferenceDayBookingID = ConferenceDayBookingID
 )
  BEGIN
  THROW 50000, 'Nie znaleziono WorkshopID lub ConferenceDayBookingID',1
 END

 ELSE

 BEGIN
 IF @BookingDate IS NULL
  BEGIN
   INSERT INTO WorkshopBooking (Workshops_WorkshopID, ConferenceDayBooking_ConferenceDayBookingID, NumberOfParticipants)
   VALUES (@WorkshopID, @ConferenceDayBookingID, @NumberOfParticipants);
  END
 ELSE
  BEGIN
   INSERT INTO WorkshopBooking (Workshops_WorkshopID, ConferenceDayBooking_ConferenceDayBookingID, BookingDate, NumberOfParticipants)
   VALUES (@WorkshopID, @ConferenceDayBookingID, @BookingDate, @NumberOfParticipants);
  END
 END
END
GO


CREATE PROCEDURE PROCEDURE_AddDayParticipant(
 @ConferenceDayBookingID INT,
 @ParticipantID INT,
 @StudentID VARCHAR(6))
 AS
BEGIN
  IF NOT EXISTS(
   SELECT * FROM ConferenceDayBooking
   WHERE @ConferenceDayBookingID = ConferenceDayBookingID
  )
  BEGIN
   THROW 50000, 'Nie znaleziono ConferenceDayBookingID',1
  END

  ELSE

  BEGIN
   IF NOT EXISTS(
    SELECT * FROM Participants
    WHERE @ParticipantID = ParticipantID
   )
   BEGIN
    THROW 50000, 'Nie znaleziono ParticipantID',1
   END

   ELSE

   BEGIN
    INSERT INTO DayParticipants (ConferenceDayBooking_ConferenceDayBookingID, Participants_ParticipantID, StudentID)
    VALUES (@ConferenceDayBookingID, @ParticipantID, @StudentID);
   END
  END
END
GO


CREATE PROCEDURE PROCEDURE_AddWorkshopParticipant(
 @WorkshopBookingID INT,
 @DayParticipantID INT)
 AS
BEGIN
  IF NOT EXISTS(
   SELECT * FROM WorkshopBooking
   WHERE @WorkshopBookingID = WorkshopBookingID
  )
  BEGIN
   THROW 50000, 'Nie znaleziono WorkshopBookingID',1
  END

  ELSE

  BEGIN
   IF NOT EXISTS(
    SELECT * FROM Participants
    WHERE @DayParticipantID = ParticipantID
   )
   BEGIN
    THROW 50000, 'Nie znaleziono ParticipantID',1
   END

   ELSE

   BEGIN
    INSERT INTO WorkshopParticipants (WorkshopBooking_WorkshopBookingID, DayParticipants_DayParticipantID)
    VALUES (@WorkshopBookingID, @DayParticipantID);
   END
  END
END
GO


CREATE PROCEDURE PROCEDURE_AddParticipant(
 @FirstName VARCHAR(40),
 @LastName VARCHAR(40),
 @Email VARCHAR(100),
 @Street VARCHAR(40),
 @City VARCHAR(40),
 @PostalCode VARCHAR(10),
 @Country VARCHAR(40))
 AS
BEGIN
 INSERT INTO Participants (FirstName, LastName, Email, Street, City, PostalCode, County)
 VALUES (@FirstName, @LastName, @Email, @Street, @City, @PostalCode, @Country);
END
GO


CREATE PROCEDURE PROCEDURE_AddClient(
 @IsCompany BIT,
 @Name VARCHAR(100),
 @Surname VARCHAR(100),
 @Email VARCHAR(100))
 AS
BEGIN
 INSERT INTO Clients (IsCompany, Name, Surname, Email)
 VALUES (@IsCompany, @Name, @Surname, @Email);
END
GO


CREATE PROCEDURE PROCEDURE_CancelConferenceBooking(
 @ConferenceBookingID INT)
 AS
BEGIN
 IF NOT EXISTS(
   SELECT * FROM ConferenceBooking
   WHERE @ConferenceBookingID = ConferenceBookingID
 )
 OR NOT (SELECT IsCanceled FROM ConferenceBooking WHERE @ConferenceBookingID = ConferenceBookingID)=0
 BEGIN
  THROW 50000, 'Nie znaleziono ConferenceBookingID lub rezerwacja została już wcześniej anulowana',1
 END

 ELSE

 BEGIN
  UPDATE ConferenceBooking
  SET IsCanceled = 1
  WHERE @ConferenceBookingID = ConferenceBookingID;
 END
 BEGIN
  UPDATE ConferenceDayBooking
  SET IsCancelled = 1
  WHERE @ConferenceBookingID = ConferenceBooking_ConferenceBookingID;
 END
END
GO


CREATE PROCEDURE PROCEDURE_CancelConferenceDayBooking(
 @ConferenceDayBookingID INT)
 AS
BEGIN
 IF NOT EXISTS(
   SELECT * FROM ConferenceDayBooking
   WHERE @ConferenceDayBookingID = ConferenceDayBookingID
 )
 OR NOT (SELECT IsCancelled FROM ConferenceDayBooking WHERE @ConferenceDayBookingID = ConferenceDayBookingID)=0
 BEGIN
  THROW 50000, 'Nie znaleziono ConferenceDayBookingID lub rezerwacja została już wcześniej anulowana',1
 END

 ELSE

 BEGIN
  UPDATE ConferenceDayBooking
  SET IsCancelled = 1
  WHERE @ConferenceDayBookingID = ConferenceDayBookingID;
 END
END
GO



CREATE PROCEDURE PROCEDURE_UpdateWorkShopNumberOfParticipants(
 @WorkshopID INT,
 @NumberOfParticipants INT)
 AS
BEGIN
 IF NOT EXISTS(
   SELECT * FROM Workshops
   WHERE @WorkshopID = WorkshopID
 )
 BEGIN
  THROW 50000, 'Nie znaleziono WorkshopID',1
 END

 ELSE

 BEGIN
  UPDATE Workshops
  SET NumberOfParticipants = @NumberOfParticipants
  WHERE @WorkshopID = WorkshopID;
 END
END
GO


CREATE PROCEDURE PROCEDURE_UpdateConferenceDayNumberOfParticipants(
 @ConferenceDayID INT,
 @NumberOfParticipants INT)
 AS
BEGIN
 IF NOT EXISTS(
   SELECT * FROM ConferenceDays
   WHERE @ConferenceDayID = ConferenceDayID
 )
 BEGIN
  THROW 50000, 'Nie znaleziono ConferenceDayID',1
 END

 ELSE

 BEGIN
  UPDATE ConferenceDays
  SET NumberOfParticipants = @NumberOfParticipants
  WHERE @ConferenceDayID = ConferenceDayID;
 END
END
GO


CREATE PROCEDURE PROCEDURE_ShowConferenceDaysAmountOfParticipants(
 @ConferenceID INT)
 AS
BEGIN
 IF EXISTS(
   SELECT * FROM Conferences
   WHERE @ConferenceID = ConferenceID
 )
 BEGIN
  THROW 50000, 'Nie znaleziono ConferenceID',1
 END

 ELSE

 BEGIN
  SELECT ConferenceDayID, Date, SUM(ConferenceDayBooking.NumberOfParticipants) AS Participants, SUM(NumberOfStudents) as Students FROM ConferenceDays
  INNER JOIN ConferenceDayBooking
      ON Conferences_ConferenceID = ConferenceDays_ConferenceDayID
  WHERE Conferences_ConferenceID = @ConferenceID AND IsCancelled = 0
  GROUP BY ConferenceDayID, Date
 END
END
GO



CREATE PROCEDURE PROCEDURE_ShowListOfEventsOfConference(
 @ConferenceID INT)
 AS
BEGIN
 IF EXISTS(
   SELECT * FROM Conferences
   WHERE @ConferenceID = ConferenceID
 )
 BEGIN
  THROW 50000, 'Nie znaleziono ConferenceID',1
 END

 ELSE

 BEGIN
  SELECT ConferenceDayID, Date, SUM(ConferenceDayBooking.NumberOfParticipants) AS Participants, SUM(NumberOfStudents) as Students FROM ConferenceDays
  INNER JOIN ConferenceDayBooking
      ON ConferenceDayID = ConferenceDays_ConferenceDayID
  WHERE Conferences_ConferenceID = @ConferenceID AND IsCancelled = 0
  GROUP BY ConferenceDayID, Date
 END
END
GO


CREATE PROCEDURE PROCEDURE_CancelConferenceBookingWithoutPayingAfterSevenDays
 AS
BEGIN
UPDATE ConferenceBooking
SET IsCanceled=1
 FROM(
 SELECT * FROM ConferenceBooking
 LEFT JOIN Payments
     ON ConferenceBookingID=ConferenceBooking_ConferenceBookingID
 WHERE IsCanceled=0 AND PaymentID IS NULL AND DATEDIFF(DAY, BookingDate, getdate())>7) as a
WHERE ConferenceBooking.ConferenceBookingID=a.ConferenceBookingID
END
 BEGIN
 UPDATE ConferenceDayBooking
SET IsCancelled=1
 FROM(
 SELECT ConferenceDayBookingID AS ID FROM ConferenceBooking
 INNER JOIN ConferenceDayBooking
     on ConferenceBookingID=ConferenceBooking_ConferenceBookingID
 WHERE ConferenceBooking.IsCanceled=1 AND ConferenceDayBooking.IsCancelled=0) as b
WHERE ConferenceDayBookingID=b.ID
END
GO

create function FUNCTION_FreeDayPlacesForParticipants(
@ConferenceDayID INTEGER
)
RETURNS INTEGER AS
BEGIN
RETURN (
SELECT cdb.numberofparticipants - isnull(SUM(dp.DayParticipantID), 0)
FROM conferencedays as cd
LEFT JOIN ConferenceDayBooking as cdb ON cd.conferencedayid =
cdb.conferencedays_conferencedayid
left join DayParticipants as dp on
dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
WHERE cd.conferencedayid = @ConferenceDayID and dp.StudentID is null
GROUP BY cd.conferencedayid, cdb.numberofparticipants
);
END;
GO

create function FUNCTION_FreeDayPlacesForStudents(
@ConferenceDayID INTEGER
)
RETURNS INTEGER AS
BEGIN
RETURN (
SELECT cdb.NumberOfStudents - isnull(SUM(dp.DayParticipantID), 0)
FROM conferencedays as cd
LEFT JOIN ConferenceDayBooking as cdb ON cd.conferencedayid =
cdb.conferencedays_conferencedayid
left join DayParticipants as dp on
dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
WHERE cd.conferencedayid = @ConferenceDayID and dp.StudentID is not null
GROUP BY cd.conferencedayid, cdb.NumberOfStudents
);
END;
GO

create function FUNCTION_FreeDayPlaces(
@ConferenceDayID INTEGER
)
RETURNS INTEGER AS
BEGIN
RETURN (dbo.FUNCTION_FreeDayPlacesForParticipants(@ConferenceDayID)+dbo.FUNCTION_FreeDayPlacesForStudents(@ConferenceDayID));
END;
GO

create function FUNCTION_FreeWorkshopPlaces(
@WorkShopID INTEGER
)
RETURNS INTEGER AS
BEGIN
RETURN (
SELECT w.numberofparticipants - isnull(SUM(wp.workshopparticipantid), 0)
FROM Workshops as w
LEFT JOIN WorkshopBooking as wb ON wb.Workshops_WorkshopID=
w.WorkshopID
left join WorkshopParticipants as wp on
wp.WorkshopBooking_WorkshopBookingID=wb.WorkshopBookingID
WHERE w.WorkshopID = @WorkShopID
GROUP BY w.WorkshopID, w.numberofparticipants
);
END;
GO

create function FUNCTION_DaysOfConference(
@ConferenceID INTEGER
)
returns @days table
(ConferenceDayID INT) as
    begin
        insert into @days
        select cd.ConferenceDayID
        from ConferenceDays as cd
        where cd.Conferences_ConferenceID=@ConferenceID
        return;
    end
GO

create function FUNCTION_ConferenceDayParticipants(
@ConferenceDayID INT
)
returns @Participants TABLE(
firstname VARCHAR(40),
lastname VARCHAR(40),
email VARCHAR(100),
county varchar(40),
city varchar(40),
street varchar(40),
postalcode varchar(10))
    as begin
    insert into @Participants
    select p.firstname,p.lastname,p.email,p.county,p.city,p.Street,p.PostalCode
    from Participants as p
    inner join DayParticipants as dp on
            dp.Participants_ParticipantID=p.ParticipantID
    inner join ConferenceDayBooking as cdb on
            cdb.ConferenceDayBookingID=dp.ConferenceDayBooking_ConferenceDayBookingID
    where cdb.ConferenceDays_ConferenceDayID=@ConferenceDayID
    and cdb.IsCancelled=0
    return
end
GO

create function FUNCTION_WorkshopsPerConference(
@ConferenceID INT
) returns @Workshop table(
workshopID int,
name varchar(100),
starttime date,
endtime date,
cost decimal(9,2),
numberofparticipants int
) as begin
    insert into @Workshop
    select w.workshopid,w.name,w.StartTime,w.EndTime,w.cost,w.NumberOfParticipants
    from Workshops as w
    inner join ConferenceDays as cd on
            cd.ConferenceDayID=w.ConferenceDays_ConferenceDayID
    where cd.Conferences_ConferenceID=@ConferenceID
    return
end
GO

create function FUNCTION_WorkshopDate(
@WorkshopID INT
) returns @WShop table(
workshopID INT,
name varchar(100),
startime date,
endtime date
) as begin
    insert into @WShop
    select workshopid,name,StartTime,EndTime
    from Workshops
    where WorkshopID=@WorkshopID
    return
end
GO

CREATE FUNCTION FUNCTION_BookingDaysCost(
@ConferenceBookingID INTEGER
)
RETURNS decimal(9,2) AS
BEGIN
RETURN (
SELECT SUM(cdb.numberofparticipants * cc.cost +
cdb.numberofstudents * cc.cost * (1.00 - c.discountforstudents))
FROM ConferenceDayBooking cdb
JOIN conferencebooking cb ON cdb.ConferenceBooking_ConferenceBookingID=
cb.ConferenceBookingID
JOIN conferences c ON cb.conferences_conferenceid = c.conferenceid
JOIN conferencecosts cc
ON c.conferenceid = cc.conferences_conferenceid
WHERE cb.conferencebookingid = @ConferenceBookingID
GROUP BY cb.conferencebookingid
);
END;
GO

CREATE FUNCTION FUNCTION_BookingWorkshopCost(
@ConferenceBookID INTEGER
)
RETURNS decimal(9,2) AS
BEGIN
RETURN (
SELECT isnull(SUM(wb.numberofparticipants * w.cost), 0)
FROM ConferenceBooking cb
LEFT JOIN conferencedaybooking cdb ON cb.conferencebookingid =
cdb.ConferenceBooking_ConferenceBookingID
LEFT JOIN workshopbooking wb ON cdb.conferencedaybookingid =
wb.conferencedaybooking_conferencedaybookingid
LEFT JOIN workshops w ON wb.workshops_workshopid = w.workshopid
WHERE cb.conferencebookingid = @ConferenceBookID
GROUP BY cb.conferencebookingid
);
END;
GO

CREATE FUNCTION FUNCTION_TotalBookingCost(
@ConferenceBookID INTEGER
)
RETURNS decimal(9,2) AS
BEGIN
RETURN (
SELECT dbo.FUNCTION_BookingDaysCost(bs.conferencebookingid) +
dbo.FUNCTION_BookingWorkshopCost(bs.conferencebookingid)
FROM conferencebooking bs
WHERE bs.conferencebookingid = @ConferenceBookID
);
END;
GO

CREATE FUNCTION FUNCTION_WorkshopListForParticipant(
@Participant INT)
RETURNS @table TABLE(workshopid INT, Name VARCHAR(100)) AS
BEGIN
insert into @table
SELECT
w.workshopid,w.name
FROM participants as p
JOIN dayparticipants as dp ON p.participantid =
dp.participants_participantid
JOIN workshopparticipants as wp
ON dp.dayparticipantid =
wp.dayparticipants_dayparticipantid
JOIN WorkshopBooking as wb ON wp.WorkshopBooking_WorkshopBookingID=
wb.workshopbookingid
JOIN workshops as w ON wb.workshops_workshopid = w.workshopid
WHERE p.participantid = @Participant
return
END
GO

CREATE FUNCTION FUNCTION_ConferencesDaysListForParticipant(
@Participant INT)
RETURNS @table TABLE(name varchar(100),place varchar(100),date date) AS
BEGIN
insert into @table
SELECT
c.name,c.place,cd.date
FROM participants as p
JOIN dayparticipants as dp ON p.participantid =
dp.participants_participantid
JOIN ConferenceDayBooking as cdb
ON cdb.ConferenceDayBookingID=dp.ConferenceDayBooking_ConferenceDayBookingID
JOIN ConferenceDays as cd ON cd.ConferenceDayID=cdb.ConferenceDays_ConferenceDayID
JOIN Conferences as c ON c.ConferenceID=cd.Conferences_ConferenceID
WHERE p.participantid = @Participant
return
END
GO

create function FUNCTION_ClientsOrdersList(
@ClientID INT
) returns @table table(conferenceid int, name varchar(100),place varchar(100)) as
    begin
        insert into @table
        select c.ConferenceID,c.name,c.place
        from Conferences as c
        join ConferenceBooking as cb on cb.Conferences_ConferenceID=c.ConferenceID
        join Clients as cl on cl.ClientID=cb.Clients_ClientID
        where cl.ClientID=@ClientID
        return
    end
    GO

CREATE TRIGGER TRIGGER_TooFewFreePlacesForDayBooking
  ON ConferenceDayBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM inserted as a WHERE dbo.FUNCTION_FreeDayPlaces(a.ConferenceDays_ConferenceDayID) < 0)
      BEGIN
        SELECT 'Brak wystarczajacej liczby miejsc w dniu konferencji'
      END
  END
  GO

CREATE TRIGGER TRIGGER_TooFewFreePlacesForWorkshopBooking
  ON WorkshopBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM inserted as a WHERE dbo.FUNCTION_FreeWorkshopPlaces(a.Workshops_WorkshopID) < 0)
      BEGIN
        SELECT 'Brak wystarczajacej liczby miejsc w warsztacie'
      END
  END
  GO

CREATE TRIGGER TRIGGER_LessPlacesForDayThanForWorkshop
  ON ConferenceDayBooking
  AFTER INSERT, UPDATE
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT * FROM inserted AS a WHERE dbo.FUNCTION_FreeDayPlaces(a.ConferenceDays_ConferenceDayID) < 0)
      BEGIN
        SELECT 'Klient zarezerwował mniej miejsc na dzień niż na warsztat'
      END
  END
  GO

CREATE TRIGGER TRIGGER_NotEnoughBookedPlacesForDay
  ON DayParticipants
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
              WHERE (a.StudentID IS NULL
                       AND dbo.FUNCTION_FreeDayPlacesForStudents(a.ConferenceDayBooking_ConferenceDayBookingID) < 0)
                 OR (a.StudentID IS NULL
                       AND dbo.FUNCTION_FreeDayPlacesForParticipants(a.ConferenceDayBooking_ConferenceDayBookingID) < 0))
      BEGIN
        SELECT 'Wszystkie miejsca klienta zostały już zarezerwowane'
      END
  END
  GO

CREATE TRIGGER TRIGGER_NotEnoughBookedPlacesForWorkshop
  ON WorkshopParticipants
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
              WHERE dbo.FUNCTION_FreeWorkshopPlaces(a.WorkshopBooking_WorkshopBookingID) < 0)
      BEGIN
        SELECT 'Wszystkie zarezerwowane miejsca są już zajęte'
      END
  END
  GO

CREATE TRIGGER TRIGGER_TooFewPlacesAfterDecreasingDayCapacity
  ON ConferenceDays
  AFTER UPDATE
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
                     LEFT JOIN ConferenceDayBooking AS cdb ON cdb.ConferenceDays_ConferenceDayID = a.ConferenceDayID
              GROUP BY a.ConferenceDayID, a.NumberOfParticipants
              HAVING a.NumberOfParticipants < SUM(cdb.NumberOfParticipants) + SUM(cdb.NumberOfStudents))
      BEGIN
        SELECT 'Po zmniejszeniu liczby miejsc na dzień konferencji zarezerwowane miejsca nie mieszczą się w nowym limicie'
      END
  END
  GO

CREATE TRIGGER TRIGGER_TooFewPlacesAfterDecreasingWorkshopCapacity
  ON Workshops
  AFTER UPDATE
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
                     LEFT JOIN WorkshopBooking AS wb ON wb.Workshops_WorkshopID = a.WorkshopID
              GROUP BY a.WorkshopID, a.NumberOfParticipants
              HAVING a.NumberOfParticipants < SUM(wb.NumberOfParticipants))
      BEGIN
        SELECT 'Po zmniejszeniu liczby miejsc na warsztat zarezerwowane miejsca nie mieszczą się w nowym limicie'
      END
  END
  GO

CREATE TRIGGER TRIGGER_BookingDayInDifferentConference
  ON ConferenceDayBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
                     INNER JOIN ConferenceDays AS cd ON cd.ConferenceDayID = a.ConferenceDays_ConferenceDayID
                     INNER JOIN Conferences AS c1 ON c1.ConferenceID = cd.Conferences_ConferenceID
                     INNER JOIN ConferenceBooking AS cb
                       ON cb.ConferenceBookingID = a.ConferenceBooking_ConferenceBookingID
                     INNER JOIN Conferences AS c2 ON c2.ConferenceID = cb.Conferences_ConferenceID
              WHERE c1.ConferenceID != c2.ConferenceID)
      BEGIN
        SELECT 'Klient próbuje przepisać do konferencji rezerwację dnia z innej konferencji'
      END
  END
  GO

CREATE TRIGGER TRIGGER_BookingDayAlreadyExists
  ON ConferenceDayBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
                     LEFT JOIN ConferenceDayBooking AS cbd
                       ON a.ConferenceBooking_ConferenceBookingID = cbd.ConferenceBooking_ConferenceBookingID
                            AND a.ConferenceDays_ConferenceDayID = cbd.ConferenceDays_ConferenceDayID
              WHERE a.ConferenceBooking_ConferenceBookingID != cbd.ConferenceBooking_ConferenceBookingID)
      BEGIN
        SELECT 'Rezerwacja danego dnia konferencji już istnieje'
      END
  END
GO

CREATE TRIGGER TRIGGER_BookingWorkshopInDifferentDay
  ON WorkshopBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
                     INNER JOIN Workshops AS w ON w.WorkshopID = a.Workshops_WorkshopID
                     INNER JOIN ConferenceDays AS cd1 ON cd1.ConferenceDayID = w.ConferenceDays_ConferenceDayID
                     INNER JOIN ConferenceDayBooking AS cdb
                       ON cdb.ConferenceDayBookingID = a.ConferenceDayBooking_ConferenceDayBookingID
                     INNER JOIN ConferenceDays AS cd2 ON cd2.ConferenceDayID = cdb.ConferenceDays_ConferenceDayID
              WHERE cd1.Conferences_ConferenceID != cd2.Conferences_ConferenceID)
      BEGIN
        SELECT 'Klient próbuje przypisać się do warsztatu z innego dnia niż jego rezerwacja'
      END
  END
  GO

CREATE TRIGGER TRIGGER_ArePriceThresholdsMonotonous
  ON ConferenceCosts
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    DECLARE @Cost DECIMAL(9, 2) = (SELECT a.Cost FROM inserted AS a);
    IF EXISTS(SELECT *
              FROM inserted AS a
                     LEFT JOIN ConferenceCosts AS cc on a.Conferences_ConferenceID = cc.Conferences_ConferenceID
              WHERE ((cc.DateFrom < a.DateFrom AND a.DateFrom < cc.dateto)
                       OR (a.DateFrom < cc.DateFrom AND cc.DateTo < a.DateTo)
                       OR (cc.DateFrom >= a.DateFrom AND a.DateTo >= cc.DateTo)
                       OR (a.DateFrom >= cc.DateFrom AND cc.DateTo >= a.DateTo))
                AND cc.ConferenceCostID != a.ConferenceCostID)
      BEGIN
        SELECT 'Koszt pokrywa się z istniejącymi kosztami'
      END
    ELSE
      BEGIN
        DECLARE @PreviousCost DECIMAL(9, 2) = (SELECT TOP 1 a.Cost
                                               FROM inserted as a
                                                      INNER JOIN ConferenceCosts as cc
                                                        on cc.ConferenceCostID = a.ConferenceCostID
                                               WHERE cc.Conferences_ConferenceID = a.Conferences_ConferenceID
                                                 AND cc.DateTo < a.DateFrom
                                               ORDER BY cc.DateFrom DESC)
        DECLARE @NextCost DECIMAL(9, 2) = (SELECT TOP 1 a.Cost
                                           FROM inserted as a
                                                  INNER JOIN ConferenceCosts as cc
                                                    on cc.ConferenceCostID = a.ConferenceCostID
                                           WHERE cc.Conferences_ConferenceID = a.Conferences_ConferenceID
                                             AND cc.DateFrom > a.DateTo
                                           ORDER BY cc.DateFrom)
        IF ((@PreviousCost IS NOT NULL AND @PreviousCost >= @Cost)
            OR (@NextCost IS NOT NULL AND @NextCost <= @Cost))
          BEGIN
            SELECT 'Cena nie jest w poprawnej kolejności z poprzednimi (PreviousCost = %, NextCost = %.',
                   @PreviousCost,
                   @NextCost;
          END
      END
  END
GO