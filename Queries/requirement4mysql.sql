#QUERY 1 (4.1)

SELECT p.personID, p.name, p.surname, emp.salary
FROM person AS p INNER JOIN employee AS emp ON p.personID = emp.employeeID
    JOIN luggagehandler AS lh ON emp.employeeID = lh.luggagehandlerID INNER JOIN flightluggagehandler AS flh ON lh.luggagehandlerID = flh.luggageHandlerID
WHERE flh.flightID NOT IN (SELECT DISTINCT flha.flightID
                           FROM flightluggagehandler AS flha
                           WHERE flha.luggageHandlerID != flh.luggageHandlerID)
    GROUP BY (p.personID)
    HAVING emp.salary < (SELECT AVG(salary)
                         FROM employee AS e JOIN luggagehandler  AS l ON e.employeeID = l.luggagehandlerID);

#QUERY TO VALIDATE
SELECT p.personID, p.name, p.surname, emp.salary, (SELECT AVG(salary)
                         FROM employee AS e, luggagehandler  AS l
                         WHERE e.employeeID = l.luggagehandlerID) AS 'average salary', COUNT(DISTINCT flh.luggageHandlerID) AS 'luggage handlers'
FROM person AS p INNER JOIN employee AS emp ON p.personID = emp.employeeID,
     luggagehandler AS lh INNER JOIN flightluggagehandler AS flh ON lh.luggagehandlerID = flh.luggageHandlerID
WHERE emp.employeeID = lh.luggagehandlerID AND flh.flightID NOT IN (SELECT DISTINCT flha.flightID
                                                                    FROM flightluggagehandler AS flha
                                                                    WHERE flha.luggageHandlerID != flh.luggageHandlerID)
    GROUP BY (p.personID)
    HAVING emp.salary < (SELECT AVG(salary)
                         FROM employee AS e, luggagehandler  AS l
                         WHERE e.employeeID = l.luggagehandlerID);

#QUERY 2 (4.2)

SELECT p.name, p.email, c.name, l.color, l.brand, (SELECT (lug.weight) FROM luggage AS lug WHERE lug.passengerID = l.passengerID  order by lug.weight limit 1) AS weight, hl.size_x*hl.size_y*hl.size_z AS volume, cl.extra_cost, so.fragile
FROM country c JOIN person p ON p.countryID = c.countryID
    LEFT JOIN luggage AS l on l.passengerID = p.personID
    LEFT JOIN handluggage AS hl ON l.luggageID = hl.handluggageID
    LEFT JOIN checkedluggage AS cl ON cl.checkedluggageID = l.luggageID
    LEFT JOIN specialobjects AS so ON so.specialobjectID = l.luggageID
WHERE SUBSTRING(c.name, 1, 4) LIKE SUBSTRING(p.name, 1, 4)
GROUP BY p.personID;

#VALIDATION

SELECT p.name, p.email, c.name, l.color, l.brand, (SELECT (lug.weight) FROM luggage AS lug WHERE lug.passengerID = l.passengerID  order by lug.weight limit 1) AS weight, hl.size_x*hl.size_y*hl.size_z AS volume, cl.extra_cost, so.fragile,
       (SELECT MIN(lug.weight) FROM luggage AS lug WHERE lug.passengerID = l.passengerID) AS 'min_weight',
       (SELECT MAX(lug.weight) FROM luggage AS lug WHERE lug.passengerID = l.passengerID) AS 'max_weight'
FROM country c, person p
    left  join luggage AS l on l.passengerID = p.personID LEFT JOIN handluggage AS hl ON l.luggageID = hl.handluggageID
    LEFT JOIN checkedluggage AS cl ON cl.checkedluggageID = l.luggageID
    LEFT JOIN specialobjects AS so ON so.specialobjectID = l.luggageID
WHERE p.countryID = c.countryID AND SUBSTRING(c.name, 1, 4) LIKE SUBSTRING(p.name, 1, 4)
GROUP BY p.personID;


#QUERY 3 (4.3) (ASEGURARSE QUE ESTA BE)

