SELECT		*
FROM		sys.database_principals

USE master

CREATE LOGIN DataLoadUser_RC70 WITH PASSWORD = 'SuperUsers1234!!';
CREATE USER DataLoadUser_RC70 FOR LOGIN DataLoadUser_RC70;

-- skifter til sqlpool01
CREATE USER DataLoadUser_RC70 FOR LOGIN DataLoadUser_RC70;

EXEC sp_addrolemember 'staticrc70', 'DataLoadUser_RC70';

GRANT INSERT ON SCHEMA::dbo TO DataLoadUser_RC70
GRANT ADMINISTER DATABASE BULK OPERATIONS TO DataLoadUser_RC70
GRANT SELECT ON SCHEMA::dbo TO DataLoadUser_RC70

select		*
from		sys.workload_management_workload_groups

-- oprettelse af tabeller

CREATE TABLE [dbo].[Date]
(
    [DateID] int NOT NULL,
    [Date] datetime NULL,
    [DateBKey] char(10)  NULL,
    [DayOfMonth] varchar(2)  NULL,
    [DaySuffix] varchar(4)  NULL,
    [DayName] varchar(9)  NULL,
    [DayOfWeek] char(1)  NULL,
    [DayOfWeekInMonth] varchar(2)  NULL,
    [DayOfWeekInYear] varchar(2)  NULL,
    [DayOfQuarter] varchar(3)  NULL,
    [DayOfYear] varchar(3)  NULL,
    [WeekOfMonth] varchar(1)  NULL,
    [WeekOfQuarter] varchar(2)  NULL,
    [WeekOfYear] varchar(2)  NULL,
    [Month] varchar(2)  NULL,
    [MonthName] varchar(9)  NULL,
    [MonthOfQuarter] varchar(2)  NULL,
    [Quarter] char(1)  NULL,
    [QuarterName] varchar(9)  NULL,
    [Year] char(4)  NULL,
    [YearName] char(7)  NULL,
    [MonthYear] char(10)  NULL,
    [MMYYYY] char(6)  NULL,
    [FirstDayOfMonth] date NULL,
    [LastDayOfMonth] date NULL,
    [FirstDayOfQuarter] date NULL,
    [LastDayOfQuarter] date NULL,
    [FirstDayOfYear] date NULL,
    [LastDayOfYear] date NULL,
    [IsHolidayUSA] bit NULL,
    [IsWeekday] bit NULL,
    [HolidayUSA] varchar(50)  NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);


-- Sikkerhed omkring synapse 

-- kryptering:
-- TDE - Transparent DAta Encryption - krypterer datafiler og translog (files at rest)
	-- sql server 2016+
	--og i Azure SQL databaser (default slået til)
	-- Dedicated pool (TDE er default IKKE slået til)


-- sikkerhed:
-- Column level security (må man se specifikke kolonner i en given tabel f.eks. løn i en medarbejder tabel)
-- Row level security (nyt fra 2016+ sql server) - findes også til synapse

-------------------------------------------------------------------------------------
-- Datamasking
-------------------------------------------------------------------------------------
-- skjul data i udvalgte kolonner for specifikke brugere
-- f.eks. de sidste 4 cifre af cprnr
-- se eksempler på sqlpool01

-------------------------------------------------------------------------------------
--  Data Factory OG Synapse Pipelines (modul 6+7)
-------------------------------------------------------------------------------------

