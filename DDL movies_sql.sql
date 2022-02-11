# Base de Datos: `movies_sql`
-- ------------------------
CREATE DATABASE movies_sql;
USE movies_sql;
-- -----------------------


# Eliminación previa de de las tablas por si existen
-- ----------------------------------------
DROP TABLE IF EXISTS cast;
DROP TABLE IF EXISTS movie_keywords;
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS crew;
DROP TABLE IF EXISTS spoken_languages;
DROP TABLE IF EXISTS production_countries;
DROP TABLE IF EXISTS production_companies;
DROP TABLE IF EXISTS movie;
DROP TABLE IF EXISTS actor;
DROP TABLE IF EXISTS keyword;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS director;
DROP TABLE IF EXISTS credit;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS `language`;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS company;
-- ----------------------------------------


# Estructura de la tabla `company`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional parcial.
# Clave primaría: idCompany, obtenida del campo production_compaies que esta en objeto tipo JSON.
-- ----------------------------------
CREATE TABLE IF NOT EXISTS company (
    idCompany INT(11) NOT NULL,
    name VARCHAR(85) NOT NULL,
    PRIMARY KEY (idCompany)
);
-- ----------------------------------


# Estructura de la tabla `country`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional parcial.
# Clave primaría: iso_3166_1, obtenida del campo production_counntries que esta en objeto tipo JSON.
-- ----------------------------------
CREATE TABLE IF NOT EXISTS country (
    iso_3166_1 CHAR(2) NOT NULL,
    name VARCHAR(30) NOT NULL,
    PRIMARY KEY (iso_3166_1)
);
-- ----------------------------------


# Estructura de la tabla `language`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional parcial.
# Clave primaría: iso_639_1, obtenida del campo spoken_languages que esta en objeto tipo JSON.
-- -------------------------------------
CREATE TABLE IF NOT EXISTS `language` (
    iso_639_1 CHAR(2) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (iso_639_1)
);
-- -------------------------------------


# Estructura de la tabla `person`
# Obtuve esta tabla a partir de la tercera forma normal, aplicando dependencia funcional transitiva.
# Clave primaría: idPerson, obtenida del campo crew que esta en objeto tipo JSON.
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS person (
    idPerson INT(11) NOT NULL,
    name VARCHAR(50) NOT NULL,
    gender INT(1) NOT NULL COMMENT 'Genero del tripulante;
		0 es sin especificar, 1 mujer y 2 hombre' 
        CHECK (gender >= 0 AND gender <= 2),
    PRIMARY KEY (idPerson)
);
-- --------------------------------------------------------


# Estructura de la tabla `credit`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional parcial.
# Clave primaría: creditId, obtenida del campo crew que esta en objeto tipo JSON.
# Clave foránea: idPerson, definida a partir de la existencia de la tercera forma normal en el campo crew con referencia a la tabla `person`.
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS credit (
    creditId VARCHAR(25) NOT NULL,
    idPerson INT(11) NOT NULL,
    department VARCHAR(25) NOT NULL,
    job VARCHAR(75) NOT NULL,
    PRIMARY KEY (creditId),
    CONSTRAINT `fk_credit_person` FOREIGN KEY (idPerson)
        REFERENCES person (idPerson)
);
-- ------------------------------------------------------


# Estructura de la tabla `director`
# Obtuve esta tabla a partir de la identificación del campo director en la tabla `movie`, en el cual verificamos que los nombres se encontraban dentro del campo crew y como buena practica se almacena dichos datos como una nueva entidad.
# Clave primaría: idDirector, obtenida de la tabla `person`.
# Clave foránea: idDirector, definida a partir de la existencia de estos datos en el campo crew, haciendo referencia a la tabla `person`.
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS director (
    idDirector INT(11) NOT NULL,
    PRIMARY KEY (idDirector),
    CONSTRAINT `fk_director_person` FOREIGN KEY (idDirector)
        REFERENCES person (idPerson)
);
-- ----------------------------------------------------------


# Estructura de la tabla `genre`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional parcial.
# Clave primaría: idGenre, obtenida del campo genres, creada con la función md5 al momento de convertir el campo en tabla relacional(atómica).
-- --------------------------------
CREATE TABLE IF NOT EXISTS genre (
    idGenre VARCHAR(35) NOT NULL,
    name VARCHAR(15) NOT NULL,
    PRIMARY KEY (idGenre)
);
-- --------------------------------


