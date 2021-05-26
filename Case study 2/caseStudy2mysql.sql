USE LSAIR;

SELECT pi.pilotID, p.name, p.surname, p.email, p.sex, e.salary, e.years_working, COUNT(DISTINCT l.languageID) AS 'speaking languages'
FROM person AS p JOIN employee e on p.personID = e.employeeID
     JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID
WHERE e.salary > 100000 AND e.retirement_date IS NOT NULL
GROUP BY p.personID
HAVING COUNT(DISTINCT l.languageID) > 3;

-- SELECT * FROM pilot p, employee e WHERE p.pilotID = e.employeeID  AND p.pilotID = 132017;

#DATASET 2

SELECT fa.flightAttendantID, p2.name, p2.surname, p2.email, p2.sex, emp.salary, emp.years_working, COUNT(DISTINCT l2.languageID)
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID
WHERE fa.flightID IN (SELECT fl.flightID
                        FROM person AS p JOIN employee e on p.personID = e.employeeID
                             JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID
                             JOIN flight AS fl ON fl.pilotID = pi.pilotID
                        WHERE e.salary > 100000 AND e.retirement_date IS NOT NULL
                        GROUP BY p.personID,fl.flightID
                        HAVING COUNT(DISTINCT l.languageID) > 3)
GROUP BY fa.flightAttendantID;


#CONNECTION OF THE DATASETS

-- SHOW VARIABLES LIKE 'secure_file_priv';

SELECT f2.flightID, f2.date, ai.name AS destination_airportID, ai2.name AS departure_airportID, fa.flightAttendantID, pil.pilotID
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID,
     flight AS f2 JOIN route r on f2.routeID = r.routeID, airport AS ai, airport AS ai2, pilot as pil
WHERE f2.flightID = fa.flightID AND f2.pilotID = pil.pilotID AND fa.flightID IN (SELECT f.flightID
        FROM person AS p JOIN employee e on p.personID = e.employeeID
            JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID, flight AS f
        WHERE e.salary > 100000 AND f.pilotID = pi.pilotID
        GROUP BY p.personID, f.flightID
        HAVING COUNT(DISTINCT l.languageID) > 3) AND fa.flightID = f2.flightID AND ai.airportID = r.destination_airportID AND ai2.airportID = r.departure_airportID
GROUP BY f2.flightID, pil.pilotID, fa.flightAttendantID;
