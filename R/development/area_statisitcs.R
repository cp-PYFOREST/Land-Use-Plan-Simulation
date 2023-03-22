# create a vector of unique combinations of width_paddock and height_paddock
paddock_dims <- expand.grid(width_paddock = 1:4, height_paddock = 1:4)

# create an empty data frame to store the results
results_df <- data.frame()

# loop through each row of the paddock_dims data frame and perform the analysis
for (i in 1:nrow(paddock_dims)) {
  # loop through each property ID
  for (i in 1:nrow(property_dataset)) {
    property_id <- property_dataset$property_id[i]
    
  # Select Property
  property_boundary <- select_property(property_id)
  
  # Riparian Corridor check
  riparian_corridor <- riparian_buffer()
  
  # Input of Paddock and Hedgerow Dimensions
  pad_hedg_dim <- property_dimensions(
    paddock_area = 999000,
    hedgerow_width = 50,
    width_paddock = paddock_dims$width_paddock[i],
    height_paddock = paddock_dims$height_paddock[i],
    tol = 0.01,
    new_dim = NULL,
    max_iter = 500)
  
  # Create Grid & Rotate
  property_grid <- grid_rotate()
  
  # cut grid with river
  property_fragment <- riparian_cut()
  
  # Create Forest Reserve ≥ 25% & \< 28%
  forest_reserve <- reserve()
  
  # Property w/o reserve area
  property_remaining <- no_reserve_area()
  
  # Hedgerows
  hedgerows <- make_hedges()
  #Check for errors
  if(class(hedgerows) == "try-error") {
    hedgerows <- NA
  } else {
    #Cut off buffer that extends over property boundary
    hedge <- st_erase(hedgerows,property_boundary) 
    hedges <- st_difference(hedgerows, hedge)
  }
  
  # Paddocks
  paddocks <- tryCatch(
    make_paddocks(),
    error = function(e) {
      message("Error: ", e$message)
      return(NA)
    }
  )
  
  # If there is a corridor cut edges
  if(is.null(riparian_corridor) == FALSE) {
    riparian_area <- round(st_area(riparian_corridor),2)
    riparian_area_per <-
      (st_area(riparian_corridor) / st_area(property_boundary)) * 100
    final_hedgerow <- st_difference(hedges, riparian_corridor)
    
  } else{
    riparian_area <- NA
    riparian_area_per <- NA
    final_hedgerow <- hedges
  }
  
  # Final Areas
  statistics <- tibble(
    id = property_boundary$cat,
    property_area = st_area(property_boundary) |> drop_units(),
    property_units = 'm^2',
    fr_area = st_area(forest_reserve) |> drop_units(),
    fr_units = 'm^2',
    fr_per = round((st_area(forest_reserve) / st_area(property_boundary)) * 100,2) |> drop_units(),
    paddocks_area = ifelse(is.na(paddocks), NA, round(sum(st_area(paddocks)) / st_area(property_boundary),2)) |> drop_units(),
    paddocks_units = 'm^2',
    paddocks_per = ifelse(is.na(paddocks), NA, round(sum(st_area(paddocks)) / st_area(property_boundary),2)) |>  drop_units(),
    hedgerow_area = ifelse(is.na(final_hedgerow), NA, st_area(final_hedgerow)))
    
    
    # Add column for the current combination of width_paddock and height_paddock
    combinations <- expand.grid(width_paddock = 1:4, height_paddock = 1:4) %>%
      filter(width_paddock <= height_paddock) # only keep unique combinations
    statistics$combination <- NA # initialize new column
    for (i in 1:nrow(combinations)) {
      w <- combinations[i, "width_paddock"]
      h <- combinations[i, "height_paddock"]
      idx <- which(paste0("w", w, "_h", h) == names(statistics))
      statistics$combination[idx] <- paste0("width_paddock = ", w, ", height_paddock = ", h)
    }
    
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
    }
    # add results to the dataframe
    results_df <- rbind(results_df, statistics)
  }
}

# save the final dataframe
saveRDS(results_df, "results.rds")