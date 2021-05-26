USE LSAIR;
-- SHOW VARIABLES LIKE 'secure_file_priv';

SELECT "PlaneID","RetirementYear","TypeName","AirlineName","TimesMaintenance","PiecesCosts"
UNION ALL
SELECT p.planeID, p.retirement_year, pt.type_name, a.name, NULL AS "Times in Maintenance", NULL AS "Piece Costs"
FROM Plane AS p JOIN PlaneType AS pt ON p.planetypeID = pt.planetypeID
JOIN Airline AS a ON a.airlineID = p.airlineID
JOIN Country AS c ON c.countryID = a.countryID
WHERE p.planeID NOT IN (SELECT m.planeID FROM Maintenance AS m)
AND retirement_year IS NOT NULL AND c.name LIKE "S%"
AND YEAR(NOW()) - retirement_year <= 3
GROUP BY p.planeID
UNION
SELECT DISTINCT(p.planeID), p.retirement_year, pt.type_name, a.name, COUNT(DISTINCT m.maintenanceID), SUM(pi.cost)
FROM Plane AS p JOIN PlaneType AS pt ON p.planetypeID = pt.planetypeID
JOIN Airline AS a ON a.airlineID = p.airlineID
JOIN Country AS c ON c.countryID = a.countryID
JOIN Maintenance AS m ON p.planeID = m.planeID
JOIN PieceMaintenance AS pm ON m.maintenanceID = pm.maintenanceID
JOIN Piece AS pi ON pi.pieceID = pm.pieceID
WHERE retirement_year IS NOT NULL AND c.name LIKE "S%"
AND YEAR(NOW()) - retirement_year <= 3
GROUP BY p.planeID
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 5.7/Uploads/case_study1_dataset1.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

# DATASET 2
SELECT "AirportID","AirportName","Altitude","CityID","CityName","Timezone", "CountryName"
UNION ALL
SELECT DISTINCT(a.airportID), a.name, a.altitude, ci.cityID, ci.name, ci.timezone, c.name
FROM Airport AS a JOIN City AS ci ON ci.cityID = a.cityID
JOIN Country AS c ON c.countryID = ci.countryID
JOIN Route AS r ON r.destination_airportID = a.airportID OR r.departure_airportID = a.airportID
JOIN Flight AS f ON f.routeID = r.routeID
JOIN Plane AS p ON p.planeID = f.planeID
WHERE p.planeID IN
	(SELECT p.planeID
	FROM Plane AS p JOIN PlaneType AS pt ON p.planetypeID = pt.planetypeID
	JOIN Airline AS a ON a.airlineID = p.airlineID
	JOIN Country AS c ON c.countryID = a.countryID
	WHERE retirement_year IS NOT NULL AND c.name LIKE "S%"
	AND YEAR(NOW()) - retirement_year <= 3)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 5.7/Uploads/case_study1_dataset2.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

 # DATASET CONNECTION
SELECT "AirportID","PlaneID"
UNION ALL
SELECT a.airportID, p.planeID
FROM Airport AS a JOIN City AS ci ON ci.cityID = a.cityID
JOIN Country AS c ON c.countryID = ci.countryID
JOIN Route AS r ON r.destination_airportID = a.airportID OR r.departure_airportID = a.airportID
JOIN Flight AS f ON f.routeID = r.routeID
JOIN Plane AS p ON p.planeID = f.planeID
WHERE p.planeID IN
	(SELECT p.planeID
	FROM Plane AS p JOIN PlaneType AS pt ON p.planetypeID = pt.planetypeID
	JOIN Airline AS a ON a.airlineID = p.airlineID
	JOIN Country AS c ON c.countryID = a.countryID
	WHERE retirement_year IS NOT NULL AND c.name LIKE "S%"
	AND YEAR(NOW()) - retirement_year <= 3)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 5.7/Uploads/case_study1_dataset3.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


/*
# Checking
SELECT a.airportID, a.name, r.destination_airportID, r.departure_airportID, p.planeID, f.flightID
FROM Airport AS a JOIN City AS ci ON ci.cityID = a.cityID
JOIN Country AS c ON c.countryID = ci.countryID
JOIN Route AS r ON r.destination_airportID = a.airportID OR r.departure_airportID = a.airportID
JOIN Flight AS f ON f.routeID = r.routeID
JOIN Plane AS p ON p.planeID = f.planeID
WHERE p.planeID IN
	(SELECT p.planeID
	FROM Plane AS p JOIN PlaneType AS pt ON p.planetypeID = pt.planetypeID
	JOIN Airline AS a ON a.airlineID = p.airlineID
	JOIN Country AS c ON c.countryID = a.countryID
	WHERE retirement_year IS NOT NULL AND c.name LIKE "S%"
	AND YEAR(NOW()) - retirement_year <= 3);

SELECT p.planeID, p.retirement_year, pt.type_name, a.name, NULL AS "Times in Maintenance", NULL AS "Piece Costs"
FROM Plane AS p JOIN PlaneType AS pt ON p.planetypeID = pt.planetypeID
JOIN Airline AS a ON a.airlineID = p.airlineID
JOIN Country AS c ON c.countryID = a.countryID
WHERE p.planeID NOT IN (SELECT m.planeID FROM Maintenance AS m)
AND retirement_year IS NOT NULL AND c.name LIKE "S%"
AND YEAR(NOW()) - retirement_year <= 3
GROUP BY p.planeID
UNION
SELECT p.planeID, p.retirement_year, pt.type_name, a.name, COUNT(DISTINCT m.maintenanceID), SUM(pi.cost)
FROM Plane AS p JOIN PlaneType AS pt ON p.planetypeID = pt.planetypeID
JOIN Airline AS a ON a.airlineID = p.airlineID
JOIN Country AS c ON c.countryID = a.countryID
JOIN Maintenance AS m ON p.planeID = m.planeID
JOIN PieceMaintenance AS pm ON m.maintenanceID = pm.maintenanceID
JOIN Piece AS pi ON pi.pieceID = pm.pieceID
WHERE retirement_year IS NOT NULL AND c.name LIKE "S%"
AND YEAR(NOW()) - retirement_year <= 3
GROUP BY p.planeID;
*/
