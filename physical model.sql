DROP DATABASE IF EXISTS LSAIR;
CREATE DATABASE LSAIR;
USE LSAIR;



/*VIOLETA*/
DROP TABLE IF EXISTS COUNTRY;
CREATE TABLE COUNTRY(		
				countryID SERIAL, 
                name VARCHAR(255),
                PRIMARY KEY (countryID)
);
SELECT * FROM COUNTRY;

DROP TABLE IF EXISTS CITY;
CREATE TABLE CITY(
				cityID SERIAL, 
                countryID BIGINT UNSIGNED NOT NULL DEFAULT 0, 
                name VARCHAR(255),
                timezone int,
                PRIMARY KEY (cityID),
                FOREIGN  KEY (countryID) REFERENCES COUNTRY(countryID)
);

DROP TABLE IF EXISTS PERSON;
CREATE TABLE PERSON(
				personID SERIAL,
                name VARCHAR(255),
                surname VARCHAR(255),
                countryID BIGINT UNSIGNED NOT NULL DEFAULT 0, 
				passport VARCHAR(11), 
                email VARCHAR(255),
                phone_number VARCHAR(20), 
                born_date DATE, 
                sex CHAR,
                PRIMARY KEY (personID),
				FOREIGN  KEY (countryID) REFERENCES COUNTRY(countryID)
);


DROP TABLE IF EXISTS EMPLOYEE;
CREATE TABLE EMPLOYEE(
				employeeID BIGINT UNSIGNED NOT NULL DEFAULT 0, 
				salary INT, 
				years_working INT,
                retirement_date DATE,
                PRIMARY KEY (employeeID),
                FOREIGN KEY (employeeID) REFERENCES Person(personID)
);


/*ROJO*/
DROP TABLE IF EXISTS AIRPORT;
CREATE TABLE AIRPORT(
				airportID SERIAL,
                cityID BIGINT UNSIGNED NOT NULL DEFAULT 1, 
                name VARCHAR(255), 
                IATA VARCHAR(3), 
                latitude double,
                longitude double,
                altitude int,
                type VARCHAR(255), 
                PRIMARY KEY (airportID),
                FOREIGN  KEY (cityID) REFERENCES CITY(cityID)
);

/*
DROP TABLE IF EXISTS INVESTOR;
CREATE TABLE INVESTOR(
				investorID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                airportID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                name VARCHAR(255), 
                money FLOAT, 
                investmentseat TEXT,
                PRIMARY KEY (investorID),
				FOREIGN  KEY (airportID) REFERENCES AIRPORT(airportID)
);
*/


DROP TABLE IF EXISTS AIRLINE;
CREATE TABLE AIRLINE(
				airlineID BIGINT UNSIGNED DEFAULT 0,
                countryID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                name VARCHAR(255), 
                IATA VARCHAR(3),
                active VARCHAR(1), 
                lowCostID BIGINT UNSIGNED DEFAULT NULL,
                PRIMARY KEY (airlineID),
				FOREIGN  KEY (countryID) REFERENCES COUNTRY(countryID),
                FOREIGN KEY (lowCostID) REFERENCES AIRLINE (airlineID)
);

DROP TABLE IF EXISTS PLANE;
CREATE TABLE PLANE(
				planeID SERIAL,
                starting_year BIGINT UNSIGNED NOT NULL DEFAULT 0, 
                retirement_year BIGINT UNSIGNED DEFAULT 0,
                airlineID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                rent_airlineID BIGINT UNSIGNED DEFAULT NULL,
                planetypeID BIGINT UNSIGNED DEFAULT NULL,
                PRIMARY KEY (planeID),
                FOREIGN  KEY (airlineID) REFERENCES AIRLINE(airlineID),
                FOREIGN KEY (rent_airlineID) REFERENCES AIRLINE (airlineID)
);


