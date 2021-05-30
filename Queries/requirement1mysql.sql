USE LSAIR;
SET GLOBAL event_scheduler = ON;

#QUERY1
(SELECT "MOST" AS "Anticipating",
 c.name,
 AVG(TIMESTAMPDIFF(HOUR, ft.date_of_purchase, f.date))  AS "Diference in hours",
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
ORDER BY AVG(TIMESTAMPDIFF(HOUR, ft.date_of_purchase, f.date))  DESC LIMIT 1)
UNION
(SELECT "LEAST" AS "Anticipating", c.name, AVG(TIMESTAMPDIFF(HOUR, ft.date_of_purchase, f.date))  AS "Diference in hours", AVG(ft.price) 
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
ORDER BY AVG(TIMESTAMPDIFF(HOUR, ft.date_of_purchase, f.date))  ASC LIMIT 1);

#QUERY1CHECK
/*
SELECT COUNT(DISTINCT pcount2.personID), cou2.name
FROM Person AS pcount2 
JOIN Country AS cou2 ON cou2.countryID = pcount2.countryID
WHERE cou2.name LIKE "Cameroon" OR cou2.name LIKE "Ghana"
GROUP BY cou2.countryID;
*/
/*
SELECT c.name, AVG(TIMESTAMPDIFF(HOUR, ft.date_of_purchase, f.date))  AS "Diference in hours", AVG(ft.price) 
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
ORDER BY AVG(TIMESTAMPDIFF(HOUR, ft.date_of_purchase, f.date)) ASC;
*/

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

#QUERY3CHECK
/*
(SELECT AVG(p.grade) + 2 FROM Pilot AS p);

SELECT COUNT(fli.flightID), pi.flying_license, copi1.grade FROM Pilot AS pi 
JOIN Flight AS fli ON fli.pilotID = pi.pilotID
JOIN Pilot AS copi1 ON copi1.pilotID = pi.copilotID
GROUP BY copi1.pilotID
ORDER BY COUNT(fli.flightID) DESC;
*/

#QUERY4
SELECT p.name, p.surname, p.born_date
FROM Person AS p
JOIN Passenger AS pa ON p.personID = pa.passengerID 
JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
WHERE YEAR(now()) - YEAR(p.born_date) > 100 AND p.personID NOT IN
(SELECT p.personID
FROM Person AS p
JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID JOIN Flight_FlightAttendant AS fa ON ft.flightID = fa.flightID
JOIN Person AS fap ON fap.personID = fa.flightAttendantID
JOIN LanguagePerson AS lp1 ON lp1.personID = p.personID JOIN LanguagePerson AS lp2 ON lp2.personID = fap.personID
WHERE lp1.languageID = lp2.languageID);

#QUERY4CHECK
/*
SELECT p.name, p.surname, p.born_date
FROM Person AS p
WHERE YEAR(now()) - YEAR(p.born_date) > 100
ORDER BY p.born_date DESC;

SELECT l.name, l.languageID FROM Language AS l WHERE l.languageID NOT IN
(SELECT lp1.languageID
FROM Person AS p
JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID JOIN Flight_FlightAttendant AS fa ON ft.flightID = fa.flightID
JOIN Person AS fap ON fap.personID = fa.flightAttendantID
JOIN LanguagePerson AS lp1 ON lp1.personID = p.personID JOIN LanguagePerson AS lp2 ON lp2.personID = fap.personID
WHERE lp1.languageID = lp2.languageID);

SELECT p.name, p.surname, p.born_date, l.name
FROM Person AS p
JOIN Passenger AS pa ON p.personID = pa.passengerID 
JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN LanguagePerson AS lp ON lp.personID = p.personID
JOIN Language AS l ON l.languageID = lp.languageID
WHERE YEAR(now()) - YEAR(p.born_date) > 100 AND p.personID NOT IN
(SELECT p.personID
FROM Person AS p
JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Flight AS f ON f.flightID = ft.flightID JOIN Flight_FlightAttendant AS fa ON ft.flightID = fa.flightID
JOIN Person AS fap ON fap.personID = fa.flightAttendantID
JOIN LanguagePerson AS lp1 ON lp1.personID = p.personID JOIN LanguagePerson AS lp2 ON lp2.personID = fap.personID
WHERE lp1.languageID = lp2.languageID) ORDER BY p.born_date DESC;
*/


