USE LSAIR;
SET GLOBAL event_scheduler = ON;

#QUERY1
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
SELECT DISTINCT p.personID, p.name, p.surname, p.born_date
FROM Person AS p
JOIN Passenger AS Pa ON pa.passengerID = p.personID 
JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID 
JOIN Status AS st ON st.statusID = f.statusID  
WHERE p.personID NOT IN
(SELECT DISTINCT p.personID
FROM Person AS p 
JOIN Passenger AS Pa ON pa.passengerID = p.personID 
JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID 
JOIN Status AS st ON st.statusID = f.statusID 
JOIN FlightTickets AS ft2 ON ft2.passengerID = pa.passengerID
JOIN Flight AS f2 ON f2.flightID = ft2.flightID 
WHERE st.status = 'Strong Turbulences' AND f2.date > f.date)
AND st.status = 'Strong Turbulences';

#QUERY2CHECK
/*
SELECT p.personID, f2.date, f.date
FROM Person AS p 
JOIN Passenger AS Pa ON pa.passengerID = p.personID 
JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID 
JOIN Status AS st ON st.statusID = f.statusID 
JOIN FlightTickets AS ft2 ON ft2.passengerID = pa.passengerID
JOIN Flight AS f2 ON f2.flightID = ft2.flightID 
WHERE st.status = 'Strong Turbulences'AND f2.date > f.date;
*/

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
DROP TABLE IF EXISTS TicketError;
CREATE TABLE TicketError(
	personID BIGINT UNSIGNED,
	name VARCHAR(255),
	surname VARCHAR(255),
    flightID BIGINT UNSIGNED,
    dateOfFlight DATE,
    dateOfTicketPurchase DATE,
    FOREIGN KEY (personID) REFERENCES Person(personID),
    FOREIGN KEY (flightID) REFERENCES Flight(flightID)
);

DROP TABLE IF EXISTS tempTicketError;
CREATE TABLE tempTicketError(
    flightTicketID BIGINT UNSIGNED
);

DELIMITER $$
DROP TRIGGER IF EXISTS invalidTicket $$
CREATE TRIGGER invalidTicket
AFTER INSERT ON FlightTickets
FOR EACH ROW
BEGIN
	IF NEW.date_of_purchase > (SELECT f.date FROM Flight AS f WHERE f.FlightID = NEW.flightID) THEN
		INSERT INTO TicketError(personID, name, surname, flightID, dateOfFlight, dateOfTicketPurchase) 
			SELECT p.personID, p.name, p.surname, f.flightID, f.date, ft.date_of_purchase
            FROM Person AS p 
            JOIN FlightTickets AS ft ON ft.passengerID = p.personID
            JOIN Flight AS f ON f.flightID = ft.flightID
            WHERE ft.flightTicketID = NEW.flightTicketID;
		INSERT INTO tempTicketError (SELECT ft2.flightTicketID FROM FlightTickets AS ft2 WHERE ft2.flightTicketID = NEW.flightTicketID);
	END IF;
END $$;
DELIMITER $$;

DELIMITER //
DROP EVENT IF EXISTS eventTicketError //
CREATE EVENT eventTicketError
ON SCHEDULE EVERY 10 SECOND
ON COMPLETION PRESERVE
	DO
	BEGIN
		DELETE FROM FlightTickets WHERE flightTicketID IN (SELECT flightTicketID FROM tempTicketError);
		DELETE FROM tempTicketError WHERE flightTicketID NOT IN (SELECT flightTicketID FROM flightTickets);
	END //
DELIMITER //;

INSERT INTO FlightTickets (flightID, passengerID, date_of_purchase) 
VALUES (4, 81383, DATE(NOW())) ;

-- SELECT * FROM TicketError;
SELECT * FROM FlightTickets WHERE flightID = 4 AND passengerID = 81383;
SELECT * FROM tempTicketError;

#TRIGGER7
DROP TABLE IF EXISTS CrimeSuspect;
CREATE TABLE CrimeSuspect(
	passengerID BIGINT UNSIGNED,
	name VARCHAR(255),
	surname VARCHAR(255),
    passport VARCHAR(255),
	phone VARCHAR(255),
    FOREIGN KEY (passengerID) REFERENCES Passenger(passengerID)
);

DELIMITER //
DROP TRIGGER IF EXISTS creditCardCrime //
CREATE TRIGGER creditCardCrime
AFTER INSERT ON Passenger
FOR EACH ROW
BEGIN
	IF NEW.creditCard IN (SELECT creditcard FROM Passenger) THEN
		INSERT INTO CrimeSuspect (SELECT p.personID, p.name, p.surname, p.passport, p.phone_number FROM Person AS p WHERE NEW.passengerID = personID);
	END IF;
END //;
DELIMITER //;

SELECT creditcard FROM Passenger
INSERT INTO Passenger (passengerID, creditCard) VALUES (1, '3551506430106933');
SELECT * FROM CrimeSuspect;

#TRIGGER8
DROP TABLE IF EXISTS CancelledFlightsMails;
CREATE TABLE CancelledFlightsMails(
	personID BIGINT UNSIGNED,
    flightID BIGINT UNSIGNED,
	namePerson VARCHAR(255),
	emailPerson VARCHAR(255),
    priceOfTicket FLOAT,
    isBusinessTicket INT,
    commission INT,
    FOREIGN KEY (personID) REFERENCES Person(personID),
    FOREIGN KEY (flightID) REFERENCES Flight(flightID)
);

DELIMITER $$
DROP TRIGGER IF EXISTS deletedFlight $$
CREATE TRIGGER deletedFlight
AFTER DELETE ON Flight
FOR EACH ROW
BEGIN
	INSERT INTO CancelledFlightsMails 
    (SELECT ft.passengerID, ft.flightID, p.namePerson, p.emailPerson, ft.priceOfTicket, ft.isBusinessTicket 
    FROM FlightTicket AS ft JOIN Person AS p ON p.personID = ft.passengerID
    WHERE ft.flightID = OLD.flightID);
END $$;
DELIMITER $$;

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
    ON SCHEDULE EVERY 1 DAY
    START '2021-01-01:00:00'
    DO
		INSERT INTO DailyFlights(date, numFlights)
			SELECT (f.date), COUNT(DISTINCT f.flightID)
			FROM Flight AS f
            WHERE f.date = CURDATE()
            GROUP BY (f.date);-- ;

SELECT * FROM DailyFlights;


SELECT MIN(f.date) FROM Flight AS f;