# Estructura de la tabla `keyword`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional parcial.
# Clave primaría: idKeyword, obtenida del campo keywords, creada con la función md5 al momento de convertir el campo en tabla relacional(atómica).
-- ----------------------------------
CREATE TABLE IF NOT EXISTS keyword (
    idKeyword VARCHAR(35) NOT NULL,
    word VARCHAR(20) NOT NULL,
    PRIMARY KEY (idKeyword)
);
-- ----------------------------------


# Estructura de la tabla `actor`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional parcial.
# Clave primaría: idActor, obtenida del campo cast, creada con la función md5 al momento de convertir el campo en tabla relacional(atómica).
-- --------------------------------
CREATE TABLE IF NOT EXISTS actor (
    idActor VARCHAR(35) NOT NULL,
    name VARCHAR(30) NOT NULL,
    PRIMARY KEY (idActor)
);
-- --------------------------------


# Estructura de la tabla `movie`
# Obtuve esta tabla a partir de la separación de los campos multivaluados y compuestos para cumplir la primera forma normal (datos atómicos) y la segunda forma normal con dependencia funcional completa.
# Clave primaría: idMovie, identificada en data.
-- -----------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS movie (
    idMovie INT(11) NOT NULL,
    `index` INT(5) NOT NULL,
    budget INT(12) NOT NULL CHECK (budget >= 0),
    homepage VARCHAR(150) DEFAULT NULL,
    original_language CHAR(2) NOT NULL,
    original_title VARCHAR(90) NOT NULL,
    overview VARCHAR(1000) DEFAULT NULL,
    popularity DECIMAL(25,21) NOT NULL CHECK (popularity >= 0),
    release_date DATE DEFAULT NULL CHECK (YEAR(release_date) >= 1900),
    revenue BIGINT(10) NOT NULL CHECK (revenue >= 0),
    runtime DECIMAL(4,1) DEFAULT NULL COMMENT 'Tiempo de la película en minutos.'
		CHECK (runtime >= 0  AND runtime <= 500),
    status VARCHAR(15) NOT NULL CHECK (status = 'Released'
        OR status = 'Rumored'
        OR status = 'Post Production'),
    tagline VARCHAR(255) DEFAULT NULL,
    title VARCHAR(90) NOT NULL,
    vote_average DECIMAL(3 , 1 ) NOT NULL CHECK (vote_average >= 0 AND vote_average <= 10),
    vote_count INT(10) NOT NULL CHECK (vote_count >= 0),
    director INT(11) DEFAULT NULL,
    PRIMARY KEY (idMovie),
    CONSTRAINT `fk_movie_language` FOREIGN KEY (original_language)
        REFERENCES `language` (iso_639_1),
	CONSTRAINT `fk_movie_director` FOREIGN KEY (director)
        REFERENCES director (idDirector)
);
-- -----------------------------------------------------------------------------------------


# Estructura de la tabla `production_companies`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional completa luego de obtener la tabla final `company` aplicando dependencia funcional parcial.
# Clave primaría: idMovie y idCompany, obtenidas a partir de la converersión del campo production_companies en tabla relacional.
# Clave foránea: idMovie y idCompany, definida a partir de la de la relación entre la tabla `movie` y `company`.
-- ----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS production_companies (
    idMovie INT(11) NOT NULL,
    idCompany INT(11) NOT NULL,
    PRIMARY KEY (idMovie , idCompany),
    CONSTRAINT `fk_production_companies_movie` FOREIGN KEY (idMovie)
        REFERENCES movie (idMovie),
    CONSTRAINT `fk_production_companies_company` FOREIGN KEY (idCompany)
        REFERENCES company (idCompany)
);
-- ----------------------------------------------------------------------


# Estructura de la tabla `production_countries`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional completa luego de obtener la tabla final `country` aplicando dependencia funcional parcial.
# Clave primaría: idMovie y iso_3166_1, obtenidas a partir de la converersión del campo production_countries en tabla relacional.
# Clave foránea: idMovie y iso_3166_1, definida a partir de la de la relación entre la tabla `movie` y `country`.
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS production_countries (
    idMovie INT(11) NOT NULL,
    iso_3166_1 CHAR(2) NOT NULL,
    PRIMARY KEY (idMovie , iso_3166_1),
    CONSTRAINT `fk_production_countries_movie` FOREIGN KEY (idMovie)
        REFERENCES movie (idMovie),
    CONSTRAINT `fk_production_countries_country` FOREIGN KEY (iso_3166_1)
        REFERENCES country (iso_3166_1)
);
-- -----------------------------------------------------------------------


