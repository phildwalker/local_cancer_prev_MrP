# https://seer.cancer.gov/explorer/application.html?site=55&data_type=1&graph_type=3&compareBy=race&chk_race_1=1&chk_race_5=5&chk_race_4=4&chk_race_3=3&chk_race_6=6&chk_race_8=8&chk_race_2=2&sex=3&rate_type=2&advopt_precision=1&advopt_display=2





SEER <- 
  readxl::read_excel(here::here("data-raw", "Summary_Cancer_Age_Rates_Female_Breast.xlsx")) %>% 
  pivot_longer(cols = 3:9, names_to = "Races", values_to = "RatePer") %>% 
  left_join(.,
            readxl::read_excel(here::here("data-raw", "Summary_Cancer_Age_Rates_Female_Breast.xlsx"), sheet = "lookup"),
            by = c("Races" = "ColName"))
