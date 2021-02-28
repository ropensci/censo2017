# packages ----

library(dplyr)
library(DBI)
library(duckdb)
library(RSQLite)

# connections ----

con <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
tablas <- dbListTables(con)

con2 <- dbConnect(duckdb(), "data-raw/censo2017.duckdb")

# comunas ----

dbSendQuery(con2, "DROP TABLE IF EXISTS comunas")

dbSendQuery(
  con2,
  "CREATE TABLE comunas (
	comuna_ref_id INTEGER NOT NULL,
	provincia_ref_id INTEGER NULL,
	idcomuna VARCHAR NULL,
	redcoden VARCHAR(5) NOT NULL,
	nom_comuna VARCHAR NULL)"
)

# hogares ----

dbSendQuery(con2, "DROP TABLE IF EXISTS hogares")

dbSendQuery(
  con2,
  "CREATE TABLE hogares (
	hogar_ref_id INTEGER NOT NULL,
	vivienda_ref_id INTEGER NULL,
	nhogar INTEGER NULL,
	tipo_hogar INTEGER NULL,
	ncu_yern_nuer INTEGER NULL,
	n_herm_cun INTEGER NULL,
	nuc_herm_cun INTEGER NULL,
	num_sueg_pad_abu INTEGER NULL,
	nuc_pad_sueg_abu INTEGER NULL,
	num_otros INTEGER NULL,
	nuc_otros INTEGER NULL,
	num_no_par INTEGER NULL,
	nuc_no_par INTEGER NULL,
	tot_nucleos INTEGER NULL)"
)

# mapa comunas ----

dbSendQuery(con2, "DROP TABLE IF EXISTS mapa_comunas")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_comunas (
	geometry VARCHAR NULL,
	region VARCHAR(2) NULL,
	provincia VARCHAR(3) NULL,
	comuna VARCHAR(5) NOT NULL)"
)

# mapa provincias ----

dbSendQuery(con2, "DROP TABLE IF EXISTS mapa_provincias")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_provincias (
	geometry VARCHAR NULL,
	region VARCHAR(2) NULL,
	provincia VARCHAR(3) NOT NULL)"
)

# mapa regiones ----

dbSendQuery(con2, "DROP TABLE IF EXISTS mapa_regiones")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_regiones (
	geometry VARCHAR NULL,
	region VARCHAR(2) NOT NULL);"
)

# mapa zonas ----
dbSendQuery(con2, "DROP TABLE IF EXISTS mapa_zonas")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_zonas (
	geometry VARCHAR NULL,
	region VARCHAR(2) NULL,
	provincia VARCHAR(3) NULL,
	comuna VARCHAR(5) NULL,
	geocodigo VARCHAR(11) NOT NULL)"
)

# personas ----

dbSendQuery(con2, "DROP TABLE IF EXISTS personas")

dbSendQuery(
  con2,
  "CREATE TABLE personas (
	persona_ref_id INTEGER NULL,
	hogar_ref_id INTEGER NULL,
	personan INTEGER NULL,
	p07 INTEGER NULL,
	p08 INTEGER NULL,
	p09 INTEGER NULL,
	p10 INTEGER NULL,
	p10comuna INTEGER NULL,
	p10pais INTEGER NULL,
	p10pais_grupo INTEGER NULL,
	p11 INTEGER NULL,
	p11comuna INTEGER NULL,
	p11pais INTEGER NULL,
	p11pais_grupo INTEGER NULL,
	p12 INTEGER NULL,
	p12comuna INTEGER NULL,
	p12pais INTEGER NULL,
	p12pais_grupo INTEGER NULL,
	p12a_llegada INTEGER NULL,
	p12a_tramo INTEGER NULL,
	p13 INTEGER NULL,
	p14 INTEGER NULL,
	p15 INTEGER NULL,
	p15a INTEGER NULL,
	p16 INTEGER NULL,
	p16a INTEGER NULL,
	p16a_otro INTEGER NULL,
	p16a_grupo INTEGER NULL,
	p17 INTEGER NULL,
	p18 VARCHAR NULL,
	p19 INTEGER NULL,
	p20 INTEGER NULL,
	p21m INTEGER NULL,
	p21a INTEGER NULL,
	escolaridad INTEGER NULL,
	rec_parentesco INTEGER NULL)"
)

# provincias ----

dbSendQuery(con2, "DROP TABLE IF EXISTS provincias")

dbSendQuery(
  con2,
  "CREATE TABLE provincias (
	provincia_ref_id INTEGER NULL,
	region_ref_id INTEGER NULL,
	idprovincia INTEGER NULL,
	redcoden VARCHAR(3) NOT NULL,
	nom_provincia VARCHAR NULL)"
)

# regiones ----

