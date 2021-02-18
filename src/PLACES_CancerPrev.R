# To set the upper bounds, pulling in the cancer prevalence data from PLACES to see what the total expected (regardless of poverty level)

library(tidyverse)
library(eadb)
library(eageo)
library(sf)

PLACES_Cancer <-
  submit_edw_query(
    template = "SELECT [stateabbr],[statedesc],[countyname],[countyfips],[tractfips],[totalpopulation], [cancer_crudeprev],[cancer_crude95ci]
  FROM [DS_Team].[demographics].[cdc_places_US_tracts]
  where stateabbr in ('NC')
  and countyname in ('Guilford', 'Alamance', 'Rockingham', 'Caswell')",
    edw_dsn = "MCCBISOLDBDEV1",
    show_query = T
  )  

tractsCounties <- tigris::tracts(state = "NC", county = c("Guilford", "Alamance", "Rockingham", "Caswell"))


PLACES_Clean <-
  tigris::geo_join(tractsCounties %>% select(GEOID), PLACES_Cancer, "GEOID", "tractfips") %>% 
  st_as_sf(crs = 4269) %>%
  st_transform(crs = 4269) %>% 
  filter(!is.na(cancer_crudeprev)) %>% 
  mutate(cancer_crudeprev = as.numeric(cancer_crudeprev)) %>% 
  mutate(cancer_crude95ci = str_remove_all(cancer_crude95ci, "\\( |\\)")) %>% 
  separate(cancer_crude95ci, into = c("upper95", "lower95"), sep = ", ") %>% 
  mutate(upper95 = as.numeric(upper95),
         lower95 = as.numeric(lower95),
         totalpopulation = as.numeric(totalpopulation)) 
  
  
# mapview::mapview(PLACES_Clean, zcol = "cancer_crudeprev")

PLACES_Clean %>% 
  st_drop_geometry() %>% 
  mutate(EstCancer = totalpopulation * (cancer_crudeprev/100)) %>% 
  group_by(countyname) %>% 
  summarise(EstTotal = sum(EstCancer),
            TotalPop = sum(totalpopulation))
