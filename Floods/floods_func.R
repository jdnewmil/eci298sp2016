# floods_func.R

library(zoo)

#' Form the name of a daily reservoir flow file
#' 
#' @param r Character scalar, code for reservoir
#' @param dtadir Character scalar, directory path for this file
#' @return Character scalar, name of file containing data for
#'  reservoir "r" 
makeReservoirFname <- function( r, dtadir ) {
  file.path( dtadir, paste0( r, '.csv' ) )
}

#' Read a daily reservoir flow data set
#' 
#' @param r Character scalar, code for reservoir
#' @param dtadir Character scalar, directory path for this file
#' @return Data frame with the following columns at a minimum:
#'  \describe{
#'    \item{datetime}{Character representation of measurement date (YYYY-MM-DD)}
#'    \item{Dt}{Date representation of measurement date}
#'  }
readReservoirDaily <- function( r, dtadir ) {
  DF <- read.csv( makeReservoirFname( r, dtadir ), as.is=TRUE )
  DF$Dt <- as.Date( DF$datetime, format = "%Y-%m-%d" )
  DF
}

#' Clean reservoir daily data
#' 
#' Uses last-observation-carried-forward
#' 
#' @param DF Data frame with Dt column (type Date) and columns
#'  as specified in the ffillcols parameter.
#' @param start Date scalar, earliest date to accept
#' @param stop Date scalar, latest date to accept
#' @param ffillcols Character vector, names of columns to fill missing data in
#' @return Data frame with Dt column and ffillcols columns (missing data filled in)
cleanReservoirDaily <- function( DF, start, stop, ffillcols ) {
  z <- zoo( as.matrix( DF[ , ffillcols ] ), order.by = DF$Dt )
  # fill in missing days
  z <- na.fill( z, "extend" )
  # last output carried forward
  z <- na.locf( z )
  # exclude data not in desired window
  z <- window( z, start = start, stop = stop )
  # Include key in returned data frame
  data.frame( Dt = index( z ), as.data.frame( z ) )
}

#' Determine water year each Date belongs to.
#' 
#' @param Dt Date vector for which water years are desired
#' @return Numeric vector of corresponding water years
waterYearFromDate <- function( Dt ) {
  y <- as.numeric( as.character( Dt, format = "%Y" ) )
  m <- as.numeric( as.character( Dt, format = "%m" ) )
  # ifelse operates on the individual elements of vectors
  ifelse( 10 > m, y, y + 1 )
}

#' Estimate value that 99% of occurrences in lognormal distribution should be less than
#' 
#' @param v Numeric vector of values
#' @return Numeric scalar value for which 99% of values should be less
estimate100yrFlood <- function( v ) {
  lv <- log( v )
  qlnorm( 0.99, meanlog =  mean( lv ), sdlog = sd( lv ) )
}
