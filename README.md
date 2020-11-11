<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![GH-actions](https://github.com/pachamaltese/censo2017/workflows/R-CMD-check/badge.svg)](https://github.com/pachamaltese/censo2017/actions)
[![codecov](https://codecov.io/gh/pachamaltese/censo2017/branch/main/graph/badge.svg?token=XI59cmGd15)](https://codecov.io/gh/pachamaltese/censo2017)
<!-- badges: end -->

# Acerca de

Provee un acceso conveniente a mas de 17 millones de registros de la base de datos del Censo 2017. Los datos fueron importados desde el DVD oficial del INE usando el Convertidor REDATAM creado por Pablo De Grande y ademas se proporcionan los mapas que acompanian a estos datos.

# Instalacion

Version de desarrollo
```
# install.packages("remotes")
remotes::install_github("pachamaltese/censo2017")
```

# Valor agregado sobre los archivos shp y redatam del INE

Tal como explico en mi sitio [SQL Databases for Students and Educators](https://db-edu.pacha.dev/), esta base presenta algunas diferencias respecto de la original que se obtiene en DVD.

Esta version corresponde a una version SQLite de la base original que hice usando PostGIS (PostgreSQL + GIS) a partir de los Microdatos del Censo 2017 en formato DVD. 

La informacion se convirtio desde REDATAM usando el [Convertidor REDATAM](https://github.com/discontinuos/redatam-converter/) creado por Pablo De Grande. La modificacion a estos archivos, que incluye geometrias detalladas, consistio en unir todos los archivos shp regionales en una unica tabla por nivel (e.g en lugar de proveer `R01_mapa_comunas`, ..., `R15_mapa_comunas` combine las 15 regiones en una unica tabla `mapa_comunas`).

Todos los datos de estos repositorios contemplan 15 regiones pues los archivos del Censo se entregan de esta forma. Esto difiere de mi otro proyecto [chilemapas](https://pacha.dev/chilemapas/) que se centra unicamente en las geometrias y donde converti las mismas cartografias del DVD del Censo a mapas simplificados (de menor tamanio) y con la posterior transformacion de codigos para dar cuenta de la creacion de la Region de Niuble.

Los cambios concretos respecto de la base original son los siguientes:
* Nombres de columna en formato "tidy" (e.g. `comuna_ref_id` en lugar de `COMUNA_REF_ID`).
* Agregue los nombres de las unidades geograficas (e.g. se incluye `nom_comuna` en la tabla `comunas` para facilitar los filtros).
* Inclui restricciones e indices en la base original PostGIS para hacer maś eficientes los filtros.
* Esta version incluye unicamente llaves primarias y no trae las llaves foraneas de la version PostGIS. Esto es debido a que SQLite no tiene todas las funciones de PostreSQL.
* Aniadi la variable `geocodigo` a la tabla de `zonas`. Esto facilita mucho las uniones con las tablas de mapas.
* Tambien inclui las observaciones 16054 to 16060 en la variable `zonaloc_ref_id`. Esto se debio a que era necesario para crear una llave foranea desde la tabla `mapa_zonas` y vincular el `geocodigo` (no todas las zonas del mapa estan presentes en los datos del Censo).

Ademas de estos datos, libere la [descripcion de variables](https://db-edu.pacha.dev/censo2017-descripcion-variables.xml), donde se puede explorar la estructura de arbol de los datos REDATAM y sus etiquetas (e.g. la variable `p15` significa "maximo nivel educacional obtenido", donde `13` significa "titulo profesional").

# Agradecimientos

Muchas gracias a Juan Correa ([\@juanizio_c](https://twitter.com/Juanizio_C/)) por su asesoria como geografo experto.

# Aportes

Si quieres donar para aportar al desarrollo de este y mas paquetes Open Source, puedes hacerlo en [Buy Me a Coffee](https://www.buymeacoffee.com/pacha/).
