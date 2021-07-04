#' Elimina la Base de Datos del Censo de tu Computador
#'
#' Elimina el directorio `censo2017` y todos sus contenidos, incluyendo versiones
#' de la base de datos del Censo creadas con cualquier version de 'DuckDB'.
#'
#' @param preguntar Si acaso se despliega un menu para confirmar la accion de
#'  borrar cualquier base del censo existente. Por defecto es verdadero.
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{ censo_eliminar() }
censo_eliminar <- function(preguntar = TRUE) {
  if (preguntar) {
    answer <- utils::menu(c("De acuerdo", "Cancelar"), 
                   title = "Esto eliminara todas las bases del censo",
                   graphics = FALSE)
    if (answer == 2) {
       return(invisible())
    }
  }
  
  suppressWarnings(censo_desconectar())
  try(unlink(censo_path(), recursive = TRUE))
  update_censo_pane()
  return(invisible())
}