SELECT lo.color AS type, COUNT(DISTINCT lo.lostObjectID) AS num_objects, COUNT(DISTINCT l.passengerID) AS num_passengers, COUNT(DISTINCT lo.lostObjectID)/COUNT(DISTINCT l.passengerID) AS ratio
FROM lostobject AS lo LEFT JOIN luggage AS l ON lo.luggageID = l.luggageID
GROUP BY lo.color
HAVING COUNT(DISTINCT l.passengerID) != 0

UNION

SELECT l.brand AS type, COUNT(DISTINCT l.luggageID) AS num_objects, COUNT(DISTINCT l.passengerID), COUNT(DISTINCT lo.lostObjectID)/COUNT(DISTINCT l.passengerID) AS ratio
FROM luggage AS l JOIN lostobject AS lo ON lo.luggageID = l.luggageID
GROUP BY l.brand
ORDER BY ratio DESC;

#QUERY TO VALIDATE
SELECT color, COUNT(DISTINCT luggageID)
FROM lostobject
GROUP BY color;

SELECT brand, COUNT(DISTINCT l.luggageID)
FROM luggage JOIN lostobject l on luggage.luggageID = l.luggageID
GROUP BY brand;

SELECT color FROM lostobject WHERE color = 'Green';

#QUERY 4 (4.4)

SELECT so.specialobjectID, so.fragile +  so.flammable + so.corrosive AS 'hazardous level', cl.extra_cost
FROM specialobjects AS so JOIN checkedluggage AS cl ON so.specialobjectID = cl.checkedluggageID
GROUP BY so.specialobjectID;

#QUERY TO VALIDATE

SELECT so.specialobjectID, so.fragile +  so.flammable + so.corrosive AS 'hazardous level', cl.extra_cost, so.fragile, so.flammable, so.corrosive
FROM specialobjects AS so, checkedluggage AS cl
WHERE so.specialobjectID = cl.checkedluggageID
GROUP BY so.specialobjectID;


#QUERY 5

SELECT p.personID, p.name, p.surname, COUNT(DISTINCT c.claimID) AS claims, COUNT(DISTINCT l.flightID) AS flights
FROM claims AS c JOIN person AS p ON c.passengerID = p.personID JOIN luggage AS l ON c.passengerID = l.passengerID
WHERE l.passengerID NOT IN (SELECT f.passengerID
                         FROM refund AS r LEFT JOIN flighttickets f on r.flightTicketID = f.flightTicketID
                         WHERE r.accepted = 1 AND f.passengerID = l.passengerID)
GROUP BY p.personID
HAVING claims > flights;

#QUERY TO VALIDATE
SELECT p.personID, p.name, p.surname, COUNT(DISTINCT c.claimID) AS claims, COUNT(DISTINCT l.flightID) AS flights, (SELECT COUNT(DISTINCT flightTicketID) FROM refund WHERE accepted = 1 AND flightTicketID = l.flightID) AS 'accepted refunds'
FROM claims AS c, person AS p, luggage AS l
WHERE c.passengerID = p.personID AND c.passengerID = l.passengerID AND l.flightID NOT IN (SELECT r.flightTicketID
                                                                                                  FROM refund AS r
                                                                                                  WHERE r.accepted = 1)
GROUP BY p.personID
HAVING claims > flights;

#TRIGGER 1 (4.6)

DROP TABLE IF EXISTS RefundsAlterations;
CREATE TABLE RefundsAlterations(
    personID INT,
    ticketID INT,
    comment VARCHAR(255)
);

DROP TABLE IF EXISTS aux;
CREATE TABLE aux(
    ticket INT
);

