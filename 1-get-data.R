# připojit se k pražskému API, stahnout data a uložit je jako csvčko do /data directory
# iterace proto, že nevím dopředu kolik bude stránek (takže točím, dokud něco vrací)

suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(tidyverse))

source('0-get-token.R') # výsledek = objekt response s access tokenem v sobě 

# inicializace
i <- 1 
result <- data.frame()

# nevím dopředu kolik bude stránek, takže cyklud dopředu neuzavřený...
repeat({
  odkaz <- paste0('https://ckc-emea.cisco.com/t/prague-city.com/cdp/v1/opendata/2.0/prague/',
                  '?domain=paidparkingreports', # parkovací automaty
                  '&periodicity=last24hours', # za 24 hodin
                  '&pageNumber=', i, # první strana
                  '&pageSize=1000', # maximum
                  '&format=json')
  
  golemio <- GET(odkaz, 
              add_headers(Authorization = paste("Bearer", content(response)$access_token)))
  
  stop_for_status(golemio)
  
  data <- content(golemio, as = "parsed")$data %>% # v poli $data jsou výstupy, jako list
    unlist(recursive = T) %>%
    enframe()
  
  if(nrow(data) == 0) break # pokud se nic se nevrátilo tak zde skončím...
  
  #  něco se vrátilo, mohu iterovat
  
  data <- rep(1:(nrow(data)/8), 8) %>% # umělá hodnota prvního sloupce - aby se spread() měl čeho chytit
    sort() %>% # napřed osm jedniček, pak dvojek a tak...
    cbind(data) %>% # připojím k datům na první místo
    spread(name, value) %>%
    select (- .) # umělý sloupec splnil svůj úkol, pryč s ním :)
  
  result <- rbind (result, data)
  i <- i +1
    
  })
  
# uložit soubor pro budoucí použití...
readr::write_csv(result, 
                 paste0('./data/parking-praha-', 
                                format(Sys.time(), '%Y-%m-%d-%T'),
                                '.csv'))