DROP TABLE IF EXISTS PLANETYPE;
CREATE TABLE PLANETYPE(
                planetypeID SERIAL,
                IATA_plane_type VARCHAR(3),
                type_name VARCHAR(255), 
                capacity int, 
                weight int,
                weight_supported int,
                petrol_capacity BIGINT UNSIGNED NOT NULL DEFAULT 0, 
                PRIMARY KEY (planetypeID)
);

ALTER TABLE PLANE ADD CONSTRAINT fk_IATA_plane_type FOREIGN KEY (planetypeID) REFERENCES PLANETYPE (planetypeID);


DROP TABLE IF EXISTS PIECE;
CREATE TABLE PIECE(
				pieceID SERIAL, 
                name VARCHAR(255), 
                cost FLOAT,
                PRIMARY KEY (pieceID)
);

DROP TABLE IF EXISTS MECHANIC;
CREATE TABLE MECHANIC(
				mechanicID SERIAL,
				grade FLOAT,
                PRIMARY KEY (mechanicID),
                FOREIGN KEY (mechanicID) REFERENCES Person (personID)
);


DROP TABLE IF EXISTS MAINTENANCE;
CREATE TABLE MAINTENANCE(
				maintenanceID SERIAL, 
                duration INT, 
                planeID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                mechanicID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                date date,
                PRIMARY KEY (maintenanceID),
                FOREIGN KEY (planeID) REFERENCES PLANE (planeID),
                FOREIGN KEY (mechanicID) REFERENCES MECHANIC (mechanicID)
);

DROP TABLE IF EXISTS PieceMaintenance;
CREATE TABLE PieceMaintenance (
				maintenanceID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                pieceID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                PRIMARY KEY (maintenanceID, pieceID),
                FOREIGN KEY (maintenanceID) REFERENCES MAINTENANCE (maintenanceID),
                FOREIGN KEY (pieceID) REFERENCES Piece (pieceID)
);

/*
DROP TABLE IF EXISTS InvestorAirline;
CREATE TABLE InvestorAirline (
				investorID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                airlineID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                PRIMARY KEY (investorID, airlineID),
                FOREIGN KEY (investorID) REFERENCES INVESTOR (investorID),
                FOREIGN KEY (airlineID) REFERENCES AIRLINE (airlineID)
);
*/
/*
DROP TABLE IF EXISTS AirportAirline;
CREATE TABLE AirportAirline (
	airportID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    airlineID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (airportID, airlineID),
    FOREIGN KEY (airportID) REFERENCES AIRPORT (airportID),
    FOREIGN KEY (airlineID) REFERENCES AIRLINE (airlineID)
);
*/		
			

/*GREEN*/

DROP TABLE IF EXISTS FLIGHT_ATTENDANT;
CREATE TABLE FLIGHT_ATTENDANT(
				flightattendantID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                PRIMARY KEY (flightattendantID),
                FOREIGN KEY (flightattendantID) REFERENCES Employee (employeeID)
);


DROP TABLE IF EXISTS LANGUAGE;
CREATE TABLE LANGUAGE(
				languageID SERIAL,
                name VARCHAR(255), 
				PRIMARY KEY (languageID)
);

DROP TABLE IF EXISTS LanguagePerson;
CREATE TABLE LanguagePerson (
	languageID BIGINT UNSIGNED,
    personID BIGINT UNSIGNED,
    PRIMARY KEY(languageID, personID),
    FOREIGN KEY (languageID) REFERENCES Language(languageID),
    FOREIGN KEY (personID) REFERENCES Person(personID)
);


DROP TABLE IF EXISTS PILOT;
CREATE TABLE PILOT(
				pilotID BIGINT UNSIGNED NOT NULL DEFAULT 0,
				flying_license VARCHAR(255),
                grade float, 
                copilotID BIGINT UNSIGNED,
                PRIMARY KEY (pilotID),
                FOREIGN KEY (copilotID) REFERENCES PILOT (pilotID),
                FOREIGN KEY (pilotID) REFERENCES Employee (employeeID)
);


