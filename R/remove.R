#' Elimina la Base de Datos del Censo de tu Computador
#'
#' Elimina el directorio `censo2017` y todos sus contenidos, incluyendo versiones
#' de la base de datos del Censo creadas con cualquier version de 'DuckDB'.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{ censo_eliminar() }
censo_eliminar <- function() {
  suppressWarnings(censo_desconectar())
  try(unlink(gsub("duckdb.*", "", censo_path()), recursive = TRUE))
  update_censo_pane()
}
