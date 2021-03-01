\name{censo_variables}
\alias{censo_variables}
\docType{data}
\title{
Variables del CENSO 2017 con su Respectiva Descripcion y Rango
}
\description{
Proporciona la descripcion de las variables de las tablas del CENSO 2017. 
Por ejemplo, indica que la columna p01 en la tabla de viviendas corresponde a
'Tipo de Vivienda' y es una columna que contiene numeros enteros.)
}
\usage{data("censo_variables")}
\format{
  Un tibble con 60 observaciones en las siguientes 5 variables.
  \describe{
    \item{\code{tabla}}{tabla censal (personas, hogares, viviendas, zonas o
    comunas)}
    \item{\code{variable}}{codigo de variable (e.g. p01)}
    \item{\code{descripcion}}{descripcion del codigo de variable 
    (e.g. 'Tipo de Vivienda')}
    \item{\code{tipo}}{tipo de columna (e.g. integer)}
    \item{\code{rango}}{rango de la variable (e.g. 1 - 10)}
  }
}
\source{
Instituto Nacional de Estadisticas (INE)
}
\examples{
censo_variables
}
\keyword{datasets}
