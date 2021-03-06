# Fitbit-Fitness-Tracker-Data-Analysis-in-R

---
title: "Bellabeat - Study and Analysis"
author: "Vishal Moradia"
date: "02/08/2021"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

```{r}
# Importing necessary libraries -------------------------------------------
library(tidyverse)
library(ggplot2)
library(dplyr)
library(lubridate)
# Loading the data --------------------------------------------------------
daily_activity <- read.csv(file.choose())
sleep_day <- read.csv(file.choose())
```

#### **Objective**
Officials at the company feel that examining gadget fitness data can help them develop. They expect the information to aid in the development of the company's marketing strategy. 

#### **Methodology** 
1. We will try to look for best potential customers for the device by analyzing their daily activities.
2. We will differentiate between heavy users of the device and light users of the device. 

##### **Business Objective** 
Deliver insights that can advise the firm which kind of customers to focus on, as well as help the organisation understand the customer's usage in depth.

Exploring the imported data.

```{r}
summary(sleep_day)
head(sleep_day)
summary(daily_activity)
head(daily_activity)
```

- By quick exploration we can see that column Id is not factor. We also found that column    SleepDay has both date and time. 
- We will begin by separating date and time part from SleepDay column.

```{r}
sleep_day_new <- sleep_day %>%
  separate(SleepDay, c("Date", "Time"), " ")
```

- Taking a look at the data again.

```{r}
glimpse(sleep_day_new)
```

Before merging both dataset, we have to make sure that column names are identical. 

```{r}
colnames(daily_activity)
colnames(sleep_day_new)
```

As we can see the Date column in both dataset are different. In next step we will rename the column name.

```{r}
colnames(sleep_day_new)[2] = "ActivityDate"
colnames(sleep_day_new)
```

**Merging the data**

```{r}
merged <- merge(daily_activity, sleep_day_new, by = c("Id", "ActivityDate"), all = FALSE)
glimpse(merged)
```


#### Analyze Phase

- lets get the unique number of observations from both dataset
- we can use ID column to check whether users have worn fibit device during day and night time
- we can see that multiple users have not worn the device during sleep

```{r}
n_distinct(daily_activity$Id)
n_distinct(sleep_day_new$Id)
```

- Lets see the quality or efficiency of sleep among users
- We will need to derive a new variable to check our desired results

```{r}
merged$sleep_efficiency <- merged$TotalMinutesAsleep/merged$TotalTimeInBed
ggplot(data = merged) + geom_histogram(aes(sleep_efficiency)) +
    xlab("Efficiency of Sleep")
```

- We can see that most users are getting sleep efficiency between 83 to 97 percent. 

***Differentiating between heavy users and light users depending upon their activity times on daily basis***

- We care going consider a user, heavy if total time spent in activity is more than 60 minutes
- Less than 60 minutes will be categorized as light user
- We will create a new column named user_type

```{r}
merged$heavy_active <- merged$FairlyActiveMinutes + merged$VeryActiveMinutes
merged$light_active <- merged$LightlyActiveMinutes + merged$SedentaryMinutes + merged$TotalMinutesAsleep
merged$user_type <- case_when(merged$heavy_active > 60 ~ "heavy", TRUE ~ "light")
```


- Lets look at the column we created

```{r}
glimpse(merged$user_type)
```
***We will now visualize the user type against the calories burnt***

```{r}
ggplot(data = merged, aes(x = user_type, y = Calories)) +
  geom_boxplot(alpha = 0.5) + labs(title = "Calories VS User Type")
```

***Lets look at the relationship between total distance travelled and calories burned***

```{r}
ggplot(data = merged, aes(x = TotalDistance, y = Calories)) + geom_jitter() +
  geom_smooth(method = 'loess') + labs(title = "Distance Travelled VS Calories")
```
- We can see a positive realationship between total distance travelled and calories burned as expected.


***We should now plot a graph considering the number of steps device registered***

- We will categorise users with respect to number of steps they walked or ran like we did in case of activity recorded
- We will distinguish them between users who have walked more than 6000 steps and less than 6000 steps

```{r}
merged$step_type <- case_when(merged$TotalSteps > 6000 ~ "more than 6k", TRUE ~ "Less than 6K")
ggplot(data = merged, aes(x = step_type, y = Calories)) + geom_boxplot() +
  facet_wrap(~user_type)
```

- As expected, users who walked more than 6000 steps have burned more calories

***Lets look into the sleep patterns of heavy and light user type if there is anything interesting***

```{r}
ggplot(data = merged, aes(x = user_type, y = TotalMinutesAsleep)) +
  geom_boxplot()
```

- We may have something interesting here
- Heavy users tend to sleep lesser than light users. This should be investigated further
- We may need scientific knowledge to justify this insight 


#### ***Conclusion***

1. We found that the majority of users have a sleep efficiency of 83 to 97 percent 

2. User with heavy activity routines tend to burn 2000 to 3600 calories while light users are burning 1800 to 2550 calories per day on an average

3. As expected heavy activity user tend to walk or run more distance against light user. There is clear positive relationship between the two variable

4. Data suggest that heavy users tend to get lesser sleep than light users. This conclusion should be further examined through external sources 

#### ***What should business do?***

1. As the number of light users are more than heavy users, company should either come up with some strategy that can encourage light users to exercise regularly or it can produce new devices with more features outside the health monitoring domain to increase the sales

2. Regular notifications should be sent to user whenever device is found having more than threshold sedentary minutes

3. Company should run marketing campaigns to encourage light users to spend more time doing some physical activity
