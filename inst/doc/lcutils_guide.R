## ----setup, include = FALSE---------------------------------------------------
library(lcutils)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----fig.show='hold'----------------------------------------------------------
library(terra)
t1 <- rast(nrows=50, ncols=50)
values(t1) <- sample(1:4, ncell(t1), replace=TRUE)
t2 <- rast(nrows=50, ncols=50)
values(t2) <- sample(2:6, ncell(t2), replace=TRUE)

rstack <- c(t1, t2) # combine into a multi-layer SpatRaster object

plot(t1, main="t1")
plot(t2, main="t2")

## -----------------------------------------------------------------------------
vals <- unique(as.vector(values(rstack)))
print(vals)

lut <- data.frame(id = vals,
                  class = c("Water", "Soil", "Forest", "Grassland", "Agri", "Wetland"),
                  mycolours = viridis::viridis(6))
print(lut)

## ----eval=FALSE---------------------------------------------------------------
#  new_lut <- data.frame(id = 1:7, # 7 will become NA value!
#                    class = c("Water", "Soil", "Forest", "Grassland", "Agri", "Wetland", "NoData"),
#                    mycolours = viridis::viridis(7)) # need 7 colours now
#  
#  diagrams <- alluvial_pairs_diagram(raster = rstack, lookup = new_lut, naValue = 7)

## ----fig.show='hold', warning=FALSE-------------------------------------------
diagrams <- alluvial_pairs_diagram(raster = rstack, lookup = lut)
plot(diagrams[[1]])

