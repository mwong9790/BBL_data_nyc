#setup environment & install packages
setwd("/Users/miawong/Desktop/Avigail_Data")
install.packages("dplyr")
library("dplyr")
#import datasets
pluto_bbl=read.csv("BBL_data_count_by_BBL.csv")
race = read.csv("ACS_14_5YR_B03002_Race.csv")
income = read.csv("ACS_14_5YR_B19025_agg_income.csv")
nycha = read.csv("COLP_2018.csv")
#edit race to have Borough, CensusTract, and Census Block Group values
race$CT2010pt1 <- as.integer(substr(race$Id2,6,9))
race$dot <- "."
race$CT2010pt2 <- substr(race$Id2,10,11)
race$CT2010 <- paste(race$CT2010pt1,race$dot,race$CT2010pt2,sep="")
race$BoroNum <- as.integer(substr(race$Id2,3,5))
index <- c(61, 5, 47, 81, 85)
values <- c("MN", "BX", "BK", "QN", "SI")
race$BoroughID <- values[match(race$BoroNum, index)]
race$CBlockGroup <- substr(race$Id2,12,12)
race$string <- paste(race$BoroughID,race$CT2010,race$CBlockGroup,sep="")
#edit pluto to have census block group, BoroughID and CT2010 as character
pluto_bbl$CBlockGroup <- substr(pluto_bbl$CB2010,1,1)
index2 <- c(1, 2, 3, 4, 5)
values2 <- c("MN", "BX", "BK", "QN", "SI")
pluto_bbl$BoroughID <-values2[match(substr(pluto_bbl$BBL,1,1), index2)]
pluto_bbl$CT2010 <- as.character(pluto_bbl$CT2010)
#left outer join with race data
pluto_w_race <- left_join(x = pluto_bbl, y = race, by=c("BoroughID","CT2010","CBlockGroup"))
#prepping income
income$CT2010pt1 <- as.integer(substr(income$Id2,6,9))
income$dot <- "."
income$CT2010pt2 <- substr(income$Id2,10,11)
income$CT2010 <- paste(income$CT2010pt1,income$dot,income$CT2010pt2,sep="")
income$BoroNum <- as.integer(substr(income$Id2,3,5))
index <- c(61, 5, 47, 81, 85)
values <- c("MN", "BX", "BK", "QN", "SI")
income$BoroughID <- values[match(income$BoroNum, index)]
income$CBlockGroup <- substr(income$Id2,12,12)
pluto_w_income <- left_join(x = pluto_bbl, y = income, by=c("BoroughID","CT2010","CBlockGroup"))

#combine race & income columns
pluto_race_income=merge(x = pluto_w_race, y = pluto_w_income, by = "BBL", all = TRUE)

#NYCHA, IN USE RESIDENTIAL STRUCTURE only
nycha1 <- subset(nycha,AGENCY=="NYCHA" & USE.CODE==1410, select=c(BOROUGH, TAX.BLOCK, TAX.LOT))

#creating BBL ID
index3 <- c("MANHATTAN", "BRONX", "BROOKLYN", "QUEENS", "STATEN ISLAND")
values3 <- c(1, 2, 3, 4, 5)
nycha1$BoroughID <- values3[match(nycha1$BOROUGH, index3)]
nycha1$BlockID <- sprintf("%05d",nycha1$TAX.BLOCK)
nycha1$LotID <- sprintf("%04d",nycha1$TAX.LOT)
nycha1$BBL <- paste(nycha1$BoroughID,nycha1$BlockID,nycha1$LotID,sep="")
nycha1$nycha <- 'Y'

#creating NYCHA indicator
pluto_race_income$BBL <- as.character(pluto_race_income$BBL)
pluto_all <- left_join(x=pluto_race_income,y=nycha1,by="BBL",all.x=TRUE)
pluto_all_short <- subset(pluto_all,select=c(BBL,CT2010.y,CBlockGroup.x,YearBuilt.x,UnitsRes.x,SUnits_by_bbl.x,HViol_by_bbl.x,Total,White,Black,Native_American,Asian,Hawaiian_or_Pacific_Islander,Latino,Other_Race,Two._Races_NL,Two._Races_not_Other_NL,Three._Races_not_Other_NL,Two._Races_Latino,Two._Races_not_Other_Latino,Three._Races_not_Other_Latino,Agg_HH_Income,nycha))

#renaming
pluto_all_short <- pluto_all_short %>% rename(CT2010 = CT2010.y, CBlockGroup = CBlockGroup.x, YearBuilt=YearBuilt.x,UnitsRes=UnitsRes.x,SUnits=SUnits_by_bbl.x,HViol=HViol_by_bbl.x,TotalRace=Total,TwoRacesNL=Two._Races_NL,TwoRacesNotOtherNL=Two._Races_not_Other_NL,ThreeRacesNotOtherNL=Three._Races_not_Other_NL,TwoRacesL=Two._Races_Latino,TwoRacesNotOtherL=Two._Races_not_Other_Latino,ThreeRacesNotOtherL=Three._Races_not_Other_Latino)

#to export data
write.csv(pluto_all_short, file = "BBL_all.csv")
