-- Funkcje
--Returns number of free places
--(counting client reservations) for given conference day

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

--FUNCTION FREEWORKSHOPPLACES
--Returns number of free places
--(counting client reservations) for given workshop

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
            cd.ConferenceDayID=w.ConferenceDays_ConferenceDaysID
    where cd.Conferences_ConferenceID=@ConferenceID
    return
end

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

-- klient -> jego konferencje
-- participant -> jego dni konferencji
-- participant -> warszaty

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