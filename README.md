<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![GH-actions Windows](https://github.com/pachamaltese/censo2017/workflows/check-windows/badge.svg)](https://github.com/pachamaltese/censo2017/actions)
[![GH-actions Linux](https://github.com/pachamaltese/censo2017/workflows/check-linux/badge.svg)](https://github.com/pachamaltese/censo2017/actions)
[![Coverage status](https://codecov.io/gh/pachamaltese/censo2017/branch/master/graph/badge.svg)](https://codecov.io/github/pachamaltese/censo2017?branch=master)
<!-- badges: end -->

# Acerca de

Provee un acceso conveniente a más de 17 millones de registros de la base de datos del Censo 2017. Los datos fueron importados desde el DVD oficial del INE usando el Convertidor REDATAM creado por Pablo De Grande y además se proporcionan los mapas que acompañan a estos datos.
    
# Documentación

La documentacion estará disponible en https://pacha.dev/censo2017. Se incluirán ejemplos de uso de las funciones del paquete censo2017 y como se integra con otros paquetes de R.

# Instalación

Version de desarrollo
```
# install.packages("remotes")
remotes::install_github("pachamaltese/censo2017")
```

# Valor agregado sobre los archivos shp y redatam del INE

Tal como explico en mi sitio [SQL Databases for Students and Educators](https://db-edu.pacha.dev/), esta base presenta algunas diferencias respecto de la original que se obtiene en DVD.

Esta versión corresponde a una versión SQLite de la base original que hice usando PostGIS (PostgreSQL + GIS) a partir de los [Microdatos del Censo 2017 en DVD](https://www.ine.cl/prensa/2019/09/16/ine-pone-a-disposici%C3%B3n-la-base-de-microdatos-del-censo-2017). 

La información se convirtió desde REDATAM usando el [Convertidor REDATAM](https://github.com/discontinuos/redatam-converter) creado por Pablo De Grande. La modificación a estos archivos, que incluye geometrías detalladas, consistió en unir todos los archivos shp regionales en una única tabla por nivel (e.g en lugar de proveer `R01_mapa_comunas`, ..., `R15_mapa_comunas` combiné las 15 regiones en una única tabla `mapa_comunas`).

Todos los datos de estos repositorios contemplan 15 regiones pues los archivos del Censo se entregan de esta forma. Esto difiere de mi otro proyecto [chilemapas](https://[pacha.dev/chilemapas]) que se centra únicamente en las geometrías y donde convertí las mismas cartografías del DVD del Censo a mapas simplificados (de menor tamaño) y con la posterior transformación de códigos para dar cuenta de la creación de la Región de Ñuble.

Los cambios concretos respecto de la base original son los siguientes:
* Nombres de columna en formato "tidy" (e.g. `comuna_ref_id` en lugar de `COMUNA_REF_ID`)
* Agregué los nombres de las unidades geográficas (e.g. se incluye `nom_comuna` en la tabla `comunas` para facilitar los filtros)
* Incluí restricciones e índices en la base original PostGIS para hacer maś eficientes los filtros.
* Esta versión incluye únicamente llaves primarias y no trae las llaves foráneas de la versión PostGIS. Esto es debido a que SQLite no tiene todas las funciones de PostreSQL.
* Añadí la variable `geocodigo` a la tabla de `zonas`. Esto facilita mucho las uniones con las tablas de mapas.
* También incluí las observaciones 16054 to 16060 en la variable `zonaloc_ref_id`. Esto se debió a que era necesario para crear una llave foránea desde la tabla `mapa_zonas` y vincular el `geocodigo` (no todas las zonas del mapa están presentes en los datos del Censo).

Además de estos datos, liberé la [descripción de variables](https://db-edu.pacha.dev/censo2017-descripcion-variables.xml), donde se puede explorar la estructura de árbol de los datos REDATAM y sus etiquetas (e.g. la variable `p15` significa "máximo nivel educacional obtenido", donde `13` significa "título profesional").

# Agradecimientos

Muchas gracias a Juan Correa ([\@juanizio_c](https://twitter.com/Juanizio_C)) por su asesoría como geógrafo experto.