#QUERY 5
SELECT p.name, p.surname, p.personID
FROM Person AS p
WHERE p.personID IN
(SELECT p.personID
FROM Person AS p JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
WHERE ft.business = 1)
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
HAVING COUNT(c.checkinID) >= 2)
GROUP BY p.personID
ORDER BY p.personID ASC;

#QUERY5CHECK
/*
SELECT p.personID
FROM Person AS p JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
WHERE ft.business = 1 GROUP BY p.personID ORDER BY p.personID ASC; 

SELECT p.personID
FROM Person AS p
WHERE p.personID NOT IN (SELECT p.personID
FROM Person AS p JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Checkin AS c ON c.flightTicketID = ft.flightTicketID
WHERE NOT (c.seat = 'F' OR c.seat = 'A'))
GROUP BY p.personID ORDER BY p.personID ASC;

SELECT p.personID
FROM Person AS p JOIN Passenger AS pa ON p.personID = pa.passengerID JOIN FlightTickets AS ft ON ft.passengerID = pa.passengerID
JOIN Checkin AS c ON c.flightTicketID = ft.flightTicketID
GROUP BY p.personID 
HAVING COUNT(c.checkinID) >= 2
ORDER BY p.personID ASC;
*/

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
END $$
DELIMITER ;

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
DELIMITER ;

INSERT INTO FlightTickets (flightID, passengerID, date_of_purchase) 
VALUES (4, 81383, DATE(NOW())) ;

-- SELECT * FROM TicketError;
SELECT * FROM Flight WHERE flightID = 4;
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

DELIMITER ||
DROP TRIGGER IF EXISTS creditCardCrime ||
CREATE TRIGGER creditCardCrime
AFTER INSERT ON Passenger
FOR EACH ROW
BEGIN
	IF NEW.creditCard IN (SELECT creditcard FROM Passenger) THEN
		INSERT INTO CrimeSuspect (SELECT p.personID, p.name, p.surname, p.passport, p.phone_number FROM Person AS p WHERE NEW.passengerID = personID);
	END IF;
END ||
DELIMITER ;

SELECT DISTINCT creditcard FROM Passenger LIMIT 3;
INSERT INTO Passenger (passengerID, creditCard) VALUES (1, '3551506430106933');
INSERT INTO Passenger (passengerID, creditCard) VALUES (2, '6767477861265965621');
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
    FOREIGN KEY (personID) REFERENCES Person(personID)
);

DROP TABLE IF EXISTS CancelledFlightsCommissions;
CREATE TABLE CancelledFlightsCommissions(
    flightID BIGINT UNSIGNED,
	refund BIGINT
);

DELIMITER $$
DROP TRIGGER IF EXISTS deletedFlight $$
CREATE TRIGGER deletedFlight
BEFORE DELETE ON Flight
FOR EACH ROW
BEGIN
	INSERT INTO CancelledFlightsMails 
    (SELECT ft.passengerID, ft.flightID, p.name, p.email, ft.price, ft.business, TIMESTAMPDIFF(HOUR, ft.date_of_purchase, f.date)
    FROM FlightTickets AS ft JOIN Person AS p ON p.personID = ft.passengerID JOIN Flight AS f ON f.flightID = ft.flightID
    WHERE f.flightID = OLD.flightID);
    
    INSERT INTO CancelledFlightsCommissions
	(SELECT c.flightID, c.priceOfTicket * c.priceOfTicket * (c.commission + 1)
    FROM CancelledFlightsMails AS c
    WHERE c.flightID = OLD.flightID AND c.flightID NOT IN (SELECT flightID FROM CancelledFlightsCommissions));
	
	DELETE FROM Flight_FlightAttendant WHERE flightID = OLD.flightID;
	DELETE FROM Checkin WHERE flightTicketID IN (SELECT flightTicketID FROM FlightTickets WHERE flightID = OLD.flightID);
	DELETE FROM Refund WHERE flightTicketID IN (SELECT flightTicketID FROM FlightTickets WHERE flightID = OLD.flightID);
	DELETE FROM FlightTickets WHERE flightID = OLD.flightID;
	DELETE FROM SpecialObjects WHERE SpecialObjectID IN (SELECT luggageID FROM Luggage WHERE flightID = OLD.flightID);
	DELETE FROM CheckedLuggage WHERE CheckedLuggageID IN (SELECT luggageID FROM Luggage WHERE flightID = OLD.flightID);
	DELETE FROM HandLuggage WHERE HandLuggageID IN (SELECT luggageID FROM Luggage WHERE flightID = OLD.flightID);
	DELETE FROM LostObject WHERE LuggageID IN (SELECT luggageID FROM Luggage WHERE flightID = OLD.flightID);
	DELETE FROM Luggage WHERE flightID = OLD.flightID;
    DELETE FROM FlightLuggageHandler WHERE flightID = OLD.flightID;
	DELETE FROM TicketError WHERE flightID = OLD.flightID;
	