DROP TRIGGER IF EXISTS trig;
CREATE TRIGGER trig BEFORE INSERT ON refund
       FOR EACH ROW BEGIN
                    INSERT INTO aux(ticket)
                    SELECT flightTicketID
                    FROM refund;
                    IF (SELECT COUNT(a.ticket)
                        FROM aux AS a
                        WHERE a.ticket = new.flightTicketID) < 3 AND (SELECT r.accepted FROM refund AS r WHERE new.flightTicketID = r.flightTicketID) = 1
                    THEN
                    INSERT INTO RefundsAlterations(personID, ticketID, comment)
                    SELECT p.personID, r.flightTicketID, 'Refund of a ticket already processed correctly'
                    FROM person AS p JOIN claims AS c ON c.passengerID = p.personID JOIN refund AS r ON c.claimID = r.refundID
                    WHERE new.flightTicketID = r.flightTicketID
                    AND new.flightTicketID NOT IN(SELECT flightTicketID FROM refundsalterations)
                    GROUP BY r.refundID;
                    ELSE
                    IF (SELECT r.accepted FROM refund AS r WHERE new.flightTicketID = r.flightTicketID) = 1
                    THEN
                    UPDATE RefundsAlterations AS ra SET comment = 'Excessive Attempts' WHERE ra.ticketID = new.flightTicketID;
                    END IF;
                    END IF;

                    END;

SELECT * FROM refund WHERE flightTicketID = 32862;
SELECT * FROM refund WHERE flightTicketID = 44235;

#DO THIS IN ORDER TO MAKE THE TRIGGER WORK
INSERT INTO refund VALUES (4,44235,'Other', 0, 66);
INSERT INTO refund VALUES (5,32862,'Other', 0, 66);
INSERT INTO refund VALUES (6,32862,'Other', 0, 66);

#VALIDATION THAT THE TRIGGER WORKS CORECTLY
SELECT * FROM RefundsAlterations;

#DELETION OF THE INSERTED VALUES
DELETE FROM refund WHERE refundID = 4;
DELETE FROM refund WHERE refundID = 5;
DELETE FROM refund WHERE refundID = 6;

#TRIGGER 2 (4.7)

DROP TABLE IF EXISTS LostObjectsDays;
CREATE TABLE LostObjectsDays (
    id INT PRIMARY KEY ,
    days INT,
    avg FLOAT
);

DROP TRIGGER IF EXISTS trig;
CREATE TRIGGER trig AFTER UPDATE ON lostobject FOR EACH ROW BEGIN
    IF (old.founded = 0 AND new.founded = 1)  THEN

        INSERT INTO LostObjectsDays
        SELECT new.lostObjectID, DATEDIFF(CURDATE(), c.date), (SELECT(AVG(DATEDIFF(CURDATE(), cl.date)) )
                                                               FROM lostobject AS lob JOIN claims AS cl ON cl.claimID = lob.lostObjectID
                                                               WHERE lob.description = new.description
                                                               AND (lob.lostObjectID IN (SELECT id FROM lostobjectsdays) OR lob.lostObjectID = new.lostObjectID))
        FROM lostobject AS lo JOIN claims AS c ON c.claimID = lo.lostObjectID
        WHERE new.lostObjectID = lo.lostObjectID
        GROUP BY lo.lostObjectID;

    end if;
end;

#SET TO NOT FOUNDED TWO OBJECTS
UPDATE lostobject SET founded = 0 WHERE lostObjectID = 15;
UPDATE lostobject SET founded = 0 WHERE lostObjectID = 27;

#SET TO FOUNDED TWO OBJECTS IN ORDER TO VALIDATE THE TRIGGER
UPDATE lostobject SET founded = 1 WHERE lostObjectID = 15;
UPDATE lostobject SET founded = 1 WHERE lostObjectID = 27;

#VALIDATION THAT THE TRIGGER WORKS CORRECTLY
SELECT * FROM LostObjectsDays;

#EVENT 1 (4.8)

DROP TABLE IF EXISTS DailyLuggageStatistics;
CREATE TABLE DailyLuggageStatistics(
    date DATE PRIMARY KEY,
    n_kilos FLOAT,
    n_danger_objects INT,
    returned_claims INT
);

DROP EVENT IF EXISTS myeventDaily;
CREATE EVENT myeventDaily
    ON SCHEDULE AT CURRENT_TIMESTAMP() + INTERVAL 1 SECOND
    DO
    INSERT INTO DailyLuggageStatistics
    SELECT (f.date), SUM(l.weight), (SELECT(COUNT(DISTINCT lu.luggageID))
                            FROM luggage AS lu JOIN specialobjects AS sob ON lu.luggageID = sob.specialobjectID
                            WHERE lu.flightID = f.flightID AND (sob.corrosive = 1 OR sob.flammable = 1 OR sob.fragile = 1)) AS 'Danger objects',
                            (SELECT COUNT(DISTINCT c.claimID)
                                                  FROM claims AS c LEFT JOIN lostobject AS los ON los.lostObjectID = c.claimID LEFT JOIN refund AS r ON c.claimID = r.refundID
                                                  WHERE (c.date) = (f.date) AND (los.founded = 1 OR r.accepted = 1)) AS 'accepted or returned claims'
