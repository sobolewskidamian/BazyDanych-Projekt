-- Table: Conferences
CREATE TABLE Conferences (
    ConferenceID int NOT NULL,
    Name varchar(100) NOT NULL,
    Place varchar(100) NOT NULL,
    DiscountForStudents float NOT NULL DEFAULT 0,
    Description varchar(200) NOT NULL,
    CONSTRAINT ProperDiscountForStudents CHECK (DiscountForStudents >= 0 AND
        DiscountForStudents <= 100),
    CONSTRAINT ProperDescription CHECK (LEN(Description) > 5),
    CONSTRAINT Conferences_pk PRIMARY KEY (ConferenceID)
);


-- Table: ConferenceDays
CREATE TABLE ConferenceDays (
    ConferenceDayID int NOT NULL,
    Conferences_ConferenceID int NOT NULL,
    Date date NOT NULL,
    NumberOfParticipants int NOT NULL,
    CONSTRAINT PositiveNumberOfConferenceParticipants CHECK (NumberOfParticipants > 0),
    CONSTRAINT ConferenceDays_pk PRIMARY KEY (ConferenceDayID)
);

-- Reference: Conferences_ConferenceDays (table: ConferenceDays)
ALTER TABLE ConferenceDays ADD CONSTRAINT Conferences_ConferenceDays FOREIGN KEY (Conferences_ConferenceID)
    REFERENCES Conferences (ConferenceID)





-- Table: ConferenceCosts
CREATE TABLE ConferenceCosts (
    ConferenceCostID int NOT NULL,
    Conferences_ConferenceID int NOT NULL,
    Cost decimal(9,2) NOT NULL,
    DateFrom date NOT NULL,
    DateTo date NOT NULL,
    CONSTRAINT ProperDayDifferance CHECK (DateFrom <= DateTo),
    CONSTRAINT NonnegativeCostConf CHECK (Cost >= 0),
    CONSTRAINT ConferenceCosts_pk PRIMARY KEY (ConferenceCostID)
);

-- Reference: Conferences_ConferenceDay (table: ConferenceCosts)
ALTER TABLE ConferenceCosts ADD CONSTRAINT Conferences_ConferenceDay FOREIGN KEY (Conferences_ConferenceID)
    REFERENCES Conferences (ConferenceID)




-- Table: Workshops
CREATE TABLE Workshops (
    WorkshopID int NOT NULL,
    ConferenceDays_ConferenceDaysID int NOT NULL,
    Name varchar(100) NOT NULL,
    StartTime date NOT NULL,
    EndTime date NOT NULL,
    Cost decimal(9,2) NOT NULL DEFAULT 0,
    NumberOfParticipants int NOT NULL DEFAULT 10,
    CONSTRAINT NonnegativeCostWorkshop CHECK (Cost >= 0),
    CONSTRAINT ProperTimeDifferance CHECK (StartTime < EndTime),
    CONSTRAINT PosiviteWorkshopParticipants CHECK (NumberOfParticipants > 0),
    CONSTRAINT Workshops_pk PRIMARY KEY (WorkshopID)
);

-- Reference: Workshops_ConferenceDays (table: Workshops)
ALTER TABLE Workshops ADD CONSTRAINT Workshops_ConferenceDays FOREIGN KEY (ConferenceDays_ConferenceDaysID)
    REFERENCES ConferenceDays (ConferenceDayID)






-- Table: ConferenceBooking
CREATE TABLE ConferenceBooking (
    ConferenceBookingID int NOT NULL,
    Clients_ClientID int NOT NULL,
    Conferences_ConferenceID int NOT NULL,
    BookingDate date NOT NULL DEFAULT getdate(),
    IsCanceled bit NOT NULL DEFAULT 0,
    CONSTRAINT ConferenceBooking_pk PRIMARY KEY (ConferenceBookingID)
);

-- Reference: BookingConference_Clients (table: ConferenceBooking)
ALTER TABLE ConferenceBooking ADD CONSTRAINT BookingConference_Clients FOREIGN KEY (Clients_ClientID)
  REFERENCES Clients (ClientID)

-- Reference: BookingConference_Conferences (table: ConferenceBooking)
ALTER TABLE ConferenceBooking ADD CONSTRAINT BookingConference_Conferences FOREIGN KEY (Conferences_ConferenceID)
    REFERENCES Conferences (ConferenceID)




