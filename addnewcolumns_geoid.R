#setup environment & install packages
setwd("/Users/miawong/Desktop/Avigail_Data")
install.packages("dplyr")
install.packages("stringr")
library("dplyr")
library("stringr")
#import datasets
pluto_bbl=read.csv("BBL_data_count_by_BBL.csv")
race = read.csv("ACS_14_5YR_B03002_Race.csv")
income = read.csv("ACS_14_5YR_B19025_agg_income.csv")
nycha = read.csv("COLP_2018.csv")
#edit pluto_bbl to have geoid values (2 state+ 3 county + 6 tract + 1 block group)
pluto_bbl$state = 36
index2 <- c(1, 2, 3, 4, 5)
values2 <- c("061", "005", "047", "081", "085")
pluto_bbl$Borough <-values2[match(substr(pluto_bbl$BBL,1,1), index2)]
pluto_bbl$tract_temp <- pluto_bbl$CT2010*100
pluto_bbl$tract <- str_pad(pluto_bbl$tract_temp,6,pad="0")
pluto_bbl$BG <- substr(pluto_bbl$CB2010,1,1)
pluto_bbl$Id2 <- paste(pluto_bbl$state,pluto_bbl$Borough,pluto_bbl$tract,pluto_bbl$BG, sep = "")

#left outer join with race data
race$Id2=as.character(race$Id2)
pluto_w_race <- left_join(x = pluto_bbl, y = race, by = NULL, copy =FALSE)
#prepping income
income$Id2 <- as.character(income$Id2)
#combine left join with income data
pluto_race_income <- left_join(x = pluto_w_race, y = income, by = "Id2", copy =FALSE)

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
pluto_all_short <- subset(pluto_all,select=c(BBL,Id2,YearBuilt,UnitsRes,SUnits_by_bbl,HViol_by_bbl,Total,White,Black,Native_American,Asian,Hawaiian_or_Pacific_Islander,Latino,Other_Race,Two._Races_NL,Two._Races_not_Other_NL,Three._Races_not_Other_NL,Two._Races_Latino,Two._Races_not_Other_Latino,Three._Races_not_Other_Latino,Agg_HH_Income,nycha))

#renaming
pluto_all_short <- pluto_all_short %>% rename( GeoID = Id2, TotalRace=Total,TwoRacesNL=Two._Races_NL,TwoRacesNotOtherNL=Two._Races_not_Other_NL,ThreeRacesNotOtherNL=Three._Races_not_Other_NL,TwoRacesL=Two._Races_Latino,TwoRacesNotOtherL=Two._Races_not_Other_Latino,ThreeRacesNotOtherL=Three._Races_not_Other_Latino)

#to export data
write.csv(pluto_all_short, file = "BBL_all_geoid.csv")
