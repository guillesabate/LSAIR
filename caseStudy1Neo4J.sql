MATCH (n)-[r]->(m) DELETE (n),(r), (m)

MATCH (n) DELETE (n)

LOAD CSV WITH HEADERS FROM
"file:///case_study1_dataset1.csv" AS csv
MERGE (p:Plane { planeID: ToInteger(csv.PlaneID),
    retirementYear : ToInteger(csv.RetirementYear), 
    type : csv.TypeName,
    airline : csv.AirlineName})
ON CREATE
    SET p.totalPieceCost = CASE trim (csv.PiecesCosts) WHEN null THEN null ELSE toInteger(csv.PiecesCosts) END
ON CREATE
    SET p.maintenanceTimes = CASE trim (csv.TimesMaintenance) WHEN null THEN null ELSE toInteger(csv.TimesMaintenance) END


LOAD CSV WITH HEADERS FROM
"file:///case_study1_dataset2.csv" AS csv
MERGE (a:Airport { airportID: (ToInteger(csv.AirportID)),
    name : csv.AirportName,
    altitude : ToInteger(csv.Altitude)})
MERGE (c:Country { name: (csv.CountryName)})
MERGE (ci:City {cityID: (toInteger(csv.CityID)),
    name: csv.CityName,
    timezone: toInteger(csv.Timezone)})
MERGE (a)-[l:LOCATION]->(ci)
MERGE (ci)-[i:INCOUNTRY]->(c)


LOAD CSV WITH HEADERS FROM
"file:///case_study1_dataset3.csv" AS csv
WITH csv
MATCH (a:Airport { airportID: ToInteger(csv.AirportID)}),
      (p:Plane { planeID: ToInteger(csv.PlaneID)})
MERGE (a)-[l:ROUTE]->(p)
   