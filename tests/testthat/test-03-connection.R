context("Connection")

olddir <- Sys.getenv("CENSO_BBDD_DIR")
Sys.setenv(CENSO_BBDD_DIR = normalizePath(file.path(getwd(), "censo2017"),
                                          mustWork = FALSE
))

test_that("Database is deleted", {
  skip_on_cran()
  skip_if_not(censo_estado())
  
  expect_true(censo_estado())
  censo_borrar_base()
  expect_false(file.exists(censo_path()))
  expect_false(censo_estado())
})

Sys.setenv(CENSO_BBDD_DIR = olddir)
