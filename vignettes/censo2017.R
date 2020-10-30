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

nivel_educacional <- tbl(censo_bbdd(), "zonas") %>% 
    mutate(provincia = substr(as.character(geocodigo), 1, 3)) %>% 
    filter(provincia == "131") %>% 
    select(geocodigo, zonaloc_ref_id) %>%
  
    inner_join(select(tbl(censo_bbdd(), "viviendas"), zonaloc_ref_id, vivienda_ref_id), by = "zonaloc_ref_id") %>%
    inner_join(select(tbl(censo_bbdd(), "hogares"), vivienda_ref_id, hogar_ref_id), by = "vivienda_ref_id") %>%
    inner_join(select(tbl(censo_bbdd(), "personas"), hogar_ref_id, nivel_educ = p15), by = "hogar_ref_id") %>%
    collect() %>% 
    
    group_by(geocodigo, nivel_educ) %>%
    summarise(cuenta = n()) %>%
    group_by(geocodigo) %>%
    mutate(proporcion = cuenta / sum(cuenta))
    
nivel_educacional

## ---- warning=FALSE, message=FALSE--------------------------------------------
mapa_santiago <- censo_tabla("mapa_zonas") %>%
  filter(provincia == 131) %>% 
  left_join(nivel_educacional, by = "geocodigo")

## ---- fig.width=10, warning=FALSE, message=FALSE------------------------------
colors <- c("#DCA761","#C6C16D","#8B9C94","#628CA5","#5A6C7A")

g <- ggplot() +
  geom_sf(data = mapa_santiago %>% 
            select(geocodigo, geometry) %>% 
            left_join(
              mapa_santiago %>% 
                st_drop_geometry() %>% 
                select(geocodigo, nivel_educ, proporcion) %>% 
                filter(nivel_educ == 14),
              by = "geocodigo"
            ),
          aes(fill = proporcion, geometry = geometry),
          size = 0.1) +
  scale_fill_gradientn(colours = rev(colors), name = "Porcentaje") +
  labs(title = "Habitantes con el grado de doctor\npor zona censal en la Provincia de Santiago") +
  theme_minimal(base_size = 13)

g

## -----------------------------------------------------------------------------
censo_desconectar_base()

