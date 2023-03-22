## -------------------------------------------------------------------------------------
library(sf)
library(tmap)
library(tidyverse)
library(here)
library(knitr)
library(mapview)


## -------------------------------------------------------------------------------------

#ource(knitr::purl(here("R",'src', "collect_stats.qmd")))
#source(knitr::purl(here("R",'src', "boundary_registry_data.qmd")))


## -------------------------------------------------------------------------------------

undeveloped_region <- st_read('/capstone/pyforest/data/undeveloped_region/expansion3.shp')

#st_crs(undeveloped_region) <- "+proj=utm +zone=21 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs"


dist_filadelphia <- st_read('/capstone/pyforest/data/dist_filadelphia/dist_filadelphia.shp')

hydro <- st_read(here('/capstone/pyforest/data/roads_hydrology/ly_hid2.shp'))  
st_crs(hydro) <- "+proj=utm +zone=21 +south +ellps=WGS84 +datum=WGS84 +units=m +no_defs"



## -------------------------------------------------------------------------------------
#tmap_mode('view')
#tmap_options(check.and.fix = TRUE)
#tm_shape(undeveloped_region) +
#  tm_fill(col = 'red')


## -------------------------------------------------------------------------------------

limit_lu <- st_intersection(dist_filadelphia, undeveloped_region ) |>
  mutate(cat = as.character(1:61)) |>
  select(cat)





## -------------------------------------------------------------------------------------
tm_shape(limit_lu) +
  tm_borders(col = 'red')


## -------------------------------------------------------------------------------------
# system.time({
#   source(knitr::purl(here("R",'src', "forest_cover_vars.qmd")))
# }) 

#districts <- st_read('/capstone/pyforest/data/Political_Boundaries/distritos.shp') |>
#  st_make_valid()

#departments <- st_read('/capstone/pyforest/data/Political_Boundaries/departamento.shp') |>
#  st_make_valid()

#wildlife_protected <- st_read('/capstone/pyforest/data/Wildlife_Protection_Areas/ASP_ROCC.shp')

#certificadas <- st_read('/capstone/pyforest/data/Certificadas/certificadas.shp')

#indigenous_land <- st_read('/capstone/pyforest/data/Indigenous_Land/native_land.shp')



## -------------------------------------------------------------------------------------
#departments <- departments |> 
#  filter(id %in% c(15,16,17)) 

#districts <- districts |>
#  filter(cod_dpto %in% c('P', 'Q', 'R'))

#dist_filadelphia <- districts |>
#  filter(codigo %in% c('Q05'))

# paraguay_study_area <- st_union(departments, is_coverage = TRUE) |> 
#   st_as_sf()



#mapview(dist_filadelphia)
#tmap_mode('view')
#tmap_options(check.and.fix = TRUE)
#tm_shape(districts) +
#  tm_sf() 
#  tm_shape(ai_1920) +
#  tm_sf()

#st_write(dist_filadelphia, 'dist_filadelphia.shp')


## -------------------------------------------------------------------------------------
#tm_shape(wildlife_protected2) +
#  tm_sf()


## -------------------------------------------------------------------------------------
# The average property size for active properties in 2020
#average_property <- study_properties_1920 |> 
#  mutate(area = )


## -------------------------------------------------------------------------------------
#active_inactive_0005 <- active_inactive |> 
#  filter(year_inactive <= 2005)


## -------------------------------------------------------------------------------------
#registered_filadelphia <- limit_lu |> 
#  filter(cod_dist == 5) |> 
#  filter(cod_dpto == 'Q')


## -------------------------------------------------------------------------------------
#https://gis.stackexchange.com/questions/375345/dividing-polygon-into-parts-which-have-equal-area-using-r



# library(mapview)
# library(dismo)
# library(osmdata)  
# library(mapview)
# split_poly <- function(sf_poly, n_areas){
# # create random points
# points_rnd <- st_sample(sf_poly, size = 10000)
# #k-means clustering
# points <- do.call(rbind, st_geometry(points_rnd)) %>%
#   as_tibble() %>% setNames(c("lon","lat"))
# k_means <- kmeans(points, centers = n_areas)
# # create voronoi polygons
# voronoi_polys <- dismo::voronoi(k_means$centers, ext = sf_poly)
# # clip to sf_poly
# crs(voronoi_polys) <- crs(sf_poly)
# voronoi_sf <- st_as_sf(voronoi_polys)
# equal_areas <- st_intersection(voronoi_sf, sf_poly)
# equal_areas$area <- st_area(equal_areas)
# return(equal_areas)
# }


## -------------------------------------------------------------------------------------
# This is a script that approximates the fractions, it has a great field for optimization. It only does horizontal cutting, not in an oriented bounding box. In the porcientos argument you may put as many values as you like, it is not only for halves (c(.5,.5), this means c(.4, .3, .2, .1) would be a valid vector as well.

# library(units)
# library(sf)
# library(dplyr)
# library(osmdata)
# 
# pol <- osmdata::getbb("aguascalientes", format_out = "sf_polygon") 
# porcientos <- c(.5,.5) # the half argument
# 
# polycent <- function(poly, porcientos) {
#   df   <- st_sf(id = 1:length(porcientos), crs = 4326, # empty sf for populating
#                 geometry = st_sfc(lapply(1:length(porcientos), function(x) st_multipolygon())))
#   area1 <- st_area(poly) %>% sum() # st_area takes multipolygons as one; # area1 is constant
#   poly2 <- poly # duplicating for the final cut
#   for(j in  seq_along(porcientos[-length(porcientos)])) { 
#     bb = st_bbox(poly2)
#     top <- bb['ymax']
#     bot <- bb['ymin']
#     steps <- seq(bot, top, by = (top - bot) / 80)
#     for(i in steps[2:length(steps)]) {  # 2:n because 1:n renders a line "ymax" = "ymin"
#       bf <- bb
#       bf['ymax'] = i
#       temp <- st_intersection(poly, st_as_sfc(bf, 4326))
#       area2 <- st_area(temp) %>% sum()           # con get(.., i) coz st_area prints rounded
#       if(drop_units(area2)/drop_units(area1) >= porcientos[j]) break
#       df$geometry[j] <- st_geometry(temp)
#     }
#     poly2 <- st_difference(poly2, st_union(df))
#   }
#   df$geometry[length(porcientos)] <- st_geometry(st_difference(poly, st_union(df)))
#   poly <- df
# }


## -------------------------------------------------------------------------------------

# Create a dataset of sfc cells using st_make_grid
#bbox <- st_bbox(c(0, 0, 10, 10))
#grid_size <- c(2, 2)
#grid <- st_make_grid(bbox, cellsize = c(diff(bbox[c(1, 3)]) / grid_size[1],
#                                         diff(bbox[c(2, 4)]) / grid_size[2]))


