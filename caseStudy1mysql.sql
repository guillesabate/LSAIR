USE LSAIR;

# DATASET 1
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

# DATASET 2  
SELECT a.airportID, a.name, a.altitude, ci.cityID, ci.name, ci.timezone, c.name
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

# Checking
SELECT a.airportID, a.name, r.destination_airportID, r.departure_airportID, p.planeID
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

/*
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