

############################################################################
# reading in the movement data and putting into long tidydata format
###########################################################################

# path <- "full_data_china_intracity_mobility.xlsx"
path <- "full_data_20200325.xlsx"


# read in China data to match names
china_new_case_data <- read.csv("china_new_case_data.csv")
china_data_province_names <- colnames(china_new_case_data)


##########################################################################
# movement data
##########################################################################

movement_data <- read_excel(path = path,
                            sheet = "data",
                            col_names = TRUE,
                            .name_repair = "minimal")

duplicated_cols <- which( duplicated(colnames(movement_data)))
if(length(duplicated_cols) > 0) {movement_data <- movement_data[ , -duplicated_cols]} 

colnames(movement_data)[1] <- "date"
movement_data$date <- date(movement_data$date)

test_movement_rm_dup_cols(movement_data)


# convert data to long form and create month and day only column

movement_data <- movement_data %>% 
  pivot_longer(cols = colnames(select(movement_data, -c("date"))), names_to = "id", values_to = "movement") %>%
  mutate( month_day = format(date, "%m-%d"))
movement_data$id <- as.numeric(movement_data$id)



############################################################################
# read in meta data
############################################################################

meta_data <- read_excel(path = path,
                        sheet = "metadata")

# renaming columns and deleteing Chinese character columns
meta_data <- meta_data %>% clean_names %>%
  select(c("id", "city_english", "province_english")) %>%
  rename( city = city_english, province = province_english)

#  convert all character vectors to snake_case
meta_data$province <- convert_to_snake(meta_data$province)
meta_data$city <- convert_to_snake(meta_data$city)

# remove duplicated rows based on ID code
duplicated_rows <- which( duplicated(meta_data$id))
if(length(duplicated_rows) > 0) {meta_data <- meta_data[-duplicated_rows, ]} 


# check for missing data
sum(is.na(meta_data))

############################################################################
# meta data by province
############################################################################

# to get the province IDs we are looking for '[0-9][0-9]0000' form of ID code
# we can divide all ID codes by 10000, floor them, then multiply back by 10000
#  to obtain the province ID codes as a numeric vector
province_ids <- unique(floor(meta_data$id/10000)*10000)

province_meta_data <- meta_data %>%
  filter(id %in% province_ids)  %>%
  mutate(associated_province_id = id)

sum(is.na(province_meta_data))


# note that the province name is listed under the city column only for 
#  province-level data so fix the data

province_meta_data <- province_meta_data %>%
  select(c(id, city, associated_province_id)) %>%
  rename(province = "city")

sum(is.na(province_meta_data))




#  need to match column names to those in the incidence data
# find which provinces in the China case data do not have a match in the movement data

china_data_province_names[which(!(china_data_province_names %in% province_meta_data$province))]

#####
# make any necessary corrections to the province metadata

province_meta_data$province[which(!(province_meta_data$province %in% china_data_province_names))]

province_meta_data$province <- recode(province_meta_data$province, 
                                      "hong_kong" = "hong_kong_sar",
                                      "macao" = "macau_sar")

#####

# check that the meta data now matches the china case data
china_data_province_names[which(!(china_data_province_names %in% province_meta_data$province))]

############################################################################
# meta data by city
############################################################################
# as data not clean, easier to use the unique ID code to get the associated province.
#  first remove province column from the city data, then join up the table of 
#  provinces by province ID code

city_meta_data <- meta_data %>%
  filter(!(id %in% province_ids)) %>%
  select(-c("province"))

associated_province_id <- floor(city_meta_data$id/10000)*10000

city_meta_data <- city_meta_data %>% bind_cols(associated_province_id = associated_province_id) %>%
  left_join(province_meta_data %>% select(c(associated_province_id, province)), by = "associated_province_id" ) %>%
  select(-c(associated_province_id))

# check for missing data
sum(is.na(city_meta_data))

####################################################################
# join up city meta data and province meta data
###################################################################

