USE LSAIR;

#QUERY1 --fix
(SELECT "MOST",
 c.name,
 AVG((f.date - ft.date_of_purchase)*24) AS "Diference in hours",
 AVG(ft.price)
FROM Country AS c 
JOIN Person AS p ON c.countryID = p.countryID 
JOIN Passenger AS pa ON  p.personID = pa.passengerID 
JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID 
JOIN Flight AS f ON f.flightID = ft.flightID
GROUP BY c.countryID
HAVING
	(SELECT COUNT(DISTINCT pcount.personID) 
	FROM Person AS pcount 
    JOIN Country AS cou ON cou.countryID = pcount.countryID
	WHERE cou.countryID = c.countryID) > 300
ORDER BY AVG(f.date - ft.date_of_purchase) DESC LIMIT 1)
UNION
(SELECT "LEAST", c.name, AVG((f.date - ft.date_of_purchase)*24) AS "Diference in hours", AVG(ft.price) 
FROM Country AS c 
JOIN Person AS p ON c.countryID = p.countryID
JOIN Passenger AS pa ON  p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID
GROUP BY c.countryID
HAVING
	(SELECT COUNT(DISTINCT pcount2.personID) 
	FROM Person AS pcount2 
    JOIN Country AS cou2 ON cou2.countryID = pcount2.countryID
	WHERE cou2.countryID = c.countryID) > 300
ORDER BY AVG(f.date - ft.date_of_purchase) ASC LIMIT 1);

#QUERY2
SELECT p.personID, p.name, p.surname, p.born_date
FROM Person AS p 
JOIN Passenger AS Pa ON pa.passengerID = p.personID 
JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID 
JOIN Status AS st ON st.statusID = f.statusID 
JOIN FlightTickets AS ft2 ON ft2.passengerID = pa.passengerID
JOIN Flight AS f2 ON f2.flightID = ft2.flightID 
WHERE st.status = 'Strong Turbulences'AND f2.date > f.date;

#QUERY2CHECK
SELECT p.personID, f2.date, f.date
FROM Person AS p JOIN Passenger AS Pa ON pa.passengerID = p.personID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID JOIN Status AS st ON st.statusID = f.statusID JOIN FlightTickets AS ft2 ON ft2.passengerID = pa.passengerID
JOIN Flight AS f2 ON f2.flightID = ft2.flightID 
WHERE st.status = 'Strong Turbulences'AND f2.date > f.date;

SELECT * FROM Pilot;

#QUERY3
SELECT copilot.flying_license, 
(SELECT COUNT(fli.flightID) 
FROM Pilot AS pi 
JOIN Flight AS fli ON fli.pilotID = pi.pilotID
JOIN Pilot AS copi1 ON copi1.pilotID = pi.copilotID
WHERE copi1.pilotID = copilot.pilotID) AS "Times Copilot",
(SELECT COUNT(fli.flightID)
FROM Pilot AS pi 
JOIN Flight AS fli ON fli.pilotID = pi.pilotID
WHERE pi.pilotID = copilot.pilotID) AS "Times Pilot",
copilot.grade
FROM Pilot AS copilot
GROUP BY copilot.pilotID
HAVING (SELECT COUNT(fli.flightID) FROM Pilot AS pi JOIN Flight AS fli ON fli.pilotID = pi.pilotID
JOIN Pilot AS copi1 ON copi1.pilotID = pi.copilotID
WHERE copi1.pilotID = copilot.pilotID)
> (SELECT COUNT(fli.flightID) FROM Pilot AS pi JOIN Flight AS fli ON fli.pilotID = pi.pilotID
WHERE pi.pilotID = copilot.pilotID)
AND copilot.grade > 2 + (SELECT AVG(p.grade) FROM Pilot AS p)
ORDER BY 
(SELECT COUNT(fli.flightID) FROM Pilot AS pi JOIN Flight AS fli ON fli.pilotID = pi.pilotID
JOIN Pilot AS copi1 ON copi1.pilotID = pi.copilotID
WHERE copi1.pilotID = copilot.pilotID) DESC,
copilot.grade DESC;

#QUERY4
SELECT p.name, p.surname, p.born_date
FROM Person AS p
WHERE YEAR(now()) - YEAR(p.born_date) > 100 AND p.personID NOT IN
(SELECT p.personID
FROM Country AS c JOIN Person AS p ON c.countryID = p.countryID 
JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID JOIN Flight_FlightAttendant AS ffa ON ft.flightID = ffa.flightID
JOIN Flight_Attendant AS fa ON ffa.flightAttendantID = fa.flightAttendantID JOIN Person AS fap ON fap.personID = fa.flightAttendantID
JOIN Country AS fac ON fap.countryID = fac.countryID
WHERE c.countryID = fac.countryID);

#QUERY5
SELECT p.name, p.surname
FROM Person AS p
WHERE p.personID IN
(SELECT p.personID
FROM Person AS p JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
WHERE NOT ft.business = 1)
AND p.personID NOT IN
(SELECT p.personID
FROM Person AS p JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Checkin AS c ON c.flightTicketID = ft.flightTicketID
WHERE NOT (c.seat = 'F' OR c.seat = 'A'))
AND p.personID IN
(SELECT p.personID
FROM Person AS p JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Checkin AS c ON c.flightTicketID = ft.flightTicketID
GROUP BY p.personID
HAVING COUNT(c.checkinID) >= 2);

#TRIGGER6
DROP TRIGGER IF EXISTS invalid;
CREATE TRIGGER invalid() AFTER UPDATE ON personal
FOR EACH ROW
BEGIN

END;

#TRIGGER7

#TRIGGER8

#EVENT9

DROP TABLE IF EXISTS DailyFlights;
CREATE TABLE DailyFlights(
    date DATE,
    numFlights INT
);

DROP TABLE IF EXISTS MonthlyAvgFlights;
CREATE TABLE MonthlyAvgFlights(
	date DATE,
    numFlights FLOAT
);

DROP EVENT IF EXISTS eventreq1;
CREATE EVENT eventreq1
    ON SCHEDULE AT CURRENT_TIMESTAMP() + INTERVAL 1 SECOND
    DO
		INSERT INTO DailyFlights(date, numFlights)
			SELECT MIN(f.date), COUNT(DISTINCT f.flightID)
			FROM Flight AS f
			GROUP BY MIN(f.date);-- ;

SELECT * FROM DailyFlights;


SELECT MIN(f.date) FROM Flight AS f;
