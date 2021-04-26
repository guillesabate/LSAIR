-- Query 2.1

SELECT
    al.name AS airlineName,
    COUNT(DISTINCT r.routeID) AS numOfRoutes
FROM routeairline AS ra
    INNER JOIN airline AS al ON ra.airlineID = al.airlineID
    INNER JOIN route AS r ON ra.routeID = r.routeID
    INNER JOIN planetype AS pt ON ra.planeTypeID = pt.planetypeID

    -- relations for country
    INNER JOIN airport AS ap_s ON r.departure_airportID = ap_s.airportID
    INNER JOIN airport AS ap_d ON r.destination_airportID = ap_d.airportID
    INNER JOIN city as ci_s ON ap_s.cityID = ci_s.cityID
    INNER JOIN city as ci_d ON ap_d.cityID = ci_d.cityID
WHERE
    -- Routes between airports in different countries
    ci_s.countryID <> ci_d.countryID
    -- Min petrol to fly > capacity of the aircraft
    AND r.minimum_petrol > pt.petrol_capacity
GROUP BY al.name;

-- Query 2.2

SELECT
    CASE
        WHEN me.grade BETWEEN 0 AND 1 THEN '0-1'
        WHEN me.grade BETWEEN 1 AND 2 THEN '1-2'
        WHEN me.grade BETWEEN 2 AND 3 THEN '2-3'
        WHEN me.grade BETWEEN 3 AND 4 THEN '3-4'
        WHEN me.grade BETWEEN 4 AND 5 THEN '4-5'
        WHEN me.grade BETWEEN 5 AND 6 THEN '5-6'
        WHEN me.grade BETWEEN 6 AND 7 THEN '6-7'
        WHEN me.grade BETWEEN 7 AND 8 THEN '7-8'
        WHEN me.grade BETWEEN 8 AND 9 THEN '8-9'
        WHEN me.grade BETWEEN 9 AND 10 THEN '9-10'
    END AS gradeRange,
    AVG(ma.duration) AS avgDuration
FROM
    mechanic AS me
        INNER JOIN maintenance AS ma ON me.mechanicID = ma.mechanicID
GROUP BY gradeRange
ORDER BY gradeRange;

-- Query 2.3 (Not sure)

SELECT
    ap.airportID,
    ci.countryID,
    AVG(r.distance) AS avgDist
FROM
    airport AS ap
        INNER JOIN route AS r ON ap.airportID = r.departure_airportID
        INNER JOIN city AS ci ON ap.cityID = ci.cityID
GROUP BY ci.countryID
HAVING avgDist >= (
    -- Select avg of airports in the same country
    SELECT AVG(auxR.distance) AS auxAvgDist
    FROM airport AS auxAp
        INNER JOIN route AS auxR ON auxAp.airportID = auxR.departure_airportID
        -- Airport from the same country
        INNER JOIN city as auxCi ON auxAp.cityID = auxCi.cityID AND ci.countryID = auxCi.countryID
)
ORDER BY avgDist;

-- Query 2.4

SELECT al.name,
       al.airlineID,
       co.name,
       MAX(r.time) AS longestRoute
FROM country AS co,
     routeairline AS ra
         INNER JOIN airline AS al ON ra.airlineID = al.airlineID
         INNER JOIN route r on ra.routeID = r.routeID

         INNER JOIN airport AS ap_s ON r.departure_airportID = ap_s.airportID
         INNER JOIN airport AS ap_d ON r.destination_airportID = ap_d.airportID
         INNER JOIN city as ci_s ON ap_s.cityID = ci_s.cityID
         INNER JOIN city as ci_d ON ap_d.cityID = ci_d.cityID
         INNER JOIN country co_s on ci_s.countryID = co_s.countryID
         INNER JOIN country co_d on ci_d.countryID = co_d.countryID
WHERE
  -- Airlines should not have departing/entering routes from/to Spain
    co.name LIKE 'Spain'
  AND co_s.name NOT LIKE co.name
  AND co_d.name NOT LIKE co.name
GROUP BY al.airlineID
ORDER BY longestRoute DESC;

-- Query 2.5

SELECT pl.planeID,
       pi.name,
       COUNT(pi.pieceID) AS timesReplaced
FROM plane AS pl
         INNER JOIN maintenance AS m ON pl.planeID = m.planeID
         INNER JOIN piecemaintenance AS pm ON m.maintenanceID = pm.maintenanceID
         INNER JOIN piece AS pi ON pm.pieceID = pi.pieceID
