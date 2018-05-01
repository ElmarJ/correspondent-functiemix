library(dplyr)
library(tidyr)
library(tictoc)

path_prefix <- "Datasets/12. Financiële verantwoording voor 2012"
path_suffix <- "csv-bestanden" 
education_types <- c("PO", "VO", "BVE", "HBO", "WO")

# Sub-directories of path_prefix
origin_years <- c("2006-2010", "2007-2011", "2008-2012",
                  "2009-2013", "2010-2014", "2011-2015")

# Two sets of data do not seem to be in sta
# Needs special treatment:
exception_1 <- "2010-2014/BVE"
replacement_1 <- "2010-2014/BVE/BVE-Versie 2"

exception_2 <- "2011-2015/VO"
# Note: do not know how to handle this exception.

# Define vector with column names that identify a row.
# De overige kolomnamen in de .csv bestanden kunnen verschillend zijn.
# Daarom reshape ik de ingelezen data van wide naar long formaat.
colnames_common <- c("BEVOEGD.GEZAG.NUMMER", "GROEPERING", "BEVOEGD.GEZAG.NAAM", "JAAR")

# Create dataframe to store file ID's (so we can later see
# where value was obtained, e.g. if there are multiple versions
# of the same file).
dat_files <- data.frame(file_id = NULL, filename = NULL, status = NULL)

tic("Reading all data")
for (tmp_origin_year in origin_years) {
  tic("Reading origin year data")
  
  # Start each origin year with a clean dataset for memory efficiency.
  dat <- NULL
  cat("Year: ", tmp_origin_year, "\n")
  for (tmp_education_type in education_types) {
    
    cat("  Year: ", tmp_origin_year, ", Education: ", tmp_education_type, "\n")
    
    tmp_path <- paste(path_prefix, tmp_origin_year, tmp_education_type, path_suffix, sep ="/")
    if (paste(tmp_origin_year, tmp_education_type, sep ="/") == exception_1) {
      tmp_path <- paste(path_prefix, replacement_1, path_suffix, sep ="/")
    }
    if (paste(tmp_origin_year, tmp_education_type, sep ="/") == exception_2) {
      cat("skipping exception 2: ", exception_2, "\n")
    }
    
    tmp_lst_files <- dir(tmp_path, full.names = TRUE)
    
    for (tmp_file in tmp_lst_files) {
      cat("    File: ", tmp_file, "\n")
      
      if (as.numeric(substr(basename(tmp_file), 1, 2)) > 15) {
        cat("Filename does start with [01], ..., [15], skipping this file\n")
      
        tmp_file_id <- nrow(dat_files) + 1
        dat_files <- rbind(
          dat_files,
          data.frame(
            "file_id"   = tmp_file_id,
            "file_name" = tmp_file,
            "status"    = "skipped"))
        
      }
      else {
        tmp_file_id <- nrow(dat_files) + 1
        dat_files <- rbind(
          dat_files,
          data.frame(
            "file_id"   = tmp_file_id,
            "file_name" = tmp_file,
            "status"    = "included"))
        
        tmp_dat_wide <- read.csv(tmp_file, stringsAsFactors = FALSE, sep = ";")
        
        # Substitute '..' with '' in variables names.
        colnames(tmp_dat_wide) <- gsub("\\.\\.", "", colnames(tmp_dat_wide))
        
        tmp_dat <- tmp_dat_wide %>% 
          gather_(key_col = "variable", 
                  value_col = "value", 
                  gather_cols = setdiff(colnames(tmp_dat_wide), colnames_common))
        
        tmp_dat$origin_year <- tmp_origin_year
        tmp_dat$file_id <- tmp_file_id
        
        # Drop NA values to save space.
        tmp_dat <- tmp_dat %>% filter(!is.na(value))
        
        # Keep only relevant columns.
        # I.e. drop BEVOEGD.GEZAG.NAAM
        tmp_dat <- tmp_dat %>%
          dplyr::select(
            file_id,
            origin_year,
            BEVOEGD.GEZAG.NUMMER,                                             
            JAAR,
            variable,
            value)
        
        # Append data to all data.
        dat <- rbind(dat, tmp_dat)
      }
    }
  }
  
  # Save intermediate results.
  write.csv(x = dat,
            file = paste0("use/financial_data_", tmp_origin_year, ".csv"),
            row.names = FALSE)
  toc()
}
toc()
