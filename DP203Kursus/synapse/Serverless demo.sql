-- built-in er serverless pool

CREATE DATABASE ServerlessDB

USE serverlessdb

-- This is auto-generated code
SELECT
    TOP 100 *, R.filename(), R.filepath(), R.filepath(1)
FROM
    OPENROWSET(
        BULK 'https://datalakesu20220620.dfs.core.windows.net/raspdata/sensor=1984/year=*/month=*/data*.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS R


-- meta data

CREATE SCHEMA ext

CREATE VIEW ext.RaspDataView AS 
    SELECT
        *, R.filename() AS Filnavn
        , R.filepath() AS FuldSti
        , R.filepath(1) AS Aarstal
    FROM
        OPENROWSET(
            BULK 'https://datalakesu20220620.dfs.core.windows.net/raspdata/sensor=1984/year=*/month=*/data*.csv',
            FORMAT = 'CSV',
            PARSER_VERSION = '2.0',
            HEADER_ROW = TRUE
        ) AS R



SELECT      top 10 *
FROM        ext.RaspDataView

-- vi laver i stedet en external table





