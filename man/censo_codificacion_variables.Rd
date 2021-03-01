\name{censo_codificacion_variables}
\alias{censo_codificacion_variables}
\docType{data}
\title{
Variables del CENSO 2017 con las Etiquetas Asociadas a los Valores
}
\description{
Proporciona la descripcion de los valores de las variables de las tablas del 
CENSO 2017. Por ejemplo, indica que en la columna p01 de la tabla de viviendas, 
el valor 1 corresponde a 'Casa'.
}
\usage{data("censo_codificacion_variables")}
\format{
  Un tibble con 1768 observaciones en las siguientes 4 variables.
  \describe{
    \item{\code{tabla}}{tabla censal (personas, hogares, viviendas, zonas o
    comunas)}
    \item{\code{variable}}{codigo de variable (e.g. p01)}
    \item{\code{valor}}{valor de la etiqueta de la variable 
    (e.g. '1')}
    \item{\code{descripcion}}{descripcion de la etiqueta de la variable 
    (e.g. 'Casa')}
  }
}
\source{
Instituto Nacional de Estadisticas (INE)
}
\examples{
censo_codificacion_variables
}
\keyword{datasets}
