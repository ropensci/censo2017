library(DBI)
library(RPostgres)
library(RSQLite)
library(duckdb)
library(dplyr)
library(stringr)
library(sf)

# create initial schema ----

# I imported the SQL dump from databases.pacha.dev
con <- dbConnect(
  Postgres(),
  user = "student",
  password = Sys.getenv("databases_student_pwd"),
  dbname = "censo",
  host = "databases.pacha.dev"
)

tablas <- dbListTables(con)
tablas <- grep("geometry_|geography_|raster_|spatial_", tablas, value = T, invert = T)
tablas <- sort(tablas)

con2 <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")

dbSendQuery(
  con2,
  "CREATE TABLE comunas (
	comuna_ref_id float8 NULL,
	provincia_ref_id float8 NULL,
	idcomuna text NULL,
	redcoden float8 NOT NULL,
	nom_comuna text NULL,
	CONSTRAINT comunas_pk PRIMARY KEY (redcoden),
	CONSTRAINT comunas_un UNIQUE (comuna_ref_id))"
)

dbSendQuery(
  con2,
  "CREATE TABLE hogares (
	hogar_ref_id float8 NOT NULL,
	vivienda_ref_id float8 NULL,
	nhogar float8 NULL,
	tipo_hogar float8 NULL,
	ncu_yern_nuer float8 NULL,
	n_herm_cun float8 NULL,
	nuc_herm_cun float8 NULL,
	num_sueg_pad_abu float8 NULL,
	nuc_pad_sueg_abu float8 NULL,
	num_otros float8 NULL,
	nuc_otros float8 NULL,
	num_no_par float8 NULL,
	nuc_no_par float8 NULL,
	tot_nucleos float8 NULL,
	CONSTRAINT hogares_pk PRIMARY KEY (hogar_ref_id))"
)

dbSendQuery(
  con2,
  "CREATE TABLE mapa_comunas (
	geometry text NULL,
	region float8 NULL,
	provincia float8 NULL,
	comuna float8 NOT NULL,
	CONSTRAINT mapa_comunas_pk PRIMARY KEY (comuna))"
)

dbSendQuery(
  con2,
  "CREATE TABLE mapa_provincias (
	geometry text NULL,
	region float8 NULL,
	provincia float8 NOT NULL,
	CONSTRAINT mapa_provincias_pk PRIMARY KEY (provincia))"
)

dbSendQuery(
  con2,
  "CREATE TABLE mapa_regiones (
	geometry text NULL,
	region float8 NOT NULL,
	CONSTRAINT mapa_regiones_pk PRIMARY KEY (region))"
)

dbSendQuery(
  con2,
  "CREATE TABLE mapa_zonas (
	geometry text NULL,
	region float8 NULL,
	provincia float8 NULL,
	comuna float8 NULL,
	geocodigo float8 NOT NULL,
	CONSTRAINT mapa_zonas_pk PRIMARY KEY (geocodigo))"
)

dbSendQuery(
  con2,
  "CREATE TABLE personas (
	persona_ref_id float8 NULL,
	hogar_ref_id float8 NULL,
	personan int4 NULL,
	p07 int4 NULL,
	p08 int4 NULL,
	p09 int4 NULL,
	p10 int4 NULL,
	p10comuna int4 NULL,
	p10pais int4 NULL,
	p10pais_grupo int4 NULL,
	p11 int4 NULL,
	p11comuna int4 NULL,
	p11pais int4 NULL,
	p11pais_grupo int4 NULL,
	p12 int4 NULL,
	p12comuna int4 NULL,
	p12pais int4 NULL,
	p12pais_grupo int4 NULL,
	p12a_llegada int4 NULL,
	p12a_tramo int4 NULL,
	p13 int4 NULL,
	p14 int4 NULL,
	p15 int4 NULL,
	p15a int4 NULL,
	p16 int4 NULL,
	p16a int4 NULL,
	p16a_otro int4 NULL,
	p16a_grupo int4 NULL,
	p17 int4 NULL,
	p18 text NULL,
	p19 int4 NULL,
	p20 int4 NULL,
	p21m int4 NULL,
	p21a int4 NULL,
	escolaridad int4 NULL,
	rec_parentesco int4 NULL)"
)

