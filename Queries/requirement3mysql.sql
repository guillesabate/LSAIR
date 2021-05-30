///////////////////////////////

---------------------------------------
		---DATABASES S2---
---------------------------------------

///////////////////////////////

1-
SELECT c.name as "company name", co.name as "country name", co.countryID, f.countryID
FROM company as c
        JOIN company as c2 ON c.companyID = c2.companyID
        JOIN country as co ON c.countryid = co.countryid
        JOIN food as f ON co.countryid = f.countryid
        JOIN product as p ON c.companyid = p.companyid AND p.productid = f.foodid
        , product as p2
        JOIN food as f2 ON f2.foodid = p2.productid
WHERE c2.companyid = p2.companyid
GROUP BY c.name
HAVING ((COUNT(DISTINCT f.foodid) / COUNT(DISTINCT f2.foodid)) * 40) >= 1;
;

SELECT co.countryID as "vip rooms country", co2.countryID as "restaurants country", COUNT(vip.vipID) as "#vip rooms/restaurants"
FROM country as co2
	JOIN company as c2 ON co2.countryID = c2.countryID
	JOIN waitingarea as wa2 ON wa2.companyID = c2.companyID
	JOIN restaurant as r ON r.restaurantID  = wa2.waitingAreaID,
	vip_room as vip
	JOIN waitingarea as wa ON vip.vipID = wa.waitingAreaID
	JOIN company as c ON wa.companyID = c.companyID
    JOIN country as co ON c.countryID = co.countryID
WHERE vip.restaurantID = r.restaurantID
    AND c2.companyID <> c.companyID
	AND co.countryID <> co2.countryID
	AND (select COUNT(fp.productID) from forbiddenproducts as fp where fp.countryID = co.countryID) < 80
    AND (select COUNT(fp2.productID) from forbiddenproducts as fp2 where fp2.countryID = co2.countryID) < 80
GROUP BY c.companyID, c2.companyID;

3-
SELECT c.name as "company name", MAX(r.score)
FROM company as c
	JOIN waitingarea as wa ON c.companyID = wa.companyID
	JOIN restaurant as r ON r.restaurantID = wa.waitingAreaID
GROUP BY c.companyID
order by count(wa.waitingAreaID) desc
LIMIT 1;


4-
SELECT c.name as "company name", c.company_value as "company value"
FROM company as c 
	JOIN product as prod ON prod.companyID = c.companyID
    JOIN productstore as prodst ON prodst.productID = prod.productId
    JOIN waitingarea as wa ON wa.companyID = c.companyID
    JOIN restaurant as res ON res.restaurantID = wa.waitingAreaID,
    product as prod2
WHERE prod2.companyID = c.companyID
GROUP BY prodst.storeID
HAVING count(DISTINCT(res.type)) >= 2 AND (count(DISTINCT(prodst.productId))/count(DISTINCT(prod2.productId)))*100 >= 20;

5-
SELECT c.name as "company name", wa.opening_hour as "opening hour", wa.close_hour as "close hour", wa.airportID as "airport ID", wa.waitingareaID as "waiting area ID"
FROM company as c
	JOIN waitingarea as wa ON c.companyID = wa.companyID
    JOIN shopkeeper as sk ON wa.waitingAreaID = sk.waitingAreaID
    
GROUP BY wa.waitingAreaID
HAVING HOUR(wa.close_hour) < 24 AND HOUR(wa.close_hour) >  HOUR(wa.opening_hour) AND (HOUR(wa.close_hour) - HOUR(wa.opening_hour)) * 7 > sum(HOUR(sk.weekly_hours));

6-
DROP TABLE IF EXISTS EconomicReductions;
CREATE TABLE EconomicReductions(
	companyName VARCHAR(256),
	waitingAreaID INT,
	savings LONG,
    expenses LONG,
PRIMARY KEY (waitingAreaID));

DELIMITER $$
DROP TRIGGER IF EXISTS WaitingAreasShutdown $$
CREATE TRIGGER WaitingAreasShutdown BEFORE DELETE ON waitingarea
FOR EACH ROW
BEGIN
	DECLARE expenses LONG;
    SET expenses = (SELECT SUM(520*sk.weekly_hours)
					from company as com, shopkeeper as sk
                    where com.companyID = OLD.companyID AND sk.waitingAreaID != OLD.waitingAreaID);
	INSERT INTO EconomicReductions(
					companyName,
                    waitingAreaID,
                    savings,
                    expenses)
				SELECT c.name, OLD.waitingAreaID, SUM(520*sk.weekly_hours), SUM(520*sk2.weekly_hours)
					from company as c, shopkeeper as sk, shopkeeper as sk2
                    where c.companyID = OLD.companyID AND sk.waitingAreaID = OLD.waitingAreaID AND sk2.waitingAreaID != OLD.waitingAreaID;

    DELETE FROM vip_room where vipID = OLD.waitingAreaID;
    DELETE FROM restaurant where restaurantID = OLD.waitingAreaID;
    DELETE FROM shopkeeper where waitingAreaID = OLD.waitingAreaID;
	DELETE FROM productStore where storeID = OLD.waitingAreaID;
    DELETE FROM store where storeID = OLD.waitingAreaID;
	IF expenses = 0 THEN DELETE FROM Company WHERE companyID = OLD.companyID;
    DELETE FROM Product WHERE companyID = OLD.companyID;
    END IF;