FROM luggage AS l JOIN flight f on l.flightID = f.flightID
WHERE f.date > DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND f.date NOT IN (SELECT date FROM DailyLuggageStatistics);
#GROUP BY (f.date);

DROP TABLE IF EXISTS MonthlyLuggageStatistics;

CREATE TABLE MonthlyLuggageStatistics(
    date VARCHAR(255) PRIMARY KEY,
    n_kilos FLOAT,
    n_danger_objects INT,
    returned_claims INT
);

DROP EVENT IF EXISTS MonthlyLuggageStatistics;
CREATE EVENT MonthlyLuggageStatistics
    ON SCHEDULE AT CURRENT_TIMESTAMP() + INTERVAL 1 MONTH
    DO
    INSERT INTO MonthlyLuggageStatistics
    SELECT DATE_FORMAT((f.date),'%Y-%m'), SUM(l.weight), (SELECT(COUNT(DISTINCT lu.luggageID))
                                                          FROM luggage AS lu JOIN specialobjects AS sob  ON lu.luggageID = sob.specialobjectID
                                                          WHERE lu.flightID = f.flightID AND (sob.corrosive = 1 OR sob.flammable = 1 OR sob.fragile = 1)),
                                                         (SELECT COUNT(DISTINCT c.claimID)
                                                          FROM claims AS c LEFT JOIN lostobject AS los ON los.lostObjectID = c.claimID
                                                                           LEFT JOIN refund AS r ON c.claimID = r.refundID
                                                                           WHERE MONTH(c.date) = MONTH(f.date)
                                                                             AND YEAR(c.date) = YEAR(f.date)
                                                                             AND (los.founded = 1 OR r.accepted = 1))

    FROM luggage AS l JOIN flight f on l.flightID = f.flightID
    WHERE MONTH(f.date) > MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
      AND YEAR(f.date) = YEAR(CURDATE())
      AND DATE_FORMAT((f.date),'%Y-%m') NOT IN (SELECT (date) FROM MonthlyLuggageStatistics);


DROP TABLE IF EXISTS YearlyLuggageStatistics; 
CREATE TABLE YearlyLuggageStatistics( 
    date INT PRIMARY KEY, 
    n_kilos FLOAT, 
    n_danger_objects INT,
    returned_claims INT 
); 

DROP EVENT IF EXISTS YearlyLuggageStatistics; 
CREATE EVENT YearlyLuggageStatistics 
    ON SCHEDULE AT CURRENT_TIMESTAMP() + INTERVAL 1 YEAR 
    DO 
    INSERT INTO YearlyLuggageStatistics 
    SELECT YEAR(f.date), SUM(l.weight), (SELECT(COUNT(DISTINCT lu.luggageID)) 
                                         FROM luggage AS lu JOIN specialobjects AS sob ON lu.luggageID = sob.specialobjectID 
                                         WHERE lu.flightID = f.flightID  AND (sob.corrosive = 1 OR sob.flammable = 1 OR sob.fragile = 1)), 
                                        (SELECT COUNT(DISTINCT c.claimID) 
                                         FROM claims AS c LEFT JOIN lostobject AS los ON los.lostObjectID = c.claimID  
                                                          LEFT JOIN refund AS r ON c.claimID = r.refundID 
                                         WHERE YEAR(c.date) = YEAR(f.date) AND (los.founded = 1 OR r.accepted = 1))  
    
    FROM luggage AS l JOIN flight f on l.flightID = f.flightID 
    WHERE YEAR(f.date) > YEAR(DATE_SUB(CURDATE(), INTERVAL 1 YEAR)) 
      AND YEAR(f.date) NOT IN (SELECT YEAR(date) FROM YearlyLuggageStatistics); 


