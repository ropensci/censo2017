context("Tables")

olddir <- Sys.getenv("CENSO_BBDD_DIR")
Sys.setenv(CENSO_BBDD_DIR = normalizePath(file.path(getwd(), "censo2017"),
                                          mustWork = FALSE
))

test_that("censo_datos returns tbl_df", {
  skip_on_cran()
  skip_if_not(censo_estado())
  
  expect_is(censo_bbdd(), "SQLiteConnection")
  
  for (t in c("comunas", "regiones")) {
    expect_is(censo_tabla(t), "tbl_df")
  }
})

test_that("censo_datos returns tbl_lazy", {
  skip_on_cran()
  skip_if_not(censo_estado())
  
  expect_is(censo_bbdd(), "SQLiteConnection")
  
  for (t in c("comunas", "regiones")) {
    expect_is(dplyr::tbl(censo_bbdd(), t), "tbl_lazy")
  }
})

Sys.setenv(CENSO_BBDD_DIR = olddir)