DROP TABLE IF EXISTS PASSENGER;
CREATE TABLE PASSENGER(
				passengerID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                creditCard BIGINT UNSIGNED NOT NULL DEFAULT 0,
                PRIMARY KEY (passengerID),
                FOREIGN KEY (passengerID) REFERENCES Person (personID)
);

DROP TABLE IF EXISTS ROUTE;
CREATE TABLE ROUTE(
				routeID SERIAL,
                destination_airportID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                departure_airportID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                distance int, 
                minimum_petrol int,
                time TIME,
                PRIMARY KEY (routeID),
                FOREIGN  KEY (destination_airportID) REFERENCES AIRPORT(airportID),
                FOREIGN  KEY (departure_airportID) REFERENCES AIRPORT(airportID)
);

DROP TABLE IF EXISTS RouteAirline;
CREATE TABLE RouteAirline (
	airlineID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    routeID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    TV boolean,
    n_meals int,
    planeTypeID BIGINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (routeID,airlineID,planeTypeID),
    FOREIGN KEY (airlineID) REFERENCES Airline (airlineID),
    FOREIGN KEY (routeID) REFERENCES Route (routeID),
    FOREIGN KEY (planeTypeID) REFERENCES PlaneType(planeTypeID)
);

DROP TABLE IF EXISTS STATUS;
CREATE TABLE STATUS(
				statusID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                status VARCHAR(255), 
                PRIMARY KEY (statusID)
);


DROP TABLE IF EXISTS FLIGHT;
CREATE TABLE FLIGHT(
				flightID SERIAL,
                pilotID BIGINT UNSIGNED,
                planeID BIGINT UNSIGNED,
                routeID BIGINT UNSIGNED,
                date DATE,
                gate VARCHAR(2),
                fuel BIGINT UNSIGNED,
                departure_hour TIME,
                statusID BIGINT UNSIGNED,
                PRIMARY KEY (flightID),
                FOREIGN  KEY (pilotID) REFERENCES PILOT(pilotID),
                FOREIGN  KEY (planeID) REFERENCES PLANE(planeID),
                FOREIGN  KEY (routeID) REFERENCES ROUTE(routeID),
                FOREIGN KEY (statusID) REFERENCES Status(statusID)
);

DROP TABLE IF EXISTS FLIGHT_FLIGHTATTENDANT;
CREATE TABLE FLIGHT_FLIGHTATTENDANT (
	flightID BIGINT UNSIGNED,
    flightAttendantID BIGINT UNSIGNED,
    PRIMARY KEY(flightID,flightAttendantID),
    FOREIGN KEY (flightID) REFERENCES Flight (flightID),
    FOREIGN KEY (flightAttendantID) REFERENCES Flight_Attendant (flightAttendantID)
);


/*BLAU*/
DROP TABLE IF EXISTS Company;
CREATE TABLE Company (
	companyID SERIAL,
    name VARCHAR(255),
    company_value DOUBLE,
    countryID BIGINT UNSIGNED,
    PRIMARY KEY (companyID),
    FOREIGN KEY (countryID) REFERENCES Country (countryID)
);


DROP TABLE IF EXISTS WaitingArea;
CREATE TABLE WaitingArea (
	waitingAreaID SERIAL,
    companyID BIGINT UNSIGNED,
    airportID BIGINT UNSIGNED,
    opening_hour TIME,
    close_hour TIME,
    PRIMARY KEY (waitingAreaID),
    FOREIGN KEY (companyID) REFERENCES Company (companyID),
    FOREIGN KEY (airportID) REFERENCES Airport (airportID)
);

DROP TABLE IF EXISTS Store;
CREATE TABLE Store (
				storeId BIGINT UNSIGNED, 
                surface INT,
				PRIMARY KEY (storeId),
                FOREIGN KEY (storeID) REFERENCES WaitingArea (waitingAreaID)
);

DROP TABLE IF EXISTS RESTAURANT;
CREATE TABLE RESTAURANT (
				restaurantID SERIAL,
                type VARCHAR(255),
                oriented_price BIGINT UNSIGNED NOT NULL DEFAULT 0, 
                capacity int,
                score FLOAT,
                PRIMARY KEY (restaurantID),
                FOREIGN KEY (restaurantID) REFERENCES WaitingArea (waitingAreaID)
);

