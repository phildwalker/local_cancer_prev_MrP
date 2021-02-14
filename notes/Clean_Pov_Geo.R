
library(tidyverse)


load(file = here::here("data", "POV_LEVL.rda"))
longACS -> POV_LEVL


ACS_map <- tibble::tribble(
  ~ID, ~name, 
  "C17002_001E","Total",  
  "C17002_002E","Under .50",
  "C17002_003E",".50 to .99",
  "C17002_004E","1.00 to 1.24",
  "C17002_005E","1.25 to 1.49",
  "C17002_006E","1.50 to 1.84",
  "C17002_007E","1.85 to 1.99",
  "C17002_008E","2.00 and over"
)


POV_LEVL_map <-
  POV_LEVL %>% 
  separate(NAME, into = c("tract_nm", "county_nm", "state_nm"), sep = ",") %>% 
  filter(trimws(county_nm) %in% c("Guilford County", "Alamance County", "Rockingham County", "Caswell County")) %>% 
  left_join(., ACS_map, by = c("vars" = "ID")) %>% 
  filter(!name == "Total") %>% 
  group_by(tract) %>% 
  mutate(Perc = values / sum(values)) %>% 
  ungroup() %>% 
  mutate(GEOID = paste0(trimws(state),trimws(county),trimws(tract))) %>% #,trimws(block_group)
  ungroup()
  
GuilBG <- tigris::tracts(state = "NC", county = c("Guilford", "Alamance", "Rockingham", "Caswell"))


Guil_POV <-
  GuilBG %>% 
  left_join(., POV_LEVL_map, by = c("GEOID"))

unique(Guil_POV$name)

Guil_POV %>% 
  filter(!name %in% c("2.00 and over")) %>%
  group_by(GEOID) %>% 
  summarise(sumPerc = sum(Perc)) %>% 
  # head()
  mapview::mapview(., zcol = "sumPerc")



#-----------

Below200Perc <-
  Guil_POV %>% 
  filter(!name %in% c("2.00 and over")) %>%
  group_by(GEOID, tract) %>% 
  summarise(sumPerc = sum(Perc, na.rm=T),
            TotalPpl = sum(values, na.rm=T))

save(Below200Perc, file = here::here("data", "Below200Perc.rda"))
