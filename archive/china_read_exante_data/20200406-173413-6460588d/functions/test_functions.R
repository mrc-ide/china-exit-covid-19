test_movement_rm_dup_cols <- function(movement_data){
  
  num_cols <- ncol(movement_data)
  num_unique_cols <- length(unique(colnames(movement_data)))
  test_equality <- num_cols ==num_unique_cols
  
  if(test_equality == FALSE){
    stop("duplicated data: repeated ID code column name in movement data")
  } 
}
