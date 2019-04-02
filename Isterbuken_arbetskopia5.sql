CREATE DATABASE Isterbuken;

CREATE TABLE hobby(
  hobbyId INT NOT NULL AUTO_INCREMENT,
  hobbyNamn VARCHAR(100),
  PRIMARY KEY (hobbyId)
);

CREATE TABLE besättning(
  besättningId INT NOT NULL AUTO_INCREMENT,
  besättningNamn VARCHAR(50),
    besättningHobbyId INT,
  PRIMARY KEY (besättningId),
    FOREIGN KEY (besättningHobbyId) REFERENCES hobby(hobbyId)
);

CREATE TABLE ansvarsområde(
  ansvarsområdeId INT NOT NULL AUTO_INCREMENT,
  ansvarsområdeTitel VARCHAR(50),
    ansvarsområdeBesättningId INT,
  PRIMARY KEY (ansvarsområdeId),
    FOREIGN KEY (ansvarsområdeBesättningId) REFERENCES besättning(besättningId)
);

CREATE TABLE brottsrubricering(
  brottsrubriceringId INT NOT NULL AUTO_INCREMENT,
  brottrubriceringNamn VARCHAR(100),
  brottsrubriceringPoäng INT,
  PRIMARY KEY (brottsrubriceringId)
);

CREATE TABLE straffregister(
  straffregisterId INT NOT NULL AUTO_INCREMENT,
  straffregisterDatum DATE,
    straffregisterBesättningId INT,
    straffregisterBrottsrubriceringId INT,
  PRIMARY KEY (straffregisterId),
    FOREIGN KEY (straffregisterBesättningId) REFERENCES besättning(besättningId),
    FOREIGN KEY (straffregisterBrottsrubriceringId) REFERENCES brottsrubricering(brottsrubriceringId)
);

-- Dags att fylla på med data
INSERT INTO hobby(hobbyNamn)
VALUES ('Kviltning och Raptorhetsning'),('Pilla och Springa'),
       ('Larma och Göra sig till'), ('Väcka anstöt och Sova räv'), ('Kafferep och Dödsfajter');

INSERT INTO besättning(besättningNamn, besättningHobbyId)
VALUES ('Ilon Zepp', 1),('Fru Östen', 5),('Nurg', 2), ('Simpa Dimp', 4), ('Kask Kolja', 1), ('Vilja Vrång', 3);

INSERT INTO ansvarsområde(ansvarsområdeTitel, ansvarsområdeBesättningId)
VALUES ('Störstebosschef', 1), ('Överstökerska', 2), ('Andre Tredjekontrollant', 3),
       ('Kuttersmycke', 4), ('Styrman', 5),('Orator', 6),('Plågoris', 1);

INSERT INTO brottsrubricering(brottrubriceringNamn, brottsrubriceringPoäng)
VALUES ('Svårt krossande av annans mjälte', 5),('Extratråkig attityd på allmän plats', 3),
       ('Särskrivning i officiellt dokument', 4), ('Våldsamt pådyvlande av semesterbilder', 2),
       ('Medelst trubbigt våld tillskansande av allmän egendom', 4), ('Total avsaknad av personlighet', 1),
       ('Underlåtenhet att visa takt och ton', 2);

INSERT INTO straffregister(straffregisterDatum, straffregisterBesättningId, straffregisterBrottsrubriceringId)
VALUES (25030204, 1, 3), (25021022, 1, 1),(25001231, 1, 5),(24750314, 2, 4), (25100505, 6, 7),(25080930, 3, 6),
       (25060425, 4, 2), (25041112, 5, 3), (24990101, 5, 3);


-- #### Frågor att ha med vid inlämning. ####

-- För att ta bort en besättningsman.
UPDATE ansvarsområde SET ansvarsområdeBesättningId = NULL WHERE ansvarsområdeBesättningId = 4;
DELETE FROM straffregister WHERE straffregisterBesättningId =4;
DELETE FROM besättning WHERE besättningId = 4;

