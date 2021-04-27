-- /*********************************************
-- / QUERY 2.1
-- /*********************************************

SELECT
    al.name AS airlineName,
    COUNT(DISTINCT r.routeID) AS numOfRoutes
FROM
    routeairline AS ra
    INNER JOIN airline AS al ON ra.airlineID = al.airlineID
    INNER JOIN route AS r ON ra.routeID = r.routeID
    INNER JOIN planetype AS pt ON ra.planeTypeID = pt.planetypeID

    -- relations for country
    INNER JOIN airport AS ap_s ON r.departure_airportID = ap_s.airportID
    INNER JOIN airport AS ap_d ON r.destination_airportID = ap_d.airportID
    INNER JOIN city as ci_s ON ap_s.cityID = ci_s.cityID
    INNER JOIN city as ci_d ON ap_d.cityID = ci_d.cityID
WHERE
    -- Routes between airports in different countries
    ci_s.countryID <> ci_d.countryID
    -- Min petrol to fly > capacity of the aircraft
    AND r.minimum_petrol > pt.petrol_capacity
GROUP BY al.name;

-- /************* QUERY VALIDATION *************/

-- TODO: query 2.1 validation

-- /*********************************************
-- / QUERY 2.2
-- /*********************************************

SELECT
    CASE
        WHEN me.grade BETWEEN 0 AND 1 THEN '0-1'
        WHEN me.grade BETWEEN 1 AND 2 THEN '1-2'
        WHEN me.grade BETWEEN 2 AND 3 THEN '2-3'
        WHEN me.grade BETWEEN 3 AND 4 THEN '3-4'
        WHEN me.grade BETWEEN 4 AND 5 THEN '4-5'
        WHEN me.grade BETWEEN 5 AND 6 THEN '5-6'
        WHEN me.grade BETWEEN 6 AND 7 THEN '6-7'
        WHEN me.grade BETWEEN 7 AND 8 THEN '7-8'
        WHEN me.grade BETWEEN 8 AND 9 THEN '8-9'
        WHEN me.grade BETWEEN 9 AND 10 THEN '9-10'
    END AS gradeRange,
    AVG(ma.duration) AS avgDuration
FROM
    mechanic AS me
    INNER JOIN maintenance AS ma ON me.mechanicID = ma.mechanicID
GROUP BY gradeRange
ORDER BY gradeRange;

-- /************* QUERY VALIDATION *************/

-- Select avg of grade range individually
-- Change range manually to check all of the ranges
SELECT AVG(ma.duration)
FROM maintenance AS ma INNER JOIN mechanic m ON ma.mechanicID = m.mechanicID
WHERE m.grade BETWEEN 0 AND 1;

-- /*********************************************
-- / QUERY 2.3
-- /*********************************************

SELECT
    ap.airportID,
    ci.countryID,
    AVG(r.distance) AS avgDist
FROM
    airport AS ap
    INNER JOIN route AS r ON ap.airportID = r.departure_airportID
    INNER JOIN city AS ci ON ap.cityID = ci.cityID
GROUP BY ci.countryID, ap.airportID
HAVING avgDist > (
    -- Select avg of airports in the same country
    SELECT AVG(auxR.distance) AS auxAvgDist
    FROM airport AS auxAp
    INNER JOIN route AS auxR ON auxAp.airportID = auxR.departure_airportID
    -- Airports from the same country
    INNER JOIN city as auxCi ON auxAp.cityID = auxCi.cityID AND ci.countryID = auxCi.countryID
)
ORDER BY avgDist;

-- /************* QUERY VALIDATION *************/

-- Select avg of routes departing from each airport
SELECT ap.airportID, c.countryID, AVG(r.distance) AS auxAvgDist
FROM airport AS ap
    LEFT JOIN route AS r ON ap.airportID = r.departure_airportID,
    city AS c
WHERE ap.cityID = c.cityID
GROUP BY ap.airportID
ORDER BY  ap.airportID;

