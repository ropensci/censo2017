.onAttach <- function(...) {
  msg(cli::rule(crayon::bold("CENSO 2017")))
  msg(" ")
  msg("La documentacion del paquete y ejemplos de uso se encuentran en https://pacha.dev/censo2017/.")
  msg("Visita https://buymeacoffee.com/pacha si deseas donar para contribuir al desarrollo de este software.")
  msg("Este paquete descarga un archivo comprimido de 310 MB y crea una base de datos de 6.5 GB.")
  msg(" ")
  if (interactive() && Sys.getenv("RSTUDIO") == "1"  && !in_chk()) {
    censo_panel()
  }
  if (interactive()) censo_estado()
}
