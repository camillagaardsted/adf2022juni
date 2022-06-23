	
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
		LOCATION = 'abfss://raspdata@datalakesu20220620.dfs.core.windows.net' 
	)
GO

drop EXTERNAL TABLE dbo.RaspDataTable

CREATE EXTERNAL TABLE ext.RaspDataTable (
	[sensorid] bigint,
	[timestamp] datetime2(0),
	[temperature_from_humidity] float,
	[temperature_from_pressure] float,
	[humidity] float,
	[pressure] float
	)
	WITH (
	LOCATION = 'sensor=1984/year=2022/month=06/*',
	DATA_SOURCE = [raspdata_datalakesu20220620_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM ext.RaspDataTable
GO


select TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://datalakesu20220516.dfs.core.windows.net/raspdata/sensor=1984/year=2022/month=05/data*.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) 
    WITH
    (
        SensorId    INT 1,
        DatoTid     DATETIME2(0) 2,
        Temperatur  DECIMAL(19,6) 4,
        Humidity    DECIMAL(19,6) 5,    
        Pressure    DECIMAL(19,6) 6
    ) AS [result]     
    


