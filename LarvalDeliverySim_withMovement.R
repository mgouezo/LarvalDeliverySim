# Set working directory
setwd("C://Users/.../")

# Load libraries
library(jsonlite)
library(sf)
library(dplyr)
library(tidyr)
library(purrr)

# Function to calculate the center of a polygon
calculate_center <- function(polygon) {
  centroid <- st_centroid(polygon)
  return(centroid)
}

# Function to process each JSON file
process_json_file <- function(json_file_path, shapefile_path) {
  # Load JSON data
  json_data <- fromJSON(json_file_path)
  
  # Convert to data frame
  data <- as.data.frame(json_data)
  data2 <- unnest(data, features.geometry, names_sep = "_")
  data3 <- unnest(data2, features.geometry_coordinates, names_sep = "_")
  data4 <- unnest(data3, features.properties, names_sep = "_")
  
  # Create separate data frames for longitude, latitude, and depth coordinates
  long_data <- data4[seq(1, nrow(data4), by = 3), c("features.properties_id", "features.geometry_coordinates","features.properties_decay_value","features.properties_time")]
  lat_data <- data4[seq(2, nrow(data4), by = 3), c("features.properties_id", "features.geometry_coordinates")]
  depth_data <- data4[seq(3, nrow(data4), by = 3), c("features.properties_id", "features.geometry_coordinates")]
  
  # Merge the data frames based on the common identifier (features.properties_id)
  merged_data <- cbind(long_data, lat_data,depth_data)
  colnames(merged_data)[1] <- "PartID"
  colnames(merged_data)[2] <- "x"
  colnames(merged_data)[3] <- "decay"
  colnames(merged_data)[4] <- "date_time"
  colnames(merged_data)[6] <- "y"
  colnames(merged_data)[8] <- "depth"
  
  # Define the desired order of columns
  desired_order <- c("PartID", "x", "y", "depth", "date_time")
  columns_to_select <- c("PartID", "x", "y", "depth", "date_time")  # Adjust as needed
  
  # Reorder and select columns in one step
  df <- merged_data[, columns_to_select, drop = FALSE]
  
  # to identify moving and stationary particles
  
  # Haversine function to calculate distance between two points in decimal degrees
  haversine_decimal_degrees <- function(lon1, lat1, lon2, lat2) {
    R <- 6371  # Earth radius in kilometers
    delta_lon <- (lon2 - lon1) * pi / 180
    delta_lat <- (lat2 - lat1) * pi / 180
    a <- sin(delta_lat/2)^2 + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(delta_lon/2)^2
    c <- 2 * atan2(sqrt(a), sqrt(1-a))
    distance <- R * c
    return(distance)
  }
  
  # Calculate distance in decimal degrees between consecutive time points for each particle
  df <- df %>%
    arrange(PartID, date_time) %>%
    group_by(PartID) %>%
    mutate(distance_decdegree = haversine_decimal_degrees(lag(x), lag(y), x, y))
  
  # Create a function to convert decimal degrees to meters
  decimal_degrees_to_meters <- function(decimal_degrees, latitude) {
    # Approximate radius of the Earth in meters
    earth_radius <- 6371000
    # Convert decimal degrees to radians
    radians <- decimal_degrees * (pi / 180)
    # Calculate distance in meters
    distance_meters <- earth_radius * radians
    return(distance_meters)
  }
  
  # Convert distance in decimal degrees to meters
  df$distance_meters <- decimal_degrees_to_meters(df$distance_decdegree, df$y)
  
  # Function to classify movement based on distance
  classify_movement <- function(distance_meters) {
    movement <- ifelse(is.na(distance_meters), "moving",
                       ifelse(distance_meters <= 50, "stationary", "moving"))
    return(movement)
  }
  
  # Add 'movement' variable
  df <- df %>%
    group_by(PartID) %>%
    mutate(movement = classify_movement(distance_meters))
  
  # Extract '06' and '11652' from the JSON filename as DeliveryTime and DeliveryDay
  delivery_time <- substr(json_filename, nchar(json_filename) - 09, nchar(json_filename) - 8)
  delivery_day <- substr(json_filename, nchar(json_filename) - 25, nchar(json_filename) - 21)
  
  # Add columns for DeliveryTime and DeliveryDay
  particles_within_specific_polygon_buffer <- particles_within_specific_polygon_buffer %>%
    mutate(DeliveryTime = delivery_time,
           DeliveryDay = as.numeric(delivery_day))
  
  # Save as .csv
  csv_filename <- sub(".json$", ".csv", json_filename)
  write.csv(particles_within_specific_polygon_buffer, file = csv_filename, row.names = FALSE)
}


#Batch process for One folder

# Folder containing JSON files
json_folder <- "Enter path to .json files here"

# List all JSON files in the folder
json_files <- list.files(json_folder, pattern = "\\.json$", full.names = TRUE)

# Process each JSON file
walk(json_files, ~ process_json_file(.x, "del_liz_PointSourceshp.shp"))

#library(beepr)
beep(sound = "success")

