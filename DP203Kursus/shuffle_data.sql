-- hashed table
SELECT  dateid
		,COUNT(*)				AS AntalTure
		, Max(tripdurationseconds)	AS LongestDuration
		, MAX(TripdistanceMiles) AS LongestTrip
FROM dbo.trip_hashed
GROUP BY dateid


-- AAA roundrobin trip tabel
SELECT  dateid
		,COUNT(*)				AS AntalTure
		, Max(tripdurationseconds)	AS LongestDuration
		, MAX(TripdistanceMiles) AS LongestTrip
FROM dbo.trip
GROUP BY dateid


