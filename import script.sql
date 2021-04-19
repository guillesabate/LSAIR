USE LSAIR;


/******************************
*
*           RED
*
******************************/

/****** Import Airports ***********/
DROP TABLE IF EXISTS Airport_Imp;
CREATE TABLE Airport_Imp (
	airportID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR (255),
    IATA VARCHAR(3),
    ICAO VARCHAR(4),
    latitude double, 
    longitude double,
    altitude int,
    timezone int,
    DST VARCHAR(255),
    tz VARCHAR(255),
    type VARCHAR (255),
    source VARCHAR(255)
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/airports.csv' 
INTO TABLE Airport_Imp 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Inserts to Country
INSERT INTO COUNTRY (name)
SELECT DISTINCT country FROM Airport_Imp
WHERE country IS NOT NULL;

-- Inserts to City
INSERT INTO CITY (countryID, name, timezone) 
SELECT DISTINCT c.countryID, ai.city, ai.timezone
FROM Country AS c 
JOIN Airport_Imp AS ai ON c.name LIKE ai.country
WHERE city IS NOT NULL;

-- Inserts Airport
INSERT INTO AIRPORT (cityID, name, IATA, latitude, longitude, altitude, type)
SELECT c.cityID, ai.name, ai.IATA, ai.latitude, ai.longitude, ai.altitude, ai.type
FROM Airport_Imp AS ai
JOIN City AS c ON ai.city = c.name AND ai.timezone = c.timezone
JOIN Country AS co ON c.countryID = co.countryID
WHERE co.name LIKE ai.country;

DROP TABLE IF EXISTS Airport_Imp;

/********** Import Airlines **************/
DROP TABLE IF EXISTS Airline_Imp;
CREATE TABLE Airline_Imp (
	airlineID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    alias VARCHAR(255),
    IATA VARCHAR(3),
    ICAO VARCHAR(255),
    callsign VARCHAR(255),
    country VARCHAR(255),
    active VARCHAR(1)
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/airlines.csv' 
INTO TABLE Airline_Imp 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Inserts Country
INSERT INTO COUNTRY (name)
SELECT DISTINCT ai.country 
FROM Airline_Imp AS ai 
WHERE ai.country NOT IN (SELECT co2.name FROM COUNTRY AS co2)
AND ai.country <> BINARY UPPER (ai.country);

-- Inserts Airline
INSERT INTO AIRLINE (airlineID, countryID, name, IATA, active)
SELECT ai.airlineID, co.countryID, ai.name, ai.IATA, ai.active
FROM Airline_Imp AS ai
JOIN Country AS co ON co.name = ai.country;

DROP TABLE IF EXISTS Airline_Imp;

-- Import LowCost
DROP TABLE IF EXISTS lowcost_Imp;
CREATE TABLE lowcost_Imp (
	airline VARCHAR(255),
    lowcost VARCHAR(255)
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/lowcost.csv' 
INTO TABLE lowcost_Imp 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert LowCost
UPDATE Airline AS air,(SELECT a2.airlineID AS lcID, a.airlineID as aID
FROM Airline AS a, Airline AS a2, lowcost_Imp AS li
WHERE a2.name LIKE li.lowcost AND a.name LIKE li.airline) AS lc
SET lowCostID = lc.lcID
WHERE lc.aID = air.airlineID;

DROP TABLE IF EXISTS lowcost_Imp;


/********** Import AirportAirline **************/
/*LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/AirportAirline.csv' 
INTO TABLE AirportAirline 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;*/

/********** Import Plane_Type **************/
DROP TABLE IF EXISTS pt_Imp;
CREATE TABLE pt_Imp (
    type_name VARCHAR(255),
    IATA VARCHAR(3),
    ICAO VARCHAR(4),
    id SERIAL
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/plane_types.csv' 
INTO TABLE pt_Imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE IF EXISTS pt_Imp2;
CREATE TABLE pt_Imp2 (
	id BIGINT UNSIGNED NOT NULL DEFAULT 0,
    capacity int,
    index1 int,
    weight int,
    index2 int,
    weight_supported int,
    index3 int,
    petrol_capacity int
);
 
LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/plane_types_data.csv' 
INTO TABLE pt_Imp2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;    

-- Insert PlaneType
INSERT INTO PlaneType (IATA_plane_type,type_name,capacity,weight,weight_supported,petrol_capacity)
SELECT DISTINCT p.IATA,p.type_name,pd.capacity,pd.weight,pd.weight_supported,pd.petrol_capacity
FROM pt_Imp AS p, pt_Imp2 AS pd 
WHERE p.id = pd.id;

/********** Import Plane **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	airlineID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    planeTypeID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    starting_year BIGINT UNSIGNED NOT NULL DEFAULT 0,
    indexx int,
    retirement_year BIGINT UNSIGNED NOT NULL DEFAULT 0,
    rent_airlineID BIGINT UNSIGNED DEFAULT NULL
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/plane_def.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


UPDATE imp
SET rent_airlineID = NULL WHERE rent_airlineID = 0;


INSERT INTO PLANE (starting_year, retirement_year, airlineID, rent_airlineID, planeTypeID)
SELECT i.starting_year, i.retirement_year, i.airlineID, i.rent_airlineID, i.planeTypeID
FROM imp AS i
JOIN Airline AS a ON i.airlineID = a.airlineID
JOIN PlaneType AS pt ON i.planeTypeID = pt.planeTypeID;

UPDATE Plane
SET retirement_year = NULL WHERE retirement_year > 2021; 





DROP TABLE IF EXISTS pt_Imp3;
CREATE TABLE pt_Imp3 (
    planeID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    planetypeID BIGINT UNSIGNED NOT NULL DEFAULT 0
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/PlanePlaneType.csv' 
INTO TABLE pt_Imp3
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Update Plane adding plane type
/*
UPDATE PLANE AS p, pt_Imp3 AS pt
SET p.planetypeID = pt.planetypeID
WHERE p.planeID = pt.planeID;
*/

DROP TABLE IF EXISTS pt_Imp;
DROP TABLE IF EXISTS pt_Imp2;
DROP TABLE IF EXISTS pt_Imp3;


/********** Import Mechanic **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	countryID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    surname VARCHAR(255),
    passport VARCHAR(11),
    domain VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    born_date DATE,
    sex CHAR,
    salary INT,
    indexx FLOAT,
    years_working INT,
    grade float
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/mechanic.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert a Person
INSERT INTO Person(countryID, name, surname, passport, email, phone_number, born_date, sex)
SELECT i.countryID, i.name, surname, passport, email, phone_number, born_date, sex
FROM imp AS i
JOIN Country AS co ON co.countryID = i.countryID;

-- Insert a Employee
INSERT INTO Employee(employeeID, salary, years_working)
SELECT p.personID, i.salary, i.years_working
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;

-- Insert Mechanic
INSERT INTO Mechanic (mechanicID,grade)
SELECT p.personID, i.grade
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;

UPDATE Employee AS emp, (SELECT (YEAR(p.born_date) + e.years_working) AS da, p.personID AS pID
FROM Person AS p, Employee AS e, Mechanic AS m WHERE e.employeeID = p.personID AND m.mechanicID = e.employeeID) AS d
SET retirement_date = CURRENT_DATE() - INTERVAL FLOOR(RAND() * (YEAR(CURRENT_DATE) - d.da - 15)) YEAR 
WHERE d.pID = emp.employeeID;

UPDATE Employee AS e, Mechanic AS m
SET retirement_date = NULL WHERE MOD(e.employeeID,6) = 0 AND e.employeeID = m.mechanicID;

DROP TABLE IF EXISTS imp;

/********** Import Maintenance **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	duration int,
    planeID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    mechanicID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    date DATE
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/maintenance.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO MAINTENANCE (duration,planeID,mechanicID,date)
SELECT i.duration, i.planeID, i.mechanicID,i.date
FROM imp AS i JOIN Plane AS p ON p.planeID = i.planeID
JOIN Mechanic AS m ON m.mechanicID = i.mechanicID
JOIN Employee AS e ON e.employeeID = m.mechanicID
JOIN Person AS pe ON pe.personID = e.employeeID
WHERE (i.date < e.retirement_date
AND i.date > e.retirement_date - INTERVAL e.years_working year
OR e.retirement_date IS NULL AND i.date > current_date() - INTERVAL e.years_working year)
AND YEAR(i.date) >= p.starting_year
AND YEAR(i.date) <= p.retirement_year;




/********** Import Piece **************/
LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/piece.csv' 
INTO TABLE Piece
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/********** Import PieceMaintenance **************/
LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/MaintenancePiece.csv' 
INTO TABLE piecemaintenance
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/******************************
*
*           GREEN
*
******************************/

/********** Import Route **************/
   
-- Insert Route
LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/ROUTE_def.csv' 
INTO TABLE Route
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert AirlineRoute
LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/RouteAirline_def.csv' 
INTO TABLE RouteAirline
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;




/********** Import Passengers **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	countryID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    surname VARCHAR(255),
    passport VARCHAR(11),
    domain VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    born_date DATE,
    sex CHAR,
	creditCard BIGINT UNSIGNED NOT NULL DEFAULT 0
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/passenger.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert a Person
INSERT INTO Person(countryID, name, surname, passport, email, phone_number, born_date, sex)
SELECT i.countryID, i.name, surname, passport, email, phone_number, born_date, sex
FROM imp AS i
JOIN Country AS co ON co.countryID = i.countryID;

-- Insert Passenger
INSERT INTO Passenger(passengerID,creditCard)
SELECT p.personID, i.creditCard
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;


/********** Import Pilot **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	countryID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    surname VARCHAR(255),
    passport VARCHAR(11),
    domain VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    born_date DATE,
    sex CHAR,
	salary INT,
    years_working INT,
    flying_license VARCHAR(255),
    grade float
	
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/pilot.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert a Person
INSERT INTO Person(countryID, name, surname, passport, email, phone_number, born_date, sex)
SELECT i.countryID, i.name, surname, passport, email, phone_number, born_date, sex
FROM imp AS i
JOIN Country AS co ON co.countryID = i.countryID;

-- Insert Employee
INSERT INTO Employee(employeeID, salary, years_working)
SELECT p.personID, i.salary, i.years_working
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;


-- Insert Pilot
INSERT INTO Pilot (pilotID,flying_license,grade)
SELECT p.personID, i.flying_license, i.grade
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;

UPDATE Employee AS emp, (SELECT (YEAR(p.born_date) + e.years_working) AS da, p.personID AS pID
FROM Person AS p, Employee AS e, Pilot AS pi WHERE e.employeeID = p.personID AND pi.pilotID = e.employeeID) AS d
SET retirement_date = CURRENT_DATE() - INTERVAL FLOOR(RAND() * (YEAR(CURRENT_DATE) - d.da - 15)) YEAR 
WHERE d.pID = emp.employeeID;

UPDATE Employee AS e, Pilot AS pi
SET retirement_date = NULL WHERE MOD(e.employeeID,6) = 0 AND e.employeeID = pi.pilotID;

-- Insert Co-pilot
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	pilotID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    copilotID BIGINT UNSIGNED NOT NULL DEFAULT 0
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/copilot.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Actualitzem id's importació
UPDATE imp AS i
SET i.pilotID = i.pilotID + (SELECT MIN(pilotID) FROM Pilot) - 1;

UPDATE imp AS i
SET i.copilotID = i.copilotID + (SELECT MIN(pilotID) FROM Pilot) - 1;

UPDATE Pilot AS p, imp AS i, Employee AS e1, Employee AS e2
SET p.copilotID = i.copilotID
WHERE i.pilotID = p.pilotID 
AND e1.employeeID = p.pilotID
AND e2.employeeID = i.copilotID
AND year(e2.retirement_date) - e2.years_working < year(e1.retirement_date)
AND year(e1.retirement_date) - e1.years_working < year(e2.retirement_date);

/********** Import Flight Attendant **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	countryID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    surname VARCHAR(255),
    passport VARCHAR(11),
    domain VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    born_date DATE,
    sex CHAR,
	salary INT,
    years_working INT
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/flight_attendant.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert a Person
INSERT INTO Person(countryID, name, surname, passport, email, phone_number, born_date, sex)
SELECT i.countryID, i.name, surname, passport, email, phone_number, born_date, sex
FROM imp AS i
JOIN Country AS co ON co.countryID = i.countryID;

-- Insert Employee
INSERT INTO Employee(employeeID, salary, years_working)
SELECT p.personID, i.salary, i.years_working
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;


-- Insert FlightAttendant
INSERT INTO Flight_Attendant (flightAttendantID)
SELECT p.personID
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;

UPDATE Employee AS emp, (SELECT (YEAR(p.born_date) + e.years_working) AS da, p.personID AS pID
FROM Person AS p, Employee AS e, Flight_Attendant AS fa WHERE e.employeeID = p.personID AND fa.flightAttendantID = e.employeeID) AS d
SET retirement_date = CURRENT_DATE() - INTERVAL FLOOR(RAND() * (YEAR(CURRENT_DATE) - d.da - 15)) YEAR 
WHERE d.pID = emp.employeeID;

UPDATE Employee AS e, Flight_Attendant AS fa
SET retirement_date = NULL WHERE MOD(e.employeeID,6) = 0 AND e.employeeID = fa.flightAttendantID;


/********** Import Status **************/
LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/status.csv' 
INTO TABLE status
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


/********** Import Flight **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	date DATE,
    gate VARCHAR(2),
    departure_hour TIME,
    statusID BIGINT UNSIGNED NOT NULL DEFAULT 0
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/flight.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



INSERT INTO Flight (routeID, date, gate, departure_hour, statusID)
SELECT (SELECT RAND() * MAX(r.routeID) FROM Route AS r), i.date, i.gate, i.departure_hour, i.statusID
FROM imp AS i
JOIN Status AS s ON s.statusID = i.statusID;

UPDATE Flight
SET planeID = NULL;

-- Update de planeID a Flight
UPDATE Flight AS fl, (SELECT p.planeID AS plane, r.routeID AS ro, p.starting_year AS sy, p.retirement_year AS ry
FROM Route AS r 
JOIN RouteAirline AS ra ON r.routeID = ra.routeID
JOIN Plane AS p ON p.planeTypeID = ra.planeTypeID AND p.airlineID = ra.airlineID
) AS pl
SET fl.planeID = pl.plane
WHERE fl.routeID = pl.ro 
AND pl.sy < year(fl.date)
AND (pl.ry > year(fl.date) OR pl.ry IS NULL);



-- Update de pilotID a Flight
UPDATE FLIGHT
SET pilotID = NULL;

UPDATE Flight AS f
SET f.pilotID = (SELECT p.pilotID FROM Pilot AS p ORDER BY RAND() LIMIT 1) WHERE f.pilotID IS NULL;

UPDATE Flight AS f, (SELECT p.pilotID AS id, e.years_working AS yw, e.retirement_date AS rd FROM Pilot AS p
JOIN Employee AS e ON p.pilotID = e.employeeID) AS pi
SET f.pilotID = NULL
WHERE pi.id = f.pilotID
AND (((year(pi.rd) - pi.yw) < year(f.date)
AND year(pi.rd) > year(f.date))
OR (pi.rd IS NULL AND (year(NOW()) - pi.yw) < year(f.date) AND year(pi.rd) > year(f.date))); 

UPDATE Flight AS f
SET f.pilotID = (SELECT p.pilotID FROM Pilot AS p ORDER BY RAND() LIMIT 1) WHERE f.pilotID IS NULL;

UPDATE Flight AS f, (SELECT p.pilotID AS id, e.years_working AS yw, e.retirement_date AS rd FROM Pilot AS p
JOIN Employee AS e ON p.pilotID = e.employeeID) AS pi
SET f.pilotID = NULL
WHERE pi.id = f.pilotID
AND (((year(pi.rd) - pi.yw) < year(f.date)
AND year(pi.rd) > year(f.date))
OR (pi.rd IS NULL AND (year(NOW()) - pi.yw) < year(f.date) AND year(pi.rd) > year(f.date))); 

UPDATE Flight AS f
SET f.pilotID = (SELECT p.pilotID FROM Pilot AS p ORDER BY RAND() LIMIT 1) WHERE f.pilotID IS NULL;

UPDATE Flight AS f, (SELECT p.pilotID AS id, e.years_working AS yw, e.retirement_date AS rd FROM Pilot AS p
JOIN Employee AS e ON p.pilotID = e.employeeID) AS pi
SET f.pilotID = NULL
WHERE pi.id = f.pilotID
AND (((year(pi.rd) - pi.yw) < year(f.date)
AND year(pi.rd) > year(f.date))
OR (pi.rd IS NULL AND (year(NOW()) - pi.yw) < year(f.date) AND year(pi.rd) > year(f.date))); 


-- Update fuel a Flight
UPDATE Flight AS f, (SELECT pt.petrol_capacity * (RAND() * 0.3 + 0.7) AS pc, fl.flightID AS id FROM Flight AS fl
JOIN Route AS r ON fl.routeID = r.routeID
JOIN RouteAirline AS ra ON ra.routeID = r.routeID
JOIN PlaneType AS pt ON pt.planeTypeID = ra.planeTypeID) AS p
SET fuel = p.pc
WHERE f.flightID = id;


/********** Import Flight_FlightAttendant **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	flightID BIGINT UNSIGNED,
    flightAttendantID BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/Flight_FlightAttendant.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE imp 
SET flightID = flightID + (SELECT MIN(flightID) - 1 FROM Flight);

UPDATE imp 
SET flightAttendantID = flightAttendantID + (SELECT MIN(flightAttendantID) - 1 FROM Flight_Attendant);

INSERT INTO Flight_FlightAttendant (FlightID, FlightAttendantID)
SELECT DISTINCT i.flightID, i.flightAttendantID
FROM imp AS i
JOIN Flight AS f ON f.flightID = i.flightID
JOIN Flight_Attendant AS fa ON fa.flightAttendantID = i.flightAttendantID
JOIN Employee AS e ON e.employeeID = fa.flightAttendantID
WHERE (year(e.retirement_date) - e.years_working <= year(f.date) 
OR e.retirement_date IS NULL AND year(now()) - e.years_working <= year(f.date))
AND (e.retirement_date > f.date OR e.retirement_date IS NULL); 


/******************************
*
*           YELLOW
*
******************************/

/********** Import FlightTickets **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	business BOOLEAN,
    price_ int,
    price int,
    flightID bigint unsigned,
    passengerID bigint unsigned
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/flightTickets.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO FlightTickets (passengerID, flightID, price, business)
SELECT i.passengerID, i.flightID, i.price, i.business FROM imp AS i
JOIN Passenger AS pa ON i.passengerID = pa.passengerID
JOIN Person AS p ON pa.passengerID = p.personID
JOIN Flight AS f ON f.flightID = i.flightID
WHERE p.born_date < f.date;


UPDATE FlightTickets AS ft, (SELECT f.date AS date, f.flightID AS id FROM Flight AS f) AS d
SET ft.date_of_purchase = ADDDATE(d.date, INTERVAL - FLOOR(100 * RAND() - (ft.price/10 * RAND())) DAY)
WHERE ft.flightID = d.id;

UPDATE FlightTickets AS ft, (SELECT f.date AS date, f.flightID AS id FROM Flight AS f) AS d
SET ft.date_of_purchase = ADDDATE(d.date, INTERVAL - FLOOR(5 * RAND()) DAY) 
WHERE ft.flightID = d.id AND ft.date_of_purchase >= d.date; 

SELECT COUNT(ft.flightTicketID) AS c FROM FlightTickets AS ft
GROUP BY ft.passengerID ORDER BY c DESC;

/********** Import CheckIn **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	id SERIAL,
	passengerID BIGINT UNSIGNED,
    flightID BIGINT UNSIGNED,
    flightTicketID BIGINT UNSIGNED,
    finalID BIGINT UNSIGNED,
    row int,
    seat char
);

INSERT INTO imp (passengerID, flightID, flightTicketID)
SELECT ft.passengerID, ft.flightID, ft.flightTicketID
FROM FlightTickets AS ft ORDER BY ft.flightID;

UPDATE imp AS i, (SELECT MIN(id) AS min, flightID AS flightID FROM imp GROUP BY flightID) AS f
SET i.finalID = i.id - f.min + 1
WHERE i.flightID = f.flightID;

UPDATE imp AS i
SET i.row = FLOOR(i.finalID/6 - 0.01) + 1;

DROP TABLE IF EXISTS imp2;
CREATE TABLE imp2 (
	id BIGINT UNSIGNED,
    seat char
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/seat.csv' 
INTO TABLE imp2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE imp AS i, imp2 AS i2
SET i.seat = i2.seat
WHERE i.finalID = i2.id;

INSERT INTO CheckIn(flightTicketID, row, seat)
SELECT i.flightTicketID, i.row, i.seat
FROM imp AS i
JOIN FlightTickets AS ft ON ft.flightTicketID = i.flightTicketID
JOIN Flight AS f ON f.flightID = ft.flightID
JOIN Plane AS p ON p.planeID = f.planeID
JOIN PlaneType AS pt ON pt.planeTypeID = p.planeTypeID
WHERE i.finalID <= pt.capacity;



/********** Import LuggageHandler **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	countryID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    surname VARCHAR(255),
    passport VARCHAR(11),
    domain VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    born_date DATE,
    sex CHAR,
    salary INT,
    years_working int,
    max_weight int
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/luggage_handler.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert a Person
INSERT INTO Person(countryID, name, surname, passport, email, phone_number, born_date, sex)
SELECT i.countryID, i.name, surname, passport, email, phone_number, born_date, sex
FROM imp AS i
JOIN Country AS co ON co.countryID = i.countryID;

-- Insert a Employee
INSERT INTO Employee(employeeID, salary, years_working)
SELECT p.personID, i.salary, i.years_working
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;

-- Insert Luggage Handler
INSERT INTO LuggageHandler (luggageHandlerID,maxWeight)
SELECT p.personID, i.max_weight
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;

UPDATE Employee AS emp, (SELECT (YEAR(p.born_date) + e.years_working) AS da, p.personID AS pID
FROM Person AS p, Employee AS e, LuggageHandler AS m WHERE e.employeeID = p.personID AND m.LuggageHandlerID = e.employeeID) AS d
SET retirement_date = CURRENT_DATE() - INTERVAL FLOOR(RAND() * (YEAR(CURRENT_DATE) - d.da - 15)) YEAR 
WHERE d.pID = emp.employeeID;

UPDATE Employee AS e, LuggageHandler AS m
SET retirement_date = NULL WHERE MOD(e.employeeID,6) = 0 AND e.employeeID = m.LuggageHandlerID;

SELECT * FROM Employee, LuggageHandler
WHERE employeeID = luggageHandlerID;






/******************************
*
*           BLUE
*
******************************/

/********** Import Company **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	name VARCHAR(255),
    company_value DOUBLE,
    countryID BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/company.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO Company (name, company_value, countryID)
SELECT i.name, i.company_value, i.countryID
FROM imp AS i
JOIN Country AS c ON c.countryID = i.countryID;

/********** Import WaitingArea **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	companyID BIGINT UNSIGNED,
    airportID BIGINT UNSIGNED,
    opening_hour TIME,
    close_hour time
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/waitingArea.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO WaitingArea (companyID, airportID, opening_hour, close_hour)
SELECT i.companyID, i.airportID, i.opening_hour, i.close_hour
FROM imp AS i
JOIN Company AS c ON c.companyID = i.companyID
JOIN Airport AS a ON a.airportID = i.airportID;

UPDATE WaitingArea
SET opening_hour = DATE_SUB(opening_hour, INTERVAL MINUTE(opening_hour) MINUTE);

UPDATE WaitingArea
SET opening_hour = DATE_SUB(opening_hour, INTERVAL 12 HOUR)
WHERE HOUR(opening_hour) > 11;

UPDATE WaitingArea
SET opening_hour = DATE_ADD(opening_hour, INTERVAL 6 HOUR)
WHERE HOUR(opening_hour) < 4;

UPDATE WaitingArea
SET close_hour = DATE_SUB(close_hour, INTERVAL MINUTE(close_hour) MINUTE);

UPDATE WaitingArea
SET close_hour = DATE_ADD(close_hour, INTERVAL 10 HOUR)
WHERE HOUR(opening_hour) < 14 AND HOUR(close_hour) > 4;


/********** Import Store **************/
INSERT INTO Store (storeID, surface)
SELECT wa.waitingAreaID, 10 + 400 * RAND()
FROM WaitingArea AS wa
WHERE wa.companyID < 150 
OR wa.companyID >= 150 AND wa.companyID < 170 AND wa.waitingAreaID < 1500;


/********** Import Restaurant **************/
INSERT INTO Restaurant (restaurantID, oriented_price, capacity)
SELECT wa.waitingAreaID, FLOOR(30 * RAND() * EXP(RAND())), FLOOR(50 * RAND()) + 5
FROM WaitingArea AS wa
WHERE wa.companyID > 200
OR wa.companyID >= 150 AND wa.companyID < 165 AND wa.waitingAreaID >= 1500
OR wa.companyID >= 165 AND wa.companyID < 170 AND wa.waitingAreaID < 2500 AND wa.waitingAreaID > 1500;

UPDATE Restaurant
SET oriented_price = oriented_price + 20 * RAND() + 2
WHERE oriented_price < 2;

DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	id BIGINT UNSIGNED,
    type VARCHAR(255),
    score float
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/restaurant.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE Restaurant AS r, imp AS i
SET r.type = i.type, r.score = i.score
WHERE i.id = r.restaurantID;

UPDATE Restaurant AS r
SET r.oriented_price = FLOOR(5 + 10 * RAND()) 
WHERE r.type LIKE 'Fast Food' AND r.oriented_price > 17;

UPDATE Restaurant AS r
SET r.oriented_price = FLOOR(r.oriented_price + 20 * RAND())
WHERE r.type LIKE 'Mediterranean' AND oriented_price < 40;


/********** Import Vip Room **************/
INSERT INTO Vip_Room (vipID, price)
SELECT wa.waitingAreaID, 50 + 150 * RAND()
FROM WaitingArea AS wa
WHERE wa.companyID >= 170 AND wa.companyID <= 200
OR wa.companyID >= 165 AND wa.companyID < 170 AND wa.waitingAreaID >= 2500;

DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	id BIGINT UNSIGNED,
    spa VARCHAR(255),
    massage_center VARCHAR(255),
    cinema VARCHAR(255),
    minimum_age int
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/vip_room.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE imp SET spa = 1 WHERE spa LIKE 'true'; 
UPDATE imp SET spa = 0 WHERE spa LIKE 'false'; 
UPDATE imp SET massage_center = 1 WHERE massage_center LIKE 'true'; 
UPDATE imp SET massage_center = 0 WHERE massage_center LIKE 'false'; 
UPDATE imp SET cinema = 1 WHERE cinema LIKE 'true'; 
UPDATE imp SET cinema = 0 WHERE cinema LIKE 'false'; 


UPDATE Vip_Room AS vr, imp AS i
SET vr.spa = i.spa, vr.massage_center = i.massage_center, vr.cinema = i.cinema, vr.minimum_age = i.minimum_age
WHERE vr.vipID = i.id;

UPDATE Vip_Room AS vr, (SELECT r.restaurantID AS restaurant, wa.airportID AS airport, wa.companyID AS company FROM Restaurant AS r
JOIN WaitingArea AS wa ON wa.waitingAreaID = r.restaurantID ORDER BY Rand()) AS res, WaitingArea AS wa
SET vr.restaurantID = res.restaurant 
WHERE vr.vipID = wa.waitingAreaID
AND wa.airportID = res.airport
AND res.restaurant > FLOOR(2064 * RAND()) + 300;


/********** Import Product **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	name VARCHAR(255),
    weight FLOAT,
    companyID BIGINT UNSIGNED,
    price FLOAT,
    fc1 BIGINT UNSIGNED,
    fc2 BIGINT UNSIGNED,
    fc3 BIGINT UNSIGNED,
    fc4 BIGINT UNSIGNED,
    fc5 BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/product.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO Product (companyID, name, weight, price)
SELECT DISTINCT i.companyID, i.name, i.weight, ROUND(i.price,2)
FROM imp AS i
JOIN Company AS c ON c.companyID = i.companyID;

DELETE FROM Product WHERE productID = 14996 OR productID = 2093 OR productID = 2171;


/********** Import ProductStore **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	storeID BIGINT UNSIGNED,
    productID BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/productStore_def.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO ProductStore (storeID, productID)
SELECT DISTINCT i.storeID, i.productID
FROM imp AS i
JOIN Store AS s ON s.storeID = i.storeID
JOIN Product AS p ON p.productID = i.productID;


/********** Import ForbiddenProducts **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	name VARCHAR(255),
    weight FLOAT,
    companyID BIGINT UNSIGNED,
    price FLOAT,
    fc1 BIGINT UNSIGNED,
    fc2 BIGINT UNSIGNED,
    fc3 BIGINT UNSIGNED,
    fc4 BIGINT UNSIGNED,
    fc5 BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/product.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO ForbiddenProducts (productID, countryID)
SELECT DISTINCT p.productID, i.fc1
FROM imp AS i 
JOIN Product AS p ON p.name LIKE i.name AND p.weight = i.weight
JOIN Country AS c ON c.countryID = i.fc1;

INSERT INTO ForbiddenProducts (productID, countryID)
SELECT DISTINCT p.productID, i.fc2
FROM imp AS i 
JOIN Product AS p ON p.name LIKE i.name AND p.weight = i.weight AND p.companyID = i.companyID
JOIN Country AS c ON c.countryID = i.fc2
WHERE i.fc1 <> i.fc2;

INSERT INTO ForbiddenProducts (productID, countryID)
SELECT DISTINCT p.productID, i.fc3
FROM imp AS i 
JOIN Product AS p ON p.name LIKE i.name AND p.weight = i.weight
JOIN Country AS c ON c.countryID = i.fc3
WHERE i.fc1 <> i.fc2
AND i.fc1 <> i.fc3
AND i.fc2 <> i.fc3;

INSERT INTO ForbiddenProducts (productID, countryID)
SELECT DISTINCT p.productID, i.fc5
FROM imp AS i 
JOIN Product AS p ON p.name LIKE i.name AND p.weight = i.weight
JOIN Country AS c ON c.countryID = i.fc5
WHERE i.fc1 <> i.fc2
AND i.fc1 <> i.fc3
AND i.fc2 <> i.fc3
AND i.fc1 <> i.fc5
AND i.fc2 <> i.fc5
AND i.fc3 <> i.fc5;


/********** Import Food **************/

INSERT INTO Food (foodID, expiration_date, countryID)
SELECT p.productID, ADDDATE('2021-03-20', INTERVAL 360 * RAND() DAY), FLOOR((SELECT MAX(countryID) - 20 FROM Country) * RAND() + 1)
FROM Product AS p
WHERE (p.companyID > 100
OR p.companyID > 75 AND p.price < 150);

/********** Import Clothes **************/
INSERT INTO Clothes (clothesID, size)
SELECT p.productID, ROUND(2*RAND(), 2)
FROM Product AS p
WHERE p.companyID <= 75
OR p.companyID > 75 AND p.price >= 150
AND p.companyID <= 100 ;

DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	clothesID BIGINT UNSIGNED,
    color VARCHAR(255),
    type VARCHAR(255)
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/clothes.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE Clothes AS c, imp AS i
SET c.color = i.color, c.type = i.type
WHERE c.clothesID = i.clothesID;

UPDATE Product AS p, Clothes AS c
SET p.price = p.price * (1 + RAND())
WHERE p.productID = c.clothesID AND c.color LIKE 'Golden';



/********** Import Shopkeeper **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	countryID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name VARCHAR(255),
    surname VARCHAR(255),
    passport VARCHAR(11),
    domain VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    born_date DATE,
    sex CHAR,
    salary INT,
    years_working INT,
    comission float,
    weekly_hours TIME,
    waitingAreaID BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/shopkeeper.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Insert a Person
INSERT INTO Person(countryID, name, surname, passport, email, phone_number, born_date, sex)
SELECT i.countryID, i.name, surname, passport, email, phone_number, born_date, sex
FROM imp AS i
JOIN Country AS co ON co.countryID = i.countryID;

-- Insert a Employee
INSERT INTO Employee(employeeID, salary, years_working)
SELECT p.personID, i.salary, i.years_working
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email;

-- Insert Shopkeeper
INSERT INTO Shopkeeper (shopkeeperID,comission,weekly_hours,waitingAreaID)
SELECT p.personID, i.comission, i.weekly_hours, i.waitingAreaID
FROM Person AS p
JOIN imp AS i ON i.passport = p.passport AND i.email = p.email
JOIN WaitingArea AS wa ON wa.waitingAreaID = i.waitingAreaID;

UPDATE Shopkeeper
SET weekly_hours = SUBDATE(weekly_hours, INTERVAL MINUTE(weekly_hours) MINUTE) * ROUND(6*RAND());


/******************************
*
*           YELLOW
*
******************************/
/********** Import Luggage **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
    size VARCHAR(2),
    color VARCHAR(255),
    brand VARCHAR(255),
    weight FLOAT,
    hand_luggage int,
    size_x int,
    size_y int,
    size_z int,
    productID BIGINT UNSIGNED,
    special_object int,
    fragility boolean,
    corrosive boolean,
    flammable boolean,
    extra_cost Float,
    passengerID BIGINT UNSIGNED,
    flightID BIGINT UNSIGNED,
    id SERIAL
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/luggage.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO Luggage (size, color, brand, weight, passengerID, flightID)
SELECT i.size, i.color, i.brand, i.weight, i.passengerID, i.flightID
FROM imp AS i
JOIN Passenger AS p ON p.passengerID = i.passengerID
JOIN Flight AS f ON f.flightID = i.flightID;

INSERT INTO HandLuggage (handluggageID, size_x, size_y, size_z)
SELECT DISTINCT l.luggageID, i.size_x, i.size_y, i.size_z
FROM imp AS i 
JOIN Luggage AS l ON i.id = l.luggageID
WHERE i.hand_luggage = 1;

SELECT ps.productID, ft.flightID, ft.passengerID, wa.airportID, r.departure_airportID FROM ProductStore AS ps
JOIN WaitingArea AS wa ON wa.waitingAreaID = ps.storeID
JOIN Route AS r ON r.departure_airportID = wa.airportID
JOIN Flight AS f ON f.routeID = r.routeID
JOIN FlightTickets AS ft ON ft.flightID = f.flightID;


UPDATE HandLuggage AS h, (SELECT ps.productID AS productID, ft.flightID AS flightID, ft.passengerID AS passengerID FROM ProductStore AS ps
JOIN WaitingArea AS wa ON wa.waitingAreaID = ps.storeID
JOIN Route AS r ON r.departure_airportID = wa.airportID
JOIN Flight AS f ON f.routeID = r.routeID
JOIN FlightTickets AS ft ON ft.flightID = f.flightID) AS p, imp AS i
SET h.productID = p.productID
WHERE i.id = h.handluggageID
AND i.productID = 1
AND i.flightID = p.flightID
AND i.passengerID = p.passengerID
AND p.productID > floor(17000 * RAND());

INSERT INTO CheckedLuggage (checkedluggageID, extra_cost)
SELECT l.luggageID, i.extra_cost
FROM imp AS i
JOIN Luggage AS l ON l.luggageID = i.id
WHERE i.hand_luggage = 0;

INSERT INTO SpecialObjects (specialobjectID, fragile, corrosive, flammable)
SELECT cl.checkedluggageID, i.fragility, i.corrosive, i.flammable
FROM CheckedLuggage AS cl
JOIN imp AS i ON i.id = cl.checkedLuggageID
WHERE i.special_object = 1;

/********** Import FlightLuggageHandler **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
    luggageHandlerID BIGINT UNSIGNED,
    flightID BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/FlightLuggageHandler.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE imp 
SET luggageHandlerID = luggageHandlerID + (SELECT MIN(luggageHandlerID) - 1 FROM LuggageHandler);

INSERT INTO FlightLuggageHandler (luggageHandlerID, flightID)
SELECT DISTINCT i.luggageHandlerID, i.flightID
FROM imp AS i
JOIN LuggageHandler AS lh ON lh.luggageHandlerID = i.luggageHandlerID
JOIN Flight AS f ON f.flightID = i.flightID;


/********** Import Claims **************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
    id BIGINT UNSIGNED,
    passengerID BIGINT UNSIGNED,
    flightID BIGINT UNSIGNED,
    luggageID BIGINT UNSIGNED,
    lost_object int,
    description VARCHAR(255),
    color VARCHAR(255),
    accepted int,
    amount int
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/claims.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO Claims (claimID,passengerID, date)
SELECT i.id, i.passengerID, ADDDATE(f.date, INTERVAL FLOOR(70 * RAND()) DAY)
FROM imp AS i
JOIN Passenger AS p ON p.passengerID = i.passengerID
JOIN Flight AS f ON f.flightID = i.flightID; 

-- Insert LostObject
INSERT INTO LostObject (lostObjectID, luggageID, description, color, founded)
SELECT c.claimID, i.luggageID, i.description, i.color, ROUND(RAND() + 0.2)
FROM imp AS i
JOIN Claims AS c ON c.claimID = i.id
JOIN Luggage AS l ON l.luggageID = i.luggageID
WHERE i.lost_object = 1; 

UPDATE LostObject AS lo, (SELECT luggageID AS lugID, color AS color FROM Luggage) AS l
SET lo.luggageID = NULL
WHERE lo.luggageID = l.lugID AND l.color NOT LIKE lo.color;


-- Insert Refund
DELETE FROM Checkin WHERE flightTicketID = 19313 OR flightTicketID = 2417 
OR flightTicketID = 3511 OR flightTicketID = 405 OR flightTicketID = 10612 OR flightTicketID = 61189;
DELETE FROM FlightTickets WHERE flightTicketID = 19313 OR flightTicketID = 2417 
OR flightTicketID = 3511 OR flightTicketID = 405 OR flightTicketID = 10612 OR flightTicketID = 61189;

INSERT INTO Refund (refundID, flightTicketID, accepted, amount)
SELECT c.claimID, ft.flightTicketID, i.accepted, i.amount
FROM imp AS i
JOIN Claims AS c ON c.claimID = i.id
JOIN FlightTickets AS ft ON ft.flightID = i.flightID AND ft.passengerID = i.passengerID
WHERE i.lost_object = 0
ON DUPLICATE KEY UPDATE refundID = i.id;

UPDATE Refund AS r, (SELECT f.flightID AS flightID, s.status AS status
FROM Flight AS f 
JOIN Status AS s ON f.statusID = s.statusID) AS fl, FlightTickets AS ft
SET r.argument = 'Flight Cancelled' 
WHERE fl.flightID = ft.flightID
AND ft.flightTicketID = r.flightTicketID
AND fl.status LIKE 'Cancelled';

UPDATE Refund AS r, (SELECT f.flightID AS flightID, s.status AS status
FROM Flight AS f 
JOIN Status AS s ON f.statusID = s.statusID) AS fl, FlightTickets AS ft
SET r.argument = 'Flight Delayed' 
WHERE fl.flightID = ft.flightID
AND ft.flightTicketID = r.flightTicketID
AND fl.status LIKE '%Delay%';

SET sql_mode = '';

UPDATE Refund AS r, (SELECT f.flightID AS flightID, s.status AS status, CAST(s.status AS SIGNED INT) AS num
FROM Flight AS f 
JOIN Status AS s ON f.statusID = s.statusID) AS fl, FlightTickets AS ft
SET r.amount = FLOOR(r.amount * fl.num/5 * RAND())
WHERE fl.flightID = ft.flightID
AND ft.flightTicketID = r.flightTicketID
AND argument LIKE 'Flight Delayed';

UPDATE Refund AS r, (SELECT ft.flightTicketID AS id FROM FlightTickets AS ft
JOIN Flight AS f ON ft.flightID = f.flightID
JOIN Plane AS p ON f.planeID = p.planeID
WHERE ft.flightTicketID NOT IN (SELECT c.flightTicketID FROM Checkin AS c)) AS ch
SET r.argument = 'Overbooking'
WHERE r.flightTicketID = ch.id;

UPDATE Refund
SET argument = 'Other' WHERE argument IS NULL;

/************* Import Language ***************/
DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	language VARCHAR(255),
    frequency int
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/languages.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO Language(name)
SELECT language FROM imp;


/************* Import Language ***************/
INSERT INTO LanguagePerson(languageID, personID)
SELECT l.languageID, p.personID
FROM Language AS l, Person AS p, Country AS c
WHERE c.countryID = p.countryID
AND SUBSTRING(c.name,1,4) = SUBSTRING(l.name,1,4)
AND c.name NOT LIKE 'Greenland'
AND c.name NOT LIKE 'Malawi'
AND c.name NOT LIKE 'Montserrat';

INSERT INTO LanguagePerson(languageID,personID)
SELECT l.languageID, p.personID
FROM Language AS l, Person AS p, Country AS c
WHERE c.countryID = p.countryID
AND (c.name LIKE 'China')
AND l.name LIKE 'Mandarin';

INSERT INTO LanguagePerson(languageID,personID)
SELECT l.languageID, p.personID
FROM Language AS l, Person AS p, Country AS c
WHERE c.countryID = p.countryID
AND (c.name LIKE '%Korea%')
AND l.name LIKE 'Korean';

INSERT INTO LanguagePerson(languageID,personID)
SELECT l.languageID, p.personID
FROM Language AS l, Person AS p, Country AS c
WHERE c.countryID = p.countryID
AND (c.name LIKE 'United States')
AND l.name LIKE 'English';

INSERT INTO LanguagePerson(languageID,personID)
SELECT l.languageID, p.personID
FROM Language AS l, Person AS p, Country AS c
WHERE c.countryID = p.countryID
AND (c.name LIKE 'United Kingdom')
AND l.name LIKE 'English';


DROP TABLE IF EXISTS imp;
CREATE TABLE imp (
	language VARCHAR(255),
    personID BIGINT UNSIGNED
);

LOAD DATA LOCAL INFILE '/Users/Shared/csv_S2/languagePerson.csv' 
INTO TABLE imp
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO LanguagePerson (languageID, personID)
SELECT DISTINCT l.languageID, i.personID
FROM imp AS i
JOIN Language AS l ON l.name = i.language
JOIN Person AS p ON p.personID = i.personID
ON DUPLICATE KEY UPDATE languageID = l.languageID;


UPDATE Employee
SET retirement_date = ADDDATE(retirement_date, INTERVAL -FLOOR(365*RAND()) DAY);


DROP TABLE IF EXISTS imp;
DROP TABLE IF EXISTS imp2;





