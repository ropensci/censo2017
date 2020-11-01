# save data as TSV ----

con2 <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
tablas <- dbListTables(con2)

for (t in tablas) {
  d <- dbReadTable(con2, t)
  f <- paste0("data-raw/", t, ".tsv")
  if (!file.exists(f)) data.table::fwrite(d, f, sep = "\t")
  rm(d)
}

dbDisconnect(con2)

# create duckdb file for testing ----

con3 <- dbConnect(duckdb(), "data-raw/censo2017.duckdb")

dbSendQuery(con3, "DROP TABLE IF EXISTS comunas")

dbSendQuery(
  con3,
  "CREATE TABLE comunas (
	comuna_ref_id float8 NULL,
	provincia_ref_id float8 NULL,
	idcomuna text NULL,
	redcoden char(5) NOT NULL,
	nom_comuna text NULL,
	CONSTRAINT comunas_pk PRIMARY KEY (redcoden),
	CONSTRAINT comunas_un UNIQUE (comuna_ref_id))"
)

dbExecute(
  con3,
  "COPY comunas 
  FROM 'data-raw/comunas.tsv'
  (DELIMITER '\t', HEADER 1, NULL 'NA')"
)

dbSendQuery(con3, "DROP TABLE IF EXISTS hogares")

dbSendQuery(
  con3,
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

dbExecute(
  con3,
  "COPY hogares
  FROM 'data-raw/hogares.tsv'
  (DELIMITER '\t', HEADER 1, NULL 'NA')"
)

dbSendQuery(con3, "DROP TABLE IF EXISTS mapa_comunas")

dbSendQuery(
  con3,
  "CREATE TABLE mapa_comunas (
	geometry text NULL,
	region char(2) NULL,
	provincia char(3) NULL,
	comuna char(5) NOT NULL,
	CONSTRAINT mapa_comunas_pk PRIMARY KEY (comuna))"
)

dbExecute(
  con3,
  "COPY mapa_comunas
  FROM 'data-raw/mapa_comunas.tsv'
  (DELIMITER '\t', HEADER 1, NULL 'NA')"
)

# Error in duckdb_execute(res) : duckdb_execute_R: Failed to run query
# Error: Parser: Maximum line size of 1048576 bytes exceeded!

dbDisconnect(con3, shutdown = T)