dbSendQuery(
  con2,
  "CREATE INDEX personas_idx ON personas (hogar_ref_id)"
)

dbSendQuery(
  con2,
  "CREATE TABLE provincias (
	provincia_ref_id float8 NULL,
	region_ref_id float8 NULL,
	idprovincia float8 NULL,
	redcoden float8 NOT NULL,
	nom_provincia text NULL,
	CONSTRAINT provincias_pk PRIMARY KEY (redcoden))"
)

dbSendQuery(
  con2,
  "CREATE TABLE regiones (
	region_ref_id float8 NOT NULL,
	censo_ref_id float8 NULL,
	idregion text NULL,
	redcoden float8 NOT NULL,
	nom_region text NULL,
	CONSTRAINT regiones_pk PRIMARY KEY (redcoden))"
)

dbSendQuery(
  con2,
  "CREATE TABLE viviendas (
	vivienda_ref_id float8 NOT NULL,
	zonaloc_ref_id float8 NULL,
	nviv int4 NULL,
	p01 int4 NULL,
	p02 int4 NULL,
	p03a int4 NULL,
	p03b int4 NULL,
	p03c int4 NULL,
	p04 int4 NULL,
	p05 int4 NULL,
	cant_hog int4 NULL,
	cant_per int4 NULL,
	ind_hacin float8 NULL,
	ind_hacin_rec int4 NULL,
	ind_material int4 NULL,
	CONSTRAINT viviendas_pk PRIMARY KEY (vivienda_ref_id))"
)

dbSendQuery(
  con2,
  "CREATE TABLE zonas (
	zonaloc_ref_id float8 NOT NULL,
	geocodigo float8 NULL,
	observacion text NULL,
	CONSTRAINT zonas_pk PRIMARY KEY (zonaloc_ref_id),
	CONSTRAINT zonas_un UNIQUE (geocodigo))"
)

dbDisconnect(con2)

for (i in seq_along(tablas)) {
  t <- tablas[i]
  message(t)
  
  d <- tbl(con, t) %>% collect()
  
  con2 <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
  
  dbWriteTable(
    con2,
    t,
    d,
    temporary = FALSE,
    overwrite = FALSE,
    append = TRUE
  )
  
  dbDisconnect(con2)
  
  rm(d)
  gc()
}

# fix varying geo codes ----

con2 <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")

zonas <- dbReadTable(con2, "zonas")

