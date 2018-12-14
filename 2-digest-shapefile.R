# načíst zóny jako GeoJson, transformovat do sf package formátu +
# + připravit pomocné geografické objekty: hranice Prahy, Vltavu, hexagony

library(sf)
library(RCzechia)
library(tidyverse)

zony_raw <- st_read('./data-raw/zony_raw.json') 

zony_body <- zony_raw %>%
  transmute(code = as.character(CODE),
            category = CATEGORY) %>%
  st_set_agr('constant') %>%
  st_centroid() %>%
  st_transform(4326) # zpátky do WGS84

obrys <- kraje("high") %>% # kraj Praha ...
  filter(KOD_CZNUTS3 == 'CZ010') %>% # ... to je to město!
  select(geometry) %>%
  st_transform(5514) # do Křováka, ať jsme v metrech

obalka <- obrys %>%
  st_buffer(1000) # kilometr kolem Prahy

vltava <- reky() %>% # kraj Praha ...
  filter(NAZEV == 'Vltava') %>%
  select(geometry) %>%
  st_transform(5514) %>% # do Křováka, ať jsme v metrech
  st_intersection(obalka) %>% # jen pražský kus
  st_transform(4326) # zpátky do WGS84

krabicka <- st_bbox(obrys)

xrange <- krabicka$xmax - krabicka$xmin
yrange <- krabicka$ymax - krabicka$ymin

sirka_ctverce <- sqrt(2 * 1e6 / (3 * sqrt(3)))  # hrana v metrech, aby plocha byl kilometr^2

rozmery <- c(xrange/sirka_ctverce, yrange/sirka_ctverce) # počet kilometrů na šířku a na výšku

prazske_polygony <- st_make_grid(obrys, square = F, n = rozmery) %>% # šestiúhelníky do obálky
  st_intersection(obrys) %>% # jenom vnitřek
  st_sf() %>%
  st_transform(4326) # do WGS84, ať jsme kompatibilni s gůglem

obrys_prahy <- st_transform(obrys, 4326) # zpátky do WGS84

save(zony_body, obrys_prahy, vltava, prazske_polygony, file = './data/pomocna-geometrie.RData')