#EVENT VALIDATION

UPDATE flight SET date = CURDATE() WHERE flightID = 1;
UPDATE luggage SET flightID = 1 WHERE luggageID = 1;

SELECT * FROM luggage;
SELECT * FROM flight WHERE flightID = 1;
SELECT * FROM yearlyluggagestatistics;


DROP TABLE IF EXISTS MonthlyLuggageStatistics;
CREATE TABLE MonthlyLuggageStatistics(
    date VARCHAR(255) PRIMARY KEY,
    n_kilos FLOAT,
    n_danger_objects INT,
    returned_claims INT
);


DROP EVENT IF EXISTS MonthlyLuggageStatistics;
CREATE EVENT MonthlyLuggageStatistics
    ON SCHEDULE AT CURRENT_TIMESTAMP() + INTERVAL 1 SECOND
    DO
    INSERT INTO MonthlyLuggageStatistics
    SELECT DATE_FORMAT((f.date),'%Y-%m'), SUM(l.weight), (SELECT(COUNT(DISTINCT lu.luggageID))
                            FROM luggage AS lu JOIN specialobjects AS sob ON lu.luggageID = sob.specialobjectID
                            WHERE lu.flightID = f.flightID AND (sob.corrosive = 1 OR sob.flammable = 1 OR sob.fragile = 1)) AS 'Danger objects',
                            (SELECT COUNT(DISTINCT c.claimID)
                                                  FROM claims AS c LEFT JOIN lostobject AS los ON los.lostObjectID = c.claimID LEFT JOIN refund AS r ON c.claimID = r.refundID
                                                  WHERE MONTH(c.date) = MONTH(f.date) AND YEAR(c.date) = YEAR(f.date) AND (los.founded = 1 OR r.accepted = 1)) AS 'accepted or returned claims'
FROM luggage AS l JOIN flight f on l.flightID = f.flightID
WHERE MONTH(f.date) > MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AND YEAR(f.date) = YEAR(CURDATE()) AND DATE_FORMAT((f.date),'%Y-%m') NOT IN (SELECT (date) FROM MonthlyLuggageStatistics);

SELECT * FROM MonthlyLuggageStatistics;

DROP TABLE IF EXISTS YearlyLuggageStatistics;
CREATE TABLE YearlyLuggageStatistics(
    date INT PRIMARY KEY,
    n_kilos FLOAT,
    n_danger_objects INT,
    returned_claims INT
);

DROP EVENT IF EXISTS YearlyLuggageStatistics;
CREATE EVENT YearlyLuggageStatistics
    ON SCHEDULE AT CURRENT_TIMESTAMP() + INTERVAL 1 SECOND
    DO
    INSERT INTO YearlyLuggageStatistics
    SELECT YEAR(f.date), SUM(l.weight), (SELECT(COUNT(DISTINCT lu.luggageID))
                            FROM luggage AS lu JOIN specialobjects AS sob ON lu.luggageID = sob.specialobjectID
                            WHERE lu.flightID = f.flightID AND (sob.corrosive = 1 OR sob.flammable = 1 OR sob.fragile = 1)) AS 'Danger objects',
                            (SELECT COUNT(DISTINCT c.claimID)
                                                  FROM claims AS c LEFT JOIN lostobject AS los ON los.lostObjectID = c.claimID LEFT JOIN refund AS r ON c.claimID = r.refundID
                                                  WHERE YEAR(c.date) = YEAR(f.date) AND (los.founded = 1 OR r.accepted = 1)) AS 'accepted or returned claims'
FROM luggage AS l JOIN flight f on l.flightID = f.flightID
WHERE YEAR(f.date) > YEAR(DATE_SUB(CURDATE(), INTERVAL 1 YEAR)) AND YEAR(f.date) NOT IN (SELECT YEAR(date) FROM YearlyLuggageStatistics);

SELECT * FROM YearlyLuggageStatistics;

#CASE STUDY 2

