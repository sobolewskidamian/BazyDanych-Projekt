create view view_MostPopularWorkshops as
select top 10 conf.name as ConferenceName,w.workshopid,w.name,isnull(sum(wp.workshopparticipantid),0) as popularnosc
from Workshops as w
inner join conferencedays as cd on cd.conferencedayid=w.ConferenceDays_ConferenceDaysID
inner join conferences as conf on conf.conferenceid=cd.Conferences_ConferenceID
inner join WorkshopBooking as wb on wb.Workshops_WorkshopID=w.WorkshopID
inner join WorkshopParticipants as wp on wp.WorkshopBooking_WorkshopBookingID=wb.workshopbookingid
GROUP BY w.workshopid, w.name,conf.name
ORDER BY popularnosc DESC

create view view_MostPopularConferences as
select top 10 c.ConferenceID,c.Name,isnull(sum(dp.DayParticipantID),0) as popularity
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID= cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
group by c.ConferenceID,c.Name
order by popularity desc

create view view_MostPopularConferencesByStudents as
select top 10 c.ConferenceID,c.Name,isnull(sum(dp.DayParticipantID),0) as popularity
from Conferences as c
inner join ConferenceDays as cd on cd.Conferences_ConferenceID=c.ConferenceID
inner join ConferenceDayBooking as cdb on cdb.ConferenceDays_ConferenceDayID= cd.ConferenceDayID
inner join DayParticipants as dp on dp.ConferenceDayBooking_ConferenceDayBookingID=cdb.ConferenceDayBookingID
and dp.StudentID is not null
group by c.ConferenceID,c.Name
order by popularity desc

create view view_MostPopularWorkshopsByStudents as
select top 10 conf.name as ConferenceName,w.workshopid,w.name,isnull(sum(wp.workshopparticipantid),0) as popularnosc
from Workshops as w
inner join conferencedays as cd on cd.conferencedayid=w.ConferenceDays_ConferenceDaysID
inner join conferences as conf on conf.conferenceid=cd.Conferences_ConferenceID
inner join WorkshopBooking as wb on wb.Workshops_WorkshopID=w.WorkshopID
inner join WorkshopParticipants as wp on wp.WorkshopBooking_WorkshopBookingID=wb.workshopbookingid
inner join DayParticipants as dp on dp.DayParticipantID=wp.DayParticipants_DayParticipantID and
        dp.StudentID is not null
GROUP BY w.workshopid, w.name,conf.name
ORDER BY popularnosc DESC

create view view_MostProfitableConference as
select top 10 c.ConferenceID,c.Name,cc.Cost+a.koszt as cena
from Conferences as c
inner join ConferenceCosts as cc on cc.Conferences_ConferenceID=c.ConferenceID
inner join (select con.ConferenceID, (
    select isnull(sum(w.Cost),0) as koszta
    from conferencedays as cd
    inner join Workshops as w on w.ConferenceDays_ConferenceDaysID=cd.ConferenceDayID
    where cd.Conferences_ConferenceID=con.ConferenceID) as koszt
           from Conferences as con) as a on c.ConferenceID=a.ConferenceID
order by cena

create view view_MostProfitableWorkshops as
select top 10 c.name as NazwaKonferencji,w.name,w.cost
from Workshops as w
inner join ConferenceDays as cd on cd.ConferenceDayID=w.ConferenceDays_ConferenceDaysID
inner join Conferences as c on c.ConferenceID=cd.Conferences_ConferenceID
order by w.cost des