#' @importFrom rappdirs user_data_dir
censo_path <- function() {
  sys_censo_path <- Sys.getenv("CENSO_BBDD_DIR")
  sys_censo_path <- gsub("\\\\", "/", sys_censo_path)
  if (sys_censo_path == "") {
    return(gsub("\\\\", "/", paste0(rappdirs::user_data_dir(), "/censo2017")))
  } else {
    return(gsub("\\\\", "/", sys_censo_path))
  }
}

censo_check_status <- function() {
  if (!censo_estado(FALSE)) {
    stop("La base de datos local del Censo 2017 esta vacia o daniada. Descargala con censo_descargar_base().")
  }
}

#' Conexion a la Base de Datos del Censo
#'
#' Devuelve una conexion a la base de datos local. Esto corresponde a una
#' conexion a una base 'SQLite' compatible con DBI. A diferencia de 
#' [censo2017::censo_tabla()], esta funcion es mas flexible y se puede usar con 
#' dbplyr para leer unicamente lo que se necesita o directamente con DBI para
#' usar comandos SQL.
#'
#' @param dir La ubicacion de la base de datos en el disco. Por defecto es
#' `censo2017` en la carpeta de datos del usuario ([rappdirs::user_data_dir()]), 
#' o la variable de entorno `CENSO_BBDD_DIR`.
#'
#' @export
#'
#' @examples
#' if (censo_estado()) {
#'  DBI::dbListTables(censo_bbdd())
#'
#'  DBI::dbGetQuery(
#'   censo_bbdd(),
#'   'SELECT * FROM comunas WHERE provincia_ref_id = 1'
#'  )
#' }
censo_bbdd <- function(dir = censo_path()) {
  db <- mget("censo_bbdd", envir = censo_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      return(db)
    }
  }
  
  try(dir.create(dir, showWarnings = FALSE, recursive = TRUE))
  
  tryCatch({
    db <- DBI::dbConnect(
      RSQLite::SQLite(),
      paste0(dir, "/censo2017.sqlite")
    )
  },
  error = function(e) {
    if (grepl("(Database lock|bad rolemask)", e)) {
      stop(
        "La base de datos local del Censo esta siendo usada por otro proceso.\nIntenta cerrar otras sesiones de R o desconectar la base usando censo_desconectar_base() en las demas sesiones.",
        call. = FALSE
      )
    } else {
      stop(e)
    }
  },
  finally = NULL
  )
  
  assign("censo_bbdd", db, envir = censo_cache)
  db
}


#' Tablas Completas de la Base de Datos del Censo
#'
#' Devuelve una tabla completa de la base de datos. Para entregar datos
#' filtrados previamente se debe usar [censo2017::censo_bbdd()]. Esta funcion puede
#' ser especialmente util para obtener los mapas y usarlos directamente con
#' tm o ggplot2, sin necesidad de transformar las columnas de geometrias.
#'
#' @param tabla Una cadena de texto indicando la tabla a extraer
#' @return Un tibble
#' @export
#'
#' @examples
#' if (censo_estado()) {
#'   censo_tabla("comunas")
#' }
censo_tabla <- function(tabla) {
  if (any(tabla %in% grep("mapa_", censo_tables(), value = T))) {
    df <- sf::st_read(censo_bbdd(), tabla)
  } else {
    df <- tibble::as_tibble(DBI::dbReadTable(censo_bbdd(), tabla)) 
  }
  return(df)
}


#' Desconecta la Base de Datos del Censo
#'
#' Una funcion auxiliar para desconectarse de la base de datos.
#'
#' @examples
#' censo_desconectar_base()
#' @export
#'
censo_desconectar_base <- function() {
  censo_db_disconnect_()
}

censo_db_disconnect_ <- function(environment = censo_cache) {
  db <- mget("censo_bbdd", envir = censo_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    DBI::dbDisconnect(db)
  }
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionClosed("Censo2017", "censo2017")
  }
}


#' Obtiene el Estado de la Base de Datos Local del Censo
#'
#' Entrega el estado de la base de datos local. Muestra un mensaje informativo
#' respecto de como obtener la base si esta no se encuentra o esta daniada.
#'
#' @param msg Mostrar o no mensajes de estado. Por defecto es TRUE.
#' 
#' @return TRUE si la base de datos existe y contiene las tablas esperadas, FALSE 
#' en caso contrario (invisible).
#' @export
#' @examples
#' censo_estado()
censo_estado <- function(msg = TRUE) {
  expected_tables <- sort(censo_tables())
  existing_tables <- sort(DBI::dbListTables(censo_bbdd()))
  
  if (isTRUE(all.equal(expected_tables, existing_tables))) {
    status_msg <- crayon::green(paste(cli::symbol$tick, "La base de datos local del Censo 2017 esta OK."))
    out <- TRUE
  } else {
    status_msg <- crayon::red(paste(cli::symbol$cross, "La base de datos local del Censo 2017 esta vacia o daniada. Descargala con censo_descargar_base()."))
    out <- FALSE
  }
  if (msg) msg(cli::rule(status_msg))
  invisible(out)
}

censo_tables <- function() {
  c("comunas", "hogares", "mapa_comunas", "mapa_provincias",
    "mapa_regiones", "mapa_zonas", "personas", "provincias",
    "regiones", "viviendas", "zonas")
}

censo_cache <- new.env()
reg.finalizer(censo_cache, censo_db_disconnect_, onexit = TRUE)