SELECT *, COUNT(DISTINCT la.languageID)
FROM employee AS e JOIN languageperson AS la on la.personID = e.employeeID, pilot AS p
WHERE e.employeeID NOT IN (SELECT emp.employeeID FROM employee AS emp WHERE retirement_date IS NOT NULL) AND salary > 100000 AND p.pilotID = e.employeeID
GROUP BY e.employeeID;

#DATASET 1 (FALTA LO DE QUE ELS PILOTS SIGUIN NON RETIRED, PK LLAVORS NO SORTIA RES, JA QUE NO QUEDEN PILOTS ACTIUS QUE CUMPLEIXIN LES CONDICIONS)

SELECT pi.pilotID, p.name, p.surname, p.email, p.sex, e.salary, e.years_working, l.languageID
FROM person AS p JOIN employee e on p.personID = e.employeeID
     JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID
WHERE e.salary > 100000 AND e.retirement_date IS NOT NULL AND l.personID IN (
    SELECT l3.personID FROM languageperson l3 GROUP BY l3.personID HAVING COUNT(l3.languageID)>3)
GROUP BY p.personID, l.languageID;
#HAVING COUNT(DISTINCT l.languageID) > 3;

SELECT * FROM pilot p, employee e WHERE p.pilotID = e.employeeID  AND p.pilotID = 132017;


#DATASET 2

SELECT fa.flightAttendantID, p2.name, p2.surname, p2.email, p2.sex, emp.salary, emp.years_working, l2.languageID
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID
WHERE fa.flightID IN (SELECT fl.flightID
                        FROM person AS p JOIN employee e on p.personID = e.employeeID
                             JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID
                             JOIN flight AS fl ON fl.pilotID = pi.pilotID
                        WHERE e.salary > 100000 AND e.retirement_date IS NOT NULL
                        GROUP BY p.personID,fl.flightID
                        HAVING COUNT(DISTINCT l.languageID) > 3)
GROUP BY fa.flightAttendantID, l2.languageID;


#CONNECTION OF THE DATASETS

SHOW VARIABLES LIKE 'secure_file_priv';

SELECT f2.flightID, f2.date, ai.name AS destination_airportID, ai2.name AS departure_airportID, fa.flightAttendantID, pil.pilotID
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID,
     flight AS f2 JOIN route r on f2.routeID = r.routeID, airport AS ai, airport AS ai2, pilot as pil
WHERE f2.flightID = fa.flightID AND f2.pilotID = pil.pilotID AND fa.flightID IN (SELECT f.flightID
        FROM person AS p JOIN employee e on p.personID = e.employeeID
            JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID, flight AS f
        WHERE e.salary > 100000 AND f.pilotID = pi.pilotID
        GROUP BY p.personID, f.flightID
        HAVING COUNT(DISTINCT l.languageID) > 3) AND fa.flightID = f2.flightID AND ai.airportID = r.destination_airportID AND ai2.airportID = r.departure_airportID
GROUP BY f2.flightID, fa.flightAttendantID;

#######################################################################

SELECT f2.flightID, f2.date, ai.name AS destination_airportID, ai2.name AS departure_airportID, fa.flightAttendantID, pil.pilotID
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID,
     flight AS f2 JOIN route r on f2.routeID = r.routeID, airport AS ai, airport AS ai2, pilot as pil
WHERE f2.flightID = fa.flightID AND f2.pilotID = pil.pilotID AND fa.flightID IN (SELECT f.flightID
        FROM person AS p JOIN employee e on p.personID = e.employeeID
            JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID, flight AS f
        WHERE e.salary > 100000 AND f.pilotID = pi.pilotID
        GROUP BY p.personID, f.flightID
        HAVING COUNT(DISTINCT l.languageID) > 3) AND fa.flightID = f2.flightID AND ai.airportID = r.destination_airportID AND ai2.airportID = r.departure_airportID
GROUP BY f2.flightID, pil.pilotID;



#-----------------------------NEO4J----------------------------------------------------

LOAD CSV WITH HEADERS FROM
"file:///case_study2.csv" AS csv

CREATE (p:Flight { flightID: ToInteger(csv.flightID),
    date : csv.date,
    destination_airportID : ToInteger(csv.destination_airportID),
    departure_airportID :ToInteger(csv.departure_airportID)})
