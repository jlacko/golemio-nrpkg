# overview za včerejšek - jak to vypadalo včera...

library(tidyverse)
library(scales)
library(sf)

load('./data/pomocna-geometrie.RData') # hranice prahy, vltava, šestiúhelníky a hlavně zóny

# relevantní stažená data - pro jiné datum bude třeba jiný soubor...
src_raw <- readr::read_csv('./data/parking-praha-2018-12-14-08:57:31.csv')

data_raw <- zony_body %>% # surová data v detailu transakce
  inner_join(src_raw, by = c('code' = 'Section'))

data <- data_raw %>% # vzít surová data
  group_by(code) %>% # seskupit podle čísla zóny
  summarise(pocet = n(), # spočítat kusy ...
            objem = sum(Price)) %>% # a sečíst kačky
  ungroup() # protože grouped data.frame špatně kamarádí se sf packagí

chart_src <- prazske_polygony %>% # polygony (ve WGS84)
  st_transform(5514) %>% # do Křováka kvůli metrům
  mutate(id = c(1:n())) %>% # technický identifikátor polygonu
  st_join(st_transform(data, 5514)) %>% # namnožit o frame data, převedený do Křováka
  st_transform(4326) %>% # WGS, ať je sever nahoře
  filter(!is.na(pocet)) %>% # vyhodit prázdné
  select(id, pocet, objem) %>% # relevantní pole (+ skrytá geometrie)
  group_by(id) %>% # seskupit podle technického idčka polygonu
  summarize(pocet = sum(pocet), # sumarizovat 
            objem = sum(objem),
            prumerka = sum(objem)/sum(pocet)) %>%
  ungroup() # odskupit, páč sf...
                     

leyenda <- c('Zaplacených\nstání', 'Vybraných\npeněz', 'Průměrná\ncena stání')

# vytvořit plot kusů, kaček a průměrné ceny

obr_kusy <- ggplot(chart_src) + 
  geom_sf(aes(fill = pocet), lwd = 0, alpha = 0.8) +
  scale_fill_gradient2(midpoint = 35,
                       low = 'green2',
                       mid = 'yellow',
                       high = 'red3',
                       na.value = 'gray95',
                       name = leyenda[1]) +
  geom_sf(data = vltava, color = 'slategray3', lwd = 1.25) +
  geom_sf(data = obrys_prahy, fill = NA, color = 'gray75', lwd = 1, alpha = 0.6) +
  theme_bw() +
  theme(legend.text.align = 1,
        legend.title.align = 0.5)

obr_kacky <- ggplot(chart_src) + 
  geom_sf(aes(fill = objem), lwd = 0, alpha = 0.8) +
  scale_fill_gradient2(midpoint = 35,
                       low = 'green2',
                       mid = 'yellow',
                       high = 'red3',
                       na.value = 'gray95',
                       name = leyenda[2],
                       labels = dollar_format(prefix = "", suffix = ' Kč')) +
  geom_sf(data = vltava, color = 'slategray3', lwd = 1.25) +
  geom_sf(data = obrys_prahy, fill = NA, color = 'gray75', lwd = 1, alpha = 0.6) +
  theme_bw() +
  theme(legend.text.align = 1,
        legend.title.align = 0.5)

obr_prumerka <- ggplot(chart_src) + 
  geom_sf(aes(fill = prumerka), lwd = 0, alpha = 0.8) +
  scale_fill_gradient2(midpoint = 35,
                       low = 'green2',
                       mid = 'yellow',
                       high = 'red3',
                       na.value = 'gray95',
                       name = leyenda[3],
                       labels = dollar_format(prefix = "", suffix = ' Kč')) +
  geom_sf(data = vltava, color = 'slategray3', lwd = 1.25) +
  geom_sf(data = obrys_prahy, fill = NA, color = 'gray75', lwd = 1, alpha = 0.6) +
  theme_bw() +
  theme(legend.text.align = 1,
        legend.title.align = 0.5)

# uložit oba obrázky do složky img
ggsave('./img/kusy.png', plot = obr_kusy, width = 8, height = 6, units = "in", dpi = 100) # čiliže 800 × 800 px
ggsave('./img/koruny.png', plot = obr_kacky, width = 8, height = 6, units = "in", dpi = 100) # čiliže 800 × 800 px
ggsave('./img/prumerka.png', plot = obr_prumerka, width = 8, height = 6, units = "in", dpi = 100) # čiliže 800 × 800 px
