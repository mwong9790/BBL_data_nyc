#editting housing violations data set
colnames(hviol)[colnames(hviol)=="Borough"] <- "Boroughold"
index <- c(1, 2, 3, 4, 5)
values <- c("MN", "BX", "BK", "QN", "SI")
hviol$Borough <- values[match(hviol$BoroID, index)]
install.packages("plyr")
library(plyr)

#getting counts for housing violations by BBL
bblviol <- count(hviol, c("Borough", "Block", "Lot"))

#outer left join housing violation data to pluto data set
pluto_w_viol <- merge(x = pluto, y = bblviol, by=c("Borough","Block", "Lot"), all.x = TRUE)
pluto_w_viol$freq[is.na(pluto_w_viol$freq)] <- 0

#editting stabilized data set
stable$Boroughnum <- substr(stable$ucbbl, 1, 1)
stable$Borough <- values[match(stable$Boroughnum, index)]
stable$Block <- substr(stable$ucbbl,2,6)
stable$Lot <- substr(stable$ucbbl,7,10)
stable$Lot <- as.integer(stable$Lot)
stable$Block <- as.integer(stable$Block)
bblstable <- subset(stable,select=c(Borough, Block, Lot, X2014uc, X2014est, X2014dhcr, X2014abat))

#outer left join stabilized data to pluto data set
pluto_final <- merge(x = pluto_w_viol, y = bblstable, by=c("Borough","Block", "Lot"), all.x = TRUE)

#to export data
write.csv(pluto_final, file = "BBL_data.csv")