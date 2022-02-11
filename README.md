# ProyectodeBD

- Explicación
En este proyecto he realizado la conversión de la data de un CSV en un esquema relacional para almacenar lo que contiene, 
en el proceso se encontraron muchas problematicas y conflictos como lo fueron los propios datos que no se extraían de
forma correcta y también que disponiamos de objetos tipos JSON, lo cual me insentivo a investigar mucho y dedicarle
bastante tiempo al tratado de los datos, ya que carecia de conocimiento en archivos de JSON y esto fue nuevo para mi.
Pero como el objetivo final era obtener el equema relacional con la data dentro de un gestor de base de datos, lo cual se
logró a base de mucho esfuerzo y dedicación, aplicando mucho concepto aprendido en clases.

- Datos de la cuenta
Nombre: francisco gonzalez
Username: fxgonzalez5
Repositorio en Github: https://github.com/fxgonzalez5/ProyectodeBD.git
Fecha de Creación: 2022-02-10

- Descripción de los Archivos
1.  Normalización del movie_dataset.xlsx
  Este archivo contiene el proceso de normalización que se aplico para toda la data que se encontro en el CSV.
2.  Database Movie.drawio
  Este archivo contiene el esquema entidad-relación(E/R) y el esquema relacional diseñado a partir de la normalización.
3.  DDL movies_sql.sql
  Este archivo contiene el código de creación del esquema de la base de datos y de cada una de las tablas finales en el 
  esquema de base de datos creado.
4.  Procedimientos de corrección y creación de datos temporales.sql
  Este archivo contiene el código de correción de los datos del dataset que no estan bien decodificados y la estracción 
  de los datos de los objetos de tipo JSON en tablas creadas temporalmente.
5.  DML movies_sql.sql
  Este archivo contiene el código de inserción de datos en cada una de las tablas finales.
6.  Modelado de movie_dataset.pptx
  Este archivo contiene las dispositivas donde se presenta todo el desarrollo del proyecto.
7.  Proyecto de Base de Datos.docx
  Este archivo contiene todo el proceso que se llevo acabo para la realización del proyecto de forma detallada.
