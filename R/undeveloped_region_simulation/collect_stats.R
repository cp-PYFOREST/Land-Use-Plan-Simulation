## -------------------------------------------------------------------------------------
library(sf)
library(tidyverse)
library(here)
library(units)
library(knitr)
library(flextable)


## -------------------------------------------------------------------------------------
source(knitr::purl(here("R", "load_data.qmd")))


## -------------------------------------------------------------------------------------
source(knitr::purl(here("R", "functions.qmd")))


## -------------------------------------------------------------------------------------
system.time({
  # create a vector of unique combinations of width_paddock and height_paddock
paddock_dims <- expand_grid(width_paddock = 1:4, height_paddock = 1:4)

# create an empty data frame to store the results
results_df <- data.frame()

#  loop through each property ID
for (i in seq_along(limit_lu$cat)) {

 # loop through each row of the paddock_dims data frame and perform the analysis
  for (j in seq_along(paddock_dims$width_paddock)){
    
    w = paddock_dims$width_paddock[j]
    h= paddock_dims$height_paddock[j]

    property_id <- as.integer(limit_lu$cat[i])
    print(paste('current iteration:', i,j, 'ratio',w,'/',h))
  # Select Property
  property_boundary <- select_property(property_id)
  
  # Riparian Corridor check
  riparian_corridor <- riparian_buffer()
  
  # Input of Paddock and Hedgerow Dimensions
  # pad_hedg_dim <- property_dimensions(
  #   paddock_area = 999000,
  #   hedgerow_width = 50,
  #   width_paddock = paddock_dims$width_paddock[j],
  #   height_paddock = paddock_dims$height_paddock[j],
  #   tol = 0.005,
  #   new_dim = NULL,
  #   max_iter = 500)
  
  pad_hedg_dim <- property_dimensions(
    desired_area = 999999,
    hedgerow_width = 100,
    width_paddock = paddock_dims$width_paddock[j],
    height_paddock = paddock_dims$height_paddock[j])
  
  # Create Grid , Rotate, Cut With Property
  property_grid <- grid_rotate()
  
  # Cut Grid w/ River
  property_fragment <- riparian_cut()

  # Create Forest Reserve ≥ 25% & \< 28%
  forest_reserve <- reserve()
  
  # Property w/o reserve area
  property_remaining <- no_reserve_area()

  # Hedgerows
  #Check for errors
  hedgerows <- tryCatch({
    make_hedges()
    },
  error = function(e) {
    message("Error: ", e)
    
    paddocks <- NULL
    final_hedgerow <- NULL
    
    # Final Areas
  statistics <- tibble(
    id = property_boundary$cat,
    ratio_xy = paste(w,'/',h),
    property_area = st_area(property_boundary) |> drop_units(),
    property_units = 'm^2',
    
    
    fr_area = st_area(forest_reserve) |> drop_units() ,
    fr_units = 'm^2',
    fr_per = round((st_area(forest_reserve) / st_area(property_boundary)) * 100,2) |> drop_units() ,
    
    paddocks_area = NA,
    paddocks_units = NA,
    paddocks_per =NA,
    
    hedgerow_area = NA,
    hedgerow_per = NA,
    
    corridor_area = NA,
    corridor_per = NA
    )

  
    
    # Add column for errors in paddocks/hedgerows
    if (is.null(paddocks)) {
      statistics$error_paddocks <- "Unable to create paddocks"
      } else {
      statistics$error_paddocks <- ifelse(sum(is.null(st_length(paddocks))) > 0, "Unable to create multistringlines", NA)
    }
    if(is.null(final_hedgerow)) {
      statistics$error_hedgerow <- "Unable to create hedgerows"
    } else {
      statistics$error_hedgerow <- ifelse(sum(is.null(st_length(final_hedgerow))) > 0, "Unable to create multistringlines", NA)}
      
      results_df <- bind_rows(results_df, statistics)
    return(statistics)
      
      }
  )

        #Cut off buffer that extends over property boundary
  
  if(is.data.frame(hedgerows)){
    results_df <- bind_rows(results_df, hedgerows)
    next
  }
  else{
    hedge <- st_erase(hedgerows,property_boundary) 
    hedges <- st_difference(hedgerows, hedge)
    }
  
  # Paddocks
  paddocks <- tryCatch(
    make_paddocks(),
  error = function(e) {
    message("Error: ", e)
    
    paddocks <- NULL
    final_hedgerow <- NULL
    
    # Final Areas
  statistics <- tibble(
    id = property_boundary$cat,
    ratio_xy = paste(w,'/',h),
    property_area = st_area(property_boundary) |> drop_units(),
    property_units = 'm^2',
    
    
    fr_area = st_area(forest_reserve) |> drop_units() ,
    fr_units = 'm^2',
    fr_per = round((st_area(forest_reserve) / st_area(property_boundary)) * 100,2) |> drop_units() ,
    
    paddocks_area = NA,
    paddocks_units = NA,
    paddocks_per =NA,
    
    hedgerow_area = NA,
    hedgerow_per = NA,

    
    corridor_area = NA,
    corridor_per = NA
    
    )

  
    
    # Add column for errors in paddocks/hedgerows
    if (is.null(paddocks)) {
      statistics$error_paddocks <- "Unable to create paddocks"
      } else {
      statistics$error_paddocks <- ifelse(sum(is.null(st_length(paddocks))) > 0, "Unable to create multistringlines", NA)
    }
    if(is.null(final_hedgerow)) {
      statistics$error_hedgerow <- "Unable to create hedgerows"
    } else {
      statistics$error_hedgerow <- ifelse(sum(is.null(st_length(final_hedgerow))) > 0, "Unable to create multistringlines", NA)}
      
      results_df <- bind_rows(results_df, statistics)
    return(statistics)
      
      }
  )
  
  if(is.data.frame(paddocks)){
    results_df <- bind_rows(results_df, hedgerows)
    next
  }
  else{
   
  # If there is a corridor cut edges
  if(is.null(riparian_corridor) == FALSE) {
    riparian_area <- round(st_area(riparian_corridor),2)
    riparian_area_per <-
      (st_area(riparian_corridor) / st_area(property_boundary)) * 100
    final_hedgerow <- st_difference(hedges, riparian_corridor)
    
  } else{
    riparian_area <- NULL
    riparian_area_per <- NULL
    final_hedgerow <- hedgerows
  }
  }
  
  
  
  
  # Final Areas
  statistics <- tibble(
    id = property_boundary$cat,
    ratio_xy = paste(w,'/',h),
    property_area = st_area(property_boundary) |> drop_units(),
    property_units = 'm^2',
    
    
    fr_area = st_area(forest_reserve) |> drop_units() ,
    fr_units = 'm^2',
    fr_per = round((st_area(forest_reserve) / st_area(property_boundary)) * 100,2) |> drop_units() ,
    
    
    paddocks_area = ifelse(!is.null(paddocks[1]), 
                           sum(st_area(paddocks)), 
                           NA),
    paddocks_units = 'm^2',
    paddocks_per = ifelse(!is.null(paddocks[1]),round(sum(st_area(paddocks)) / st_area(property_boundary)* 100,2),NA),

    
    
    hedgerow_area = ifelse(is.null(final_hedgerow), NA, st_area(final_hedgerow)),
    hedgerow_per = round((st_area(final_hedgerow) / st_area(property_boundary)) * 100,2) |> drop_units(),
    
    corridor_area = riparian_area,
    corridor_per = riparian_area_per
    
    #areas_pads = ifelse(!is.null(paddocks[1]),tibble(st_area(paddocks)),NA)
    )

  
    
    # Add column for errors in paddocks/hedgerows
    if (is.null(paddocks)) {
      statistics$error_paddocks <- "Unable to create paddocks"
    } else {
      statistics$error_paddocks <- ifelse(sum(is.na(st_length(paddocks))) > 0, "Unable to create multistringlines", NA)
    }
    if (is.null(final_hedgerow)) {
      statistics$error_hedgerow <- "Unable to create hedgerows"
    } else {
      statistics$error_hedgerow <- ifelse(sum(is.na(st_length(final_hedgerow))) > 0, "Unable to create multistringlines", NA)
          # add results to the dataframe

    }
  results_df <- bind_rows(results_df, statistics)
  }
}

# save the final dataframe
#saveRDS(results_df, "results.rds")
})


## -------------------------------------------------------------------------------------

results_df <- readRDS(results_df, 'results2.rds')


## -------------------------------------------------------------------------------------
percentages <- results_df |>
  select(-error_paddocks, -error_hedgerow, -corridor_area, -property_area, -property_units, -fr_area, -paddocks_area, -paddocks_units, - hedgerow_area, -fr_units) |>
  drop_units() |> 
  replace_na(replace = list(corridor_per = 0)) |> mutate(sum_percentage = fr_per + paddocks_per + hedgerow_per + corridor_per)
flextable(percentages)


## -------------------------------------------------------------------------------------

read_rds('areas_pads_999999.rds')
read_rds('areas_pads_999.rds')
read_rds('areas_pads_tol005.rds')
paddocks_list <- read_rds('paddocks_df.rds')

#areas_pads
paddocks_list$paddocks_list
#saveRDS(areas_pads_999999,"areas_pads_999999.rds")

