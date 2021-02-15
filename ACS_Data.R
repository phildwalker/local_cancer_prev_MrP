# ACS data

library(tidycensus)
library(tidyverse)


vars <- paste0("B17024_", stringr::str_pad(c(1:131),3,pad = "0"))

PovLevl <- get_acs(geography = "tract", variables = vars,
                state = "NC", 
                county = c("Guilford", "Alamance", "Caswell", "Rockingham"), geometry = TRUE)


v19 <- load_variables(2019, "acs5", cache = TRUE)



Pov_Names <-
  PovLevl %>% 
  left_join(., v19, by = c("variable" = "name")) %>% 
  mutate(labelRaw = label) %>% 
  separate(label, into = c("Var", "Total", "Age", "IncomeToPov"), sep = "!!") %>% 
  mutate(PovGroup = case_when(IncomeToPov %in% c("5.00 and over", "4.00 to 4.99", "3.00 to 3.99", "2.00 to 2.99") ~ "Above 2",
                              !IncomeToPov %in% c("5.00 and over", "4.00 to 4.99", 
                                                  "3.00 to 3.99", "2.00 to 2.99") & !is.na(IncomeToPov) ~ "Below 2", 
                              is.na(IncomeToPov) ~ "TotalGrouping",
                              is.na(IncomeToPov) & is.na(Age) ~ "TotalOverall",
                              TRUE ~ "Unknown")) %>% 
  filter(!PovGroup %in% c("TotalGrouping", "TotalOverall")) %>% 
  group_by(PovGroup, GEOID, NAME, Age) %>% 
  summarise(TotalPerson = sum(estimate)) %>% 
  ungroup() %>% 
  group_by(GEOID, NAME, Age) %>% 
  mutate(TotalGroup = sum(TotalPerson)) %>%
  ungroup() %>% 
  mutate(Perc = TotalPerson/TotalGroup) %>% 
  filter(PovGroup == "Below 2")
  
save(Pov_Names, file = here::here("data-raw", "ACS_Pov_Age_tract.rda"))



