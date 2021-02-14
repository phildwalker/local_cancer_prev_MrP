library(tidyverse)
library(rstanarm)
library(tidybayes)

# fake data ---------------------------------------------------------------

dat <- data.frame(age = sample(x = seq(0,100,10), size = 100, replace = TRUE),
                  sex = sample(c(0, 1), size = 100, replace = TRUE))

dat$cancer_z <- dat$age*2/100 - dat$sex + rnorm(100) -1
dat$prob <- arm::invlogit(dat$cancer_z)
dat$cancer <- ifelse(dat$prob>.5,1,0)

dat

# step 1 fit survey data you have -----------------------------------------

fit <- stan_glm(cancer ~ age + sex , data = dat, family = binomial)

summary(fit)

track_data <- data.frame(age = sample(x = seq(0,100,10), size = 1000, replace = TRUE),
                         sex = sample(c(0, 1), size = 1000, replace = TRUE))
track_data$id <- sample(letters[1:5], 100, replace = TRUE)

## This is what you get from ACS or Census
census_data <- track_data %>%
  count(id, age, sex)


# now you apply your model on your data -----------------------------------
# # Fit Model on Complete Cross Section
prediction_grid <- crossing(age = unique(census_data$age),
                            sex = unique(census_data$sex))



## Add Predictions
## See <https://michaeldewittjr.com/dewitt_blog/posts/2018-11-07-mrp-using-brms/>
## Additional example using more of posterior distribution

prediction_grid$pred = predict(fit, newdata = prediction_grid, type = "response")


## Post Stratify
census_data %>%
  left_join(prediction_grid) %>%
  mutate(likely_cases = pred * n)->mrp_out

## add the weights together
mrp_out %>%
  ungroup() %>%
  group_by(id) %>%
  summarise(n_cancer = sum(pred),
            pct_cancer = sum(pred)/sum(n))
