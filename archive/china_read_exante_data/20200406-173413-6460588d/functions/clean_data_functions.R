# check that every unique ID is associated with exactly one province.
# If this is TRUE then the function check_id_uniqueness_province will return 0.

check_id_uniqueness_province <- function(meta_data){
  
  #browser()
  # function which returns TRUE if an ID is associated with exactly one province
  
  number_of_id_recurrances <- function(meta_data, unique_id){
    
    sub_data <- meta_data %>% filter(ID == unique_id)
    
    length(unique(sub_data$province)) == 1
    
  }
  
  meta_id <- unique(meta_data$ID)  # all unique IDs
  
  # apply number of id occurrances over all IDs
  id_unique <- vapply(meta_id, number_of_id_recurrances, meta_data = meta_data, logical(1))
  
  # sum the id unique vector and check equal to length of meta_id vector
  sum(id_unique) == length(meta_id)
  
}



check_id_uniqueness_city <- function(meta_data){
  
  #browser()
  # function which returns TRUE if an ID is associated with exactly one province
  
  number_of_id_recurrances <- function(meta_data, unique_id){
    
    sub_data <- meta_data %>% filter(ID == unique_id)
    
    length(unique(sub_data$city)) == 1
    
  }
  
  meta_id <- unique(meta_data$ID)  # all unique IDs
  
  # apply number of id occurrances over all IDs
  id_unique <- vapply(meta_id, number_of_id_recurrances, meta_data = meta_data, logical(1))
  
  # sum the id unique vector and check equal to length of meta_id vector
  sum(id_unique) == length(meta_id)
  
}

##############################################################################

convert_to_snake <- function(char_vec){
  char_vec %>% tolower() %>% gsub(pattern = " ", replacement = "_")
}

####################################################################################

'# calculate the mean movement by province for where we have only city-level data'
#  I assume that the mean is an appropriate average to use.

# calc_mean_movement <- function(movement_meta_city_df){
#   
#   # calculate mean movement for a single province, single date
#   calc_mean_mov <- function(movement_meta_city_df, province, date){
#     
#     # unable to filter over 'date', unsure why
#     
#     prov <- province
#     yr <- year(date)
#     mth <- month(date)
#     dy <- day(date)
#     
#     prov_date_data <- movement_meta_city_df %>% 
#       filter(province == prov) %>% 
#       filter(year == yr) %>% 
#       filter(month == mth) %>% 
#       filter(day == dy)
#     
#     average_movement <- mean(prov_date_data$movement)
#     
#     prov_date_data[1, ] %>% 
#       select(-c("city", "movement")) %>%
#       bind_cols(movement = average_movement)
#   }
#   
#   #apply over all dates
#   over_date <- function(movement_meta_city_df, province, all_dates){
#     
#     bind_rows(lapply(all_dates,
#                      calc_mean_mov, 
#                      movement_meta_city_df = movement_meta_city_df,
#                      province = province))
#     
#   }
#   
#   # apply over all dates and all provinces
#   over_date_province <- function(movement_meta_city_df, all_provinces, all_dates){
#     
#     bind_rows(
#       lapply(all_provinces,
#              over_date, 
#              movement_meta_city_df = movement_meta_city_df,
#              all_dates = all_dates))
#     
#   }
#   
#   # get all provinces and all dates
#   all_provinces <- unique(movement_meta_city_df$province)
#   all_dates <- unique(movement_meta_city_df$date)
#   
#   # do the calculation
#   
#   ret <- over_date_province(movement_meta_city_df = movement_meta_city_df,
#                             all_provinces = all_provinces,
#                             all_dates = all_dates)
#   
#   
#   # the number of rows of the returned dataframe should be equal to 
#   #  length(all_provinces) * length(all_dates)
#   
#   if(length(all_provinces) * length(all_dates) == nrow(ret)){
#     
#     ret
#   } else {
#     
#     message("returned dataframe has incorrect number of rows")
#   }
#   
# }



