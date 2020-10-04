library(sf)
library(tidyverse)
library(tmap)


gis <- read_sf("shp_bdry_votingdistricts")
election <- read.csv("ushousepct.txt", sep = ";",
                     col.names = c("State",
                                   "County ID",
                                   "Precinct name",
                                   "Office ID",
                                   "Office Name",
                                   "District",
                                   "Order Code",
                                   "Candidate Name",
                                   "Suffix",
                                   "Incumbent Code",
                                   "Party Abbreviation**",
                                   "Number of Precincts reporting",
                                   "Total number of precincts voting for the office",
                                   "Votes for Candidate",
                                   "Percentage of Votes",
                                   "Total number of votes"))


election.ilhan <- election %>% filter(Candidate.Name == "Ilhan Omar",
                                      Total.number.of.votes > 0)
election.ilhan <- election.ilhan %>% mutate(won = ifelse(Percentage.of.Votes > 50, 1, 0))
gis <- gis %>% mutate(PCTCODE = as.integer(PCTCODE),
                      COUNTYCODE = as.integer(COUNTYCODE))
gis.ilhan <- gis %>% filter(CONGDIST == 5)


data <- left_join(gis.ilhan, election.ilhan,
                  by= c("PCTCODE" = "Precinct.name",
                        "COUNTYCODE" = "County.ID"))
                  


tmap_mode("view")
tm_shape(data) +
    tm_basemap("OpenStreetMap") + 
    tm_polygons(col="Percentage.of.Votes",
                alpha = .8,
                midpoint = 50,
                breaks = seq(0, 100, 10),
                palette = "RdBu")