# Estructura de la tabla `spoken_languages`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional completa luego de obtener la tabla final `language` aplicando dependencia funcional parcial.
# Clave primaría: idMovie y iso_639_1, obtenidas a partir de la converersión del campo spoken_languages en tabla relacional.
# Clave foránea: idMovie y iso_639_1, definida a partir de la de la relación entre la tabla `movie` y `language`.
-- -------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS spoken_languages (
    idMovie INT(11) NOT NULL,
    iso_639_1 CHAR(2) NOT NULL,
    PRIMARY KEY (idMovie , iso_639_1),
    CONSTRAINT `fk_spoken_languages_movie` FOREIGN KEY (idMovie)
        REFERENCES movie (idMovie),
    CONSTRAINT `fk_spoken_languages_language` FOREIGN KEY (iso_639_1)
        REFERENCES `language` (iso_639_1)
);
-- -------------------------------------------------------------------


# Estructura de la tabla `crew`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional completa luego de obtener la tabla final `credit` aplicando dependencia funcional parcial.
# Clave primaría: idMovie y creditId, obtenidas a partir de la converersión del campo crew en tabla relacional.
# Clave foránea: idMovie y creditId, definida a partir de la de la relación entre la tabla `movie` y `credit`.
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS crew (
    idMovie INT(11) NOT NULL,
    creditId VARCHAR(25) NOT NULL,
    PRIMARY KEY (idMovie , creditId),
    CONSTRAINT `fk_crew_movie` FOREIGN KEY (idMovie)
        REFERENCES movie (idMovie),
    CONSTRAINT `fk_crew_credit` FOREIGN KEY (creditId)
        REFERENCES credit (creditId)
);
-- ----------------------------------------------------


# Estructura de la tabla `movie_genres`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional completa luego de obtener la tabla final `genre` aplicando dependencia funcional parcial.
# Clave primaría: idMovie y idGenre, obtenidas a partir de la converersión del campo genres en tabla relacional.
# Clave foránea: idMovie y idGenre, definida a partir de la de la relación entre la tabla `movie` y `genre`.
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS movie_genres (
    idMovie INT(11) NOT NULL,
    idGenre VARCHAR(35) NOT NULL,
    PRIMARY KEY (idMovie , idGenre),
    CONSTRAINT `fk_movie_genres_movie` FOREIGN KEY (idMovie)
        REFERENCES movie (idMovie),
    CONSTRAINT `fk_movie_genres_genre` FOREIGN KEY (idGenre)
        REFERENCES genre (idGenre)
);
-- ----------------------------------------------------------


# Estructura de la tabla `movie_keywords`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional completa luego de obtener la tabla final `keyword` aplicando dependencia funcional parcial.
# Clave primaría: idMovie y idKeyword, obtenidas a partir de la converersión del campo keywords en tabla relacional.
# Clave foránea: idMovie y idKeyword, definida a partir de la de la relación entre la tabla `movie` y `keyword`.
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS movie_keywords (
    idMovie INT(11) NOT NULL,
    idKeyword VARCHAR(35) NOT NULL,
    PRIMARY KEY (idMovie , idKeyword),
    CONSTRAINT `fk_movie_keywords_movie` FOREIGN KEY (idMovie)
        REFERENCES movie (idMovie),
    CONSTRAINT `fk_movie_keywords_keyword` FOREIGN KEY (idKeyword)
        REFERENCES keyword (idKeyword)
);
-- ----------------------------------------------------------------


# Estructura de la tabla `cast`
# Obtuve esta tabla a partir de la segunda forma normal, aplicando dependencia funcional completa luego de obtener la tabla final `actor` aplicando dependencia funcional parcial.
# Clave primaría: idMovie y idActor, obtenidas a partir de la converersión del campo cast en tabla relacional.
# Clave foránea: idMovie y idActor, definida a partir de la de la relación entre la tabla `movie` y `actor`.
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS cast (
    idMovie INT(11) NOT NULL,
    idActor VARCHAR(35) NOT NULL,
    PRIMARY KEY (idMovie , idActor),
    CONSTRAINT `fk_cast_movie` FOREIGN KEY (idMovie)
        REFERENCES movie (idMovie),
    CONSTRAINT `fk_cast_actor` FOREIGN KEY (idActor)
        REFERENCES actor (idActor)
);
-- --------------------------------------------------