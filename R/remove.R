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
  suppressWarnings(censo_desconectar_base())
  try(unlink(censo_path(), recursive = TRUE))
  update_censo_pane()
  censo_panel()
}
