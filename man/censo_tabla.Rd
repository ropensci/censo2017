% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/connect.R
\name{censo_tabla}
\alias{censo_tabla}
\title{Tablas Completas de la Base de Datos del Censo}
\usage{
censo_tabla(tabla)
}
\arguments{
\item{tabla}{Una cadena de texto indicando la tabla a extraer}
}
\value{
Un tibble
}
\description{
Devuelve una tabla completa de la base de datos. Para entregar datos
filtrados previamente se debe usar \code{\link[=censo_conectar]{censo_conectar()}}.
}
\examples{
\dontrun{ censo_tabla("comunas") }
}
