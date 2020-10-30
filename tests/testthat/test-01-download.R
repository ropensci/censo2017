context("Download")

olddir <- Sys.getenv("CENSO_BBDD_DIR")
Sys.setenv(CENSO_BBDD_DIR = normalizePath(file.path(getwd(), "censo2017"),
                                          mustWork = FALSE
))

test_that("Download succeeds", {
  skip_on_cran()
  censo_descargar_base()
  expect_true(censo_estado())
})

Sys.setenv(CENSO_BBDD_DIR = olddir)
