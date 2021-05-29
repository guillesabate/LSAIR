1--

SELECT a.name as 'Airlane Name', count(pa.passengerID) as 'passengers'
FROM airline AS a 
JOIN plane AS p on a.airlineID = p.airlineID
JOIN flight AS f on p.planeId = f.planeID 
JOIN flighttickets AS fl on f.flightID = fl.flightID
JOIN passenger AS pa on fl.passengerID = pa.passengerID
GROUP BY a.name
HAVING COUNT((SELECT pa2.passengerid 
FROM Airline as a2, passenger as pa2, flighttickets as fl2, plane as p2, flight as f2
WHERE  a2.airlineid =p2.airlineid AND f2.planeid=p2.planeid  AND f2.flightid=fl2.flightid 
AND pa2.passengerid=fl2.passengerid  AND fl2.flightticketID=fl.flightticketid
AND fl2.flightticketid NOT IN (SELECT ck.flightticketid FROM checkin as ck)))/count(pa.passengerID) >=0.1;

2--
SELECT ABS(cdep.timezone-carr.timezone) as "time zone difference in hours", COUNT( DISTINCT lo.lostobjectid) as lostobjects
FROM  passenger as pa
JOIN luggage as lu on lu.passengerid=pa.passengerid
JOIN lostobject as lo on lo.luggageid=lu.luggageid
JOIN claims as cl on cl.passengerid=pa.passengerid
JOIN flight as f ON f.flightID=lu.flightid
JOIN Route as ro on ro.routeid=f.routeid
JOIN Airport as adep on adep.airportid=ro.departure_airportid
JOIN Airport as aarr on aarr.airportid=ro.destination_airportid
JOIN  City as carr on carr.cityid=aarr.cityid
JOIN City as cdep on cdep.cityid=adep.cityid
WHERE  (EXTRACT(MONTH FROM cl.date)-EXTRACT(MONTH FROM f.date))<=3
GROUP BY ABS(cdep.timezone-carr.timezone);


3--
SELECT p.name as Name, p.surname as surname, p.phone_number as "Phone Number", COUNT(l.languageid) as "# languages spoken"
FROM Person as p 
JOIN Passenger as pa on p.personid=pa.passengerid
JOIN flighttickets as fl on fl.passengerid=pa.passengerid
JOIN flight as f on f.flightid= fl.flightid
JOIN Route as ro on ro.routeid=f.routeid
JOIN Airport as adep on adep.airportid=ro.departure_airportid
JOIN Airport as aarr on aarr.airportid=ro.destination_airportid
JOIN City as cdep on cdep.cityid=adep.cityid
JOIN City as carr on carr.cityid=aarr.cityid
JOIN languageperson as la on la.personid=p.personID
JOIN language as l on l.languageid=la.languageID
WHERE p.personid in 
	(SELECT p.personid
	FROM Person as p
	JOIN languageperson as la on la.personid=p.personID
	JOIN language as l on l.languageid=la.languageID
	WHERE l.name LIKE "Chavacano")
AND ABS(cdep.timezone-carr.timezone) > 3
GROUP BY p.personid
HAVING COUNT(l.languageid)>=2;

4-
SELECT aarr.name as 'Airport Name' , (SELECT COUNT(pas.passengerID) FROM passenger pas
     join flighttickets as fl2 on pas.passengerID = fl2.passengerID
     join flight  as f2 on fl2.flightID = f2.flightID
     join route as ro2 on f2.routeID = ro2.routeID
    where ro2.destination_airportID = aarr.airportID or ro2.departure_airportID = ro.destination_airportID
    GROUP BY aarr.airportID) as  'total number of passengers'
FROM Airport as aarr
JOIN Route as ro on aarr.airportid=ro.destination_airportid
JOIN flight as f on f.routeid= ro.routeid
JOIN flighttickets as fl on fl.flightid=f.flightid
JOIN luggage as lu on lu.flightID=fl.flightID
JOIN handluggage as hl on hl.handluggageID=lu.luggageid
JOIN forbiddenproducts as fp on fp.productid=hl.productid
JOIN country as co on fp.countryid=co.countryid
JOIN City as carr on carr.countryid=co.countryid  AND carr.cityid=aarr.cityid
GROUP BY aarr.airportid ;

5--
SELECT pt.type_name as 'Plane type'
FROM Plane as pl inner join planetype as pt on pt.planetypeID = pl.planetypeID 
JOIN Flight as f on f.planeid=pl.planeid
JOIN Status as st on st.statusid=f.statusid
JOIN airline as a on a.airlineID=pl.airlineid
JOIN Route as ro on ro.routeid=f.routeid
group by  pl.planetypeid
    HAVING ((SELECT COUNT(f4.flightid) 
     FROM Status as st4
     JOIN Flight as f4 on st4.statusid=f4.statusid
	 JOIN  Plane as pl4 on f4.planeid=pl4.planeid
     JOIN airline as a4 on a4.airlineID=pl4.airlineid
	WHERE pl4.planetypeid= pl.planetypeid AND st4.status='Perfect')/ COUNT(f.flightid))>=0.53 and 
COUNT(f.flightid)>500 
and   ((SELECT count(a2.airlineID) FROM  airline as a2 
JOIN  Plane as pl2 on a2.airlineID=pl2.airlineid
JOIN Flight as f2 on f2.planeid=pl2.planeid
JOIN Status as st2 on st2.statusid=f2.statusid
JOIN Route as ro2 on ro2.routeid=f2.routeid
WHERE pl.planetypeid = pl2.planetypeid))>70 
and sum(ro.distance)>1000000;

6--
SELECT "flightattendant" as "employee type" , l.name as language, count(e.employeeID) as people, e.employeeID as id  
FROM employee as e
JOIN person as p ON e.employeeid=p.personid
JOIN  flight_attendant as fl ON e.employeeid=fl.flightattendantid 
JOIN languageperson as lan ON p.personID=lan.personID
JOIN language  as l ON lan.languageid=l.languageid
group by L.name
UNION 
SELECT "other employee" as "employee type" , l.name as language, count(e.employeeID) as people, e.employeeid as id 
FROM employee as e 
JOIN person as p on e.employeeid=p.personid   
JOIN languageperson as lan on  p.personID=lan.personID
JOIN language as l ON lan.languageid=l.languageid 
LEFT JOIN flight_attendant as fl on flightattendantID=e.employeeID WHERE fl.flightattendantID is null
group by l.name
order by people DESC;
