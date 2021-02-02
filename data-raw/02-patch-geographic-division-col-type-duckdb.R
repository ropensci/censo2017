library(duckdb)
library(DBI)
library(dplyr)
library(stringr)

con <- dbConnect(duckdb(), "/home/pacha/.local/share/R/censo2017/duckdb-0.2.3/censo2017.duckdb")

mapa_zonas <- dbReadTable(con, "mapa_zonas") %>% as_tibble()

mapa_zonas <- mapa_zonas %>% 
  mutate(
    region = stringr::str_pad(region, 2, "left", "0"),
    provincia = stringr::str_pad(provincia, 3, "left", "0"),
    comuna = stringr::str_pad(comuna, 5, "left", "0")
  )

dbSendQuery(con, "DROP TABLE mapa_zonas")

dbSendQuery(
  con,
  "CREATE TABLE mapa_zonas (
	geometry VARCHAR NULL,
	region VARCHAR(2) NULL,
	provincia VARCHAR(3) NULL,
	comuna VARCHAR(5) NULL,
	geocodigo VARCHAR(11) NOT NULL)"
)

dbWriteTable(con, "mapa_zonas", mapa_zonas, append = T, temporary = F)

dbSendQuery(con, "CREATE INDEX mapa_zonas_geocodigo ON mapa_zonas (geocodigo)")

dbDisconnect(con, shutdown = TRUE)
