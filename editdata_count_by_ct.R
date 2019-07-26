#install packages
install.packages("dplyr")
library(dplyr)

#cutting down pluto dataset columns
pluto_short <- subset(pluto,select=c(Borough, Block, Lot, CT2010, YearBuilt, UnitsRes))

#getting counts for housing violations by Census Tract
ctviol <- count(hviol, CensusTract)

#prepping for merge
ctviol$CT2010 <- ctviol$CensusTract
pluto_short$CT2010 <- floor(pluto_short$CT2010)

#outer left join housing violation data to pluto data set
pluto_w_viol <- merge(x = pluto_short, y = ctviol, by=c("CT2010"), all.x = TRUE)
pluto_w_viol$freq[is.na(pluto_w_viol$n)] <- 0

#getting counts for 2014 stabilized units by Census Tract
stable_by_ct <- aggregate(stable$X2014uc, by=list(CT2010=stable$ct2010), FUN=sum)
stable_by_ct$x[is.na(stable_by_ct$x)] <- 0

#outer left join stabilized data to pluto data set
pluto_ct_data <- merge(x = pluto_w_viol, y = stable_by_ct, by=c("CT2010"), all.x = TRUE)

#renaming & reorganizing
index <- c("MN", "BX", "BK", "QN", "SI")
values <- c(1, 2, 3, 4, 5)
pluto_ct_data$BoroughID <- values[match(pluto_ct_data$Borough, index)]
pluto_ct_data$BlockID <- sprintf("%05d",pluto_ct_data$Block)
pluto_ct_data$LotID <- sprintf("%04d",pluto_ct_data$Lot)
pluto_ct_data$BBL <- paste(pluto_ct_data$BoroughID,pluto_ct_data$BlockID,pluto_ct_data$LotID,sep="")
pluto_ct_short <- subset(pluto_ct_data,select=c(BBL,CT2010,YearBuilt,UnitsRes,x,n))
pluto_ct_short <- pluto_ct_short %>% rename(SUnits_by_ct = x, HViol_by_ct = n)

#to export data
write.csv(pluto_ct_short, file = "BBL_data_count_by_CT.csv")