-- För att lägga till en besättningsman som tar över ovan nämndas ansvarsområde.
INSERT INTO besättning(besättningNamn, besättningHobbyId, besättningId) VALUES ('Zilja Zork', 3, 4);
UPDATE ansvarsområde SET ansvarsområdeBesättningId = 4 WHERE ansvarsområdeTitel = 'Kuttersmycke';

-- Index. lite onödigt med så lite data, men jag utgår ifrån att denna tabell är den som kommer att ha flest rader.
CREATE INDEX brottsrubriceringsNamn ON brottsrubricering(brottrubriceringNamn);

SELECT * from brottsrubricering WHERE brottrubriceringNamn LIKE 'S%';

-- Exempel på en Vy som visar Störstebosschefens straffregister.
CREATE VIEW Störstebosschefens_Straffregister AS SELECT besättningNamn, straffregisterDatum, brottrubriceringNamn
  FROM ansvarsområde INNER JOIN besättning ON ansvarsområdeBesättningId = besättningId
  INNER JOIN straffregister ON besättningId = straffregisterBesättningId
  INNER JOIN brottsrubricering ON straffregisterBrottsrubriceringId = brottsrubriceringId
  WHERE ansvarsområdeTitel = 'Störstebosschef';

SELECT straffregisterDatum, brottrubriceringNamn FROM Störstebosschefens_Straffregister;

-- Lagrad procedur som listar besättningen.
DELIMITER //
CREATE PROCEDURE Hämta_Besättning()
  BEGIN
    SELECT * FROM besättning;
  END //

CALL Hämta_Besättning();

-- Lagrad procedur som ger möjlighet att söka på besättningsnamn.
-- Den visar besättningsmedlemmar som förekommer samtliga tabeller.
DELIMITER //
CREATE PROCEDURE Besättning_Sök(IN besättning1 VARCHAR(50))
  BEGIN
  SELECT besättningNamn, ansvarsområdeTitel, brottrubriceringNamn, brottsrubriceringPoäng ,hobbyNamn FROM besättning
  INNER JOIN ansvarsområde ON besättningId = ansvarsområdeBesättningId
  INNER JOIN hobby ON besättningHobbyId = hobbyId
  INNER JOIN straffregister ON besättningId = straffregisterBesättningId
  INNER JOIN brottsrubricering ON straffregisterBrottsrubriceringId = brottsrubriceringId
  WHERE besättningNamn LIKE CONCAT('%', besättning1, '%');
  END //

CALL Besättning_Sök('Z');


-- Besättningsmedlemmar med deras totala straffpoäng
CREATE VIEW Straffpoäng_Per_Besättningsmedlem AS SELECT besättningNamn, SUM(brottsrubriceringPoäng) AS totalPoäng
 FROM brottsrubricering INNER JOIN straffregister ON brottsrubricering.brottsrubriceringId = straffregister.straffregisterBrottsrubriceringId
  INNER JOIN besättning  ON straffregisterBesättningId = besättningId
  GROUP BY besättningNamn;

SELECT * FROM Straffpoäng_Per_Besättningsmedlem;

-- Statisktik över den sammanlagda brottsrubriceringsPoängen per hobby
CREATE VIEW Poäng_Per_Hobby AS SELECT hobbyNamn, SUM(brottsrubriceringPoäng) AS Poäng_per_hobby FROM hobby INNER JOIN besättning ON hobbyId = besättningHobbyId
  INNER JOIN straffregister ON besättningId = straffregisterBesättningId
  INNER JOIN brottsrubricering ON straffregisterBrottsrubriceringId = brottsrubriceringId
  GROUP BY hobbyNamn;

SELECT * FROM Poäng_Per_Hobby;





-- #### Nedanstående frågor är arbetsmaterial jag använt under skapandet av databasen ####
DROP TABLE ansvarsområde;
DROP TABLE straffregister;
DROP TABLE brottsrubricering;
DROP TABLE besättning;
DROP TABLE hobby;

SELECT * FROM besättning;
SELECT  * FROM ansvarsområde;


SELECT besättning.besättningNamn, hobby.hobbyNamn FROM hobby INNER JOIN besättning ON hobby.hobbyId = besättningHobbyId WHERE hobbyId = 1;

