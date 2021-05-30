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

-- Replace airline name in WHERE clause to validate any of the results
-- obtained in query 2.1
SELECT
    al.name,
    c_s.name AS departureAirport,
    c_d.name AS destinationAirport,
    pt.petrol_capacity,
    r.minimum_petrol
FROM
    routeairline AS ra
    INNER JOIN airline AS al on ra.airlineID = al.airlineID
    INNER JOIN route AS r ON ra.routeID = r.routeID
    INNER JOIN planetype AS pt ON ra.planeTypeID = pt.planetypeID

    -- relations for country
    INNER JOIN airport AS ap_s ON r.departure_airportID = ap_s.airportID
    INNER JOIN airport AS ap_d ON r.destination_airportID = ap_d.airportID
    INNER JOIN city as ci_s ON ap_s.cityID = ci_s.cityID
    INNER JOIN city as ci_d ON ap_d.cityID = ci_d.cityID
    INNER JOIN country c_s ON ci_s.countryID = c_s.countryID
    INNER JOIN country c_d ON ci_d.countryID = c_d.countryID
WHERE
    ci_s.countryID <> ci_d.countryID
    AND r.minimum_petrol > pt.petrol_capacity
    AND al.name LIKE 'Aer Lingus';

-- /*********************************************
-- / QUERY 2.2
-- /*********************************************

SELECT
    CONCAT(me.grade - me.grade MOD 1 , '-', (me.grade - me.grade MOD 1) + 1) AS gradeRange,
    AVG(ma.duration) AS avgDuration
FROM
    maintenance AS ma
    INNER JOIN mechanic me ON ma.mechanicID = me.mechanicID
WHERE ma.maintenanceID IN (
    -- Select those maintenance where less than 10 pieces have been replaced
    SELECT auxMa.maintenanceID
    FROM maintenance AS auxMa
    INNER JOIN piecemaintenance AS auxPm ON auxMa.maintenanceID = auxPm.maintenanceID
    GROUP BY auxMa.maintenanceID
    HAVING COUNT(auxPm.maintenanceID) < 10
)
GROUP BY gradeRange
ORDER BY gradeRange;

-- /************* QUERY VALIDATION *************/

-- Replace range to check all of the ranges individually
SELECT
    ma.duration,
    COUNT(pm.maintenanceID) AS piecesReplaced,
    me.grade
FROM
    maintenance AS ma
    INNER JOIN mechanic me ON ma.mechanicID = me.mechanicID
    INNER JOIN piecemaintenance AS pm ON ma.maintenanceID = pm.maintenanceID
WHERE me.grade BETWEEN 2 AND 3
GROUP BY ma.maintenanceID
HAVING piecesReplaced < 10;

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
GROUP BY ap.airportID
HAVING avgDist > (
    -- Select avg of airports in the same country
    SELECT AVG(auxR.distance) AS auxAvgDist
    FROM airport AS auxAp
    INNER JOIN route AS auxR ON auxAp.airportID = auxR.departure_airportID
    -- Airports from the same country
    INNER JOIN city as auxCi ON auxAp.cityID = auxCi.cityID AND ci.countryID = auxCi.countryID
);

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
SELECT co.countryID, AVG(r.distance) AS auxAvgDist
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
    MAX(r.time) AS longestRouteDuration
FROM
    routeairline AS ra
    INNER JOIN route r on ra.routeID = r.routeID
    INNER JOIN airline AS al ON ra.airlineID = al.airlineID
    INNER JOIN country AS co ON al.countryID = co.countryID
