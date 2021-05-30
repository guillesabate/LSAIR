####DATASET 1###################

SELECT pi.pilotID, p.name, p.surname, p.email, p.sex, e.salary, e.years_working, l2.name AS language_name
FROM person AS p JOIN employee e on p.personID = e.employeeID
     JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID JOIN language l2 on l.languageID = l2.languageID

WHERE e.salary > 100000 AND e.retirement_date IS NOT NULL AND l.personID IN (
    SELECT l3.personID FROM languageperson l3 GROUP BY l3.personID HAVING COUNT(l3.languageID)>3)
GROUP BY p.personID, l.languageID
INTO OUTFILE 'C:/Users/josep/AppData/Local/Programs/Neo4j Desktop/relate-data/dbmss/dbms-051e915e-2eab-4bbb-b37c-0afe42890e39/import/dataset1.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

####DATASET 2####################

SELECT fa.flightAttendantID, p2.name, p2.surname, p2.email, p2.sex, emp.salary, emp.years_working, l3.name AS language_name
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID JOIN language l3 on l2.languageID = l3.languageID
WHERE fa.flightID IN (SELECT fl.flightID
                        FROM person AS p JOIN employee e on p.personID = e.employeeID
                             JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID
                             JOIN flight AS fl ON fl.pilotID = pi.pilotID
                        WHERE e.salary > 100000 AND e.retirement_date IS NOT NULL
                        GROUP BY p.personID,fl.flightID
                        HAVING COUNT(DISTINCT l.languageID) > 3)
GROUP BY fa.flightAttendantID, l2.languageID
INTO OUTFILE 'C:/Users/josep/AppData/Local/Programs/Neo4j Desktop/relate-data/dbmss/dbms-051e915e-2eab-4bbb-b37c-0afe42890e39/import/dataset2.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

####DATASET 3####################

SELECT f2.flightID, f2.date, ai.airportID AS destination_airportID, ai2.airportID AS departure_airportID
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID,
     flight AS f2 JOIN route r on f2.routeID = r.routeID, airport AS ai, airport AS ai2, pilot as pil
WHERE f2.flightID = fa.flightID AND f2.pilotID = pil.pilotID AND fa.flightID IN (SELECT f.flightID
        FROM person AS p JOIN employee e on p.personID = e.employeeID
            JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID, flight AS f
        WHERE e.salary > 100000 AND f.pilotID = pi.pilotID
        GROUP BY p.personID, f.flightID
        HAVING COUNT(DISTINCT l.languageID) > 3) AND fa.flightID = f2.flightID AND ai.airportID = r.destination_airportID AND ai2.airportID = r.departure_airportID
GROUP BY f2.flightID, fa.flightAttendantID
INTO OUTFILE 'C:/Users/josep/AppData/Local/Programs/Neo4j Desktop/relate-data/dbmss/dbms-051e915e-2eab-4bbb-b37c-0afe42890e39/import/dataset3.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

####DATASET 4####################

SELECT f2.flightID, pil.pilotID
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID,
     flight AS f2 JOIN route r on f2.routeID = r.routeID, airport AS ai, airport AS ai2, pilot as pil
WHERE f2.flightID = fa.flightID AND f2.pilotID = pil.pilotID AND fa.flightID IN (SELECT f.flightID
        FROM person AS p JOIN employee e on p.personID = e.employeeID
            JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID, flight AS f
        WHERE e.salary > 100000 AND f.pilotID = pi.pilotID
        GROUP BY p.personID, f.flightID
        HAVING COUNT(DISTINCT l.languageID) > 3) AND fa.flightID = f2.flightID AND ai.airportID = r.destination_airportID AND ai2.airportID = r.departure_airportID
GROUP BY f2.flightID, pil.pilotID
INTO OUTFILE 'C:/Users/josep/AppData/Local/Programs/Neo4j Desktop/relate-data/dbmss/dbms-051e915e-2eab-4bbb-b37c-0afe42890e39/import/dataset4.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


####DATASET 5####################

SELECT f2.flightID, fa.flightAttendantID
FROM flight_flightattendant AS fa JOIN employee AS emp ON emp.employeeID = fa.flightAttendantID JOIN person p2 on emp.employeeID = p2.personID JOIN languageperson l2 on p2.personID = l2.personID,
     flight AS f2 JOIN route r on f2.routeID = r.routeID, airport AS ai, airport AS ai2, pilot as pil
WHERE f2.flightID = fa.flightID AND f2.pilotID = pil.pilotID AND fa.flightID IN (SELECT f.flightID
        FROM person AS p JOIN employee e on p.personID = e.employeeID
            JOIN pilot pi on e.employeeID = pi.pilotID JOIN languageperson l on p.personID = l.personID, flight AS f
        WHERE e.salary > 100000 AND f.pilotID = pi.pilotID
        GROUP BY p.personID, f.flightID
        HAVING COUNT(DISTINCT l.languageID) > 3) AND fa.flightID = f2.flightID AND ai.airportID = r.destination_airportID AND ai2.airportID = r.departure_airportID
GROUP BY f2.flightID, fa.flightAttendantID
INTO OUTFILE 'C:/Users/josep/AppData/Local/Programs/Neo4j Desktop/relate-data/dbmss/dbms-051e915e-2eab-4bbb-b37c-0afe42890e39/import/dataset5.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
