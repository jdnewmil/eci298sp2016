# SimpleData1.R

# To build this file
# If you are not already in the main project directory
# setwd('..')
# Once in the main project directory
# setwd('SimpleData1')


# import
dta <- read.csv( "../data/sampledta1/Test1.csv" )

# sample analysis
dta.lm <- lm( Reading ~ Seconds, data = dta )

# text output
summary( dta )  # summarize data
dta.lm # minimal printout
summary( dta.lm ) # more complete printout

# graphical output

# R base graphics... like "painting" on the screen
# plot clears the default graphic device
plot( dta$Seconds, dta$Reading )
# this function paints on top of the graphic device
abline( dta.lm, col = "blue" )

# R lattice graphics... graphs are "objects" that get "printed"
library(lattice)
p <- xyplot( Reading ~ Seconds
           , dta 
           , panel = function( x, y ) {
               panel.xyplot( x, y )
               panel.abline( dta.lm, col = "blue" )
             }
           )
print( p )

# ggplot graphics - like lattice, graphs are "printed", but 
# syntax is different
library(ggplot2)
ggp <- ggplot( dta   # The default data frame to get data from
             , aes( x=Seconds, y=Reading ) # mapping columns to "aesthetics"
             ) + # ggplot objects "add" functions to make new layers or modify existing 
  geom_point() +  # specify point-style geometry
  geom_smooth( method="lm" # smooth = line or curve, method = way to turn data into a line or curve
             , se=FALSE    # don't show uncertainty
             , color = "blue"  # use blue color
             )
print( ggp )

