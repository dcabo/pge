Los Presupuestos
================

Los Presupuestos Generales del Estado del año 2010 se encuentran disponibles en la web del [Ministerio de Economía y Hacienda][1]. Antes de comenzar a trabajar con los Presupuestos es muy recomendable leer el [Libro Azul][2], que da una visión general de la estructura de los mismos.

Ejecutando los scripts
======================

Preparación: descargando los Presupuestos
-----------------------------------------

Los Presupuestos Generales del año 2010 están disponibles en la web del Ministerio tanto en su versión aprobada (la que nos interesa por ahora) como en la versión del proyecto de ley. Cada una de estas versiones se puede visualizar en línea o se puede descargar. En nuestro caso, estamos interesados en descargar la información para trabajar localmente, mucho más cómoda y rápidamente.

Las descargas se pueden hacer "por tomos", donde un fichero PDF representa cada uno de los tomos que componen la versión física del Presupuesto, pero para procesar la información automáticamente es mucho mejor la versión "normal", que incluye una versión HTML de cada uno de los artículos del Presupuesto.

[1]: http://www.sgpg.pap.meh.es/SITIOS/SGPG/ES-ES/PRESUPUESTOS/Paginas/PGE2010.aspx
[2]: http://www.sgpg.pap.meh.es/sitios/sgpg/es-ES/Presupuestos/Presupuestos/Documents/PROYECTO/LIBRO%20AZULv3.pdf

Entendiendo la estructura de ficheros
-------------------------------------

La versión de los Presupuestos que nos hemos descargado consiste en un enorme conjunto de ficheros .HTM con nombres aparentemente crípticos. Una pequeña explicación del significado de los nombres de los ficheros se encuentra en `budget.rb` (hasta donde yo sé).

Extracción de organismos de primer nivel
----------------------------------------

'Sección' es el término en los Presupuestos para las entidades de más alto nivel en el organigrama de la Administración: básicamente Ministerios, pero también organismos del Estado como las Cortes Generales o el Tribunal Constitucional.

Al ejecutar el script, debemos pasarle como parámetro la ruta a la carpeta `PGE-ROM` de los presupuestos a analizar. 

    > ./extract_top_level_sections.rb <ruta>

Extracción de organismos de segundo nivel
-----------------------------------------

Dentro de las secciones (i.e. Ministerios y similares) se encuentran los 'servicios', que se corresponden generalmente con Secretarías Generales y entidades similares. Además, para cada sección existe una serie de 'Organismos Autónomos', 'Organismos Públicos' y 'Agencias Estatales'.

Para extraer la lista de organismos de los Presupuestos, ejecutar:

    > ./extract_child_sections.rb <ruta>

La lista resultante debería coincidir con la Estructura Orgánica que se muestra en el Libro Azul de los Presupuestos a partir de la página 66.

Si no te apetece hacer todo lo anterior, y sólo quieres ver el resultado final, mira en `/output`.

Extracción de gastos presupuestados
-----------------------------------

Para extraer los datos de gastos de los Presupuestos, ejecutar:

    > ./extract_expenses.rb > output/expenses.csv

Para importar los datos del fichero CSV generado en la base de datos de la aplicación, de momento usamos la consola de administración de sqlite3:

    > sqlite3 development.db
    sqlite3> .mode csv
    sqlite3> .separator "|"
    sqlite3> .import parser/output/expenses.csv expenses
    sqlite3> .exit

Rake
----

Existen tareas Rake para ejecutar las tareas anteriores:

    $ rake -T
    rake parse:budget[year]              # Extract all information from budget files
    rake parse:child_sections[year]      # Extract children section names from budget files
    rake parse:expenses[year]            # Extract expenses from budget files
    rake parse:top_level_sections[year]  # Extract top level section names from budget files

Los datos extraídos se redirigen a ficheros en la carpeta `output/[año]/`.