WHERE
    -- Active airlines
    al.active LIKE 'Y'
    -- Airlines should not have departing/entering routes from/to their country
    AND al.airlineID NOT IN (
        SELECT auxAl.airlineID
        FROM routeairline AS auxRa
            INNER JOIN route auxR on auxRa.routeID = auxR.routeID
            INNER JOIN airline AS auxAl ON auxRa.airlineID = auxAl.airlineID
            INNER JOIN country AS auxCo ON auxAl.countryID = auxCo.countryID

            -- Relations for airports countries
            INNER JOIN airport AS ap_s ON auxR.departure_airportID = ap_s.airportID
            INNER JOIN airport AS ap_d ON auxR.destination_airportID = ap_d.airportID
            INNER JOIN city as ci_s ON ap_s.cityID = ci_s.cityID
            INNER JOIN city as ci_d ON ap_d.cityID = ci_d.cityID
        WHERE
            ci_s.countryID = auxAl.countryID
            OR ci_d.countryID = auxAl.countryID
        )
GROUP BY al.airlineID
ORDER BY longestRouteDuration DESC;

-- /************* QUERY VALIDATION *************/

-- Select departure and destination airports of all routes from specified airline
-- Replace airlineID in WHERE clause to validate any of the results from query 2.4
SELECT
    r.routeID,
    al.active AS isAirlineActive,
    co.name AS airlineCountry,
    co_s.name AS departureAirport,
    co_d.name AS destinationAirport
FROM
    routeairline AS ra
    INNER JOIN airline AS al ON ra.airlineID = al.airlineID
    INNER JOIN route AS r ON ra.routeID = r.routeID

    -- airline country
    INNER JOIN country AS co ON al.countryID = co.countryID

    -- departure airport country
    INNER JOIN airport AS ap_s ON r.departure_airportID = ap_s.airportID
    INNER JOIN city AS ci_s ON ap_s.cityID = ci_s.cityID
    INNER JOIN country AS co_s ON ci_s.countryID = co_s.countryID

    -- destination airport country
    INNER JOIN airport AS ap_d ON r.destination_airportID = ap_d.airportID
    INNER JOIN city AS ci_d ON ap_d.cityID = ci_d.cityID
    INNER JOIN country AS co_d ON ci_d.countryID = co_d.countryID
WHERE al.airlineID = 4464;

-- /*********************************************
-- / QUERY 2.5
-- /*********************************************

SELECT
    pl.planeID,
    pi.name,
    COUNT(pi.pieceID) AS timesReplaced
FROM
    plane AS pl
    INNER JOIN maintenance AS m ON pl.planeID = m.planeID
    INNER JOIN piecemaintenance AS pm ON m.maintenanceID = pm.maintenanceID
    INNER JOIN piece AS pi ON pm.pieceID = pi.pieceID
GROUP BY pl.planeID, pi.pieceID, pi.cost
HAVING timesReplaced > 1 AND (pi.cost * timesReplaced) > 0.5 * (
    -- Sum of all of the other pieces
    SELECT SUM(auxPi.cost)
    FROM piece AS auxPi
    INNER JOIN piecemaintenance AS auxPm ON auxPi.pieceID = auxPm.pieceID
    INNER JOIN maintenance AS auxM ON auxPm.maintenanceID = auxM.maintenanceID
    INNER JOIN plane AS auxPl ON auxM.planeID = auxPl.planeID AND auxPl.planeID = pl.planeID
    WHERE auxPi.pieceID <> pi.pieceID
);

-- /************* QUERY VALIDATION *************/

-- Select all pieces replaced from specified plane
SELECT
    pi.name,
    pi.cost
FROM
    maintenance AS ma
    INNER JOIN piecemaintenance AS pm ON ma.maintenanceID = pm.maintenanceID
    INNER JOIN piece AS pi ON pm.pieceID = pi.pieceID
    INNER JOIN plane AS pl ON ma.planeID = pl.planeID
WHERE pl.planeID = 80;

