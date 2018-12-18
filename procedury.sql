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


