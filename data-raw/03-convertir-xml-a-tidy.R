library(censo2017)
library(xml2)
library(tidyverse)

d <- read_xml("data-raw/censo2017-descripcion-variables.xml")

cadena_a_titulo <- function(x) {
  x %>% 
    iconv(., to = "UTF-8") %>% 
    str_trim() %>% 
    ifelse(. == "", NA, .) %>% 
    str_to_title() %>% 
    str_replace_all(., "/A", "/a") %>% 
    str_replace_all(., " De ", " de ") %>% 
    str_replace_all(., " De\\)", " de)") %>% 
    str_replace_all(., " Del ", " del ") %>% 
    str_replace_all(., " O ", " o ") %>% 
    str_replace_all(., " Y ", " y ") %>% 
    str_replace_all(., " Por ", " por ") %>% 
    str_replace_all(., " En ", " en ") %>% 
    str_replace_all(., " U ", " u ") %>% 
    str_replace_all(., " El ", " el ") %>% 
    str_replace_all(., " La ", " la ") %>% 
    str_replace_all(., " Al ", " al ") %>% 
    str_replace_all(., "\\(Grupo", " (Grupo") %>% 
    str_replace_all(., "_recode", " recodificado/a")
}

# explorar ----

# persona <-
#   xml_attrs(xml_child(xml_child(xml_child(
#     xml_child(xml_child(xml_child(
#       xml_child(xml_child(xml_child(xml_child(
#         d, 2
#       ), 2), 3), 3), 3
#     ), 2), 3), 2
#   ), 14), 13))
# 
# hogar <-
#   xml_attrs(xml_child(xml_child(xml_child(
#     xml_child(xml_child(xml_child(
#       xml_child(xml_child(xml_child(d, 2), 2), 3), 3
#     ), 3), 2), 3
#   ), 2), 14))
# 
# vivienda <-
#   xml_attrs(xml_child(xml_child(xml_child(
#     xml_child(xml_child(xml_child(
#       xml_child(xml_child(d, 2), 2), 3
#     ), 3), 3), 2
#   ), 3), 2))
# 
# zonaloc <-
#   xml_attrs(xml_child(xml_child(xml_child(
#     xml_child(xml_child(xml_child(xml_child(
#       d, 2
#     ), 2), 3), 3), 3
#   ), 2), 3))
# 
# distrito <-
#   xml_attrs(xml_child(xml_child(xml_child(
#     xml_child(xml_child(d, 2), 2), 3
#   ), 3), 3))
# 
# comuna <-
#   xml_attrs(xml_child(xml_child(xml_child(xml_child(
#     d, 2
#   ), 2), 3), 3))
# 
# provincia <- xml_attrs(xml_child(xml_child(xml_child(d, 2), 2), 3))
# 
# region <- xml_attrs(xml_child(xml_child(d, 2), 2))
# 
# censo <- xml_attrs(xml_child(xml_child(d, 2), 2))

# personas ----

personas <-
  xml_child(xml_child(xml_child(xml_child(
    xml_child(xml_child(xml_child(
      xml_child(xml_child(xml_child(d, 2), 2), 3), 3
    ), 3), 2), 3
  ), 2), 14), 13)

# xml_attrs(xml_child(personas, 1))
# xml_attrs(xml_child(personas, 34))
personas2 <- xml_attrs(xml_children(personas))

personas2 <- bind_rows(personas2) %>% 
  select(variable = name, descripcion = label, tipo = type, 
         tamanio = size, decimales = decimals, rango = range)

personas2 <- personas2 %>% 
  mutate(
    rango = str_replace_all(rango, " TO ", " - "),
    descripcion = cadena_a_titulo(descripcion)
  ) %>% 
  mutate_if(is.character, function(x) { str_trim(x) }) %>% 
  mutate(
    variable = str_to_lower(variable)
  )

# xml_attrs(xml_child(xml_child(xml_child(personas, 1), 1), 1))
# xml_attrs(xml_child(xml_child(xml_child(personas, 1), 1), 2))
personas_codificacion <- map_df(
  seq_along(personas2$variable),
  function(x) {
    d <- bind_rows(xml_attrs(xml_children(xml_children(xml_child(personas, x)))))
    d$variable <- personas2$variable[[x]]
    
    d <- d %>% 
      select(variable, valor = name, descripcion = value)
    
    d <- d %>% 
      mutate(
        descripcion = case_when(
          descripcion == "MISSING" ~ "Valor Perdido",
          descripcion == "NOTAPPLICABLE" ~ "No Aplica",
          TRUE ~ descripcion
        ),
        descripcion = str_trim(cadena_a_titulo(descripcion))
      )
    
    d
  }
)

