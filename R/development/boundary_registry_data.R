## ------------------------------------------------------------------------
library(sf)
library(here)
library(knitr)


## ------------------------------------------------------------------------
# property_limit <- st_read(dsn = "/capstone/pyforest/data/Permited_Land_Use/limite_put.shp")


## ------------------------------------------------------------------------
property_boundary <- st_read(dsn = "/capstone/pyforest/data/Permited_Land_Use/limite_put.shp") 

# 
# land_registry <- st_read(dsn = "/capstone/pyforest/data/Permited_Land_Use/catastro_forestal.shp") 
# st_crs(land_registry$geometry) <- 32721



## ------------------------------------------------------------------------
forestry_registry <- st_read(dsn = "/capstone/pyforest/data/Permited_Land_Use/catastro_forestal.shp") 

