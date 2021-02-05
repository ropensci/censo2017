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
#' @param destdir La carpeta donde se va a descargar y descomprimir el archivo
#' zip para crear la base de datos. Por defecto es una carpeta temporal.
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
censo_descargar_base <- function(ver = NULL, destdir = tempdir()) {
  msg("Descargando la base de datos desde GitHub...")
  
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


#' @importFrom httr GET stop_for_status content accept write_disk progress
#' @importFrom purrr keep
get_gh_release_file <- function(repo, tag_name = NULL, dir = tempdir(),
                                overwrite = TRUE) {
  releases <- GET(
    paste0("https://api.github.com/repos/", repo, "/releases")
  )
  stop_for_status(releases, "buscando versiones")
  
  releases <- content(releases)
  
  if (is.null(tag_name)) {
    release_obj <- releases[1]
  } else {
    release_obj <- purrr::keep(releases, function(x) x$tag_name == tag_name)
  }
  
  if (!length(release_obj)) stop("No se encuenta una version disponible \"",
                                 tag_name, "\"")
  
  if (release_obj[[1]]$prerelease) {
    msg("Estos datos aun no se han validado.")
  }
  
  download_url <- release_obj[[1]]$assets[[1]]$url
  filename <- basename(release_obj[[1]]$assets[[1]]$browser_download_url)
  out_path <- normalizePath(file.path(dir, filename), mustWork = FALSE)
  response <- GET(
    download_url,
    accept("application/octet-stream"),
    write_disk(path = out_path, overwrite = overwrite),
    progress()
  )
  stop_for_status(response, "downloading data")
  
  attr(out_path, "ver") <- release_obj[[1]]$tag_name
  return(out_path)
}
