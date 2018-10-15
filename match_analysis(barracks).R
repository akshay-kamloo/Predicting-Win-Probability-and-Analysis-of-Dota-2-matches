#first team to damage an enemy barracks determine [win-rate]?

library(data.table)
library(dplyr)
library(ggplot2)
# Read in the neccessary data
matches <- fread('../input/match.csv')
objectives <- fread('../input/objectives.csv')
# Determine which team was first to do barracks damage
data <- left_join(matches, objectives, by="match_id")
glimpse(data)
unique(data$subtype)
result <- data %>% 
  group_by(match_id) %>%
  arrange(time) %>%
  filter(subtype == 'CHAT_MESSAGE_BARRACKS_KILL') %>%
  top_n(1, time)
head(result)
barracks_event_result <- data %>%
  filter(subtype == 'CHAT_MESSAGE_BARRACKS_KILL') %>%
  group_by(match_id, radiant_win) %>%
  summarise(count_rad = sum(key <= 2^5), count_dire = sum(key > 2^5))
barracks_event_result[1:10,]
result <- result %>%
  mutate(first_barracks_killed_by = ifelse(key <= 2^5, 'radiant', 'dire'))
result %>% select(time, radiant_win, first_barracks_killed_by)
result$first_and_win <- (result$radiant_win & result$first_barracks_killed_by == 'radiant') | 
  (!result$radiant_win & result$first_barracks_killed_by == 'dire')

summary(result$time)
ggplot(result, aes(time, fill = first_and_win)) + geom_bar(stat='bin') +
  geom_vline(xintercept = 2333, linetype = "longdash") +
  xlim(0,6000) + 
  annotate("text", label = '--- Median First Barracks Kill: \n      39 minutes into the game', x = 3950, y = 7200,)
BUCKET_SIZE <- round((6420 - min(result$time)) / 30)
result$time_bucket <- floor(result$time / BUCKET_SIZE) * BUCKET_SIZE
pct_result <- result %>%
  group_by(time_bucket) %>%
  summarise(percent_first_and_win = sum(first_and_win) / n())
BUCKET_SIZE
ggplot(pct_result %>% filter(time_bucket <= BUCKET_SIZE*25), aes(time_bucket, percent_first_and_win)) + 
  geom_line() + 
  geom_point(color='red') +
  ylim(0,1) +
  labs(x = 'Time of First Barracks Kill', y='Percent First and Win') +
  geom_vline(xintercept = 2333, linetype = "longdash")
#Excluded datapoints where first barracks kill was after 203*25 seconds into the game; not enough data.
#Limited data makes it hard to determine if winrate increases or decreases after 4200 seconds.