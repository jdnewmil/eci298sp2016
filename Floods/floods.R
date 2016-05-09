# floods.R

library(dplyr)
library(tidyr)
library(RcppRoll)

# setwd( ".." )
# setwd( "Floods" )

reservoirs <- c( 'FOL', 'ORO', 'SHA' )
start <- as.Date( '2000-10-01' )
stop <- as.Date( '2015-09-30' )
origdtadir <- '../data/floods/original/'
cleandtadir <- '../data/floods/clean/'
ffillcols <- c( "storage", "elevation", "outflow", "inflow", "precip", "evap", "tocs" )

source( "floods_func.R" )

# for testing
# testFOLDF <- readReservoirDaily( "FOL", origdtadir )
# cleanFOLDF <- cleanReservoirDaily( testFOLDF, start, stop, ffillcols )

# for full analysis
floodList <- lapply( reservoirs
                   , function( r ) {
                      DF <- readReservoirDaily( r, origdtadir )
                      cleanReservoirDaily( DF, start, stop, ffillcols )
                     }
                   )
names( floodList ) <- reservoirs

# optional cleaned data output to files
for ( r in reservoirs ) {
  write.csv( floodList[[ r ]], makeReservoirFname( r, cleandtadir ), row.names = FALSE )
}

# reduce test dataset to annual data
# cleanFOLDFA <- (   cleanFOLDF
#                %>% mutate( WaterYear = waterYearFromDate( Dt ) )
#                %>% group_by( WaterYear )
#                %>% summarise( maxInflow = max( inflow ) )
#                %>% ungroup
#                %>% mutate( inflow5 = roll_mean( c( NA, NA, maxInflow, NA, NA )
#                                               , n = 5
#                                               , align = "center"
#                                               , na.rm = FALSE
#                                               )
#                          )
#                %>% as.data.frame
#                )

# create annual processing pipe
crunchA <- (   .
           %>% mutate( WaterYear = waterYearFromDate( Dt ) )
           %>% group_by( WaterYear )
           %>% summarise( maxInflow = max( inflow ) )
           %>% ungroup
           %>% mutate( inflow5 = roll_mean( c( NA, NA, maxInflow, NA, NA )
                                          , n = 5
                                          , align = "center"
                                          , na.rm = FALSE
                                          )
                     )
           %>% as.data.frame
           )

# combine daily values into water annual year maximums
# and add a column indicating which reservoir each row belongs to in preparation
# for combining it into one data frame
floodListA <- setNames( lapply( reservoirs
                              , function( r ) {
                                  floodList[[ r ]] %>% crunchA %>% mutate( Reservoir = r )
                                }
                              )
                      , reservoirs
                      )

floodsDFA <- bind_rows( floodListA )

# stack all data values into one column
#  for all columns not including WaterYear and Reservoir (input columns)
#  put the name of the input column in the column named "variable"
#  put the values from the input column into a column named "value"
floodsDFAlong <- (   floodsDFA
                 %>% gather( variable, value, -c( WaterYear, Reservoir ) )
                 )

logFloodsDFA <- (   floodsDFA
                %>% mutate( logMaxInflow = log( maxInflow ) )
                )

floodsLongTerm <- (   floodsDFA
                  %>% group_by( Reservoir )
                  %>% summarise( MaxRecord = max( maxInflow )
                               , Q100 = estimate100yrFlood( maxInflow )
                               )
        )
