# MrP Model for Breast Cancer

library(tidyverse)

load(file = here::here("data-raw", "Pov_Names.rda"))
load(file = here::here("data", "fit.rda"))

prediction_grid <- data.frame(AgeGroup = unique(Pov_Names$AgeGroup))

prediction_grid$pred <- predict(fit, newdata = prediction_grid, type = "response")




## Post Stratify
mrp_out <- 
  Pov_Names %>%
  left_join(prediction_grid) %>%
  mutate(likely_cases = pred * (TotalGroup/2))

## add the weights together
mrp_out %>%
  ungroup() %>%
  st_drop_geometry() %>% 
  separate(NAME, into = c("Tract", "County", "State"), sep = ",") %>% 
  mutate(County = trimws(County)) %>% 
  group_by(County) %>%
  summarise(n_cancer = sum(likely_cases))



