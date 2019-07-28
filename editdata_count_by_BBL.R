#read data
setwd("/Users/miawong/Desktop/Avigail_Data")
hviol=read.csv("Housing_Maintenance_Code_Violations2014.csv")
stable=read.csv("stabilized.csv")
plutoMN=read.csv("MN.csv")
plutoBX=read.csv("BX.csv")
plutoBK=read.csv("BK.csv")
plutoQN=read.csv("QN.csv")
plutoSI=read.csv("SI.csv")
pluto <- rbind(plutoBK,plutoBX,plutoMN,plutoQN,plutoSI)

#install packages
install.packages("dplyr")
library(dplyr)

#only residential units & cutting down pluto dataset columns
pluto_short <- subset(pluto,UnitsRes >0,select=c(Borough, Block, Lot, CT2010, CB2010, YearBuilt, UnitsRes))

#creating BBL ID
index <- c("MN", "BX", "BK", "QN", "SI")
values <- c(1, 2, 3, 4, 5)
pluto_short$BoroughID <- values[match(pluto_short$Borough, index)]
pluto_short$BlockID <- sprintf("%05d",pluto_short$Block)
pluto_short$LotID <- sprintf("%04d",pluto_short$Lot)
pluto_short$BBL <- paste(pluto_short$BoroughID,pluto_short$BlockID,pluto_short$LotID,sep="")

#creating BBL ID in hviol (there are some blanks in hviol's BBL column)
hviol$BoroughID <- hviol$BoroID
hviol$BlockID <- sprintf("%05d",hviol$Block)
hviol$LotID <- sprintf("%04d",hviol$Lot)
hviol$BBL <- paste(hviol$BoroughID,hviol$BlockID,hviol$LotID,sep="")

#getting counts for housing violations by BBL
bblviol <- count(hviol, BBL)

#outer left join housing violation data to pluto data set
pluto_w_viol <- merge(x = pluto_short, y = bblviol, by=c("BBL"), all.x = TRUE)
pluto_w_viol$n[is.na(pluto_w_viol$n)] <- 0

#editting stabilized data set
stable$BBL <- stable$ucbbl
bblstable <- subset(stable,select=c(BBL, X2014uc))

#outer left join stabilized data to pluto data set
pluto_bbl_data <- merge(x = pluto_w_viol, y = bblstable, by=c("BBL"), all.x = TRUE)
pluto_bbl_data$X2014uc[is.na(pluto_bbl_data$X2014uc)] <- 0

#renaming & reorganizing
pluto_bbl_short <- subset(pluto_bbl_data,select=c(BBL,CT2010,CB2010,YearBuilt,UnitsRes,X2014uc,n))
pluto_bbl_short <- pluto_bbl_short %>% rename(SUnits_by_bbl = X2014uc, HViol_by_bbl = n)

#to export data
write.csv(pluto_bbl_short, file = "BBL_data_count_by_BBL.csv")