meta_data <-   province_meta_data %>% bind_cols(city = rep(NA, length.out = nrow(province_meta_data))) %>%
  select(-c(associated_province_id)) %>%
  bind_rows(city_meta_data)


#####################################################################
# join up the province meta data and the city meta data
#####################################################################


# check that every ID code within the movement data is also in the metadata

mov_id <- unique(movement_data$id)
meta_id <- unique(meta_data$id)

which(mov_id %in% meta_id == FALSE) # gives all entries from mov_id that do not appear in meta_id


# the movement data is some by province and some by city. 
# need to check that no province is include as both aggregate and as at city level 
#  as this could make our averages (to come later) wrong. 

# find which movement data which is recorded by province
recorded_by_province <- province_meta_data %>% filter(province_meta_data$id %in% mov_id)
recorded_by_city <- city_meta_data %>% filter(city_meta_data$id %in% mov_id)

# check that the sets are mutually exclusive, so if movememnt data is given by 
#  province then it is not also given by city and vice versa
sum(recorded_by_province$province %in% recorded_by_city$province)
sum(recorded_by_city$province %in% recorded_by_province$province)


# create a dataframe of the recorded by province data
# take the movement by province data and join it with the province meta data
movement_province_data <- movement_data %>% filter(id %in% recorded_by_province$id)
movement_meta_province_data <- movement_province_data %>% left_join(province_meta_data, by = c("id" = "id"))





#####################################################################
# calculate the province average for those in city data
####################################################################


# create a dataframe of the recorded by city data
# take the movement by city data and join it with the province meta data
# also remove any duplicted rows using 'distinct'
movement_city_data <- movement_data %>% filter(id %in% recorded_by_city$id)

movement_meta_city_data <- movement_city_data %>% 
  left_join(city_meta_data, by = c("id" = "id")) 



# now we need to take the mean movement value for each province by date.
# this is uniform wieghted mean
mean_movement <- calc_mean_movement(movement_meta_city_data)

# now join up the two dataframes with movement at province-level:
# mean_movement and movement_meta_province_df

movement_province_level <- bind_rows(mean_movement, 
                                     movement_meta_province_data %>% select(-c(associated_province_id)))

movement_province_level <- movement_province_level %>% bind_cols(year = as.character(year(movement_province_level$date)))




#############################################################
# population weighted mean for top 6 provinces
#############################################################

city_population_size_data <- read_excel(path = "top_six_provinces_population_size.xlsx",
                                        col_names = TRUE)

city_population_size_data <- city_population_size_data %>%
  clean_names() %>%
  select(c(id, province, pop))

city_population_size_data$province <- convert_to_snake(city_population_size_data$province)

top_six_province_ids <- floor(city_population_size_data$id/10000)*10000

city_population_size_data <- city_population_size_data %>%
  mutate(associated_province_id = top_six_province_ids)

movement_data_subset <- movement_data %>% filter( id %in% unique(city_population_size_data$id)) 
movement_data_subset <- bind_cols(movement_data_subset, year = as.character(year(movement_data_subset$date)))


movement_meta_data_subset <- movement_data_subset %>% left_join(city_population_size_data)


weighted_data <- calc_weighted_mean_movement(movement_meta_city_df = movement_meta_data_subset)
weighted_data <- weighted_data %>% select(c(date, id, month_day, province, movement, year))


#############################################################

top_six_beijing_hk <- movement_province_level %>% 
  filter(province %in% c("beijing", "hong_kong_sar")) %>% 
  bind_rows(weighted_data)


#############################################################
# files to write out
#############################################################

saveRDS(movement_province_level, "exante_movement_data.rds")
write.csv(movement_province_level, "exante_movement_data.csv")


saveRDS(weighted_data, "top_six_pop_weighted_exante_movement_data.rds")
write.csv(weighted_data, "top_six_pop_weighted_exante_movement_data.csv")

# check the correct dataframe is being saved here
saveRDS(top_six_beijing_hk, "movement_province_level_subset.rds")
write.csv(top_six_beijing_hk, "movement_province_level_subset.csv")



