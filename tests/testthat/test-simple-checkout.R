context("Download")

olddir <- Sys.getenv("CENSO2017_DIR")
Sys.setenv(CENSO2017_DIR = tempdir())

test_that("censo_tabla returns tbl_df", {
  skip_on_cran()
  
  censo_descargar()
  
  expect_is(censo_conectar(), "duckdb_connection")
  
  for (t in c("comunas", "regiones")) {
    expect_is(censo_tabla(t), "tbl_df")
  }
  
  if (require("dplyr") & require("dbplyr")) {
    for (t in c("comunas", "regiones")) {
      expect_is(dplyr::tbl(censo_conectar(), t), "tbl_lazy")
    }
  }

  censo_desconectar()
  
  censo_eliminar(preguntar = FALSE)
  
  expect_false(file.exists(censo_path()))
})

Sys.setenv(CENSO2017_DIR = olddir)
