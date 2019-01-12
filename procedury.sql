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