zonas <- zonas %>% 
  mutate(
    geocodigo = str_pad(geocodigo, 11, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE zonas")

dbSendQuery(
  con2,
  "CREATE TABLE zonas (
	zonaloc_ref_id float8 NOT NULL,
	geocodigo char(11) NULL,
	observacion text NULL,
	CONSTRAINT zonas_pk PRIMARY KEY (zonaloc_ref_id),
	CONSTRAINT zonas_un UNIQUE (geocodigo))"
)

dbWriteTable(
  con2,
  "zonas",
  zonas,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

mapa_zonas <- dbReadTable(con2, "mapa_zonas")

mapa_zonas <- mapa_zonas %>% 
  mutate(
    region = str_pad(region, 2, "left", "0"),
    provincia = str_pad(provincia, 3, "left", "0"),
    comuna = str_pad(comuna, 5, "left", "0"),
    geocodigo = str_pad(geocodigo, 11, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE mapa_zonas")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_zonas (
	geometry text NULL,
	region char(2) NULL,
	provincia char(3) NULL,
	comuna char(5) NULL,
	geocodigo char(11) NOT NULL,
	CONSTRAINT mapa_zonas_pk PRIMARY KEY (geocodigo))"
)

dbWriteTable(
  con2,
  "mapa_zonas",
  mapa_zonas,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

comunas <- dbReadTable(con2, "comunas")

comunas <- comunas %>% 
  mutate(
    redcoden = stringr::str_pad(redcoden, 5, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE comunas")

dbSendQuery(
  con2,
  "CREATE TABLE comunas (
	comuna_ref_id float8 NULL,
	provincia_ref_id float8 NULL,
	idcomuna text NULL,
	redcoden char(5) NOT NULL,
	nom_comuna text NULL,
	CONSTRAINT comunas_pk PRIMARY KEY (redcoden),
	CONSTRAINT comunas_un UNIQUE (comuna_ref_id))"
)

dbWriteTable(
  con2,
  "comunas",
  comunas,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

mapa_comunas <- dbReadTable(con2, "mapa_comunas")

mapa_comunas <- mapa_comunas %>% 
  mutate(
    region = stringr::str_pad(region, 2, "left", "0"),
    provincia = stringr::str_pad(provincia, 3, "left", "0"),
    comuna = stringr::str_pad(comuna, 5, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE mapa_comunas")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_comunas (
	geometry text NULL,
	region char(2) NULL,
	provincia char(3) NULL,
	comuna char(5) NOT NULL,
	CONSTRAINT mapa_comunas_pk PRIMARY KEY (comuna))"
)

dbWriteTable(
  con2,
  "mapa_comunas",
  mapa_comunas,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

provincias <- dbReadTable(con2, "provincias")

provincias <- provincias %>% 
  mutate(
    redcoden = stringr::str_pad(redcoden, 3, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE provincias")

dbSendQuery(
  con2,
  "CREATE TABLE provincias (
	provincia_ref_id float8 NULL,
	region_ref_id float8 NULL,
	idprovincia float8 NULL,
	redcoden char(3) NOT NULL,
	nom_provincia text NULL,
	CONSTRAINT provincias_pk PRIMARY KEY (redcoden))"
)

dbWriteTable(
  con2,
  "provincias",
  provincias,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

mapa_provincias <- dbReadTable(con2, "mapa_provincias")

mapa_provincias <- mapa_provincias %>% 
  mutate(
    region = stringr::str_pad(region, 2, "left", "0"),
    provincia = stringr::str_pad(provincia, 3, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE mapa_provincias")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_provincias (
	geometry text NULL,
	region char(2) NULL,
	provincia char(3) NOT NULL,
	CONSTRAINT mapa_provincias_pk PRIMARY KEY (provincia))"
)

dbWriteTable(
  con2,
  "mapa_provincias",
  mapa_provincias,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

regiones <- dbReadTable(con2, "regiones")

regiones <- regiones %>% 
  mutate(
    redcoden = stringr::str_pad(redcoden, 2, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE regiones")

dbSendQuery(
  con2,
  "CREATE TABLE regiones (
	region_ref_id float8 NOT NULL,
	censo_ref_id float8 NULL,
	idregion text NULL,
	redcoden char(2) NOT NULL,
	nom_region text NULL,
	CONSTRAINT regiones_pk PRIMARY KEY (redcoden))"
)

dbWriteTable(
  con2,
  "regiones",
  regiones,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

mapa_regiones <- dbReadTable(con2, "mapa_regiones")

mapa_regiones <- mapa_regiones %>% 
  mutate(
    region = stringr::str_pad(region, 2, "left", "0")
  )

dbSendQuery(con2, "DROP TABLE mapa_regiones")

dbSendQuery(
  con2,
  "CREATE TABLE mapa_regiones (
	geometry text NULL,
	region char(2) NOT NULL,
	CONSTRAINT mapa_regiones_pk PRIMARY KEY (region))"
)

dbWriteTable(
  con2,
  "mapa_regiones",
  mapa_regiones,
  temporary = FALSE,
  row.names = FALSE,
  overwrite = F,
  append = T
)

dbDisconnect(con2)