personas_codificacion <- personas_codificacion %>% 
  distinct(variable, valor, .keep_all = T)

personas_codificacion <- personas_codificacion %>% 
  mutate(tabla = "personas") %>% 
  select(tabla, everything())
  
personas <- personas2 %>% 
  mutate(rango = ifelse(rango == "", NA_character_, rango)) %>% 
  mutate(tabla = "personas") %>% 
  select(tabla, everything())

rm(personas2)

# hogares ----

hogares <-
  xml_child(xml_child(xml_child(
    xml_child(xml_child(xml_child(
      xml_child(xml_child(xml_child(d, 2), 2), 3), 3
    ), 3), 2), 3
  ), 2), 14)

# xml_attrs(xml_child(hogares, 1))
# xml_attrs(xml_child(hogares, 34))
hogares2 <- xml_attrs(xml_children(hogares))

hogares2 <- bind_rows(hogares2) %>% 
  select(variable = name, descripcion = label, tipo = type, 
         tamanio = size, decimales = decimals, rango = range)

hogares2 <- hogares2 %>% 
  mutate(
    rango = str_replace_all(rango, " TO ", " - "),
    descripcion = cadena_a_titulo(descripcion)
  ) %>% 
  mutate_if(is.character, function(x) { str_trim(x) }) %>% 
  mutate(
    variable = str_to_lower(variable)
  )

# xml_attrs(xml_child(xml_child(xml_child(hogares, 1), 1), 1))
# xml_attrs(xml_child(xml_child(xml_child(hogares, 1), 1), 2))
hogares_codificacion <- map_df(
  seq_along(hogares2$variable),
  function(x) {
    print(x)
    
    d <- bind_rows(xml_attrs(xml_children(xml_children(xml_child(hogares, x)))))
    d$variable <- hogares2$variable[[x]]
    
    if (!any(colnames(d) %in% "name")) { d$name <- NA_character_ }
    if (!any(colnames(d) %in% "value")) { d$value <- NA_character_ }
    
    d <- d %>% 
      select(variable, valor = name, descripcion = value)
    
    d <- d %>% 
      mutate(
        descripcion = case_when(
          descripcion == "MISSING" ~ "Valor Perdido",
          descripcion == "NOTAPPLICABLE" ~ "No Aplica",
          TRUE ~ descripcion
        ),
        descripcion = str_trim(cadena_a_titulo(descripcion)),
        variable = str_to_lower(variable)
      )
    
    d
  }
)

hogares_codificacion <- hogares_codificacion %>% 
  distinct(variable, valor, .keep_all = T)

hogares_codificacion <- hogares_codificacion %>% 
  mutate(tabla = "hogares") %>% 
  select(tabla, everything())

hogares <- hogares2 %>% 
  drop_na(descripcion) %>% 
  mutate(rango = ifelse(rango == "", NA_character_, rango)) %>% 
  mutate(tabla = "hogares") %>% 
  select(tabla, everything())

rm(hogares2)

# viviendas ----

viviendas <-
  xml_child(xml_child(xml_child(
    xml_child(xml_child(xml_child(
      xml_child(xml_child(d, 2), 2), 3
    ), 3), 3), 2
  ), 3), 2)

# xml_attrs(xml_child(viviendas, 1))
# xml_attrs(xml_child(viviendas, 34))
viviendas2 <- xml_attrs(xml_children(viviendas))

viviendas2 <- bind_rows(viviendas2) %>% 
  select(variable = name, descripcion = label, tipo = type, 
         tamanio = size, decimales = decimals, rango = range)

viviendas2 <- viviendas2 %>% 
  mutate(
    rango = str_replace_all(rango, " TO ", " - "),
    descripcion = cadena_a_titulo(descripcion)
  ) %>% 
  mutate_if(is.character, function(x) { str_trim(x) }) %>% 
  mutate(
    variable = str_to_lower(variable)
  )

