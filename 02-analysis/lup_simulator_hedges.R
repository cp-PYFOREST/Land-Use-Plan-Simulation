
select_property <- function(property_cat) {
  #property_cat <- as.character(property_cat)
  #property_cat <- paste0('0', property_cat)
  
  
  if (property_cat %in% limit_lu$cat) {
    boundary <- limit_lu |>
      filter(cat == property_cat)
  }else{
      message('ID not found')
    return(NULL)
  }
}
    
  



riparian_buffer <-
  function(boundary_property = property_boundary,
           hydrology = hydro) {
 # check if there's is river crossing property and subset
    if (lengths(st_intersects(boundary_property, hydrology)) > 0) {
      riparian <- st_intersection(hydrology, boundary_property) |>
        st_make_valid() 
  
      return(riparian)
      
    } else{
      return(NULL)
    }
  }





# 
property_dimensions <- function(desired_area = 999000 ,
                        hedgerow_width = 100,
                        width_paddock = 1,
                        height_paddock = 1) {
    width_paddock <- as.integer(width_paddock)
    height_paddock <- as.integer(height_paddock)
  #Dimensions

 

  # Aspect Ratio (from square to rectangle)
  ratio_x <- c(1,2,3,4)
  ratio_y <- c(1,2,3,4)

  if(width_paddock %in% ratio_x & height_paddock %in% ratio_y){
  y <- sqrt(desired_area / (ratio_x[width_paddock]/ratio_y[height_paddock])) + (hedgerow_width)

  x <- sqrt(desired_area * (ratio_x[width_paddock]/ratio_y[height_paddock])) + (hedgerow_width)

  x_y <- tibble(x, y)

  return(x_y)
  }else{
    print('INVALID RATIO OF WIDTH TO HEIGHT')
  }

}




grid_rotate <-
  function(boundary_property = property_boundary,
           x_y = pad_hedg_dim) {
    coords_df <- st_coordinates(boundary_property)
    number_col <- ncol(coords_df)
    x1 <- coords_df[1, 1]
    y1 <- coords_df[1, 2]
    x2 <- coords_df[2, 1]
    y2 <- coords_df[2, 2]

    
    
    # calcualte the angle in radians and the trasformate to degrees
    angle_r <- atan2(y2 - y1, x2 - x1)
    #angle_r <- atan2(height, base)
    angle <- 90 + ((angle_r * (180 / pi)) * -1)

    
    
    inpoly <- boundary_property |>
      st_geometry()
    rotang = angle 
    
    
    
    rot = function(a)
      matrix(c(cos(a), sin(a), -sin(a), cos(a)), 2, 2)
    
    
    
    tran = function(geo, ang, center)
      (geo - center) * rot(ang * pi / 180) + center
    
    center <- st_centroid(st_union(boundary_property))

    grd <-
      sf::st_make_grid(tran(inpoly, -rotang, center),
                       cellsize = c(x_y[[1]], x_y[[2]]),
                       n = 50)
    
    
    
    grd_rot <- tran(grd, rotang, center) |> st_set_crs("EPSG:32721")
    

    
    
    
    test_rot <-  st_intersection(grd_rot, boundary_property)
    return(test_rot)
  }





riparian_cut <- function(rip_corr = riparian_corridor, prop_gr = property_grid) {
  # Using riparian corridor cut the property fragments
  if (is.null(rip_corr)) {
    return(prop_gr)
  } else{
    prop_frag_rip <-
      st_difference(prop_gr, rip_corr) |> st_cast(to = 'MULTIPOLYGON') |> st_cast(to = 'POLYGON')
    return(prop_frag_rip)
  }
}



make_hedges <- function(fragment = property_remaining) {

  fragment <- fragment[!st_geometry_type(fragment) %in% c("POINT")]  
  
  fragment <- fragment |> st_cast(to= 'MULTILINESTRING') |> st_make_valid() 
  
  hedge <- st_buffer(fragment, dist = 50, nQuadSegs = 60)  |>  st_as_sf() |> st_make_valid()  |>  st_union() 
  
  
  return(hedge)
}    




reserve <- function(grid = paddocks , hedge_per = hedgerow_per, boundary_property = property_boundary ) {
  paddock_sf <- st_as_sf(grid)
  
  cell_areas <- paddock_sf |>
    mutate(cell_area = st_area(paddock_sf))
  
  n <- 1
  repeat {
    forest <-  cell_areas %>%
      arrange(cell_area) %>%
      head(n)
    
    area_check <-
      sum((st_area(forest) / sum(st_area(boundary_property))) * 100) + hedge_per
    
    if (area_check >= set_units(25, 1)) {
      break
    }
    n <- n + 1
  }
  forest <- st_union(forest)
  
  return(forest)
  
}








no_reserve_area <- function(grid_property = property_fragment,
                            fr_union = forest_reserve){
  #remaining property without forest reserve
  #grd_sf <- st_as_sf(grid_property)
  #fr_sf <- st_as_sf(fr_union)
  remaining_property <- st_difference(grid_property, fr_union)
  

}



reserve_with_hedgerows <-
  function(frag = property_fragment,
           limits = property_boundary,
           pre_hedge =  hedges) {
    # Calculate the area of the hedgerows
    hedgerows_area <- sum(st_area(pre_hedge))
    
    # Adjust the desired area for forest reserve
    desired_reserve_area <-
      ((0.25 * st_area(limits)) - hedgerows_area) |> drop_units()
    
    
    
    # Create forest reserve with the adjusted desired area
    grid_boundary_sf <- st_as_sf(frag)
    
    cell_areas <- grid_boundary_sf |>
      mutate(cell_area = st_area(grid_boundary_sf))
    
    n <- 1
    repeat {
      forest2 <-  cell_areas %>%
        arrange(cell_area) %>%
        head(n)
      
      area_check <-
        sum((st_area(forest2) / sum(st_area(limits))) * 100)  +  set_units(desired_reserve_area,1)
      
      if (area_check >= set_units(25, 1)) {
        break
      }
      n <- n + 1
      
    }
    return(forest2)
  }



st_erase = function(x, y) st_difference(x, st_union(st_combine(y)))

