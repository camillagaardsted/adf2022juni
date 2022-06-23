--Microsoft SQL Azure (RTM) - 12.0.2000.8   Jun  9 2022 05:48:58   Copyright (C) 2022 Microsoft Corporation 
SELECT @@version

USE serverlessdb

SELECT		*
FROM		[ext].[RaspDataView]

-- Nu laver vi et credential til at få adgang til vores datalake 
CREATE CREDENTIAL [https://datalakesu20220620.dfs.core.windows.net]
WITH IDENTITY='Managed Identity'