-- CASE
-- Hent zip fil fra ssi (https://files.ssi.dk/covid19/overvagning/data/overvaagningsdata-covid19-21062022-z94t)
-- den skal skrives unzippet (csv filer) til en container i vores data lake

-- https://files.ssi.dk/covid19/overvagning/data/overvaagningsdata-covid19-22062022-mkim

-- Linked service - tænk det som endpoint (kilden) og credentials
	-- web sitet hos ssi
	-- data lake


-- ADF vs Pipelines i Synapse
-- https://docs.microsoft.com/en-us/azure/synapse-analytics/data-integration/concepts-data-factory-differences





































CREATE TABLE [dbo].[Geography]
(
    [GeographyID] int NOT NULL,
    [ZipCodeBKey] varchar(10)  NOT NULL,
    [County] varchar(50)  NULL,
    [City] varchar(50)  NULL,
    [State] varchar(50)  NULL,
    [Country] varchar(50)  NULL,
    [ZipCode] varchar(50)  NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE [dbo].[HackneyLicense]
(
    [HackneyLicenseID] int NOT NULL,
    [HackneyLicenseBKey] varchar(50)  NOT NULL,
    [HackneyLicenseCode] varchar(50)  NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE [dbo].[Medallion]
(
    [MedallionID] int NOT NULL,
    [MedallionBKey] varchar(50)  NOT NULL,
    [MedallionCode] varchar(50)  NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE [dbo].[Time]
(
    [TimeID] int NOT NULL,
    [TimeBKey] varchar(8)  NOT NULL,
    [HourNumber] tinyint NOT NULL,
    [MinuteNumber] tinyint NOT NULL,
    [SecondNumber] tinyint NOT NULL,
    [TimeInSecond] int NOT NULL,
    [HourlyBucket] varchar(15)  NOT NULL,
    [DayTimeBucketGroupKey] int NOT NULL,
    [DayTimeBucket] varchar(100)  NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE [dbo].[Trip]
(
    [DateID] int NOT NULL,
    [MedallionID] int NOT NULL,
    [HackneyLicenseID] int NOT NULL,
    [PickupTimeID] int NOT NULL,
    [DropoffTimeID] int NOT NULL,
    [PickupGeographyID] int NULL,
    [DropoffGeographyID] int NULL,
    [PickupLatitude] float NULL,
    [PickupLongitude] float NULL,
    [PickupLatLong] varchar(50)  NULL,
    [DropoffLatitude] float NULL,
    [DropoffLongitude] float NULL,
    [DropoffLatLong] varchar(50)  NULL,
    [PassengerCount] int NULL,
    [TripDurationSeconds] int NULL,
    [TripDistanceMiles] float NULL,
    [PaymentType] varchar(50)  NULL,
    [FareAmount] money NULL,
    [SurchargeAmount] money NULL,
    [TaxAmount] money NULL,
    [TipAmount] money NULL,
    [TollsAmount] money NULL,
    [TotalAmount] money NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);

CREATE TABLE [dbo].[Weather]
(
    [DateID] int NOT NULL,
    [GeographyID] int NOT NULL,
    [PrecipitationInches] float NOT NULL,
    [AvgTemperatureFahrenheit] float NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);


SELECT  r.[request_id]                           
,       r.[status]                               
,       r.resource_class                         
,       r.command
,       sum(bytes_processed) AS bytes_processed
,       sum(rows_processed) AS rows_processed
FROM    sys.dm_pdw_exec_requests r
              JOIN sys.dm_pdw_dms_workers w
                     ON r.[request_id] = w.request_id
WHERE [label] = 'COPY : Load [dbo].[Date] - Taxi dataset' OR
    [label] = 'COPY : Load [dbo].[Geography] - Taxi dataset' OR
    [label] = 'COPY : Load [dbo].[HackneyLicense] - Taxi dataset' OR
    [label] = 'COPY : Load [dbo].[Medallion] - Taxi dataset' OR
    [label] = 'COPY : Load [dbo].[Time] - Taxi dataset' OR
    [label] = 'COPY : Load [dbo].[Weather] - Taxi dataset' OR
    [label] = 'COPY : Load [dbo].[Trip] - Taxi dataset' 
and session_id <> session_id() and type = 'WRITER'
GROUP BY r.[request_id]                           
,       r.[status]                               
,       r.resource_class                         
,       r.command;



DBCC PDW_SHOWSPACEUSED('dbo.Date')

DBCC PDW_SHOWSPACEUSED('dbo.Geography')

--2.803.470
DBCC PDW_SHOWSPACEUSED('dbo.Trip')

-- vi opretter tabellen trip med hash distribution på kolonnen dateid

CREATE TABLE [dbo].[Trip_hashed]
(
    [DateID] int NOT NULL,
    [MedallionID] int NOT NULL,
    [HackneyLicenseID] int NOT NULL,
    [PickupTimeID] int NOT NULL,
    [DropoffTimeID] int NOT NULL,
    [PickupGeographyID] int NULL,
    [DropoffGeographyID] int NULL,
    [PickupLatitude] float NULL,
    [PickupLongitude] float NULL,
    [PickupLatLong] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [DropoffLatitude] float NULL,
    [DropoffLongitude] float NULL,
    [DropoffLatLong] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PassengerCount] int NULL,
    [TripDurationSeconds] int NULL,
    [TripDistanceMiles] float NULL,
    [PaymentType] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [FareAmount] money NULL,
    [SurchargeAmount] money NULL,
    [TaxAmount] money NULL,
    [TipAmount] money NULL,
    [TollsAmount] money NULL,
    [TotalAmount] money NULL
)
WITH
(
    DISTRIBUTION = HASH(DateID),
    CLUSTERED COLUMNSTORE INDEX
);




SELECT		top 10 *
FROM		dbo.trip
GROUP BY	Datetid


-- Pipeline
	-- vi har variable til at kontrollere ting dynamisk
	-- vi har string,boolean og array (liste) som typer


