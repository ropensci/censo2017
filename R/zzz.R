.onAttach <- function(...) {
  msg(cli::rule(crayon::white("CENSO 2017")))
  msg(crayon::yellow(paste(cli::symbol$star,
  "Por favor, lee la documentación. Este paquete descarga una base de datos de 3GB.")))
  msg(crayon::yellow(paste(cli::symbol$star,
  "Si usas este paquete en tus artículos, no olvides citarlo.")))
  msg(crayon::yellow(paste(cli::symbol$star,
  "El comando citation('censo2017') genera una entrada bibtex con todos los detalles.")))
  msg(crayon::yellow(paste(cli::symbol$star,
  "Puedes aportar al desarrollo de este paquete en https://buymeacoffee.com/pacha.")))
  msg(crayon::cyan(paste(cli::symbol$warning,
  "IMPORTANTE: Si no quieres descargar la base de datos en tu home, crea la variable de entorno CENSO_BBDD_DIR con la ruta.")))
  if (interactive() && Sys.getenv("RSTUDIO") == "1"  && !in_chk()) {
    censo_panel()
  }
  if (interactive()) censo_estado()
}

in_chk <- function() {
  any(
    grepl("check",
          sapply(sys.calls(), function(a) paste(deparse(a), collapse = "\n"))
    )
  )
}
