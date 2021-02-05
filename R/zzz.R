.onAttach <- function(...) {
  msg(cli::rule(crayon::bold("CENSO 2017")))
  msg(" ")
  msg("Por favor, lee la documentacion.")
  msg("Usa el comando citation('censo2017') para citar este paquete en publicaciones.")
  msg("Visita https://buymeacoffee.com/pacha si deseas donar para contribuir al desarrollo de este software.")
  msg("Este paquete descarga un archivo comprimido de 750 MB y crea una base de datos de 3 GB.")
  msg(" ")
  if (interactive() && Sys.getenv("RSTUDIO") == "1"  && !in_chk()) {
    censo_panel()
  }
  if (interactive()) censo_estado()
}

