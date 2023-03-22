## ---------------------------------------------------------------------------------------------
library(sf)
library(tmap)
library(tidyverse)
library(here)
library(knitr)


## ---------------------------------------------------------------------------------------------
source(knitr::purl(here("R",'src', "boundary_registry_data.qmd")))
rm(forestry_registry)
#property_boundaries
#forestry_registry


## ---------------------------------------------------------------------------------------------

# Divide  into inactive 

inactive_properties <- property_boundary %>%
  filter(estado  == 1) |> 
  select(id, put_id, anho_capa, estado, cod_dpto, cod_dist) |> 
  mutate(year_inactive = NA, .before = geometry)

# find the inactive properties from subset that interesect the larger dataset
inactive_intersect <- st_intersection(inactive_properties, property_boundary) 

inactive_put_ids <- sort(inactive_properties$put_id)


for (i in inactive_put_ids){
  temp_df <- inactive_intersect %>%
    filter(put_id == i) %>%
    select(put_id, put_id.1, anho_capa, anho_capa.1)
  if(nrow(temp_df) == 1){
    # if there's only one row, use the current year
    inactive_properties <- inactive_properties %>% 
      mutate(year_inactive = ifelse(put_id == i, temp_df$anho_capa, year_inactive))
  } else {
    current_year <- temp_df$anho_capa[1]
    next_year <- min(temp_df$anho_capa.1[temp_df$anho_capa.1 > current_year])
    if (is.infinite(next_year)) {
      # if there's no next higher year, use the current year
      inactive_properties <- inactive_properties %>% 
        mutate(year_inactive = ifelse(put_id == i & is.na(year_inactive), current_year, year_inactive))
    } else {
      inactive_properties <- inactive_properties %>% 
        mutate(year_inactive = ifelse(put_id == i & is.na(year_inactive), next_year, year_inactive))
    }
  }
}

rm(inactive_intersect, temp_df, current_year, i, inactive_put_ids, next_year)


## ---------------------------------------------------------------------------------------------

# Divide  into active 

active_properties <- property_boundary %>%
  filter(estado == 0) |>
  select(id, put_id, anho_capa, estado, cod_dpto, cod_dist) |> 
  mutate(year_inactive = NA, .before = geometry)

active_put_ids <- sort(active_properties$put_id)
active_intersect <- st_intersection(active_properties, property_boundary)
for (i in active_put_ids){
  temp_df <- active_intersect %>%
    filter(put_id == i) %>%
    select(put_id, put_id.1, anho_capa, anho_capa.1)
  if(nrow(temp_df) == 1){
    # if there's only one row, set the year_inactive to 2022
    active_properties <- active_properties %>% 
      mutate(year_inactive = ifelse(put_id == i, 2022, year_inactive))
  } else {
    current_year <- temp_df$anho_capa[1]
    next_year <- min(temp_df$anho_capa.1[temp_df$anho_capa.1 > current_year])
    if (is.infinite(next_year)) {
      # if there's no next higher year, set the year_inactive to 2022
      active_properties <- active_properties %>% 
        mutate(year_inactive = ifelse(put_id == i & is.na(year_inactive), 2022, year_inactive))
    } else {
      active_properties <- active_properties %>% 
        mutate(year_inactive = ifelse(put_id == i & is.na(year_inactive), next_year, year_inactive))
    }
  }
}

active_inactive <- bind_rows(active_properties, inactive_properties)

rm(active_properties,inactive_properties,active_intersect, temp_df, current_year, i, active_put_ids, next_year, property_boundary)





## ---------------------------------------------------------------------------------------------
# 
# t_df <- inactive_active_intersect |> 
#   filter(put_id == 'PUT0003') |> 
#   select(put_id, put_id.1, anho_capa, anho_capa.1) |> 
#   st_drop_geometry()
# current <- t_df$anho_capa[2]
# next_index <- which(temp_df$anho_capa.1 > current_year)[1]
# 
# # find the index of the smallest year greater than the current year
# next_index <- which(temp_df$anho_capa.1 > current_year)[1]
# # get the next year
# next_year <- temp_df$anho_capa.1[next_index]
# inactive_properties['year_inactive'][i] <- next_year

