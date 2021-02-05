#' Elimina la Base de Datos del Censo de tu Computador
#'
#' Elimina el directorio `censo2017` en el directorio de datos de usuario.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \donttest{
#' \dontrun{
#' censo_borrar_base()
#' }
#' }
censo_borrar_base <- function() {
  duckdb_version <- utils::packageVersion("duckdb")
  db_pattern <- paste0("v", gsub("\\.", "", duckdb_version), ".duckdb")
  
  existing_files <- list.files(censo_path())
  
  if (!any(grepl(db_pattern, existing_files))) {
    suppressWarnings(censo_desconectar_base())
    try(unlink(censo_path(), recursive = TRUE))
  }
  
  update_censo_pane()
  censo_panel()
}
