# ACS data

library(tidycensus)
library(tidyverse)


vars <- paste0("B17024_", stringr::str_pad(c(1:131),3,pad = "0"))

PovLevl <- get_acs(geography = "tract", variables = vars,
                state = "NC", 
                county = c("Guilford", "Alamance", "Caswell", "Rockingham"), geometry = TRUE)


v19 <- load_variables(2019, "acs5", cache = TRUE)

# unique(Pov_Names$Age)

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
  mutate(AgeGroup = case_when(Age %in% c("Under 6 years:", "6 to 11 years:", "12 to 17 years:", "18 to 24 years:") ~ "0-24",
                              Age %in% c("25 to 34 years:") ~ "25-34", 
                              Age %in% c("35 to 44 years:") ~ "35-44", 
                              Age %in% c("45 to 54 years:") ~ "45-54", 
                              Age %in% c("55 to 64 years:") ~ "55-64", 
                              Age %in% c("65 to 74 years:") ~ "65-74", 
                              Age %in% c("75 years and over:") ~ "75+", 
                              TRUE ~ "Unknown")) %>% 
  filter(!PovGroup %in% c("TotalGrouping", "TotalOverall")) %>% 
  group_by(PovGroup, GEOID, NAME, AgeGroup) %>% 
  summarise(TotalPerson = sum(estimate)) %>% 
  ungroup() %>% 
  group_by(GEOID, NAME, AgeGroup) %>% 
  mutate(TotalGroup = sum(TotalPerson)) %>%
  ungroup() %>% 
  mutate(Perc = TotalPerson/TotalGroup) %>% 
  filter(PovGroup == "Below 2")
  
save(Pov_Names, file = here::here("data-raw", "Pov_Names.rda"))

#---------- Sex, Age, RE -----

vars <- sort(paste0("B01001", rep(LETTERS[1:9] , times = 31) ,"_", stringr::str_pad(c(1:31),3,pad = "0")))

SexAgeRE <- get_acs(geography = "tract", variables = vars,
                   state = "NC", 
                   county = c("Guilford", "Alamance", "Caswell", "Rockingham"), geometry = TRUE)


SexAgeRE_Names <-
  SexAgeRE %>% 
  left_join(., v19, by = c("variable" = "name")) %>% 
  mutate(labelRaw = label) %>% 
  separate(label, into = c("Var", "Total", "Sex", "Age"), sep = "!!") %>% 
  separate(NAME, into = c("Tract", "County", "State"), sep = ",") %>% 
  mutate(Race = str_remove_all(concept, "SEX BY AGE"),
         Race = trimws(str_remove_all(Race, "\\(|\\)")),
         Sex = str_remove_all(Sex, ":")) %>% 
  mutate(DataGroup = case_when(is.na(Age) ~ "TotalGrouping",
                              is.na(Sex) & is.na(Age) ~ "TotalOverall",
                              TRUE ~ "Counts")) %>%   
  filter(!DataGroup %in% c("TotalGrouping", "TotalOverall")) %>% 
  select(-Total, -DataGroup, -concept) %>% 
  ungroup()


save(SexAgeRE_Names, file = here::here("data-raw", "SexAgeRE_Names.rda"))


unique(SexAgeRE_Names$Race)