SELECT besättning.besättningNamn, ansvarsområdeTitel FROM ansvarsområde INNER JOIN besättning ON besättningId = ansvarsområdeBesättningId;

-- Här visas Ilon Zepps Brottsrubriceringar tillsammans med datum för dom.
Select besättningNamn, straffregisterDatum, brottrubriceringNamn FROM besättning INNER JOIN straffregister ON straffregisterBesättningId = besättningId
  INNER JOIN brottsrubricering ON brottsrubriceringId = straffregisterBrottsrubriceringId WHERE besättningNamn = 'Ilon Zepp';

-- försök med poäng (det verkar funka ganska bra)
Select besättningNamn, straffregisterDatum, brottrubriceringNamn, brottsrubriceringPoäng FROM besättning INNER JOIN straffregister ON straffregisterBesättningId = besättningId
  INNER JOIN brottsrubricering ON brottsrubriceringId = straffregisterBrottsrubriceringId WHERE besättningId = 1;



-- test
SELECT besättningNamn, hobbyNamn, SUM(brottsrubriceringPoäng) AS totalPoäng FROM brottsrubricering
  INNER JOIN straffregister ON brottsrubricering.brottsrubriceringId = straffregister.straffregisterBrottsrubriceringId
  INNER JOIN besättning b on straffregister.straffregisterBesättningId = b.besättningId
  INNER JOIN hobby h on b.besättningHobbyId = h.hobbyId GROUP BY hobbyNamn;

-- test med view, den verkar funka
CREATE VIEW Ilon_Zepps_Straffregister AS Select besättningNamn, straffregisterDatum, brottrubriceringNamn
  FROM besättning INNER JOIN straffregister ON straffregisterBesättningId = besättningId
  INNER JOIN brottsrubricering ON brottsrubriceringId = straffregisterBrottsrubriceringId
  WHERE besättningNamn = 'Ilon Zepp';

SELECT * FROM Ilon_Zepps_Straffregister;

SELECT straffregisterDatum, brottsrubriceringPoäng FROM Ilon_Zepps_Straffregister;


-- poäng per ansvarsområde
SELECT ansvarsområdeTitel, sum(brottsrubriceringPoäng), besättningNamn AS Poäng_per_titel from ansvarsområde
INNER JOIN besättning on besättningId = ansvarsområdeBesättningId
INNER JOIN straffregister ON besättningId = straffregisterBesättningId
INNER JOIN brottsrubricering ON straffregisterBrottsrubriceringId = brottsrubriceringId
GROUP BY ansvarsområdeTitel;


-- Vy över Ilon Zepps straffregister
CREATE VIEW Ilon_Zepps_Straffregister AS Select besättningNamn, straffregisterDatum, brottrubriceringNamn, brottsrubriceringPoäng
  FROM besättning INNER JOIN straffregister ON straffregisterBesättningId = besättningId
  INNER JOIN brottsrubricering ON brottsrubriceringId = straffregisterBrottsrubriceringId
  WHERE besättningNamn = 'Ilon Zepp';

SELECT * FROM Ilon_Zepps_Straffregister;

DROP VIEW Ilon_Zepps_Straffregister;

DROP VIEW Störstebosschefens_Straffregister;


-- Stored procedures

DELIMITER //
CREATE PROCEDURE Besättning_Sök(IN besättning1 VARCHAR(50))
  BEGIN
SELECT besättningNamn, ansvarsområdeTitel, brottrubriceringNamn, brottsrubriceringPoäng ,hobbyNamn FROM besättning
  INNER JOIN hobby ON besättningHobbyId = hobbyId
  INNER JOIN ansvarsområde ON besättningId = ansvarsområdeBesättningId
  INNER JOIN straffregister ON besättningId = straffregisterBesättningId
  INNER JOIN brottsrubricering ON straffregisterBrottsrubriceringId = brottsrubriceringId
  WHERE besättningNamn LIKE CONCAT('%', besättning1, '%');
  END //

  CALL Besättning_Sök('ilon');

DROP PROCEDURE IF EXISTS Besättning_Sök;

