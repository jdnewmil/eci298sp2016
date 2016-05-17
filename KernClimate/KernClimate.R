# KernClimate.R

library(lpSolveAPI)
library(dplyr)
library(tidyr)

inflowFname <- "../data/KernClimate/KernClimate.csv"
# read first 9 lines to get information about the simulation
inflowhdr <- read.csv( inflowFname
                     , header=TRUE
                     , as.is=TRUE
                     , nrows = 9
                     )

# read remaining lines to get inflow data
inflows <- read.csv( inflowFname
                   , header=FALSE
                   , skip=10
                   )
# Column names in first row actually apply to these columns starting at row 10
names( inflows ) <- names( inflowhdr )
# Give info header table more appropriate column names
names( inflowhdr ) <- c( "Label", "V1", "V2" )

s0 <- inflowhdr$V1[ "CapInitial" == inflowhdr$Label ]  # initial storage

# Water year definition
SeasonIntervals <- read.table( text =
"Season   StartMo  DurationMo CalendarYrOffset
Flood          10           7                0
Irrigation      5           5                1
", header=TRUE, as.is=TRUE )
caps <- (   inflowhdr[ inflowhdr$Label %in% c( "EndCap", "Evap", "Dist", "PumpCoef", "PumpExp" ), ]
        %>% rename( Flood = V1, Irrigation = V2 )
        %>% gather( Season, value, -Label )
        %>% spread( Label, value )
        %>% inner_join( SeasonIntervals, "Season" )
        )

# Constraints
#   206 maximum storage capacity
#       s0 + sum( i_t, 1, k ) - sum( w_t, 1, k ) - sum( evap_t, 1, k ) - sum( Dist, 1, k ) * q <= c
#       or
#       sum( w_t, 1, k ) + sum( Dist, 1, k ) * q >= s0 + sum( i_t, 1, k ) - sum( evap_t, 1, k ) - c
#   206 minimum (0) storage capacity
#       sum( w_t, 1, k ) + sum( Dist, 1, k ) * q <= s0 + sum( i_t, 1, k ) - sum( evap_t, 1, k )
#   1 excess + releases must total less than 
#       or equal to all inflows
#       sum( w_t, 1, n ) + sum( Dist, 1, n ) * q <= sum( i_t, 1, n ) - sum( evap_t, 1, n )
# Variables
#   206 distribution values (firm yield plus spillage)
#   1 annual release value
#

inflowsl <- (   inflows
            %>% gather( Season, Inflow, -WaterYear ) # stack all Inflows together
            %>% inner_join( caps, "Season" ) # line up appropriate rows of caps table
            %>% mutate( Year = WaterYear -1 + CalendarYrOffset ) # identify calendar year for plotting
            %>% arrange( Year, StartMo ) # sort by calendar year/start month
            %>% mutate( CumInflow = cumsum( Inflow ) # cumulative inflow
                      , CumStgMin =  s0 + CumInflow - cumsum( Evap ) # rhs for min storage
                      , CumStgMax =  CumStgMin - EndCap # rhs for max storage
                      , CumDist = cumsum( Dist ) # multiplier for q
                      , EndDate = as.Date( paste( Year + ( StartMo+DurationMo ) %/% 12
                                                , ( StartMo+DurationMo ) %% 12
                                                , 1
                                                , sep="-" 
                                                )
                                         ) - 1
                      )
            )

N <- nrow( inflowsl )
lpmodel <- make.lp( 2 * N + 1
                  , N + 1
                  )

# build first two blocks of equations
for ( seasIdx in seq.int( N ) ) {
    # maximum storage capacity
    set.row( lpmodel
           , row = seasIdx                 # which season
           , xt = c( rep( 1, seasIdx )     # excess multipliers
                   , inflowsl$CumDist[ seasIdx ]     # yield multiplier
                   )
           , indices = c( seq.int( seasIdx )
                        , N + 1
                        )
           )
    # minimum storage capacity
    set.row( lpmodel
           , row = seasIdx + N             # which season
           , xt = c( rep( 1, seasIdx )     # excess multipliers
                   , inflowsl$CumDist[ seasIdx ]     # yield multiplier
                   )
           , indices = c( seq.int( seasIdx )
                        , nrow( inflowsl ) + 1
                        )
           )
}

# overall mass balance (last equation)
set.row( lpmodel
       , row = 2*N + 1                   # constraint
       , xt = c( rep( 1, N )             # excess multipliers
               , inflowsl$CumDist[ N ]   # yield multiplier
               )
       , indices = c( seq.int( N )
                    , N + 1
                    )
       )

# set rhs max storage constraints
set.constr.value( lpmodel
                , rhs = inflowsl$CumStgMax
                , constraints = seq.int( N )
                )
set.constr.type( lpmodel
               , types = rep( ">=", N )
               , constraints = seq.int( N )
               )

# set rhs min storage constraints
set.constr.value( lpmodel
                , rhs = inflowsl$CumStgMin
                , constraints = seq.int( N ) + N
                )
# default type is <=

# set rhs constraints for mass balance
set.constr.value( lpmodel
                , rhs = sum( inflowsl$Inflow )
                , constraints = 2 * N + 1
                )

# set objective coefficients
set.objfn( lpmodel
         , 1
         , indices = N + 1
         )

# set objective direction
lp.control( lpmodel, sense='max' )

# for review
write.lp( lpmodel, 'KernClimate.lp', type = 'lp' )

solve( lpmodel )
#get.objective( lpmodel )
#get.variables( lpmodel )

#' Calculate amount of water in storage at each season
#' 
#' The \code{inflow}, \code{outflow}, and \code{capacity} parameters are
#' vectors with elements corresponding to all of the seasons to be analyzed in order.
#' All should have the same length.
#' 
#' @param initialStorage Numeric scalar, amount of water in reservoir at time 0
#' @param inflow Numeric vector, amount of water entering reservoir in each season
#' @param outflow Numeric vector, amount of water leaving reservoir in each season
#' @param capacity Numeric vector, amount of water reservoir is capable of holding 
#'  in each season
#' @return Numeric vector, amount of water in reservoir at the end of each season corresponding 
#'  to the seasons indicated in the \code{inflow}, \code{outflow}, and \code{capacity} 
#'  parameters.
calcStorage <- function( initialStorage, inflow, outflow, capacity ) {
    result <- rep( NA, length( inflow ) )
    s <- initialStorage
    for ( i in seq_along( inflow ) ) {
        s <- s + inflow[ i ] - outflow[ i ]
        result[ i ] <- max( 0, min( s, capacity[ i ] ) )
    }
    result
}

flowsl <- (   inflowsl
          %>% select( EndDate, Inflow, CumInflow, EndCap, Dist, Evap, Season )
          %>% mutate( Excess = get.variables( lpmodel )[ -( nrow( inflowsl ) + 1 ) ]
                    , Outflow = Excess + Dist * get.objective( lpmodel ) + Evap
                    , Storage = calcStorage( s0, Inflow, Outflow, EndCap )
                    , CumOutFlow = cumsum( Outflow )
                    )
          )

