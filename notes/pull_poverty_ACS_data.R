# Pull poverty level data...
# Fri Feb 12 10:00:08 2021 ------------------------------

library(tidyverse)
library(censusapi)

# https://api.census.gov/data.html
#pov:: C170002C17

ACS_codes <- tibble::tribble(
  ~group, ~name, ~geoLevel, ~code, 
  "overall", "POV_LEVL", "tract", list("B17001_002M"), 
)

#list("C17002_001E","C17002_002E","C17002_003E","C17002_004E", "C17002_005E","C17002_006E","C17002_007E","C17002_008E")

ACSdata <- function(i = 10){
  vars <- dput(as.character(ACS_codes$code[[i]]))
  
  acs_main <- getCensus(name = "acs/acs5",
                        vintage = 2018,
                        vars = c("NAME", vars), #dput(as.character(ACS_codes$code[[i]]))
                        region = dput(paste0(ACS_codes$geoLevel[[i]],":*")),
                        regionin = "state:37") #+county:081
  
  longACS <- 
    acs_main %>%
    pivot_longer(cols = starts_with(substring(ACS_codes$code[[i]][[1]],1,1),ignore.case = F), 
                 names_to = "vars", values_to = "values") %>%
    filter(values >= 0) %>%
    mutate(SVI_metric = ACS_codes$name[[i]],
           SVI_group = ACS_codes$group[[i]])
  
  save(longACS, file = here::here("data", paste0(ACS_codes$name[[i]],".rda")))
  
}


for (k in 1:nrow(ACS_codes)){
  ACSdata(k)
}


load(file = here::here("data", "POV_LEVL.rda"))
