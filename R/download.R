#' Descarga la Base de Datos del Censo a tu Computador
#'
#' Este comando descarga la base de datos completa como un unico archivo bz2 que
#' se descomprime para dejar disponible la base de datos local. La descarga son 
#' 750 MB y la base de datos usa 3 GB en disco. Nota: se usa bz2 para evitar el
#' truncamiento al descomprimir zip en algunos sistemas operativos.
#'
#' @param ver La version a descargar. Por defecto es la ultima version 
#' disponible en GitHub. Se pueden ver todas las versiones en
#' <https://github.com/pachamaltese/censo2017/releases>.
#' @param borrar Borrar o no el archivo zip luego de cargar la base de datos.
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
censo_descargar_base <- function(ver = NULL, borrar = TRUE) {
  msg("Descargando la base de datos desde GitHub...")
  
  dir <- censo_path()
  try(dir.create(dir))
  
  zfile <- get_gh_release_file("pachamaltese/censo2017",
                               tag_name = ver,
                               dir = dir
  )
  ver <- attr(zfile, "ver")
  
  msg("Descomprimiendo la base de datos local...")
  
  dfile <- gsub(".bz2", "", zfile)
  if (file.exists(dfile)) censo_borrar_base()
  suppressWarnings(try(censo_desconectar_base()))
  R.utils::gunzip(zfile, dfile, overwrite = TRUE, remove = borrar)
  
  suppressWarnings(censo_desconectar_base())
  invisible(DBI::dbListTables(censo_bbdd()))
  
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
  try(
    file.remove(paste0(censo_path(), "/censo2017.sqlite"), 
                recursive = TRUE)
  )
  update_censo_pane()
  censo_panel()
}
