# ++++++++++++++++++++++++++++++++++++++++++++++ PRIMERA ACCIÓN ++++++++++++++++++++++++++++++++++++++++++++
-- Persistencia de movie_dataset formateando el campo `crew` y `director`.
DROP TABLE IF EXISTS movie_dataset_formatted ;
CREATE TABLE movie_dataset_formatted  AS
SELECT
	`index`, budget, genres, homepage, id, 
	REPLACE(JSON_EXTRACT(CONCAT('["',REPLACE(keywords, """", "'"),'"]'), "$[0]"), """", "") AS keywords,
	original_language, original_title, overview, popularity, 
	production_companies, production_countries, release_date, revenue, runtime, spoken_languages, `status`,
	tagline, title, vote_average, vote_count, 
	REPLACE(JSON_EXTRACT(CONCAT('["',REPLACE(cast, """", "'"),'"]'), "$[0]"), """", "") AS cast,
	IF(crewf LIKE '%"''%' AND crewf LIKE '%''"%', 
		REPLACE(REPLACE(crewf, ": ""'", ": """), "'"",", ""","), 
		crewf) AS crew,
	REPLACE(JSON_EXTRACT(CONCAT('["',director,'"]'), "$[0]"), """", "") AS director
FROM(
	SELECT *,
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(crew,
				"""", "'"), 
				"', '", """, """), 
				"': '", """: """), 
				"': ", """: "), 
				", '", ", """), 
				"{'", "{""")AS crewf
	FROM movie_dataset
) t1;

-- Asignación de clave primaria en la tabla movie_dataset_formatted.
ALTER TABLE movie_dataset_formatted  ADD PRIMARY KEY (id) ;
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++++++++++++++++++++++++ SEGUNDA ACCIÓN +++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento para extraer la data del campo production_companies.
DROP PROCEDURE IF EXISTS table_tmp_production_companies;
DELIMITER //
CREATE PROCEDURE table_tmp_production_companies()
BEGIN
	DECLARE i INT DEFAULT 0;
    -- Creación de la tabla tmp_production_companies para almacenar los elementos del JSON de production_companies.
	DROP TABLE IF EXISTS tmp_production_companies ;
	CREATE TABLE IF NOT EXISTS tmp_production_companies(idMovie INT, idCompany INT, name varchar(85));
    
	WHILE i <= 25 DO
    -- Cargando datos del objeto JSON en la tabla temporal.
    INSERT INTO tmp_production_companies
    SELECT DISTINCT * FROM (
		SELECT id AS idMovie,
			JSON_EXTRACT(production_companies, CONCAT("$[",i,"].id")) AS idCompany,
			REPLACE(JSON_EXTRACT(production_companies, CONCAT("$[",i,"].name")), """", "") AS name
		FROM movie_dataset_formatted
		WHERE id IN (SELECT id FROM movie_dataset_formatted WHERE i <= JSON_LENGTH(production_companies))
	) t;
	SET i=i+1;
	END WHILE;
    
	-- Limpieza de registros nulos en la tabla temporal production_companies.
	DELETE FROM tmp_production_companies WHERE idCompany IS NULL;
END //
DELIMITER ;

-- Llamada al procedimiento.
CALL table_tmp_production_companies();

-- Asignación de clave primaria en la tabla tmp_production_companies.
ALTER TABLE tmp_production_companies ADD PRIMARY KEY (idMovie, idCompany) ;

-- Carga de datos a la tabla oficial company (sin registros duplicados) - Total Registros: 5.047
INSERT INTO company SELECT DISTINCT idCompany, name FROM tmp_production_companies;
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# ++++++++++++++++++++++++++++++++++++++++++++++++ TERCERA ACCIÓN ++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento para extraer la data del campo production_countries.
DROP PROCEDURE IF EXISTS table_tmp_production_countries;
DELIMITER //
CREATE PROCEDURE table_tmp_production_countries()
BEGIN
	DECLARE i INT DEFAULT 0;
    -- Creación de la tabla tmp_production_countries para almacenar los elementos del JSON de production_countries.
	CREATE TABLE IF NOT EXISTS tmp_production_countries(idMovie INT, iso_3166_1 char(2), name varchar(30));
    
	WHILE i <= 11 DO
    -- Cargando datos del objeto JSON en la tabla temporal.
    INSERT INTO tmp_production_countries
    SELECT DISTINCT * FROM (
		SELECT id AS idMovie,
			REPLACE(JSON_EXTRACT(production_countries, CONCAT("$[",i,"].iso_3166_1")), """", "") AS iso_3166_1,
			REPLACE(JSON_EXTRACT(production_countries, CONCAT("$[",i,"].name")), """", "") AS name
		FROM movie_dataset_formatted
		WHERE id IN (SELECT id FROM movie_dataset_formatted WHERE i <= JSON_LENGTH(production_countries))
	) t;
    
    -- Limpieza de registros nulos en la tabla temporal production_countries.
	DELETE FROM tmp_production_countries WHERE iso_3166_1 IS NULL;
	SET i=i+1;
	END WHILE;
END //
DELIMITER ;

-- Llamada al procedimiento.
CALL table_tmp_production_countries();

-- Asignación de clave primaria en la tabla tmp_production_countries.
ALTER TABLE tmp_production_countries ADD PRIMARY KEY (idMovie, iso_3166_1) ;

-- Carga de datos a la tabla oficial country (sin registros duplicados) - Total Registros: 88
INSERT INTO country SELECT DISTINCT iso_3166_1, name FROM tmp_production_countries;
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++++++++++++++++++++++ CUARTA ACCIÓN ++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento para extraer la data del campo spoken_languages.
DROP PROCEDURE IF EXISTS table_tmp_spoken_languages;
DELIMITER //
CREATE PROCEDURE table_tmp_spoken_languages()
BEGIN
	DECLARE i INT DEFAULT 0;
    -- Creación de la tabla tmp_spoken_languages para almacenar los elementos del JSON de spoken_languages.
	CREATE TABLE IF NOT EXISTS tmp_spoken_languages (idMovie INT, iso_639_1 CHAR(2), name VARCHAR(50));
    
	WHILE i <= 8 DO
    -- Cargando datos del objeto JSON en la tabla temporal.
    INSERT INTO tmp_spoken_languages
    SELECT DISTINCT * FROM (
		SELECT id AS idMovie,
			REPLACE(JSON_EXTRACT(spoken_languages, CONCAT("$[",i,"].iso_639_1")), """", "") AS iso_639_1,
			REPLACE(JSON_EXTRACT(spoken_languages, CONCAT("$[",i,"].name")), """", "") AS name
		FROM movie_dataset_formatted
		WHERE id IN (SELECT id FROM movie_dataset_formatted WHERE i <= JSON_LENGTH(spoken_languages))) t;
	SET i=i+1;
	END WHILE;
    
    -- Limpieza de registros nulos en la tabla temporal spoken_languages.
	DELETE FROM tmp_spoken_languages WHERE iso_639_1 IS NULL;
END //
DELIMITER ;

-- Llamada al procedimiento.
CALL table_tmp_spoken_languages();

-- Asignación de clave primaria en la tabla tmp_crew.
ALTER TABLE tmp_spoken_languages ADD PRIMARY KEY (idMovie, iso_639_1) ;

-- Carga de datos en la tabla oficial language (sin registros duplicados).
INSERT INTO `language` SELECT DISTINCT iso_639_1, name FROM tmp_spoken_languages;

-- Inserción de un lenguaje faltante para la relción con el campo `original_language` - Total Registros: 88
INSERT INTO `language` VALUES ('nb', 'noruego bokmål');
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++ QUINTA ACCIÓN +++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento para extraer la data del campo crew.
DROP PROCEDURE IF EXISTS table_tmp_crew;
DELIMITER //
CREATE PROCEDURE table_tmp_crew()
BEGIN
	DECLARE i INT DEFAULT 0 ;
    -- Creación de la tabla tmp_crew para almacenar los elementos del JSON de crew.
	DROP TABLE IF EXISTS tmp_crew;
	CREATE TABLE IF NOT EXISTS tmp_crew (idMovie INT, idPerson INT, credit_id VARCHAR(25), 	job VARCHAR(75), 
		department VARCHAR(25), gender INT, name VARCHAR(200));
    
	WHILE i <= 345 DO
		-- Cargando datos del objeto JSON en la tabla temporal.
		INSERT INTO tmp_crew
        SELECT idMovie, idPerson, credit_id, job, department, gender,
				REPLACE(name, """", "")
		FROM(
			SELECT id as idMovie, 
				JSON_EXTRACT(CONVERT(crew USING utf8mb4), CONCAT("$[",i,"].id")) AS idPerson,
				REPLACE(JSON_EXTRACT(CONVERT(crew USING utf8mb4), CONCAT("$[",i,"].credit_id")), """", "") AS credit_id,
				REPLACE(JSON_EXTRACT(CONVERT(crew USING utf8mb4), CONCAT("$[",i,"].job")), """", "") AS job,
				REPLACE(JSON_EXTRACT(CONVERT(crew USING utf8mb4), CONCAT("$[",i,"].department")),  """", "") AS department,
				JSON_EXTRACT(CONVERT(crew USING utf8mb4), CONCAT("$[",i,"].gender")) AS gender,
				REPLACE(JSON_EXTRACT(CONVERT(REPLACE(crew, '\\\\', '\\') USING utf8mb4), 
					CONCAT("$[",i,"].name")), "\\t", "") AS name
			FROM movie_dataset_formatted
			WHERE id IN (SELECT id FROM movie_dataset_formatted WHERE i <= JSON_LENGTH(crew))) t; 
		SET i=i+1;	
	END WHILE;
    
    -- Limpieza de registros nulos en la tabla temporal crew.
	DELETE FROM tmp_crew WHERE idPerson IS NULL;
END //
DELIMITER ;

-- Llamada al procedimiento table_tmp_crew.
CALL table_tmp_crew();

-- Actualización de un registro incorrecto.
UPDATE tmp_crew SET gender = 2 WHERE idPerson = 30711 ;

-- Asignación de clave primaria en la tabla tmp_crew.
ALTER TABLE tmp_crew ADD PRIMARY KEY (idMovie, credit_id) ;

-- Carga de datos a la tabla oficial person (sin registros duplicados) - Total Registros: 52.810
INSERT INTO person SELECT DISTINCT idPerson, name, gender FROM tmp_crew;

-- Carga de datos a la tabla oficial credit (sin registros duplicados) - Total Registros: 129.492
INSERT INTO credit SELECT DISTINCT credit_id, idPerson, department, job FROM tmp_crew;

-- Carga de datos a la tabla oficial director (sin registros duplicados) - Total Registros: 2.578
INSERT INTO director SELECT DISTINCT idPerson FROM tmp_crew WHERE department = "Directing" AND job = "Director";
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++++++++++++++++++++ SEXTA ACCIÓN +++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento para extraer la data del campo genres.
DROP PROCEDURE IF EXISTS table_tmp_genres ;
DELIMITER //
CREATE PROCEDURE table_tmp_genres()
BEGIN
	DECLARE i INT DEFAULT 0 ;
    -- Creación de la tabla tmp_genres para almacenar los géneros del campo multivaliado genres.
	DROP TABLE IF EXISTS tmp_genres;
	CREATE TABLE IF NOT EXISTS tmp_genres (idMovie INT(11), idGenre VARCHAR(35), name VARCHAR(30));
    
	WHILE i <= 6 DO
		-- Cargando datos del campo multivaluado en la tabla temporal.
		INSERT INTO tmp_genres 
		SELECT id AS idMovie, 
			md5(REPLACE(JSON_EXTRACT(CONCAT('["', REPLACE(REPLACE (genres, ' ', '","'), 
				'Science","Fiction', 'Science Fiction'), '"]'), CONCAT("$[",i,"]")), """", "")) AS idGenre,
            REPLACE(JSON_EXTRACT(CONCAT('["', REPLACE(REPLACE (genres, ' ', '","'), 
				'Science","Fiction', 'Science Fiction'), '"]'), CONCAT("$[",i,"]")), """", "") AS name
		FROM movie_dataset_formatted
        WHERE id IN (SELECT id FROM movie_dataset_formatted 
			WHERE i <= JSON_LENGTH(CONCAT('["', REPLACE(REPLACE (genres, ' ', '","'), 
				'Science","Fiction', 'Science Fiction'), '"]'))) ; 
		SET i=i+1;	
	END WHILE;
    
    -- Limpieza de registros nulos en la tabla temporal genres.
	DELETE FROM tmp_genres WHERE name IS NULL OR name = "";
END //
DELIMITER ;

-- Llamada al procedimiento table_tmp_genres.
CALL table_tmp_genres();

-- Asignación de clave primaria en la tabla tmp_genres.
ALTER TABLE tmp_genres ADD PRIMARY KEY (idMovie, idGenre) ;

-- Carga de datos a la tabla oficial genre - Total Registros: 21
INSERT INTO genre SELECT DISTINCT idGenre, name FROM tmp_genres;
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++++++++++++++++ SÉPTIMA ACCIÓN +++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento para extraer la data del campo keywords.
DROP PROCEDURE IF EXISTS table_tmp_keywords ;
DELIMITER //
CREATE PROCEDURE table_tmp_keywords()
BEGIN
	DECLARE i INT DEFAULT 0 ;
    -- Creación de la tabla tmp_keywords para almacenar las palabras del campo multivaliado keywords.
	DROP TABLE IF EXISTS tmp_keywords;
	CREATE TABLE IF NOT EXISTS tmp_keywords (idMovie INT(11), idKeyword VARCHAR(35), word VARCHAR(20));
    
	WHILE i <= 14 DO
		-- Cargando datos del campo multivaluado en la tabla temporal.
		INSERT INTO tmp_keywords 
		SELECT id AS idMovie,
			md5(REPLACE(JSON_EXTRACT(CONCAT('["',REPLACE(REPLACE(keywords, ' ', '","'), "+", " "),'"]'), 
				CONCAT("$[",i,"]")), """", "")) AS idKeyword,
			REPLACE(JSON_EXTRACT(CONCAT('["',REPLACE(REPLACE(keywords, ' ', '","'), "+", " "),'"]'), 
				CONCAT("$[",i,"]")), """", "") AS word
		FROM(SELECT id,
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(keywords,
				"'trudy jackson'", "'trudy+jackson'"), ' on ', ' on+'), ' of ', ' of+'), 
                ' and ', ' and+'), ' a ', ' a+'), ' at ', ' at+'), ' ii ', ' ii+'), ' vu ', '+vu '),
                'u.s. ', 'u.s.+'), 'dc ', 'dc+'), ' mi6', '+mi6'), 'd.c. ', 'd.c.+'), ' to ', ' to+'),
                ' the ', ' the+'), ' de ', ' de+'), ' by ', ' by+'), ' tu ', ' tu+'), ' st ', ' st+'),
                'st. ', 'st.+'), ' in ', ' in+'), ' all ', ' all+'), ' al ', ' al+'), '51', '+51'),
                ' 1 ', '+1 '), ' 11 2021', '+11 2021') AS keywords
			FROM movie_dataset_formatted) t
        WHERE id IN (SELECT id FROM movie_dataset_formatted 
			WHERE i <= JSON_LENGTH(CONCAT('["',REPLACE(keywords, ' ', '","'),'"]'))) ; 
		SET i=i+1;	
	END WHILE;
    
    -- Limpieza de registros nulos en la tabla temporal keywords.
	DELETE FROM tmp_keywords WHERE word IS NULL OR word = "";
END //
DELIMITER ;

-- Llamada al procedimiento table_tmp_keywords.
CALL table_tmp_keywords();

-- Asignación de clave primaria en la tabla tmp_keywords.
ALTER TABLE tmp_keywords ADD PRIMARY KEY (idMovie, idKeyword) ;

-- Carga de datos a la tabla oficial keyword - Total Registros: 4.596
INSERT INTO keyword SELECT DISTINCT idKeyword, word FROM tmp_keywords;
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++++++++++++++++++++++++++ OCTAVA ACCIÓN +++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedimiento para extraer la data del campo cast.
DROP PROCEDURE IF EXISTS table_tmp_cast ;
DELIMITER //
CREATE PROCEDURE table_tmp_cast()
BEGIN
	DECLARE i INT DEFAULT 0 ;
    -- Creación de la tabla tmp_cast para almacenar las palabras del campo multivaliado cast.
	DROP TABLE IF EXISTS tmp_cast;
	CREATE TABLE IF NOT EXISTS tmp_cast (idMovie INT(11), idActor VARCHAR(35), name VARCHAR(30));
    
	WHILE i <= 7 DO
		-- Cargando datos del campo multivaluado en la tabla temporal.
		INSERT INTO tmp_cast 
        SELECT idMovie,
			md5(REPLACE(JSON_EXTRACT(CastJson, CONCAT("$[",i,"]")), """", "")) AS idActor,
			REPLACE(JSON_EXTRACT(CastJson, CONCAT("$[",i,"]")), """", "") AS name
		FROM (SELECT id AS idMovie, cast, SpacesNumber,
				REPLACE(CONCAT('["',
					IF(SpacesNumber >= 13, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', 14), ' ', -2), '","'), ''),
					IF(SpacesNumber >= 11, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', 12), ' ', -2), '","'), ''),
					IF(SpacesNumber >= 9, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', 10), ' ', -2), '","'), ''),
					IF(SpacesNumber >= 7, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', 8), ' ', -2), '","'), ''),
					IF(SpacesNumber >= 5, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', 6), ' ', -2), '","'), ''),
					IF(SpacesNumber >= 3, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', 4), ' ', -2), '","'), ''),
					IF(SpacesNumber = 2, SUBSTRING_INDEX(cast, ' ', 3), SUBSTRING_INDEX(cast, ' ', 2)),
				'"]'), "+", " ") AS CastJson
			FROM(SELECT id, cast, LENGTH(cast) - LENGTH(REPLACE(cast, ' ', '')) AS SpacesNumber 
				FROM(SELECT id,
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
							REPLACE(REPLACE(REPLACE(cast, 
							'  ', ' '), ' Jr.', '+Jr.'), ' Jr ', '+Jr '), 'E.G. ', 'E.G.+'), ' the ', ' the+'), 
							' The ', ' The+'), ' de ','+de '), 'Le Gros',' LeGros'), ' Le ',' Le+'),
							'J. T.', 'J.+T.'), 'E. J.', 'E.+J.'),' J. ', '+J. '), "' ", "'+"), ' D. ', ' D.+'),
							'50 ', '50+'), 'R. D.','R.+D.'), 'Billy Bob Thornton', 'Billy+Bob Thornton'), 
							'M ', 'M+'), ' T. ',' T.+'), 'G. W.', 'G.+W.'), ' G. ', ' G.+'), ' W. ', ' W.+'), 
							'K. D.', 'K.+D.'), 'K. C.', 'K.+C.'), 'D. B.', 'D.+B.'), 'D. L.', 'D.+L.'),
							'Xzibit', 'Xzi bit'), ' L. ', ' L.+'), ' C. ', ' C.+'), 'William Scott', 'William+Scott'), 
							'R. H.','R.+H.'), ' R. ', ' R.+'), 'T.I.', 'T. I.'), ' O. ', ' O.+'), ' H. ', ' H.+'), 
							' A. ', ' A.+'), ' E. ', ' E.+'), ' P. ', ' P.+'), ' F. ', ' F.+'), ' F. ', ' F.+'), 
							' B. ', ' B.+'), ' II', '+II'), 'Lil\'+', 'Lil\' ') AS cast
					FROM movie_dataset_formatted
					)t1
			)t2
        )t3
        WHERE idMovie IN (SELECT id FROM movie_dataset_formatted WHERE i <= JSON_LENGTH(CastJson)) ; 
		SET i=i+1;	
	END WHILE;

    -- Limpieza de registros nulos en la tabla temporal cast.
	DELETE FROM tmp_cast WHERE name IS NULL OR name = "";
END //
DELIMITER ;

-- Llamada al procedimiento table_tmp_cast.
CALL table_tmp_cast();

-- Asignación de clave primaria en la tabla tmp_cast.
ALTER TABLE tmp_cast ADD PRIMARY KEY (idMovie, idActor) ;

-- Carga de datos a la tabla oficial cast - Total Registros: 10.702
INSERT INTO actor SELECT DISTINCT idActor, name FROM tmp_cast;
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++ NOVENA ACCIÓN ++++++++++++++++++++++++++
-- Carga de datos a la tabla oficial movie - Total Registros: 4.803
INSERT INTO movie
SELECT * FROM (
	SELECT DISTINCT id, `index`, budget, 
		IF(homepage != "", homepage, NULL), 
		original_language, original_title, 
		IF(overview != "", overview, NULL),
		popularity,	IF(release_date != "", release_date, NULL), 
        revenue, runtime, `status`, 
		IF(tagline != "", tagline, NULL),
		title, vote_average, vote_count, 
		IF(director != "", tc.idPerson, NULL) idDirector
	FROM movie_dataset_formatted
	LEFT JOIN tmp_crew tc ON (director IN (tc.name, ""))
	WHERE tc.job = "Director"
) t
WHERE idDirector NOT IN (1009253, 930212) OR idDirector is NULL ;
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# ++++++++++++++++++++++++++++++++++ DÉCIMA ACCIÓN +++++++++++++++++++++++++++++++++
-- Carga de datos a la tabla oficial production_companies - Total Registros: 13.677
INSERT INTO production_companies
SELECT DISTINCT idMovie, idCompany FROM tmp_production_companies;

-- Eliminación de la tabla temporal de production_companies
DROP TABLE IF EXISTS tmp_production_companies;
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++++++ UNDÉCIMA ACCIÓN +++++++++++++++++++++++++++++++++
-- Carga de datos a la tabla oficial production_countries - Total Registros: 6.436
INSERT INTO production_countries
SELECT DISTINCT idMovie, iso_3166_1 FROM tmp_production_countries;

-- Eliminación de la tabla temporal de production_countries
DROP TABLE IF EXISTS tmp_production_countries;
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++++ DUODÉCIMA ACCIÓN ++++++++++++++++++++++++++++++
-- Carga de datos a la tabla oficial spoken_languages - Total Registros: 6.937
INSERT INTO spoken_languages
SELECT DISTINCT idMovie, iso_639_1 FROM tmp_spoken_languages;

-- Eliminación de la tabla temporal de spoken_languages
DROP TABLE IF EXISTS tmp_spoken_languages;
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++ DÉCIMATERCERA ACCIÓN ++++++++++++++++++++++
-- Carga de datos a la tabla oficial crew - Total Registros: 129.492
INSERT INTO crew
SELECT DISTINCT idMovie, credit_id FROM tmp_crew;

-- Eliminación de la tabla temporal de crew
DROP TABLE IF EXISTS tmp_crew;
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# ++++++++++++++++++++++++++ DÉCIMACUARTA ACCIÓN ++++++++++++++++++++++++++++
-- Carga de datos a la tabla oficial movies_genres - Total Registros: 12.127
INSERT INTO movie_genres
SELECT DISTINCT idMovie, idGenre FROM tmp_genres;

-- Eliminación de la tabla temporal de genres
DROP TABLE IF EXISTS tmp_genres;
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++++++ DÉCIMAQUINTA ACCIÓN +++++++++++++++++++++++++++++
-- Carga de datos a la tabla oficial movies_keywords - Total Registros: 25.933
INSERT INTO movie_keywords
SELECT DISTINCT idMovie, idKeyword FROM tmp_keywords;

-- Eliminación de la tabla temporal de keywords
DROP TABLE IF EXISTS tmp_keywords;
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# +++++++++++++++++++++++ DÉCIMASEXTA ACCIÓN +++++++++++++++++++++++
-- Carga de datos a la tabla oficial cast - Total Registros: 23.632
INSERT INTO cast
SELECT DISTINCT idMovie, idActor FROM tmp_cast;

-- Eliminación de la tabla temporal de cast
DROP TABLE IF EXISTS tmp_cast;
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++