dbSendQuery(con2, "DROP TABLE IF EXISTS regiones")

dbSendQuery(
  con2,
  "CREATE TABLE regiones (
	region_ref_id INTEGER NOT NULL,
	censo_ref_id INTEGER NULL,
	idregion VARCHAR NULL,
	redcoden VARCHAR(2) NOT NULL,
	nom_region VARCHAR NULL)"
)

# viviendas ----

dbSendQuery(con2, "DROP TABLE IF EXISTS viviendas")

dbSendQuery(
  con2,
  "CREATE TABLE viviendas (
	vivienda_ref_id INTEGER NOT NULL,
	zonaloc_ref_id INTEGER NULL,
	nviv INTEGER NULL,
	p01 INTEGER NULL,
	p02 INTEGER NULL,
	p03a INTEGER NULL,
	p03b INTEGER NULL,
	p03c INTEGER NULL,
	p04 INTEGER NULL,
	p05 INTEGER NULL,
	cant_hog INTEGER NULL,
	cant_per INTEGER NULL,
	ind_hacin DOUBLE NULL,
	ind_hacin_rec INTEGER NULL,
	ind_material INTEGER NULL)"
)

# zonas ----

dbSendQuery(con2, "DROP TABLE IF EXISTS zonas")

dbSendQuery(
  con2,
  "CREATE TABLE zonas (
	zonaloc_ref_id INTEGER NOT NULL,
	geocodigo VARCHAR NOT NULL,
	observacion VARCHAR NULL)"
)

# disconnect ----

duckdb::dbDisconnect(con2, shutdown = T)
gc()

# metadata ----

metadatos <- data.frame(version_duckdb = utils::packageVersion("duckdb"),
                        fecha_modificacion = Sys.time())
metadatos$version_duckdb <- as.character(metadatos$version_duckdb)
metadatos$fecha_modificacion <- as.character(metadatos$fecha_modificacion)

# connect, copy table, disconnect and repeat ----

for (t in c(tablas)) {
  message(t)
  d <- dbReadTable(con, t)
  
  con2 <- dbConnect(duckdb(), "data-raw/censo2017.duckdb")
  dbWriteTable(con2, t, d, append = T, temporary = F)
  dbDisconnect(con2, shutdown = T)
  
  gc()
  rm(d)
}

gc()
dbDisconnect(con)

con2 <- dbConnect(duckdb(), "data-raw/censo2017.duckdb")
copy_to(con2, metadatos, "metadatos", temporary = F)
dbDisconnect(con2, shutdown = T)

# create indexes ----

con2 <- dbConnect(duckdb(), "data-raw/censo2017.duckdb")

dbSendQuery(con2, "CREATE UNIQUE INDEX comunas_redcoden ON comunas (redcoden)")
dbSendQuery(con2, "CREATE UNIQUE INDEX provincias_redcoden ON provincias (redcoden)")
dbSendQuery(con2, "CREATE UNIQUE INDEX regiones_redcoden ON regiones (redcoden)")

dbSendQuery(con2, "CREATE UNIQUE INDEX hogares_hogar_ref_id ON hogares (hogar_ref_id)")
dbSendQuery(con2, "CREATE UNIQUE INDEX viviendas_vivienda_ref_id ON viviendas (vivienda_ref_id)")

dbSendQuery(con2, "CREATE UNIQUE INDEX zonas_zonaloc_ref_id ON zonas (zonaloc_ref_id)")
dbSendQuery(con2, "CREATE UNIQUE INDEX zonas_geocodigo ON zonas (geocodigo)")

dbSendQuery(con2, "CREATE INDEX mapa_comunas_comuna ON mapa_comunas (comuna)")
dbSendQuery(con2, "CREATE INDEX mapa_provincias_provincia ON mapa_provincias (provincia)")
dbSendQuery(con2, "CREATE INDEX mapa_regiones_region ON mapa_regiones (region)")
dbSendQuery(con2, "CREATE INDEX mapa_zonas_geocodigo ON mapa_zonas (geocodigo)")

dbDisconnect(con2, shutdown = T)

# test ----

for (t in tablas) {
  message(t)
  
  con <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
  d <- dbReadTable(con, t)
  d <- c(nrow(d), ncol(d))
  dbDisconnect(con)
  
  con2 <- dbConnect(duckdb(), "data-raw/censo2017.duckdb")
  d2 <- dbReadTable(con2, t)
  d2 <- c(nrow(d2), ncol(d2))
  dbDisconnect(con2, shutdown = T)
  stopifnot(d[1] == d2[1])
  stopifnot(d[2] == d2[2])
  
  message(paste(paste0("r", d[1], " c", d[2]), "vs", paste0("r", d2[1], " c", d2[2])))
}
