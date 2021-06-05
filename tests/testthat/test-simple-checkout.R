context("Download")

olddir <- Sys.getenv("CENSO_BBDD_DIR")
Sys.setenv(CENSO_BBDD_DIR = tempdir())

test_that("censo_tabla returns tbl_df", {
  skip_on_cran()
  censo_descargar()
  expect_is(censo_conectar(), "duckdb_connection")
  for (t in c("comunas", "regiones")) {
    expect_is(censo_tabla(t), "tbl_df")
  }
})

test_that("censo_conectar returns tbl_lazy", {
  skip_on_cran()
  expect_is(censo_conectar(), "duckdb_connection")
  if (require("dplyr") & require("dbplyr")) {
    for (t in c("comunas", "regiones")) {
      expect_is(dplyr::tbl(censo_conectar(), t), "tbl_lazy")
    }
  }
})

test_that("database is deleted", {
  skip_on_cran()
  censo_desconectar()
  censo_eliminar()
  expect_false(file.exists(censo_path()))
})

Sys.setenv(CENSO_BBDD_DIR = olddir)