calc_mean_movement <- function(movement_meta_city_df){

  # calculate mean movement for a single province, single date
  
  calc_mean_mov <- function(movement_meta_city_df, province, char_date){
    
    # unable to filter over 'date', unsure why
    
    prov <- province
    char_d <- char_date
    
    prov_date_data <- movement_meta_city_df %>% 
      filter(province == prov) %>% 
      filter(char_date == char_d) 
    
    average_movement <- mean(prov_date_data$movement)
    
    prov_date_data[1, ] %>% 
      select(-c("city", "movement", "char_date")) %>%
      bind_cols(movement = average_movement)
  }
  
  #apply over all dates
  over_date <- function(movement_meta_city_df, province, all_dates){
    
    bind_rows(lapply(all_dates,
                     calc_mean_mov, 
                     movement_meta_city_df = movement_meta_city_df,
                     province = province))
    
  }
  
  # apply over all dates and all provinces
  over_date_province <- function(movement_meta_city_df, all_provinces, all_dates){
    
    bind_rows(
      lapply(all_provinces,
             over_date, 
             movement_meta_city_df = movement_meta_city_df,
             all_dates = all_dates))
    
  }
  
  char_date <- as.character(movement_meta_city_df$date)
  movement_meta_city_df <- bind_cols(movement_meta_city_df, char_date = char_date)
  
  # get all provinces and all dates
  all_provinces <- unique(movement_meta_city_df$province)
  all_dates <- unique(movement_meta_city_df$char_date)
  
  # do the calculation
  
  ret <- over_date_province(movement_meta_city_df = movement_meta_city_df,
                            all_provinces = all_provinces,
                            all_dates = all_dates)
  
  
  # the number of rows of the returned dataframe should be equal to 
  #  length(all_provinces) * length(all_dates)
  
  if(length(all_provinces) * length(all_dates) == nrow(ret)){
    
    ret
  } else {
    
    message("returned dataframe has incorrect number of rows")
  }
  
}


calc_weighted_mean_movement <- function(movement_meta_city_df){
  
  # calculate mean movement for a single province, single date
  
  calc_mean_mov <- function(movement_meta_city_df, province, char_date){
    
    # unable to filter over 'date', unsure why
    #browser()
    
    prov <- province
    char_d <- char_date
    
    prov_date_data <- movement_meta_city_df %>% 
      filter(province == prov) %>% 
      filter(char_date == char_d) 
    
    average_movement <- weighted.mean(x = prov_date_data$movement, w = prov_date_data$pop)
    
    prov_date_data[1, ] %>% 
      select(c("date", "id", "month_day", "province", "associated_province_id", "year")) %>%
      bind_cols(movement = average_movement)
    
  }
  
  #apply over all dates
  over_date <- function(movement_meta_city_df, province, all_dates){
    
    bind_rows(lapply(all_dates,
                     calc_mean_mov, 
                     movement_meta_city_df = movement_meta_city_df,
                     province = province))
    
  }
  
  # apply over all dates and all provinces
  over_date_province <- function(movement_meta_city_df, all_provinces, all_dates){
    
    bind_rows(
      lapply(all_provinces,
             over_date, 
             movement_meta_city_df = movement_meta_city_df,
             all_dates = all_dates))
    
  }
  
  char_date <- as.character(movement_meta_city_df$date)
  movement_meta_city_df <- bind_cols(movement_meta_city_df, char_date = char_date)
  
  # get all provinces and all dates
  all_provinces <- unique(movement_meta_city_df$province)
  all_dates <- unique(movement_meta_city_df$char_date)
  
  # do the calculation
  
  ret <- over_date_province(movement_meta_city_df = movement_meta_city_df,
                            all_provinces = all_provinces,
                            all_dates = all_dates)
  
  
  # the number of rows of the returned dataframe should be equal to 
  #  length(all_provinces) * length(all_dates)
  
  if(length(all_provinces) * length(all_dates) == nrow(ret)){
    
    ret
  } else {
    
    message("returned dataframe has incorrect number of rows")
  }
  
}