END $$
DELIMITER ;
7-
DROP TABLE IF EXISTS priceUpdates;
CREATE TABLE priceUpdates(
	productID INT,
    productName VARCHAR(256),
	companyID INT,
	previousPrice INT,
    newPrice INT,
    updateDate Date,
    updateComment VARCHAR(256),
PRIMARY KEY (productID));

DELIMITER $$
DROP TRIGGER IF EXISTS priceUpdatesTrigger $$
CREATE TRIGGER priceUpdatesTrigger AFTER UPDATE ON product
FOR EACH ROW 
BEGIN 
	INSERT INTO priceUpdates(
					productID,
					productName,
					companyID,
					previousPrice,
					newPrice,
					updateDate,
					updateComment)
				SELECT OLD.productID, OLD.name, OLD.companyID, OLD.price, NEW.price, now(),
					CASE
						WHEN NEW.price < (SELECT newPrice from priceUpdates where OLD.productID = productID) AND 0 < (SELECT count(productID) from priceUpdates where OLD.productID = productID) THEN "This product has been changing over time, it is possible that it is a strategy of the company"
                        ELSE null
					END;
END $$
DELIMITER ;

8-
DROP TABLE IF EXISTS AverageSquareMetreValue;
CREATE TABLE AverageSquareMetreValue(
	storeID INT,
	valueM2 INT,
PRIMARY KEY (storeID));

DELIMITER $$
DROP TRIGGER IF EXISTS priceUpdatesTrigger $$
CREATE TRIGGER AverageSquareMetreValueTrigger AFTER INSERT ON productStore
FOR EACH ROW 
BEGIN 
	UPDATE AverageSquareMetreValue SET valueM2 = (SELECT AVG(prod.price) / st.surface from product as prod, store as st, productstore as ps where prod.productId = ps.productID AND ps.storeID = st.storeID AND st.storeID = NEW.storeID);
    INSERT INTO AverageSquareMetreValue(
					storeID,
                    valueM2)
				 SELECT  st.storeID, AVG(pr.price) / st.surface from store as st, product as pr,  productstore as ps where prod.productId = ps.productID AND ps.storeID = st.storeID AND st.storeId NOT IN (select storeID from AverageSquareMetreValue);
END $$
DELIMITER ;

9-
DROP TABLE IF EXISTS ExpiredProducts;
CREATE TABLE ExpiredProducts(
	productID INT,
    expiration_date date,
	warning_date date,
PRIMARY KEY (productID));

DELIMITER $$
DROP EVENT IF EXISTS ExpiredProductsEvent $$
CREATE EVENT IF NOT EXISTS ExpiredProductsEvent ON SCHEDULE EVERY 1 DAY

DO BEGIN
    INSERT INTO ExpiredProducts(
					productID,
                    expiration_date,
                    warning_date)
				 SELECT  foodId, expiration_date, CURDATE() from food where expiration_date >= CURDATE();
END $$
DELIMITER ;


//Neo4j

//1-
match (n:FlightAttendant)-->(f:Flight)<--(n2:FlightAttendant) return n, n2, f

//2-
match (n:FlightAttendant)-->(l:Language)<--(n2:FlightAttendant), (n)-->(f:Flight)-->(a:Airport)<--(f2:Flight)<--(n2) where f <> f2 return n, l, n2, a, f2, f

//3- 
match (n:FlightAttendant)-->(f:Flight)<--(n2:Pilot), (n)-->(l:Language)<--(n2) where (n.years_working - n2.years_working < 10) return n, f, n2, l

//4-
match (n:FlightAttendant)-->(f:Flight)<--(n2:Pilot), (n)-->(l:Language)<--(n2) return count(*) as affairs, l as language order by count(*) desc

//5-
match (n:FlightAttendant)-->(f:Flight)<--(n2:Pilot)-->(f2:Flight)<--(n3:FlightAttendant), (n)-->(f3)<--(n3), (n)-->(l:Language)<--(n2)-->(l2:Language)<--(n3) return n, n2, n3

//6-




