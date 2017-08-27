# ECI298 Spring 2016 R Notes Day 2 and 3

*Jeff Newmiller*

Materials for describing R for Engineering for a self-study seminar in Programming for Civil Engineers. This is an RStudio project directory, with sub-directories corresponding to two sample analyses and two reference documents.

It is assumed that Day 1 will have covered starting RStudio and basic R syntax.

## Sample Analyses

These form the primary basis for the in-class discussions.

To execute any of the R files in subdirectories, open it in the editor and copy the second setwd function call from near the top (without the # comment symbol) into the Console (lower left pane of RStudio) and press enter. Then, leaving the setwd function call commented out, execute each line in the R file, one at a time. Observe the variables created in the Environment window in the upper right. If you are currently in one of the subdirectories, you need to execute the first setwd function call before you can enter the other subdirectory.

### SimpleData1

This is a very simple analysis that loads a CSV file, performs a linear regression, and exercises various output functions. An RMarkdown presentation file is included that walks through the key points made in this file.

* Packages used: `lattice`, `ggplot2` for the R file. Also `DiagrammeR` and `magrittr` for the Rmd file (optional).

### KernClimate

This is a fairly involved analysis that uses Linear Programming to identify the firm yield for a series of seasonal water flows. The R file forms the *input* and *analysis* phases, and the Rmd file generates output as an HTML file. The problem is a subset of a problem often posed by Dr. Jay Lund at UC Davis.

* Packages used: `ggplot2`, `dplyr`, `lpSolveAPI`, and `tidyr` for the R file. `ggplot2` and `knitr` for the Rmd file.

### Floods

This is a fairly detailed example of a complete analysis with a separate functions file, top-level R file to create global data and results objects (*Input* and *Analysis* phases), and an RMarkdown file that implements the *Output* phase of the analysis. The HTML file is the result.

This code follows the example of the sample Python code provided by Dr. Jon Herman earlier in this course.

* Packages used: `zoo`, `RcppRoll`, `dplyr`, `tidyr`, `ggplot2`.

## Reference Documents

The other three directories contain supporting information.

### QuickHowto1

The QuickHowto1.html file describes how to accomplish several focussed tasks using R.

* Packages used: `ggplot2`, `dplyr` (optional).

### QuickHowto2

The QuickHowto2.html file gives some simplified examples of using the `ave`, `diff` and `cumsum` functions as well as the `tidyr` functions `spread` and `gather`.

* Packages used: `tufte`, `ggplot2`, `dplyr` and `tidyr`.


### Handout1

The Handout1.pdf file is intended to be used as a study "cheat sheet" and notes in printed form.

* Packages used: `tufte`, `knitr`. Also requires a system installation of XeTeX.

### MaskedObjects

This R file provides a guided review of how functions in one package may be
"masked" by functions with the same name in another package, and why this
is not normally a problem but you might need to pay attention to the warnings 
sometimes.

* Packages used: `dplyr`
