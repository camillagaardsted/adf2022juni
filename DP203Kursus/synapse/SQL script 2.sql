IF NOT EXISTS (SELECT * FROM sys.objects O JOIN sys.schemas S ON O.schema_id = S.schema_id WHERE O.NAME = 'raspdatacopyinto' AND O.TYPE = 'U' AND S.NAME = 'dbo')

-- copy into 

CREATE TABLE dbo.raspdatacopyinto
	(
	 [sensorid] bigint,
	 [timestamp] datetime2(0),
	 [temperature_from_humidity] float,
	 [temperature_from_pressure] float,
	 [humidity] float,
	 [pressure] float
	)
WITH
	(
	DISTRIBUTION = ROUND_ROBIN,
	 CLUSTERED COLUMNSTORE INDEX
	 -- HEAP
	)
GO

--Uncomment the 4 lines below to create a stored procedure for data pipeline orchestration​
--CREATE PROC bulk_load_raspdatacopyinto
--AS
--BEGIN
COPY INTO dbo.raspdatacopyinto
(sensorid 1, timestamp 2, temperature_from_humidity 3, temperature_from_pressure 4, humidity 5, pressure 6)
FROM 'https://datalakesu20220620.dfs.core.windows.net/raspdata/sensor=1984/year=2022/month=06/data2022_06_20_13_08_32.csv'
WITH
(
	FILE_TYPE = 'CSV'
	,MAXERRORS = 0
	,FIRSTROW = 02
	,ERRORFILE = 'https://datalakesu20220620.dfs.core.windows.net/raspdata/'
)
--END
GO

SELECT TOP 100 * FROM dbo.raspdatacopyinto
GO