-- Uso de la base de datos movies_sql
USE movies_sql;

# **********************************************************************
-- Carga de datos a la tabla oficial company (sin registros duplicados)
INSERT INTO company 
SELECT DISTINCT idCompany, name
FROM tmp_production_companies;
-- Total Registros: 5.047
# **********************************************************************


# **********************************************************************
-- Carga de datos a la tabla oficial country (sin registros duplicados)
INSERT INTO country 
SELECT DISTINCT iso_3166_1, name
FROM tmp_production_countries;
-- Total Registros: 88
# **********************************************************************


# *************************************************************************************
-- Carga de datos en la tabla oficial language (sin registros duplicados)
INSERT INTO `language` 
SELECT DISTINCT iso_639_1, name 
FROM tmp_spoken_languages;

-- Inserción de un lenguaje faltante para la relación con el campo `original_language`
INSERT INTO `language` VALUES ('nb', 'noruego bokmål');
-- Total Registros: 88
# *************************************************************************************


# *********************************************************************
-- Carga de datos a la tabla oficial person (sin registros duplicados)
INSERT INTO person 
SELECT DISTINCT idPerson, name, gender 
FROM tmp_crew;
-- Total Registros: 52.810
# *********************************************************************


# ***********************************************************************
-- Carga de datos a la tabla oficial director (sin registros duplicados)
INSERT INTO director 
SELECT DISTINCT idPerson 
FROM tmp_crew WHERE job = "Director";
-- Total Registros: 2.578
# ***********************************************************************


# *********************************************************************
-- Carga de datos a la tabla oficial credit (sin registros duplicados)
INSERT INTO credit 
SELECT DISTINCT credit_id, idPerson, department, job 
FROM tmp_crew;
-- Total Registros: 129.492
# *********************************************************************


# ********************************************************************
-- Carga de datos a la tabla oficial genre (sin registros duplicados)
INSERT INTO genre 
SELECT DISTINCT idGenre, name 
FROM tmp_genres;
-- Total Registros: 21
# ********************************************************************


# **********************************************************************
-- Carga de datos a la tabla oficial keyword (sin registros duplicados)
INSERT INTO keyword
SELECT DISTINCT idKeyword, word
FROM tmp_keywords;
-- Total Registros: 4.596
# **********************************************************************


# *******************************************************************
-- Carga de datos a la tabla oficial cast (sin registros duplicados)
INSERT INTO actor 
SELECT DISTINCT idActor, name 
FROM tmp_cast;
-- Total Registros: 10.702
# *******************************************************************

# ******************************************************************
-- Carga de datos a la tabla oficial movie
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
-- Total Registros: 4.803
# ******************************************************************


# **********************************************************
-- Carga de datos a la tabla oficial production_companies
INSERT INTO production_companies
SELECT DISTINCT idMovie, idCompany
FROM tmp_production_companies;
-- Total Registros: 13.677

-- Eliminación de la tabla temporal de production_companies
DROP TABLE IF EXISTS tmp_production_companies;
# **********************************************************


# **********************************************************
-- Carga de datos a la tabla oficial production_countries
INSERT INTO production_countries
SELECT DISTINCT idMovie, iso_3166_1 
FROM tmp_production_countries;
-- Total Registros: 6.436

-- Eliminación de la tabla temporal de production_countries
DROP TABLE IF EXISTS tmp_production_countries;
# **********************************************************


# ******************************************************
-- Carga de datos a la tabla oficial spoken_languages
INSERT INTO spoken_languages
SELECT DISTINCT idMovie, iso_639_1
FROM tmp_spoken_languages;
-- Total Registros: 6.937

-- Eliminación de la tabla temporal de spoken_languages
DROP TABLE IF EXISTS tmp_spoken_languages;
# ******************************************************


# ******************************************
-- Carga de datos a la tabla oficial crew
INSERT INTO crew
SELECT DISTINCT idMovie, credit_id 
FROM tmp_crew;
-- Total Registros: 129.492

-- Eliminación de la tabla temporal de crew
DROP TABLE IF EXISTS tmp_crew;
# ******************************************


# *************************************************
-- Carga de datos a la tabla oficial movies_genres
INSERT INTO movie_genres
SELECT DISTINCT idMovie, idGenre FROM tmp_genres;
-- Total Registros: 12.127

-- Eliminación de la tabla temporal de genres
DROP TABLE IF EXISTS tmp_genres;
# *************************************************


# ***************************************************
-- Carga de datos a la tabla oficial movies_keywords
INSERT INTO movie_keywords
SELECT DISTINCT idMovie, idKeyword
FROM tmp_keywords;
-- Total Registros: 25.933

-- Eliminación de la tabla temporal de keywords
DROP TABLE IF EXISTS tmp_keywords;
# ***************************************************


# ******************************************
-- Carga de datos a la tabla oficial cast
INSERT INTO cast
SELECT DISTINCT idMovie, idActor 
FROM tmp_cast;
-- Total Registros: 23.632

-- Eliminación de la tabla temporal de cast
DROP TABLE IF EXISTS tmp_cast;
# ******************************************