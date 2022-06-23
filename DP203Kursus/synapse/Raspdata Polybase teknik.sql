
-- Load Raspdata via polybase teknik

	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 USE_TYPE_DEFAULT = FALSE,
			 FIRST_ROW = 2
			))
GO


	CREATE EXTERNAL DATA SOURCE [raspdata_datalakesu20220620_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://raspdata@datalakesu20220620.dfs.core.windows.net', 
		TYPE = HADOOP 
	)
GO

Create SCHEMA EXT

GO

DROP EXTERNAL TABLE EXT.RaspData

CREATE EXTERNAL TABLE EXT.RaspData (
	[sensorid] bigint,
	--[timestamp] datetime2(0),
	[timestamp] VARCHAR(20),
	[temperature_from_humidity] float,
	[temperature_from_pressure] float,
	[humidity] float,
	[pressure] float
	)
	WITH (
	LOCATION = 'sensor=1984/year=2022/month=06/',
	DATA_SOURCE = [raspdata_datalakesu20220620_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM ext.RaspData
GO


INSERT INTO dbo.RaspData
SELECT [sensorid]
,CAST([timestamp] AS DATETIME2) AS Datotid
,[temperature_from_humidity]
,[temperature_from_pressure]
,[humidity]
,[pressure]
 FROM [EXT].[RaspData]



SELECT 		*
FROM		dbo.RaspData



CREATE TABLE dbo.RaspData (
	[sensorid] bigint,
	[timestamp] datetime2(0),	
	[temperature_from_humidity] float,
	[temperature_from_pressure] float,
	[humidity] float,
	[pressure] float
	)
WITH (
	DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
)

SELECT 





