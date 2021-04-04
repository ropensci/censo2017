msg <- function(..., startup = FALSE) {
  if (startup) {
    if (!isTRUE(getOption("censo2017.quiet"))) {
      packageStartupMessage(text_col(...))
    }
  } else {
    message(text_col(...))
  }
}

text_col <- function(x) {
  # If RStudio not available, messages already printed in black
  if (!rstudioapi::isAvailable()) {
    return(x)
  }

  if (!rstudioapi::hasFun("getThemeInfo")) {
    return(x)
  }

  theme <- rstudioapi::getThemeInfo()

  if (isTRUE(theme$dark)) crayon::white(x) else crayon::black(x)
}

in_chk <- function() {
  any(
    grepl("check",
          sapply(sys.calls(), function(a) paste(deparse(a), collapse = "\n"))
    )
  )
}

read_table_error <- function(e) {
  e <- as.character(e)
  # return(e)
  msg <- c(
    sprintf("No esta disponible la tabla %s.", get("tabla", envir = 1)),
    "\nVerifica que escribiste el nombre correctamente y que instalaste los",
    "\ndatos con censo_descargar_base()."
  )
  stop(msg, call. = FALSE)
}