-- Select avg of routes departing from airports in the same country
SELECT  co.countryID, AVG(r.distance) AS auxAvgDist
FROM country AS co
    LEFT JOIN city AS c ON co.countryID = c.countryID
    LEFT JOIN airport AS ap ON c.cityID = ap.cityID
    LEFT JOIN route AS r ON ap.airportID = r.departure_airportID
GROUP BY co.countryID
ORDER BY co.countryID;

-- /*********************************************
-- / QUERY 2.4
-- /*********************************************

SELECT
    al.name,
    al.airlineID,
    co.name,
    MAX(r.time) AS longestRoute
FROM
     country AS co,
     routeairline AS ra
        INNER JOIN airline AS al ON ra.airlineID = al.airlineID
        INNER JOIN route r on ra.routeID = r.routeID

        INNER JOIN airport AS ap_s ON r.departure_airportID = ap_s.airportID
        INNER JOIN airport AS ap_d ON r.destination_airportID = ap_d.airportID
        INNER JOIN city as ci_s ON ap_s.cityID = ci_s.cityID
        INNER JOIN city as ci_d ON ap_d.cityID = ci_d.cityID
        INNER JOIN country co_s on ci_s.countryID = co_s.countryID
        INNER JOIN country co_d on ci_d.countryID = co_d.countryID
WHERE
  -- Airlines should not have departing/entering routes from/to Spain
    co.name LIKE 'Spain'
    AND co_s.name NOT LIKE co.name
    AND co_d.name NOT LIKE co.name
GROUP BY al.airlineID
ORDER BY longestRoute DESC;

-- /************* QUERY VALIDATION *************/

-- TODO: query 2.4 validation

-- /*********************************************
-- / QUERY 2.5
-- /*********************************************

-- TODO: finish query 2.5

SELECT pl.planeID,
       pi.name,
       COUNT(pi.pieceID) AS timesReplaced
FROM plane AS pl
         INNER JOIN maintenance AS m ON pl.planeID = m.planeID
         INNER JOIN piecemaintenance AS pm ON m.maintenanceID = pm.maintenanceID
         INNER JOIN piece AS pi ON pm.pieceID = pi.pieceID

-- /************* QUERY VALIDATION *************/

-- TODO: query 2.5 validation

-- /*********************************************
-- / TRIGGER 2.6
-- /*********************************************

DROP TABLE IF EXISTS RoutesCancelled;
CREATE TABLE RoutesCancelled (
    destination VARCHAR(255),
    origin VARCHAR(255),
    num_airlines INT,
    cancellation_date DATE
);

DELIMITER $$

DROP TRIGGER IF EXISTS CovidCancellations $$
CREATE TRIGGER CovidCancellations BEFORE DELETE ON route
FOR EACH ROW
BEGIN
    -- Insert route cancelled into RoutesCancelled
    INSERT INTO RoutesCancelled VALUES (
        (SELECT ap.name FROM airport AS ap WHERE ap.airportID = OLD.destination_airportID),
        (SELECT ap.name FROM airport AS ap WHERE ap.airportID = OLD.departure_airportID),
        (SELECT COUNT(DISTINCT ra.airlineID) FROM routeairline AS ra WHERE ra.routeID = OLD.routeID),
        CURDATE()
        );

    -- Delete other data from the cancelled route (RouteAirline)
    DELETE FROM routeairline AS ra WHERE ra.routeID = OLD.routeID;
END $$

DELIMITER ;

-- /************ TRIGGER VALIDATION ************/

-- TODO: trigger 2.6 validation