END $$
DELIMITER ;

#CHECK TRIGGER 8
DELETE FROM Flight WHERE flightID = 13;

SELECT * FROM CancelledFlightsMails;
SELECT * FROM CancelledFlightsCommissions;



#EVENT9
DROP TABLE IF EXISTS DailyFlights;
CREATE TABLE DailyFlights(
    date DATE,
    numFlights INT
);

DROP TABLE IF EXISTS MonthlyAvgFlights;
CREATE TABLE MonthlyAvgFlights(
	month INT,
    year INT,
    numFlights FLOAT
);

DROP EVENT IF EXISTS eventreq1;
CREATE EVENT eventreq1
    ON SCHEDULE EVERY 10 SECOND
    -- STARTS '2021-01-01:00:00'
    DO
		INSERT INTO DailyFlights(date, numFlights)
			SELECT (f.date), COUNT(DISTINCT f.flightID)
			FROM Flight AS f
            WHERE f.date = CURDATE()
            GROUP BY (f.date);
            
DROP EVENT IF EXISTS eventreq2;
CREATE EVENT eventreq2
    ON SCHEDULE EVERY 30 SECOND
    -- STARTS '2021-01-01:00:00'
    DO
		INSERT INTO MonthlyAvgFlights(month, year, numFlights)
			SELECT MONTH(df.date), YEAR(df.date), AVG(df.numFlights)
			FROM DailyFlights AS df
            WHERE MONTH(df.date) = MONTH(CURDATE()) AND YEAR(df.date) = YEAR(CURDATE())
            GROUP BY YEAR(df.date), MONTH(df.date);
            
            

#CHECKEVENT9
/*
DROP EVENT IF EXISTS eventreq1;
CREATE EVENT eventreq1
    ON SCHEDULE EVERY 10 SECOND
    -- STARTS '2021-01-01:00:00'
    DO
		INSERT INTO DailyFlights(date, numFlights)
			SELECT (f.date), COUNT(DISTINCT f.flightID)
			FROM Flight AS f
            WHERE MONTH(f.date) = 12 AND YEAR(f.date) = 2020
            GROUP BY (f.date);
            
DROP EVENT IF EXISTS eventreq2;
CREATE EVENT eventreq2
    ON SCHEDULE EVERY 30 SECOND
    -- STARTS '2021-01-01:00:00'
    DO
		INSERT INTO MonthlyAvgFlights(month, year, numFlights)
			SELECT MONTH(df.date), YEAR(df.date), AVG(df.numFlights)
			FROM DailyFlights AS df
            WHERE MONTH(df.date) = 12 AND YEAR(df.date) = 2020
            GROUP BY YEAR(df.date), MONTH(df.date);

SELECT * FROM DailyFlights LIMIT 200000;
SELECT * FROM MonthlyAvgFlights;
SELECT * FROM Flight WHERE MONTH(date) = 12 AND YEAR(date) = 2020 ORDER BY date DESC;

SELECT * FROM DailyFlights LIMIT 200000;
SELECT * FROM MonthlyAvgFlights;
SELECT * FROM Flight ORDER BY date DESC;
*/

