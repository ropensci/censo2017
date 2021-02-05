#' Descarga la Base de Datos del Censo a tu Computador
#'
#' Este comando descarga la base de datos completa como un unico archivo zip que
#' se descomprime para crear la base de datos local. La descarga es 
#' 570 MB y la base de datos usa 8 GB en disco. Si no quieres descargar la base 
#' de datos en tu home, ejecuta usethis::edit_r_environ() para crear la variable
#' de entorno CENSO_BBDD_DIR con la ruta.
#'
#' @param ver La version a descargar. Por defecto es la ultima version 
#' disponible en GitHub. Se pueden ver todas las versiones en
#' <https://github.com/pachamaltese/censo2017/releases>.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \donttest{
#' \dontrun{
#' censo_descargar_base()
#' }
#' }
censo_descargar_base <- function(ver = NULL) {
  msg("Descargando la base de datos desde GitHub...")
  
  destdir <- tempdir()
  dir <- censo_path()
  
  suppressWarnings(try(dir.create(dir, recursive = TRUE)))
  
  zfile <- get_gh_release_file("pachamaltese/censo2017",
                               tag_name = ver,
                               dir = destdir
  )
  ver <- attr(zfile, "ver")
  
  msg("Descomprimiendo la base de datos local...")
  
  suppressWarnings(try(censo_desconectar_base()))
  try(censo_borrar_base())
  
  utils::unzip(zfile, overwrite = TRUE, exdir = destdir)
  
  finp_tsv <- list.files(destdir, full.names = TRUE, pattern = "tsv")
  finp_shp <- list.files(destdir, full.names = TRUE, pattern = "shp")
  
  invisible(create_schema())
  
  for (x in seq_along(finp_tsv)) {
    tout <- gsub(".*/", "", gsub("\\.tsv", "", finp_tsv[x]))
    
    msg(sprintf("Creando tabla %s ...", tout))
    
    con <- censo_bbdd()
    
    suppressMessages(
      DBI::dbExecute(
        con,
        paste0(
          "COPY ", tout, " FROM '",
          finp_tsv[x],
          "' ( DELIMITER '\t', HEADER 1, NULL 'NA' )"
        )
      )
    )
    
    DBI::dbDisconnect(con, shutdown = TRUE)
    invisible(gc())
  }
  
  for (x in seq_along(finp_shp)) {
    tout <- gsub(".*/", "", gsub("\\.shp", "", finp_shp[x]))

    msg(sprintf("Creando tabla %s ...", tout))

    con <- censo_bbdd()

    d <- sf::st_read(finp_shp[x], quiet = TRUE)
    suppressMessages(DBI::dbWriteTable(con, tout, d, append = T, temporary = F))

    DBI::dbDisconnect(con, shutdown = TRUE)
    rm(d)
    invisible(gc())
  }
  
  metadatos <- data.frame(version_duckdb = utils::packageVersion("duckdb"),
                          fecha_modificacion = Sys.time())
  metadatos$version_duckdb <- as.character(metadatos$version_duckdb)
  metadatos$fecha_modificacion <- as.character(metadatos$fecha_modificacion)
  
  con <- censo_bbdd()
  suppressMessages(DBI::dbWriteTable(con, "metadatos", metadatos, append = F, temporary = F))
  DBI::dbDisconnect(con, shutdown = TRUE)
  
  unlink(destdir, recursive = TRUE)
  
  invisible(DBI::dbListTables(censo_bbdd()))
  censo_desconectar_base()
  
  update_censo_pane()
  censo_panel()
  censo_estado()
}
