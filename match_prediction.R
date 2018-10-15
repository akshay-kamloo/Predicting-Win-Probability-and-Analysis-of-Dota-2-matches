# This R environment comes with all of CRAN preinstalled, as well as many other helpful packages
# The environment is defined by the kaggle/rstats docker image: https://github.com/kaggle/docker-rstats
# For example, here's several helpful packages to load in 

library(ggplot2) # Data visualizwation
library(readr) # CSV file I/O, e.g. the read_csv function
library(dplyr)
library(matrixStats)
library(randomForest)
library(ROCR)
# Input data files are available in the "../input/" directory.
# For example, running this (by clicking run or pressing Shift+Enter) will list the files in the input directory


# Any results you write to the current directory are saved as output.
data = read.table("E:/dota-2-matches/player_time.csv"
                  ,header=TRUE
                  , row.names=NULL
                  ,sep = ","
                  ,fill = TRUE)
dataMatch = read.table("E:/dota-2-matches/match.csv"
                       ,header=TRUE
                       , row.names=NULL
                       ,sep = ","
                       ,fill = TRUE)
#Create dataframes
df <- data.frame(data)
dfMatch <- data.frame(dataMatch)

#Remove all 0 rows at match start
df <- df[!(df$times == 0),]
#Remove different gamemodes
dfMatch<- dfMatch[(dfMatch$game_mode == 22),]
dfMatch <- dfMatch[,!(colnames(dfMatch) %in% c("negative_votes","positive_votes","cluster"))]

#Sum of teams Gold
RadiantGold <- df$gold_t_0 + df$gold_t_1 + df$gold_t_2 + df$gold_t_3 + df$gold_t_4
df$RadiantGold <- RadiantGold

RadiantGoldSD <-apply(df[,c("gold_t_0","gold_t_1","gold_t_2","gold_t_3","gold_t_4")],1,sd)
df$RadiantGoldSD <- RadiantGoldSD

RadiantGoldMAD <-apply(df[,c("gold_t_0","gold_t_1","gold_t_2","gold_t_3","gold_t_4")],1,mad)
df$RadiantGoldMAD <- RadiantGoldMAD

DireGold <- df$gold_t_128 + df$gold_t_129 + df$gold_t_130 + df$gold_t_131 + df$gold_t_132
df$DireGold <- DireGold

#Sum of teams XP
RadiantXp <- df$xp_t_0 + df$xp_t_1 + df$xp_t_2 + df$xp_t_3 + df$xp_t_4
df$RadiantXp <- RadiantXp

RadiantXpSD <-apply(df[,c("xp_t_0","xp_t_1","xp_t_2","xp_t_3","xp_t_4")],1,sd)
df$RadiantXpSD <- RadiantXpSD

RadiantXpMAD <-apply(df[,c("xp_t_0","xp_t_1","xp_t_2","xp_t_3","xp_t_4")],1,mad)
df$RadiantXpMAD <- RadiantXpMAD

DireXp <- df$xp_t_128 + df$xp_t_129 + df$xp_t_130 + df$xp_t_131 + df$xp_t_132
df$DireXp <- DireXp

#Team Advantages
df$RadiantGoldAdv <- df$RadiantGold - df$DireGold 
df$DireGoldAdv <- df$DireGold - df$RadiantGold

df$RadiantXpAdv <- df$RadiantXp - df$DireXp 
df$DireXpAdv <- df$DireXp - df$RadiantXp

#Merge match results with match flow
matchSoT <- merge(df,dfMatch, by ="match_id")
matchSoT$radiant_win <- matchSoT$radiant_win == "True"
matchSoT$dire_win <- !matchSoT$radiant_win

#Get match status @15minutes to predict Win%
match15 <- matchSoT[(matchSoT$times == 900),]

   #Use Advantages
   match15Adv <- match15[,c("match_id","RadiantXpAdv","RadiantGoldAdv","RadiantGoldSD","RadiantGoldMAD","RadiantXpSD","RadiantXpMAD","radiant_win")]

#Use Advantages
matchEvery5 <- matchSoT[(matchSoT$times%%900==0),]
matchTableau <- matchEvery5[,c("match_id","times","RadiantXpAdv","RadiantGoldAdv","radiant_win")]

#library(ggplot2)
#ggplot(data = dat$game_mode, mapping = aes(x = value)) + 
#  geom_histogram(bins = 10) + facet_wrap(~variable, scales = 'free_x')




#Predicting
set.seed(1234)

train <- head(match15Adv,45000)
test  <- tail(match15Adv,3666)

extractFeatures <- function(data) {
  features <- c("RadiantXpAdv","RadiantGoldAdv","RadiantGoldSD","RadiantGoldMAD","RadiantXpSD","RadiantXpMAD")
  fea <- data[,features]
  return(fea)
}


rf <- randomForest(extractFeatures(train),as.factor(train$radiant_win), ntree=100, importance = TRUE,keep.forest=TRUE, do.trace=T)
submission <- data.frame(match_id = test$match_id)
submission$WinPct <- 1-predict(rf,extractFeatures(test), type="prob")
write.csv(submission , file = "dotapredict.csv", row.names = FALSE)


submission <- data.frame(match_id = test$match_id)
submission$WinPct <- 1-predict(rf,extractFeatures(test), type="prob")
write.csv(submission , file = "dotapredict.csv", row.names = FALSE)

imp <- importance(rf,type=1)
featureImportance <- data.frame(Feature = row.names(imp), Imporance = imp[,1])


aucData <- merge(submission, match15Adv, by ="match_id")
aucData$radiant_win <- lapply(aucData$radiant_win, as.numeric) 

pred <- prediction(unname(aucData$WinPct[,1]),unlist(data.matrix(aucData$radiant_win)))
auc.tmp <- performance(pred,"auc")
auc <- as.numeric(auc.tmp@y.values)

perf <- performance(pred, measure = "tpr", x.measure = "fpr")

rf$confusion[, 'class.error']

plot(perf, col=rainbow(10))
plot(rf$confusion[, 'class.error'])
