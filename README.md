# local_cancer_prev_MrP
Building an example of how to use multilevel regression with poststratification 


# Goal  

Building out the model to estimate the cancer prevalence on a smaller geographic level

using the cancer prevalence by age group to develop an estimated prevalence of breast cancer by age and poverty level


# Current level of data  

Using the BRFSS? (Behavioral Risk Factor Surveillance System)

* Using the SEER 21 areas data
    * SEER 21- Available for cases diagnosed from 2000 through the current data year and includes expanded races.  It has a more limited set of available variables than other groupings and is only available for limited statistics.

# Desired level of data

Down to the tract level

# Steps

1. Use SEER data to model estimates of prevalence of breast cancer for women by age and race (might need to back into it from their summary table)
... using glm or brms to model
2. Create poststrat table for the 4 counties on the tract level
... using the acs to gather the splits of race,  age and poverty level? (Is there a view that has all of that?)... maybe not using race on the initial model?
3. Combine to the predict estimated prevalence on tract level
4. Compare to patients with breast cancer dx in the past 3* years? (Maybe wider net?)
... using those patients who we have decided information for
... this could allow us a form of validation or helping to highlight where cone could outreach?



# Assumptions

that sex is split evenly on the tract level (so we end up dividing totals by 2 )