DROP TABLE IF EXISTS VIP_ROOM;
CREATE TABLE VIP_ROOM(
				vipID BIGINT UNSIGNED, 
				price BIGINT UNSIGNED NOT NULL DEFAULT 0, 
                spa boolean,
                massage_center boolean, 
                cinema boolean, 
                minimum_age int,
                restaurantID BIGINT UNSIGNED,
				PRIMARY KEY (vipID),
                FOREIGN KEY (vipID) REFERENCES WaitingArea (waitingAreaID),
                FOREIGN KEY (restaurantID) REFERENCES Restaurant (restaurantID)
);

DROP TABLE IF EXISTS Product;
CREATE TABLE Product(
				productId SERIAL, 
                companyID BIGINT UNSIGNED, 
                name VARCHAR(255), 
                weight FLOAT, 
                price  VARCHAR(255), 
                PRIMARY KEY (productId),
                FOREIGN  KEY (companyID) REFERENCES Company(companyID)
);

DROP TABLE IF EXISTS ProductStore;
CREATE TABLE ProductStore(
	storeID BIGINT UNSIGNED,
    productID BIGINT UNSIGNED,
	PRIMARY KEY (storeID,productID),
    FOREIGN KEY (storeID) REFERENCES Store(storeID),
    FOREIGN KEY (productID) REFERENCES Product(productID)
);

DROP TABLE IF EXISTS ForbiddenProducts;
CREATE TABLE ForbiddenProducts (
	productID BIGINT UNSIGNED,
    countryID BIGINT UNSIGNED,
    PRIMARY KEY (productID, countryID),
    FOREIGN KEY (productID) REFERENCES Product(productID),
    FOREIGN KEY (countryID) REFERENCES Country (countryID)
);

DROP TABLE IF EXISTS Food;
CREATE TABLE Food (
	foodID BIGINT UNSIGNED,
    expiration_date date,
    countryID BIGINT UNSIGNED,
    PRIMARY KEY (foodID),
    FOREIGN KEY (foodID) REFERENCES Product(productID)
    -- FOREIGN KEY (countryID) REFERENCES Country(countryID)
);

DROP TABLE IF EXISTS Clothes;
CREATE TABLE Clothes (
	clothesID BIGINT UNSIGNED,
    size FLOAT,
    color VARCHAR(255),
    type VARCHAR(255),
    PRIMARY KEY (clothesID),
    FOREIGN KEY (clothesID) REFERENCES Product(productID)
);
    
DROP TABLE IF EXISTS Shopkeeper;
CREATE TABLE Shopkeeper (
	shopkeeperID BIGINT UNSIGNED,
    comission float,
    weekly_hours TIME,
    waitingAreaID BIGINT UNSIGNED,
    PRIMARY KEY (shopkeeperID),
    FOREIGN KEY (shopkeeperID) REFERENCES Employee (employeeID),
    FOREIGN KEY (waitingAreaID) REFERENCES WaitingArea (waitingAreaID)
);




/*AMARILLO*/
DROP TABLE IF EXISTS FLIGHTTICKETS;
CREATE TABLE FLIGHTTICKETS(
				flightTicketID SERIAL,
                passengerID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                flightID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                price int, 
                business BOOLEAN, 
                date_of_purchase DATE, 
                PRIMARY KEY (flightTicketID),
                FOREIGN  KEY (passengerID) REFERENCES PASSENGER(passengerID),
				FOREIGN  KEY (flightID) REFERENCES FLIGHT(flightID)
);

DROP TABLE IF EXISTS CHECKIN;
CREATE TABLE CHECKIN(
				checkinID SERIAL,
                flightTicketID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                row int, 
                seat CHAR, 
                PRIMARY KEY (checkinID),
                FOREIGN  KEY (flightTicketID) REFERENCES FLIGHTTICKETS(flightTicketID)
);

