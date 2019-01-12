CREATE TRIGGER TRIGGER_TooFewFreePlacesForDayBooking
  ON ConferenceDayBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM inserted as a WHERE dbo.FUNCTION_FreeDayPlaces(a.ConferenceDays_ConferenceDayID) < 0)
      BEGIN
        THROW 50000, 'Brak wystarczajacej liczby miejsc w dniu konferencji',1
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
        THROW 50000, 'Brak wystarczajacej liczby miejsc w warsztacie',1
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
        THROW 50000, 'Klient zarezerwował mniej miejsc na dzień niż na warsztat',1
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
        THROW 50000, 'Wszystkie miejsca klienta zostały już zarezerwowane',1
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
        THROW 50000, 'Wszystkie zarezerwowane miejsca są już zajęte',1
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
        THROW 50000, 'Po zmniejszeniu liczby miejsc na dzień konferencji zarezerwowane miejsca nie mieszczą się w nowym limicie',1
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
        THROW 50000, 'Po zmniejszeniu liczby miejsc na warsztat zarezerwowane miejsca nie mieszczą się w nowym limicie',1
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
        THROW 50000, 'Klient próbuje przepisać do konferencji rezerwację dnia z innej konferencji',1
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
        THROW 50000, 'Rezerwacja danego dnia konferencji już istnieje',1
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
        THROW 50000, 'Klient próbuje przypisać się do warsztatu z innego dnia niż jego rezerwacja',1
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
        THROW 50000, 'Koszt pokrywa się z istniejącymi kosztami',1
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
            THROW 50000, 'Cena nie jest w poprawnej kolejności z poprzednimi (PreviousCost = %, NextCost = %.,
                   @PreviousCost,
                   @NextCost',1;
          END
      END
  END
GO