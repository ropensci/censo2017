.onAttach <- function(...) {
  msg(cli::rule(crayon::green("CENSO 2017")))
  msg(crayon::green(paste(cli::symbol$star,
  "Por favor, lee la documentacion.")))
  msg(crayon::green(paste(cli::symbol$star,
  "Usa el comando citation('censo2017') para citar este paquete en publicaciones.")))
  msg(crayon::green(paste(cli::symbol$star,
  "Visita https://buymeacoffee.com/pacha si deseas donar para contribuir al desarrollo de este software.")))
  msg(crayon::green(paste(cli::symbol$warning,
  "Este paquete descarga un archivo comprimido de 1 GB con una base de datos de 8GB.")))
  msg(crayon::green(paste(cli::symbol$warning,
  "Si no quieres descargar la base de datos en tu home,")))
  msg(crayon::green(paste(cli::symbol$warning,
  "ejecuta usethis::edit_r_environ() para crear la variable de entorno CENSO_BBDD_DIR con la ruta.")))
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
