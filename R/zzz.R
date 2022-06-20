.onAttach <- function(...) {
  msg(cli::rule(crayon::bold("CENSO 2017")))
  msg(" ")
  msg("La documentacion del paquete y ejemplos de uso se encuentran en https://pacha.dev/censo2017/.")
  msg("Visita https://buymeacoffee.com/pacha si deseas donar para contribuir al desarrollo de este software.")
  msg("Esta libreria necesita 3.5 GB libres para la crear la base de datos localmente. Una vez creada la base, esta ocupa 1.0 GB en disco.")
  msg(" ")
  if (interactive() && Sys.getenv("RSTUDIO") == "1"  && !in_chk()) {
    censo_pane()
  }
  if (interactive()) censo_status()
}
