## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  cache = FALSE,
  collapse = TRUE,
  eval = TRUE,
  comment = "#>"
)

## ---- warning=FALSE, message=FALSE--------------------------------------------
library(censo2017)
library(dplyr)
library(ggplot2)
library(sf)

## ---- warning=FALSE, message=FALSE, eval=FALSE--------------------------------
#  nivel_educacional_biobio <- tbl(censo_bbdd(), "zonas") %>%
#    mutate(
#      region = substr(as.character(geocodigo), 0, 2),
#      comuna = substr(as.character(geocodigo), 1, 5)
#    ) %>%
#    filter(region == "08") %>%
#    select(comuna, geocodigo, zonaloc_ref_id) %>%
#  
#    inner_join(select(tbl(censo_bbdd(), "viviendas"), zonaloc_ref_id, vivienda_ref_id), by = "zonaloc_ref_id") %>%
#    inner_join(select(tbl(censo_bbdd(), "hogares"), vivienda_ref_id, hogar_ref_id), by = "vivienda_ref_id") %>%
#    inner_join(select(tbl(censo_bbdd(), "personas"), hogar_ref_id, nivel_educ = p15), by = "hogar_ref_id") %>%
#    collect()

## ---- warning=FALSE, message=FALSE, eval=FALSE--------------------------------
#  nivel_educacional_biobio <- nivel_educacional_biobio %>%
#    group_by(comuna, nivel_educ) %>%
#    summarise(cuenta = n()) %>%
#    group_by(comuna) %>%
#    mutate(proporcion = cuenta / sum(cuenta))

## -----------------------------------------------------------------------------
nivel_educacional_biobio

## ---- warning=FALSE, message=FALSE--------------------------------------------
mapa_biobio <- censo_tabla("mapa_comunas") %>%
  filter(region == "08") %>% 
  left_join(nivel_educacional_biobio, by = "comuna")

## ---- warning=FALSE, message=FALSE--------------------------------------------
censo_desconectar_base()

## ---- fig.width=10, warning=FALSE, message=FALSE------------------------------
colors <- c("#DCA761","#C6C16D","#8B9C94","#628CA5","#5A6C7A")

g <- ggplot() +
  geom_sf(data = mapa_biobio %>% 
            select(comuna, geometry) %>% 
            left_join(
              mapa_biobio %>% 
                st_drop_geometry() %>% 
                select(comuna, nivel_educ, proporcion) %>% 
                filter(nivel_educ == 14),
              by = "comuna"
            ),
          aes(fill = proporcion, geometry = geometry),
          size = 0.1) +
  scale_fill_gradientn(colours = rev(colors), name = "Porcentaje") +
  labs(title = "Porcentaje de habitantes con el grado de doctor\npor comuna en la Region del Bio Bio") +
  theme_minimal(base_size = 13)

g

