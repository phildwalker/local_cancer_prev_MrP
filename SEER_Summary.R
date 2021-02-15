# https://seer.cancer.gov/explorer/application.html?site=55&data_type=1&graph_type=3&compareBy=race&chk_race_1=1&chk_race_5=5&chk_race_4=4&chk_race_3=3&chk_race_6=6&chk_race_8=8&chk_race_2=2&sex=3&rate_type=2&advopt_precision=1&advopt_display=2





SEER <- 
  readxl::read_excel(here::here("data-raw", "Summary_Cancer_Age_Rates_Female_Breast.xlsx")) %>% 
  pivot_longer(cols = 3:9, names_to = "Races", values_to = "RatePer") %>% 
  left_join(.,
            readxl::read_excel(here::here("data-raw", "Summary_Cancer_Age_Rates_Female_Breast.xlsx"), sheet = "lookup"),
            by = c("Races" = "ColName"))


SEER_All_Long <-
  SEER %>% 
  filter(Short == "All_Race") %>% 
  mutate(RatePer = ifelse(is.na(RatePer), 0,RatePer)) %>% 
  group_by(AgeGroup, Short) %>% 
  summarise(RateAvg = mean(RatePer)) %>% 
  ungroup() %>% 
  mutate(NonCan = 100000-RateAvg) %>% 
  pivot_longer(cols = 3:4, names_to = "CancerFlag", values_to = "EstIncid") %>% 
  mutate(CancerFlag = ifelse(CancerFlag == "RateAvg", 1,0),
         EstCount = round(EstIncid)) %>% 
  uncount(weights = EstCount)

library(lme4)
fit <- glmer(CancerFlag ~ 1 + (1|AgeGroup) , data = SEER_All_Long, family = binomial)

summary(fit)

save(fit, file = here::here("data", "fit.rda"))
