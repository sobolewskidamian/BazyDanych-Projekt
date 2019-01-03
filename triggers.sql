--Sprawdenie wystarczajacej liczby miejsc w dniu konferencji
CREATE TRIGGER TRIGGER_TooFewFreePlacesForDayBooking
  ON ConferenceDayBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM inserted as a WHERE dbo.FUNCTION_CheckFreeDayPlaces(a.ConferenceDays_ConferenceDayID) < 0)
      BEGIN
        SELECT 'Brak wystarczajacej liczby miejsc w dniu konferencji'
      END
  END


-- Sprawdenie wystarczajacej liczby miejsc na warsztacie
CREATE TRIGGER TRIGGER_TooFewFreePlacesForWorkshopBooking
  ON WorkshopBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON
    IF EXISTS(SELECT * FROM inserted as a WHERE dbo.FUNCTION_CheckFreeWorkshopPlaces(a.Workshops_WorkshopID) < 0)
      BEGIN
        SELECT 'Brak wystarczajacej liczby miejsc w warsztacie'
      END
  END


--Blokuje rezerwację na warsztat, jeżeli klient zarezerwował mniej miejsc na dzień niż warsztat.
CREATE TRIGGER TRIGGER_LessPlacesForDayThanForWorkshop
  ON ConferenceDayBooking
  AFTER INSERT, UPDATE
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT * FROM inserted AS a WHERE dbo.FUNCTION_CheckFreeDayPlaces(a.ConferenceDays_ConferenceDayID) < 0)
      BEGIN
        SELECT 'Klient zarezerwował mniej miejsc na dzień niż na warsztat'
      END
  END


--Blokuje zapis uczestnika na dzień konferencji, jeżeli wszystkie miejsca od klienta są już zajęte.
CREATE TRIGGER TRIGGER_NotEnoughBookedPlacesForDay
  ON DayParticipants
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
              WHERE (a.StudentID IS NULL
                       AND dbo.FUNCTION_BookingDayFreeStudentPlaces(a.ConferenceDayBooking_ConferenceDayBookingID) < 0)
                 OR (a.StudentID IS NULL
                       AND dbo.FUNCTION_BookingDayFreeNormalPlaces(a.ConferenceDayBooking_ConferenceDayBookingID) < 0))
      BEGIN
        SELECT 'Wszystkie miejsca klienta zostały już zarezerwowane'
      END
  END


--Blokuje zapis uczestnika na warsztat, jeżeli wszystkie zarezerwowane miejsca są już zajęte.
CREATE TRIGGER TRIGGER_NotEnoughBookedPlacesForWorkshop
  ON WorkshopParticipants
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
              WHERE dbo.FUNCTION_BookingWorkshopFreePlaces(a.WorkshopBooking_WorkshopBookingID) < 0)
      BEGIN
        SELECT 'Wszystkie zarezerwowane miejsca są już zajęte'
      END
  END


--Pilnuje czy po zmniejszeniu liczby miejsc na dzień konferencji zarezerwowane miejsca mieszczą się w nowym limicie.
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


--Pilnuje czy po zmniejszeniu liczby miejsc na warsztat zarezerwowane miejsca mieszczą sie w nowym limicie.
CREATE TRIGGER TRIGGER_TooFewPlacesAfterDecreasingDayCapacity
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


--Sprawdza, czy rezerwowany jest dzień z konferencji odpowiadającej rezerwacji na konferencję. Tzn. klient zarezerwował jedną konferencję i nie próbuje przypisać do niej rezerwację na dzień z innej konferencji.
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


--Sprawdza, czy rezerwacja danego dnia konferencji już istnieje.
CREATE TRIGGER TRIGGER_BookingDayAlreadyExists
  ON ConferenceDayBooking
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT *
              FROM inserted AS a
                     INNER JOIN ConferenceDayBooking AS cbd
                       ON a.ConferenceBooking_ConferenceBookingID = cbd.ConferenceBooking_ConferenceBookingID
                            AND a.ConferenceDays_ConferenceDayID = cbd.ConferenceDays_ConferenceDayID
              WHERE a.ConferenceBooking_ConferenceBookingID != cbd.ConferenceBooking_ConferenceBookingID)
      BEGIN
        SELECT 'Rezerwacja danego dnia konferencji nie istnieje'
      END
  END


--Sprawdza, czy rezerwowany jest warsztat z dnia odpowiadającemu rezerwacji na dzień.
CREATE TRIGGER TRIGGER_BookingDayInDifferentConference
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
        SELECT 'Klient próbuje przepisać do warsztat z innego dnia niż jego rezerwacja'
      END
  END


--Blokuje zapisanie się na warsztat, jeżeli uczestnik jest zapisany na inny warsztat trwający w tym samym czasie
CREATE TRIGGER TRIGGER_ArePriceThresholdsMonotonous
  ON ConferenceCosts
  AFTER INSERT
AS
  BEGIN
    SET NOCOUNT ON;
    DECLARE @Cost DECIMAL(9, 2) = (SELECT a.Cost FROM inserted AS a);
    IF EXISTS(SELECT *
              FROM inserted AS a
                     INNER JOIN ConferenceCosts AS cc on a.Conferences_ConferenceID = cc.Conferences_ConferenceID
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
        DECLARE @PreviousCost DECIMAL(9, 2) = (SELECT TOP 1 *
                                               FROM inserted as a
                                                      INNER JOIN ConferenceCosts as cc
                                                        on cc.ConferenceCostID = a.ConferenceCostID
                                               WHERE cc.Conferences_ConferenceID = a.Conferences_ConferenceID
                                                 AND cc.DateTo < a.DateFrom
                                               ORDER BY cc.DateFrom DESC)
        DECLARE @NextCost DECIMAL(9, 2) = (SELECT TOP 1 *
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