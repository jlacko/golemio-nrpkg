# Nerezidenční parkování v městě Praze 

Malý projekt o parkování v Praze; hlavním cílem je prokázat proveditelnost přístupu ke [Golemio API](https://golemio.cz/cs/oblasti) obecně a datům nerezidenčního parkování konkrétně + nenáročná vizualizace tří základních veličin:  
- počtu vykázaných stání
- objemu vybraných peněz
- průměrné ceně stání

Pro snazší zpracování a interpretaci je plocha města Prahy rozdělena do šestiúhelníků o hraně 620.4 metru, což dává plochu kilometr čtverečný.

Ilustrační data jsou za 13. prosínce 2018, což nemá žádný hlubší význam nežli to že jsem to sjížděl 14. prosince.

Pražská data jsou open, ale stažení vyžaduje klíč a [tedy registraci](https://forms.office.com/Pages/ResponsePage.aspx?id=G_covg45fU2pSJTcfbAq47pHNd0Qs7JBlMIQJar5KcxUQjVaWUlORlEyRU1OVVQ0SU1BVTNLMEdIViQlQCN0PWcu). Golemio z toho problém nedělá, ale určitá komplikace to je. Proto jsem v adresáři `/data` ponechal jeden vzorový datový soubor, aby repo fungovalo i bez klíče.

### Zaplacených nerezidenčních stáních dne 13.12.2018
<p align="center">
  <img src="https://github.com/jlacko/golemio-nrpkg/blob/master/img/kusy.png?raw=true" alt="počty stání"/>
</p>

### Objem peněz vybraných za nerezidenční stání dne 13.12.2018
<p align="center">
  <img src="https://github.com/jlacko/golemio-nrpkg/blob/master/img/koruny.png?raw=true" alt="objem vybraných peněz"/>
</p>

### Průměrná cena nerezidenčního stání dne 13.12.2018 (objem / počet kusů)
<p align="center">
  <img src="https://github.com/jlacko/golemio-nrpkg/blob/master/img/prumerka.png?raw=true" alt="průměrná cena stání"/>
</p>

<hr>

# Technicky:

Kód je rozdělen do 4 logických částí, které jsou v samostatných souborech:  
- `0-get-token.R` se má na starost autorizaci a vygeneruje token  
- `1-get-data.R` stahuje surová data z relevantního API a uloží je jako csvčko do `/data`  
- `2-digest-shapefile.R` připraví z GeoJSONu parkovacích zón v `/data-raw` erkově přítulnější formát + vytvoří pomocné geometrické prvky jako jsou obrysy Prahy a relevantní kus Vltavy; tento soubor stačí spustit jednou  
- `3-plot-yesterday.R` vytvoří z dat v `/data` obrázky do `/img`   
