create view view_MostPopularWorkshops as
select top 10 conf.name as ConferenceName,w.workshopid,w.name,isnull(sum(wb.NumberOfParticipants),0) as popularnosc
from Workshops as w
inner join conferencedays as cd on cd.conferencedayid=w.ConferenceDays_ConferenceDayID
inner join conferences as conf on conf.conferenceid=cd.Conferences_ConferenceID
inner join WorkshopBooking as wb on wb.Workshops_WorkshopID=w.WorkshopID
inner join WorkshopParticipants as wp on wp.WorkshopBooking_WorkshopBookingID=wb.workshopbookingid
GROUP BY w.workshopid, w.name,conf.name
ORDER BY popularnosc DESC
GO

create view view_MostPopularConferences as
select top 10 c.ConferenceID,c.Name,isnull(sum(cdb.NumberOfParticipants),0) as popularity
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID= cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
group by c.ConferenceID,c.Name
order by popularity desc
GO

create view view_MostPopularConferencesByStudents as
select top 10 c.ConferenceID,c.Name,isnull(sum(cdb.NumberOfParticipants),0) as popularity
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID= cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
and dp.StudentID is not null
group by c.ConferenceID,c.Name
order by popularity desc
GO

create view view_MostPopularWorkshopsByStudents as
select top 10 conf.name as ConferenceName,w.workshopid,w.name,isnull(sum(wb.NumberOfParticipants),0) as popularnosc
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
order by cena desc
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
isnull ( SUM(wb.NumberOfParticipants) , 0) as Zajete,
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
select c.ConferenceID,c.name,cd.Date,isnull(sum(cdb.NumberOfParticipants),0) as Zajete,
       cd.NumberOfParticipants as Miejsca,cd.NumberOfParticipants-isnull(sum(cdb.NumberOfParticipants),0) as WolneMiejsca
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID=cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
group by c.conferenceid,c.Name,cd.Date,cd.NumberOfParticipants
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