DROP TABLE IF EXISTS LUGGAGEHANDLER;
CREATE TABLE LUGGAGEHANDLER(
				luggagehandlerID SERIAL,
                maxweight int, 
                PRIMARY KEY (luggageHandlerID),
                FOREIGN KEY (luggageHandlerID) REFERENCES Employee (employeeID)
);

DROP TABLE IF EXISTS LUGGAGE;
CREATE TABLE LUGGAGE(
				luggageID SERIAL,
                size VARCHAR(2), 
                color VARCHAR(255), 
                brand VARCHAR(255), 
				weight FLOAT, 
                passengerID BIGINT UNSIGNED,
                flightID BIGINT UNSIGNED,
                PRIMARY KEY (luggageID),
                FOREIGN KEY (passengerID) REFERENCES Passenger (passengerID),
                FOREIGN KEY (flightID) REFERENCES Flight (flightID)
);

DROP TABLE IF EXISTS HANDLUGGAGE;
CREATE TABLE HANDLUGGAGE(
				handluggageID BIGINT UNSIGNED,
                size_x int, 
                size_y int, 
                size_z int, 
                productID BIGINT UNSIGNED,
                PRIMARY KEY (handluggageID),
                FOREIGN KEY (handluggageID) REFERENCES Luggage (luggageID)
);

DROP TABLE IF EXISTS CHECKEDLUGGAGE;
CREATE TABLE CHECKEDLUGGAGE(
				checkedluggageID BIGINT UNSIGNED,
                extra_cost FLOAT, 
                PRIMARY KEY (checkedluggageID),
                FOREIGN KEY (checkedluggageID) REFERENCES Luggage (luggageID)
);

DROP TABLE IF EXISTS SPECIALOBJECTS;
CREATE TABLE SPECIALOBJECTS(
				specialobjectID SERIAL,
                fragile BOOLEAN, 
                corrosive BOOLEAN,
				flammable BOOLEAN,
                PRIMARY KEY (specialobjectID),
                FOREIGN KEY (specialobjectID) REFERENCES CheckedLuggage (checkedluggageID)
);

DROP TABLE IF EXISTS FlightLuggageHandler; 
CREATE TABLE FlightLuggageHandler (
	luggageHandlerID BIGINT UNSIGNED,
    flightID BIGINT UNSIGNED,
    PRIMARY KEY(luggageHandlerID, flightID),
    FOREIGN KEY (luggageHandlerID) REFERENCES LuggageHandler(luggageHandlerID),
    FOREIGN KEY (flightID) REFERENCES Flight (flightID)
);

DROP TABLE IF EXISTS CLAIMS;
CREATE TABLE CLAIMS(
				claimID BIGINT UNSIGNED,
                passengerID BIGINT UNSIGNED NOT NULL DEFAULT 0,
                date DATE,
                PRIMARY KEY (claimID),
                FOREIGN  KEY (passengerID) REFERENCES PASSENGER(passengerID)
);

DROP TABLE IF EXISTS LOSTOBJECT;
CREATE TABLE LOSTOBJECT(
				lostObjectID BIGINT UNSIGNED,
                luggageID BIGINT UNSIGNED,
                description TEXT,
                color VARCHAR(255), 
                founded BOOLEAN,
                PRIMARY KEY (lostObjectID),
                FOREIGN  KEY (lostObjectID) REFERENCES Claims(ClaimID),
                FOREIGN KEY (luggageID) REFERENCES Luggage(luggageID)
);

DROP TABLE IF EXISTS REFUND;
CREATE TABLE REFUND(
				refundID BIGINT UNSIGNED,
                flightTicketID  BIGINT UNSIGNED,
                argument TEXT, 
                accepted BOOLEAN, 
                amount BIGINT UNSIGNED, 
                PRIMARY KEY (refundID),
                FOREIGN KEY (refundID) REFERENCES Claims(claimID),
                FOREIGN  KEY (flightTicketID) REFERENCES FLIGHTTICKETS(flightTicketID)
);


