sql_action <- function() {
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      exists("documentNew", asNamespace("rstudioapi"))) {
    contents <- paste(
      "-- !preview conn=censo2017::censo_bbdd()",
      "",
      "SELECT * FROM comunas",
      "",
      sep = "\n"
    )

    rstudioapi::documentNew(
      text = contents, type = "sql",
      position = rstudioapi::document_position(2, 40),
      execute = FALSE
    )
  }
}

#' Abre el Panel de Conexion a la Base de Datos del Censo en RStudio
#'
#' Esta funcion abre el panel "Connections" para explorar la base de datos
#' local de forma interactiva.
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (!is.null(getOption("connectionObserver"))) censo_panel()
censo_panel <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer) && interactive()) {
    observer$connectionOpened(
      type = "Censo2017",
      host = "censo2017",
      displayName = "Tablas Censo 2017",
      icon = system.file("img", "cl-logo.png", package = "censo2017"),
      connectCode = "censo2017::censo_panel()",
      disconnect = censo2017::censo_desconectar_base,
      listObjectTypes = function() {
        list(
          table = list(contains = "data")
        )
      },
      listObjects = function(type = "datasets") {
        tbls <- DBI::dbListTables(censo_bbdd())
        data.frame(
          name = tbls,
          type = rep("table", length(tbls)),
          stringsAsFactors = FALSE
        )
      },
      listColumns = function(table) {
        res <- DBI::dbGetQuery(censo_bbdd(),
                               paste("SELECT * FROM", table, "LIMIT 1"))
        data.frame(
          name = names(res), type = vapply(res, function(x) class(x)[1],
                                           character(1)),
          stringsAsFactors = FALSE
        )
      },
      previewObject = function(rowLimit, table) {
        DBI::dbGetQuery(censo_bbdd(),
                        paste("SELECT * FROM", table, "LIMIT", rowLimit))
      },
      actions = list(
        Status = list(
          icon = system.file("img", "cl-logo.png", package = "censo2017"),
          callback = censo_estado
        ),
        SQL = list(
          icon = system.file("img", "edit-sql.png", package = "censo2017"),
          callback = sql_action
        )
      ),
      connectionObject = censo_bbdd()
    )
  }
}

update_censo_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionUpdated("Censo2017", "censo2017", "")
  }
}
