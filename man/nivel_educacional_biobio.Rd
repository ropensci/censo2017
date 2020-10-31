\name{nivel_educacional_biobio}
\alias{nivel_educacional_biobio}
\docType{data}
\title{
Poblacion por Nivel Educacional en la Region del Bio Bio
}
\description{
Proporciona la cuenta y porcentaje por comuna de las personas de la Region del
Bio Bio de acuerdo al maximo nivel educacional que reportan (e.g. primaria, 
secundaria, universitaria, etc.)
}
\usage{data("nivel_educacional_biobio")}
\format{
  Un tibble con 860 observaciones en las siguientes 4 variables.
  \describe{
    \item{\code{comuna}}{codigo de comuna (15 regiones)}
    \item{\code{nivel_educ}}{maximo nivel educacional alcanzado (ver la
    vinieta con los links a la descripcion de codigos)}
    \item{\code{cuenta}}{cantidad de personas censadas en la comuna}
    \item{\code{proporcion}}{porcentaje que representan las personas censadas en la comuna}
  }
}
\source{
Instituto Nacional de Estadisticas (INE)
}
\examples{
nivel_educacional_biobio
}
\keyword{datasets}