-- Table: ConferenceDayBooking
CREATE TABLE ConferenceDayBooking (
    ConferenceDayBookingID int NOT NULL,
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

-- Reference: ConferenceDayBooking_ConferenceBooking (table: ConferenceDayBooking)
ALTER TABLE ConferenceDayBooking ADD CONSTRAINT ConferenceDayBooking_ConferenceBooking FOREIGN KEY (ConferenceBooking_ConferenceBookingID)
    REFERENCES ConferenceBooking (ConferenceBookingID)

-- Reference: ConferenceDayBooking_ConferenceDays (table: ConferenceDayBooking)
ALTER TABLE ConferenceDayBooking ADD CONSTRAINT ConferenceDayBooking_ConferenceDays FOREIGN KEY (ConferenceDays_ConferenceDayID)
    REFERENCES ConferenceDays (ConferenceDayID)





-- Table: WorkshopBooking
CREATE TABLE WorkshopBooking (
    WorkshopBookingID int NOT NULL,
    Workshops_WorkshopID int NOT NULL,
    ConferenceDayBooking_ConferenceDayBookingID int NOT NULL,
    BookingDate date NOT NULL DEFAULT getdate(),
    NumberOfParticipants int NOT NULL,
    CONSTRAINT PositiveWorkshopNumberOfParticipants CHECK (NumberOfParticipants > 0),
    CONSTRAINT WorkshopBooking_pk PRIMARY KEY (WorkshopBookingID)
);

-- Reference: WorkshopBooking_ConferenceDayBooking (table: WorkshopBooking)
ALTER TABLE WorkshopBooking ADD CONSTRAINT WorkshopBooking_ConferenceDayBooking FOREIGN KEY (ConferenceDayBooking_ConferenceDayBookingID)
    REFERENCES ConferenceDayBooking (ConferenceDayBookingID)

-- Reference: WorkshopBooking_Workshops (table: WorkshopBooking)
ALTER TABLE WorkshopBooking ADD CONSTRAINT WorkshopBooking_Workshops FOREIGN KEY (Workshops_WorkshopID)
    REFERENCES Workshops (WorkshopID)







-- Table: Payments
CREATE TABLE Payments (
    PaymentID int NOT NULL,
    ConferenceBooking_ConferenceBookingID int NOT NULL,
    Amount decimal(9,2) NOT NULL,
    PayDate date NOT NULL DEFAULT getdate(),
    CONSTRAINT PositiveValue CHECK (Amount > 0),
    CONSTRAINT Payments_pk PRIMARY KEY (PaymentID)
);

-- Reference: Payments_ConferenceBooking (table: Payments)
ALTER TABLE Payments ADD CONSTRAINT Payments_ConferenceBooking FOREIGN KEY (ConferenceBooking_ConferenceBookingID)
    REFERENCES ConferenceBooking (ConferenceBookingID)





-- Table: Participants
CREATE TABLE Participants (
    ParticipantID int NOT NULL,
    FirstName varchar(40) NOT NULL,
    LastName varchar(40) NOT NULL,
    Email varchar(100) NOT NULL,
    Street varchar(40) NOT NULL,
    City varchar(40) NOT NULL,
    PostalCode varchar(10) NOT NULL,
    County varchar(40) NOT NULL,
    CONSTRAINT ProperEmail CHECK (Email LIKE '^\S+[@]\S+[.]\S+$'),
    CONSTRAINT Participants_pk PRIMARY KEY (ParticipantID)
);





-- Table: DayParticipants
CREATE TABLE DayParticipants (
    DayParticipantID int NOT NULL,
    ConferenceDayBooking_ConferenceDayBookingID int NOT NULL,
    Participants_ParticipantID int NOT NULL,
    StudentID varchar(6) NULL DEFAULT null,
    CONSTRAINT ProperStudentID CHECK (StudentID LIKE '^\d{6}$' OR StudentID IS NULL),
    CONSTRAINT DayParticipants_pk PRIMARY KEY (DayParticipantID)
);

-- Reference: DayParticipants_ConferenceDayBooking (table: DayParticipants)
ALTER TABLE DayParticipants ADD CONSTRAINT DayParticipants_ConferenceDayBooking FOREIGN KEY (ConferenceDayBooking_ConferenceDayBookingID)
    REFERENCES ConferenceDayBooking (ConferenceDayBookingID)

-- Reference: Participants_DayParticipants (table: DayParticipants)
ALTER TABLE DayParticipants ADD CONSTRAINT Participants_DayParticipants FOREIGN KEY (Participants_ParticipantID)
    REFERENCES Participants (ParticipantID)





-- Table: WorkshopParticipants
CREATE TABLE WorkshopParticipants (
    WorkshopParticipantID int NOT NULL,
    WorkshopBooking_WorkshopBookingID int NOT NULL,
    DayParticipants_DayParticipantID int NOT NULL,
    CONSTRAINT WorkshopParticipants_pk PRIMARY KEY (WorkshopParticipantID)
);

-- Reference: DayParticipants_WorkshopParticipants (table: WorkshopParticipants)
ALTER TABLE WorkshopParticipants ADD CONSTRAINT DayParticipants_WorkshopParticipants FOREIGN KEY (DayParticipants_DayParticipantID)
    REFERENCES DayParticipants (DayParticipantID)

-- Reference: WorkshopParticipants_WorkshopBooking (table: WorkshopParticipants)
ALTER TABLE WorkshopParticipants ADD CONSTRAINT WorkshopParticipants_WorkshopBooking FOREIGN KEY (WorkshopBooking_WorkshopBookingID)
    REFERENCES WorkshopBooking (WorkshopBookingID)



-- Table: Clients
CREATE TABLE Clients (
    ClientID int NOT NULL,
    IsCompany bit NOT NULL,
    Name varchar(100) NOT NULL,
    Surname varchar(100) NULL,
    Email varchar(100) NOT NULL,
    CONSTRAINT ProperPassword CHECK (LEN(Password) > 8),
    CONSTRAINT Clients_pk PRIMARY KEY (ClientID)
);



-- krason nieudacznik
-- hehehehehhehehehe .|.
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>__