-- /*********************************************
-- / TRIGGER 2.7
-- /*********************************************

DROP TABLE IF EXISTS MechanicFirings;
CREATE TABLE MechanicFirings (
    mechanicID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    surname VARCHAR(255),
    born_date DATE,
    firing_reason VARCHAR(255)
);

DELIMITER $$

DROP TRIGGER IF EXISTS FiringsHistory $$
CREATE TRIGGER FiringsHistory BEFORE DELETE ON mechanic
FOR EACH ROW
BEGIN
    DECLARE mechanic_age INT DEFAULT 0;
    DECLARE repair_hours INT DEFAULT 0;

    -- Get values to determine firing reason
    SET mechanic_age =
        (SELECT TIMESTAMPDIFF(YEAR, p.born_date, CURDATE()) FROM person AS p WHERE p.personID = OLD.mechanicID);
    SET repair_hours = (SELECT SUM(ma.duration) FROM maintenance AS ma WHERE ma.mechanicID = OLD.mechanicID);

    -- Insert firing reason to MechanicFiring
    INSERT INTO MechanicFirings VALUES (
        OLD.mechanicID,
        (SELECT p.name FROM person AS p WHERE p.personID = OLD.mechanicID),
        (SELECT p.surname FROM person AS p WHERE p.personID = OLD.mechanicID),
        (SELECT p.born_date FROM person AS p WHERE p.personID = OLD.mechanicID),
        (SELECT
            CASE
                WHEN mechanic_age >= 65 THEN 'Retirement'
                WHEN repair_hours < 10 THEN 'Not completing the evaluation period'
                ELSE 'Firing without reason'
            END
        )
    );

    -- Delete other data from the fired mechanic (Maintenance and PieceMaintenance)
    -- First delete from PieceMaintenance as Maintenance hold id
    DELETE FROM piecemaintenance AS pm WHERE pm.maintenanceID =
        (SELECT ma.maintenanceID FROM maintenance AS ma WHERE ma.mechanicID = OLD.mechanicID);
    DELETE FROM maintenance AS ma WHERE ma.mechanicID = OLD.mechanicID;
END $$

DELIMITER ;

-- /************ TRIGGER VALIDATION ************/

-- TODO: trigger 2.7 validation

-- /*********************************************
-- / TRIGGER 2.8
-- /*********************************************

DROP TABLE IF EXISTS EnvironmentalReductions;
CREATE TABLE EnvironmentalReductions (
    route VARCHAR(255),
    petrol_difference INT,
    update_date DATE
);

DELIMITER $$

-- WHEN (OLD.minimum_petrol > NEW.minimum_petrol)

DROP TRIGGER IF EXISTS PetrolUpdate $$
CREATE TRIGGER PetrolUpdate AFTER UPDATE ON route
FOR EACH ROW
BEGIN
    INSERT INTO EnvironmentalReductions VALUES (
        CONCAT(
            (SELECT ap.name FROM airport AS ap WHERE ap.airportID = OLD.departure_airportID),
            '-',
            (SELECT ap.name FROM airport AS ap WHERE ap.airportID = OLD.destination_airportID)
        ),
        ABS(OLD.minimum_petrol - NEW.minimum_petrol),
        CURDATE()
    );
END $$

DELIMITER ;

-- /************ TRIGGER VALIDATION ************/

-- TODO: trigger 2.8 validation

-- /*********************************************
-- / EVENT 2.9
-- /*********************************************

DROP TABLE IF EXISTS MaintenanceCost;
CREATE TABLE MaintenanceCost (
    plane_name VARCHAR(255),
    annual_cost FLOAT
);

DROP EVENT IF EXISTS AnnualCosts;
CREATE EVENT AnnualCosts ON SCHEDULE EVERY 1 YEAR
COMMENT 'Records the annual maintenance cost of each plane'
DO
    INSERT INTO MaintenanceCost
    SELECT
        pt.type_name,
        SUM(pi.cost)
    FROM
        plane AS pl
        INNER JOIN planetype AS pt ON pl.planetypeID = pt.planetypeID

        INNER JOIN maintenance AS ma ON pl.planeID = ma.planeID
        INNER JOIN piecemaintenance AS pm ON ma.maintenanceID = pm.maintenanceID
        INNER JOIN piece AS pi ON pm.pieceID = pi.pieceID
    WHERE
        YEAR(ma.date) = YEAR(CURDATE())
    GROUP BY pl.planeID;

-- /************* EVENT VALIDATION *************/

-- TODO: event 2.9 validation