# xml_attrs(xml_child(xml_child(xml_child(viviendas, 1), 1), 1))
# xml_attrs(xml_child(xml_child(xml_child(viviendas, 1), 1), 2))
viviendas_codificacion <- map_df(
  seq_along(viviendas2$variable),
  function(x) {
    print(x)
    
    d <- bind_rows(xml_attrs(xml_children(xml_children(xml_child(viviendas, x)))))
    d$variable <- viviendas2$variable[[x]]
    
    if (!any(colnames(d) %in% "name")) { d$name <- NA_character_ }
    if (!any(colnames(d) %in% "value")) { d$value <- NA_character_ }
    
    d <- d %>% 
      select(variable, valor = name, descripcion = value)
    
    d <- d %>% 
      mutate(
        descripcion = case_when(
          descripcion == "MISSING" ~ "Valor Perdido",
          descripcion == "NOTAPPLICABLE" ~ "No Aplica",
          TRUE ~ descripcion
        ),
        descripcion = str_trim(cadena_a_titulo(descripcion)),
        variable = str_to_lower(variable)
      )
    
    d
  }
)

viviendas_codificacion <- viviendas_codificacion %>% 
  distinct(variable, valor, .keep_all = T)

viviendas_codificacion <- viviendas_codificacion %>% 
  mutate(tabla = "viviendas") %>% 
  select(tabla, everything())

viviendas <- viviendas2 %>% 
  drop_na(descripcion) %>% 
  mutate(rango = ifelse(rango == "", NA_character_, rango)) %>% 
  mutate(tabla = "vivienda") %>% 
  select(tabla, everything())

rm(viviendas2)

# zonas ----

zonas <- tibble(
  tabla = "zonas",
  variable = "geocodigo",
  descripcion = "Sub-División Comunal de la forma RRPCCDDLLLL. RR = Región; RRP = Provincia; RRPCC = Comuna; RRPCCDD = Distrito Censal; RRPCCDDLLLL = Zona Censal.",
  tipo = "string",
  tamanio = "11",
  decimales = "0",
  rango = NA_character_
)


# comunas ----

comunas <-
  xml_child(xml_child(xml_child(xml_child(
    d, 2
  ), 2), 3), 3)

# xml_attrs(xml_child(comunas, 1))
# xml_attrs(xml_child(comunas, 34))
comunas2 <- xml_attrs(xml_children(comunas))

comunas2 <- bind_rows(comunas2) %>% 
  select(variable = name, descripcion = label, tipo = type, 
         tamanio = size, decimales = decimals, rango = range)

comunas2 <- comunas2 %>% 
  mutate(
    rango = str_replace_all(rango, " TO ", " - "),
    descripcion = cadena_a_titulo(descripcion)
  ) %>% 
  mutate_if(is.character, function(x) { str_trim(x) }) %>% 
  mutate(
    variable = str_to_lower(variable)
  )

comunas <- comunas2 %>% 
  drop_na(descripcion) %>% 
  mutate(rango = ifelse(rango == "", NA_character_, rango)) %>% 
  mutate(tabla = "comunas") %>% 
  select(tabla, everything())

rm(comunas2)

# unir ----

censo_variables <- personas %>% 
  bind_rows(hogares) %>% 
  bind_rows(viviendas) %>% 
  bind_rows(zonas) %>% 
  bind_rows(comunas)

censo_variables <- censo_variables %>% 
  mutate(
    tipo = str_to_lower(tipo),
    tamanio = as.integer(tamanio),
    decimales = as.integer(decimales)
  )

censo_variables <- censo_variables %>% 
  mutate(
    tabla = ifelse(tabla == "vivienda", "viviendas", tabla),
  )

personas <- censo_tabla("personas")
viviendas <- censo_tabla("viviendas")
hogares <- censo_tabla("hogares")
zonas <-  censo_tabla("zonas")
comunas <- censo_tabla("comunas")

censo_variables <- censo_variables %>% 
  mutate(
    pretipo = paste0("class(", tabla, "$", variable, ")")
  )

tipo <- NULL
for(i in seq_len(nrow(censo_variables))) {
  tipo[i] <- eval(parse(text = censo_variables$pretipo[i]))
}

censo_variables$tipo <- tipo

censo_variables <- censo_variables %>% 
  select(-c(tamanio, decimales, pretipo))

censo_variables <- censo_variables %>% 
  mutate(
    tabla = as_factor(tabla),
    tipo = as_factor(tipo)
  )

censo_codificacion_variables <- personas_codificacion %>% 
  bind_rows(hogares_codificacion) %>% 
  bind_rows(viviendas_codificacion)

censo_codificacion_variables <- censo_codificacion_variables %>% 
  drop_na() %>% 
  mutate(valor = as.integer(valor))

data.table::fwrite(censo_variables, "data-raw/variables.tsv", sep = "\t")
data.table::fwrite(censo_codificacion_variables, "data-raw/variables_codificacion.tsv", sep = "\t")
