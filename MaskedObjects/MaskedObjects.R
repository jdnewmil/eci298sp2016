# Jeanette Newmiller
# May 20, 2016
# Explanation of the "objects are masked" warning message that library() produces 
# Using example from setops{dplyr} help file


# mtcars is one of several datasets supplied in R.
# These datasets are frequently used in the help files to provide
# a common starting point for illustrating the examples.

# Execute each line one at a time, watch in the console and environment to see how R responds.

# First let's see what the given data looks like.
?mtcars # Help file explaining the dataset
mtcars # prints the object "mtcars" to console 
str(mtcars) # prints the structure of the object to the console The first line says this is a data frame
View(mtcars) # opens the data frame in a new tab, this view looks a lot like Excel 

# Modifies "mtcars" and then makes two new data frames from some of the rows in "mtcars"
mtcars$model <- rownames(mtcars) # creates a new column called "model" 
                                 # and fills it with the rownames of the data frame
first <- mtcars[1:20, ]          # rows 1 though 20 of "mtcars" inclusive
second <- mtcars[10:32, ]        # rows 10 through 32 


# If you want, use any of the methods above to look at the three data frames. 
# Now that they appear in the Global Environment in the top right section of RStudio
# you can also look at them by clicking on the triangle or table symbol on 
# the left and right of their name.



# THe following are some set operator functions in base R.
# They happen to be the base R functions that dplyr will mask.
# Execute them one at a time and look at the results in the console. 
intersect(first$model, second$model)    # only the models that exist in both sets

union(first$model, second$model)        # all the models from both sets without 
                                        # duplicating the overlap 

setdiff(first$model, second$model)      # all the models in the first set that are 
                                        # NOT in the second set

setdiff(second$model, first$model)      # likewise all second that are NOT in first


# So those are kind of useful but they only work nicely on vectors and we have three data frames.
# (first$model etc. are vectors in the data frame)
intersect(first, second)    # none of the columns are identical so result is empty
union(first, second)        # all of the columns from both data frames combined into one list.


# So in base R the set oprators act on vectors and when given a data frame
# the columns are each elements in a vector and that vector is the list of columns 



# first go to the console and start typing "intersect"
# you will see the help pop up 
# when you get to intersect note what package is inside the {}
# if you haven't loaded any packages it should say, "intersect() {base}"


# now call dplyr
library(dplyr)
# there's the message about which functions are being masked or covered up by dplyr


# in the console start typing "intersect" again
# note that this time you'll see, "intersect() {dplyr}"
# The {} tells you which package the function is coming from. 


# lets repeat the same set operations above 
# even though the code looks the same and returns the same result (for the vectors) 
# it is now using dlpyr and not base R
intersect(first$model, second$model) # all the models in both sets
union(first$model, second$model) # all the models in both sets without duplicates 
setdiff(first$model, second$model) # all the models in the first set that are NOT in the second set
setdiff(second$model, first$model) # all second that are NOT in first

# Those have the same behavior as before

# the difference is that dplyr is all about data frames 
intersect(first, second)
union(first, second)
setdiff(first, second)

# So in this case the masked functions will work the same way on vectors in both packages
# dplyr just makes them useful to data frames as well.

# If for some reason you want to use some of the functions in a package without 
# masking anything from another package you can always do the other call method like Python.
# You can refer to a masked function the same way.

dplyr::union(first, second)
base::union(first, second)

# nice! :-)
