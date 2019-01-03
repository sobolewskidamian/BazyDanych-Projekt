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

CREATE PROCEDURE PROCEDURE_AddConferenceDay(
 @ConferenceID INT,
 @Date DATE,
 @NumberOfParticipants INT)
 AS
BEGIN
 INSERT INTO ConferenceDays (Conferences_ConferenceID, Date, NumberOfParticipants)
 VALUES (@ConferenceID, @Date, @NumberOfParticipants);
END


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


CREATE PROCEDURE PROCEDURE_RemoveConference(
 @ConferenceID INT)
 AS
IF NOT EXISTS(
 SELECT * FROM Conferences
 WHERE @ConferenceID = ConferenceID
)
BEGIN
 SELECT 'Nie znaleziono konferencji'
END

ELSE

BEGIN
 DELETE FROM Conferences
 WHERE Conferences.ConferenceID = @ConferenceID;
END


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
  SELECT 'Nie znaleziono konferencji'
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
    SELECT 'ConferenceID is null'
   END
  IF @DiscountForStudents IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET DiscountForStudents = @DiscountForStudents
   WHERE ConferenceID = @ConferenceID;
  END
  ELSE
   BEGIN
    SELECT 'DiscountForStudents is null'
   END
  IF @Place IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Place = @Place
   WHERE ConferenceID = @ConferenceID;
  END
  ELSE
   BEGIN
    SELECT 'Place is null'
   END
  IF @Description IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Description = @Description
   WHERE ConferenceID = @ConferenceID;
  END
  ELSE
   BEGIN
    SELECT 'Description is null'
   END
 END
END


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
  SELECT 'Nie znaleziono warsztatu'
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
   SELECT 'WorkshopID is null'
  END
  IF @StartTime IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET StartTime = @StartTime
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   SELECT 'StartTime is null'
  END
  IF @EndTime IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET EndTime = @EndTime
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   SELECT 'EndTime is null'
  END
  IF @Cost IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET Cost = @Cost
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   SELECT 'Cost is null'
  END
  IF @NumberOfParticipants IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET NumberOfParticipants = @NumberOfParticipants
   WHERE WorkshopID = @WorkshopID;
  END
  ELSE
  BEGIN
   SELECT 'NumberOfParticipants is null'
  END
 END
END


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
  SELECT 'Nie znaleziono konferencji'
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
  SELECT 'Nie znaleziono ConferenceDayID lub ConferenceBookingID'
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
  SELECT 'Nie znaleziono WorkshopID lub ConferenceDayBookingID'
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
   SELECT 'Nie znaleziono ConferenceDayBookingID'
  END

  ELSE

  BEGIN
   IF NOT EXISTS(
    SELECT * FROM Participants
    WHERE @ParticipantID = ParticipantID
   )
   BEGIN
    SELECT 'Nie znaleziono ParticipantID'
   END

   ELSE

   BEGIN
    INSERT INTO DayParticipants (ConferenceDayBooking_ConferenceDayBookingID, Participants_ParticipantID, StudentID)
    VALUES (@ConferenceDayBookingID, @ParticipantID, @StudentID);
   END
  END
END


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
   SELECT 'Nie znaleziono WorkshopBookingID'
  END

  ELSE

  BEGIN
   IF NOT EXISTS(
    SELECT * FROM Participants
    WHERE @DayParticipantID = ParticipantID
   )
   BEGIN
    SELECT 'Nie znaleziono ParticipantID'
   END

   ELSE

   BEGIN
    INSERT INTO WorkshopParticipants (WorkshopBooking_WorkshopBookingID, DayParticipants_DayParticipantID)
    VALUES (@WorkshopBookingID, @DayParticipantID);
   END
  END
END


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
  SELECT 'Nie znaleziono ConferenceBookingID lub rezerwacja została już wcześniej anulowana'
 END

 ELSE

 BEGIN
  UPDATE ConferenceBooking
  SET IsCanceled = 1
  WHERE @ConferenceBookingID = ConferenceBookingID;
 END
END


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
  SELECT 'Nie znaleziono ConferenceDayBookingID lub rezerwacja została już wcześniej anulowana'
 END

 ELSE

 BEGIN
  UPDATE ConferenceDayBooking
  SET IsCancelled = 1
  WHERE @ConferenceDayBookingID = ConferenceDayBookingID;
 END
END



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
  SELECT 'Nie znaleziono WorkshopID'
 END

 ELSE

 BEGIN
  UPDATE Workshops
  SET NumberOfParticipants = @NumberOfParticipants
  WHERE @WorkshopID = WorkshopID;
 END
END


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
  SELECT 'Nie znaleziono ConferenceDayID'
 END

 ELSE

 BEGIN
  UPDATE ConferenceDays
  SET NumberOfParticipants = @NumberOfParticipants
  WHERE @ConferenceDayID = ConferenceDayID;
 END
END


CREATE PROCEDURE PROCEDURE_ShowConferenceDaysAmountOfParticipants(
 @ConferenceID INT)
 AS
BEGIN
 IF EXISTS(
   SELECT * FROM Conferences
   WHERE @ConferenceID = ConferenceID
 )
 BEGIN
  SELECT 'Nie znaleziono ConferenceID'
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



CREATE PROCEDURE PROCEDURE_ShowListOfEventsOfConference(
 @ConferenceID INT)
 AS
BEGIN
 IF EXISTS(
   SELECT * FROM Conferences
   WHERE @ConferenceID = ConferenceID
 )
 BEGIN
  SELECT 'Nie znaleziono ConferenceID'
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