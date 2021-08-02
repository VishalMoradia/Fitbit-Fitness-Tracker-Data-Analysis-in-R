
# Importing necessary libraries -------------------------------------------




library(tidyverse)
library(ggplot2)
library(dplyr)
library(lubridate)



# Loading the data --------------------------------------------------------


daily_activity <- read.csv(file.choose())
sleep_day <- read.csv(file.choose())



# Exploring the data ------------------------------------------------------
# as we can see that IDs in both data are not factors. We will convert double into factor if required......


summary(sleep_day)
head(sleep_day)

summary(daily_activity)
head(daily_activity)



# splitting the column sleepday into data and time....................
# we should now have 6 varaibles in sleep_day dataset.............

sleep_day_new <- sleep_day %>%
  separate(SleepDay, c("Date", "Time"), " ")

#checking the dataset........................

glimpse(sleep_day_new)

#In order to merge the data, we have to ensure identical column names........

colnames(daily_activity)
colnames(sleep_day_new)

# renaming date column in sleep_day_new...................

colnames(sleep_day_new)[2] = "ActivityDate"

colnames(sleep_day_new)

# merging the data......
?merge

merged <- merge(daily_activity, sleep_day_new, by = c("Id", "ActivityDate"), all = FALSE)
glimpse(merged)


head(merged)



# analyze phase -----------------------------------------------------------

# lets get the unique number of observations from both dataset...................
# we can use ID column to check whether users have worn fibit device during both activities....
# we can see that users have not worn the device during sleep at multiple occasions..

n_distinct(daily_activity$Id)
n_distinct(sleep_day_new$Id)


# In our sleep data we can see that there are two varaibles, which are total time in bed and total time asleep.

# we can derive a new column called only_sleep by reducing the time asleep from total time in bed......

merged$sleep_efficiency <- merged$TotalMinutesAsleep/merged$TotalTimeInBed

# lets create two columns to differentiate heavy and light users....................

merged$heavy_active <- merged$FairlyActiveMinutes + merged$VeryActiveMinutes
merged$light_active <- merged$LightlyActiveMinutes + merged$SedentaryMinutes + merged$TotalMinutesAsleep
merged$user_type <- case_when(merged$heavy_active > 60 ~ "heavy", TRUE ~ "light")

