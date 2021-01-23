.onAttach <- function(...) {
  msg(cli::rule(crayon::white("CENSO 2017")))
  msg(crayon::yellow(paste(cli::symbol$star,
  "Por favor, lee la documentacion. Este paquete descarga un archivo comprimido de 700MB con una base de datos de 3GB.")))
  msg(crayon::yellow(paste(cli::symbol$star,
  "Usa el comando citation('censo2017') para citar este paquete en publicaciones.")))
  msg(crayon::yellow(paste(cli::symbol$star,
  "Puedes aportar al desarrollo de este paquete en https://buymeacoffee.com/pacha.")))
  msg(crayon::yellow(paste(cli::symbol$warning,
  "Si no quieres descargar la base de datos en tu home, crea la variable de entorno CENSO_BBDD_DIR con la ruta.")))
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