-- Rest of validation is done through excel / manual computations

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

    -- Deletes needed because route is also referenced in table flight
    DELETE FROM flight_flightattendant AS ffa WHERE ffa.flightID IN (
        SELECT f.flightID FROM flight AS f WHERE f.routeID = OLD.routeID);
    DELETE FROM flightluggagehandler AS flh WHERE flh.flightID IN (
        SELECT f.flightID FROM flight AS f WHERE f.routeID = OLD.routeID);
    -- Luggage
    DELETE FROM handluggage AS hl WHERE hl.handluggageID IN (
        SELECT l.luggageID FROM luggage AS l, flight AS f WHERE f.routeID = OLD.routeID AND f.flightID = l.flightID);
    DELETE FROM specialobjects AS so WHERE so.specialobjectID IN (
        SELECT l.luggageID FROM luggage AS l, flight AS f WHERE f.routeID = OLD.routeID AND f.flightID = l.flightID);
    DELETE FROM checkedluggage AS cl WHERE cl.checkedluggageID IN (
        SELECT l.luggageID FROM luggage AS l, flight AS f WHERE f.routeID = OLD.routeID AND f.flightID = l.flightID);
    DELETE FROM lostobject AS lo WHERE lo.lostObjectID IN (
        SELECT l.luggageID FROM luggage AS l, flight AS f WHERE f.routeID = OLD.routeID AND f.flightID = l.flightID);
    DELETE FROM luggage AS l WHERE l.flightID IN (
        SELECT f.flightID FROM flight AS f WHERE f.routeID = OLD.routeID);
    -- FlightTickets
    DELETE FROM refund AS r WHERE r.flightTicketID IN (
        SELECT ft.flightTicketID FROM flighttickets AS ft, flight AS f WHERE f.routeID = OLD.routeID AND f.flightID = ft.flightID);
    DELETE FROM checkin AS c WHERE c.flightTicketID IN (
        SELECT ft.flightTicketID FROM flighttickets AS ft, flight AS f WHERE f.routeID = OLD.routeID AND f.flightID = ft.flightID);

    DELETE FROM flighttickets AS ft WHERE ft.flightID IN (
        SELECT f.flightID FROM flight AS f WHERE f.routeID = OLD.routeID);
    DELETE FROM flight AS f WHERE f.routeID = OLD.routeID;
END $$

DELIMITER ;

-- /************ TRIGGER VALIDATION ************/

-- Activate trigger
DELETE FROM route WHERE route.routeID = 3;
DELETE FROM route WHERE route.routeID = 12;
DELETE FROM route WHERE route.routeID = 45;

-- Tables affected in the trigger
SELECT * FROM RoutesCancelled;
SELECT * FROM routeairline WHERE routeairline.routeID = 1;

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

DROP TRIGGER IF EXISTS FiringsReason $$
CREATE TRIGGER FiringsReason BEFORE DELETE ON mechanic
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
    DELETE FROM piecemaintenance AS pm WHERE pm.maintenanceID IN
        (SELECT ma.maintenanceID FROM maintenance AS ma WHERE ma.mechanicID = OLD.mechanicID);
    DELETE FROM maintenance AS ma WHERE ma.mechanicID = OLD.mechanicID;
END $$

DELIMITER ;

-- /************ TRIGGER VALIDATION ************/

-- Activate trigger
DELETE FROM mechanic WHERE mechanic.mechanicID = 15;    -- Retirement
DELETE FROM mechanic WHERE mechanic.mechanicID = 264;   -- Not completing period
DELETE FROM mechanic WHERE mechanic.mechanicID = 32;    -- No reason

-- Tables affected in the trigger
SELECT * FROM MechanicFirings;
SELECT * FROM piecemaintenance AS pm WHERE pm.maintenanceID IN
        (SELECT ma.maintenanceID FROM maintenance AS ma WHERE ma.mechanicID = 15);
SELECT * FROM maintenance AS ma WHERE ma.mechanicID = 15;

-- Mechanics older than 65
SELECT
    m.*,
    TIMESTAMPDIFF(YEAR, p.born_date, CURDATE()) AS age
FROM
    mechanic AS m
    INNER JOIN person AS p ON m.mechanicID = p.personID
GROUP BY m.mechanicID
HAVING age >= 65;

