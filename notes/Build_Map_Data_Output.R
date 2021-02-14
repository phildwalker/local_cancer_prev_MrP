# Estimated Counts and Error for Living below 200% FPL and estimated cancer rates


library(tidyverse)
library(eadb)
library(eastyle)

load(file = here::here("data", "Below200Perc.rda"))

# Pull PLACES dataset for 

PLACES <- 
  submit_edw_query(
    template = " SELECT countyname, tractfips, totalpopulation, cancer_crudeprev, cancer_crude95ci
      FROM [DS_Team].[demographics].[cdc_places_US_tracts]
      where stateabbr in ('NC')
      and countyname in ('Guilford', 'Alamance', 'Rockingham', 'Caswell')
      ",
    edw_dsn = "MCCBISOLDBDEV1",
    show_query = T
  )


POV_Cancer <-
  left_join(Below200Perc, PLACES,by = c("GEOID" = "tractfips")) %>% 
  mutate(cancer_crudeprev = as.numeric(cancer_crudeprev)/100) %>% 
  rename(EstPer_Below200Pov = sumPerc)


library(mapview)

mapview(POV_Cancer, zcol=c("EstPer_Below200Pov", "cancer_crudeprev"))



