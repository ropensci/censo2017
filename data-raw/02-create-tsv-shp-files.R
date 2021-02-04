# packages ----

library(dplyr)
library(stringr)
library(DBI)
library(RSQLite)
library(data.table)
library(sf)
library(geojsonio)
library(xml2)

# connections ----

con <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
tablas <- dbListTables(con)
tablas_no_mapas <- grep("mapa", tablas, value = T, invert = T)
tablas_mapas <- grep("mapa", tablas, value = T, invert = F)
dbDisconnect(con)

# export TSV ----

for (t in tablas_no_mapas) {
  message(t)
  
  con <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
  d <- dbReadTable(con, t)
  dbDisconnect(con)
  
  fwrite(d, paste0("data-raw/", t, ".tsv"), sep = "\t")
  gc()
  rm(d)
}

# export shape ----

for (t in tablas_mapas) {
  message(t)
  
  con <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
  d <- st_read(con, t)
  dbDisconnect(con)
  
  if (t == "mapa_zonas") {
    d <- d %>% 
      mutate(
        region = str_pad(region, 2, "left", "0"),
        provincia = str_pad(provincia, 3, "left", "0"),
        comuna = str_pad(comuna, 5, "left", "0")
      )
  }
  
  st_write(d, paste0("data-raw/", t, ".shp"))
  gc()
  rm(d)
}

# test ----

for (t in tablas_no_mapas) {
  message(t)
  
  con <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
  d <- dbReadTable(con, t)
  d <- c(nrow(d), ncol(d))
  dbDisconnect(con)
  
  d2 <- fread(paste0("data-raw/", t, ".tsv"))
  d2 <- c(nrow(d2), ncol(d2))

  stopifnot(d[1] == d2[1])
  stopifnot(d[2] == d2[2])
  
  message(paste(paste0("r", d[1], " c", d[2]), "vs", paste0("r", d2[1], " c", d2[2])))
}

for (t in tablas_mapas) {
  message(t)
  
  con <- dbConnect(SQLite(), "data-raw/censo2017.sqlite")
  d <- st_read(con, t)
  d <- c(nrow(d), ncol(d))
  dbDisconnect(con)
  
  d2 <- st_read(paste0("data-raw/", t, ".shp"))
  d2 <- c(nrow(d2), ncol(d2))
  
  stopifnot(d[1] == d2[1])
  stopifnot(d[2] == d2[2])
  
  message(paste(paste0("r", d[1], " c", d[2]), "vs", paste0("r", d2[1], " c", d2[2])))
}