-- Mechanics not completing the evaluation period
SELECT * FROM maintenance AS ma GROUP BY mechanicID HAVING SUM(ma.duration) < 10;

-- /*********************************************
-- / TRIGGER 2.8
-- /*********************************************

DROP TABLE IF EXISTS EnvironmentalReductions;
CREATE TABLE EnvironmentalReductions (
    route VARCHAR(515),
    petrol_difference INT,
    update_date DATE
);

DELIMITER $$

DROP TRIGGER IF EXISTS PetrolUpdate $$
CREATE TRIGGER PetrolUpdate AFTER UPDATE ON route
FOR EACH ROW
BEGIN
    IF OLD.minimum_petrol > NEW.minimum_petrol THEN
        INSERT INTO EnvironmentalReductions VALUES (
            CONCAT(
                (SELECT ap.name FROM airport AS ap WHERE ap.airportID = OLD.departure_airportID),
                ' -> ',
                (SELECT ap.name FROM airport AS ap WHERE ap.airportID = OLD.destination_airportID)
            ),
            OLD.minimum_petrol - NEW.minimum_petrol,
            CURDATE()
        );
    END IF;
END $$

DELIMITER ;

-- /************ TRIGGER VALIDATION ************/

-- Activate trigger (only if set petrol is lower than actual)
UPDATE route SET minimum_petrol = 8567 WHERE routeID = 4;     -- Petrol increased, ignored
UPDATE route SET minimum_petrol = 4200 WHERE routeID = 8;     -- Petrol decreased, record changes
UPDATE route SET distance = 473 WHERE routeID = 10;           -- distance changed, ignored
UPDATE route SET minimum_petrol = 7298 WHERE routeID = 15;    -- Petrol decreased, record changes

-- Tables affected in the trigger
SELECT * FROM EnvironmentalReductions;

-- /*********************************************
-- / EVENT 2.9
-- /*********************************************

DROP TABLE IF EXISTS MaintenanceCost;
CREATE TABLE MaintenanceCost (
    planeID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    annual_cost BIGINT,
    year INT
);

DROP EVENT IF EXISTS AnnualCosts;
CREATE EVENT AnnualCosts ON SCHEDULE EVERY 1 YEAR
COMMENT 'Records the annual maintenance cost of each plane'
DO
    INSERT INTO MaintenanceCost
    SELECT
        pl.planeID,
        IFNULL(SUM(pi.cost), 0),
        YEAR(CURDATE()) AS year
    FROM
        plane AS pl
        INNER JOIN maintenance AS ma ON pl.planeID = ma.planeID
        LEFT JOIN piecemaintenance AS pm ON ma.maintenanceID = pm.maintenanceID
        LEFT JOIN piece AS pi ON pm.pieceID = pi.pieceID
    WHERE
        YEAR(ma.date) = YEAR(CURDATE())
    GROUP BY pl.planeID;

-- /************* EVENT VALIDATION *************/

-- Maintenance with no cost, no pieces replaced
SELECT ma.*
FROM maintenance AS ma
LEFT JOIN piecemaintenance AS p ON ma.maintenanceID = p.maintenanceID
WHERE p.maintenanceID IS NULL;

-- Update maintenance so that they occur 2021 (Before run event)
UPDATE maintenance SET date = '2021-01-02' WHERE maintenanceID = 1;
UPDATE maintenance SET date = '2021-03-10' WHERE maintenanceID = 2;
UPDATE maintenance SET date = '2021-04-24' WHERE maintenanceID = 3;
UPDATE maintenance SET date = '2021-04-12' WHERE maintenanceID = 4;

UPDATE maintenance SET date = '2021-05-19' WHERE maintenanceID = 282;  -- Cost 0
UPDATE maintenance SET date = '2021-05-31' WHERE maintenanceID = 1074; -- Cost 0

SELECT * FROM MaintenanceCost;

SHOW EVENTS;
