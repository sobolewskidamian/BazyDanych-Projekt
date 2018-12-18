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
 @ConferenceDayID INT)
 AS
BEGIN
 DELETE FROM Conferences
 WHERE Conferences.ConferenceID = @ConferenceDayID;
END


CREATE PROCEDURE PROCEDURE_UpdateConferenceDetails(
 @ConferenceID INT,
 @Name VARCHAR(100),
 @Place VARCHAR(100),
 @DiscountForStudents FLOAT,
 @Description VARCHAR(200))
 AS
BEGIN
 IF EXISTS(
  SELECT * FROM Conferences
  WHERE @ConferenceID = ConferenceID
 )
 BEGIN
  IF @Name IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Name = @Name
   WHERE ConferenceID = @ConferenceID;
  END
  IF @DiscountForStudents IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET DiscountForStudents = @DiscountForStudents
   WHERE ConferenceID = @ConferenceID;
  END
  IF @Place IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Place = @Place
   WHERE ConferenceID = @ConferenceID;
  END
  IF @Description IS NOT NULL
  BEGIN
   UPDATE Conferences
   SET Description = @Description
   WHERE ConferenceID = @ConferenceID;
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
 IF EXISTS(
  SELECT * FROM Workshops
  WHERE @WorkshopID = WorkshopID
 )
 BEGIN
  IF @Name IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET Name = @Name
   WHERE WorkshopID = @WorkshopID;
  END
  IF @StartTime IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET StartTime = @StartTime
   WHERE WorkshopID = @WorkshopID;
  END
  IF @EndTime IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET EndTime = @EndTime
   WHERE WorkshopID = @WorkshopID;
  END
  IF @Cost IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET Cost = @Cost
   WHERE WorkshopID = @WorkshopID;
  END
  IF @NumberOfParticipants IS NOT NULL
  BEGIN
   UPDATE Workshops
   SET NumberOfParticipants = @NumberOfParticipants
   WHERE WorkshopID = @WorkshopID;
  END
 END
END


CREATE PROCEDURE PROCEDURE_AddConferenceBooking(
 @ConferenceID INT,
 @ClientID INT,
 @BookingDate DATE)
 AS
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


