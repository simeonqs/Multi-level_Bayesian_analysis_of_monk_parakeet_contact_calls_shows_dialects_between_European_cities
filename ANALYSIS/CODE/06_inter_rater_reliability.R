# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: Monk Parakeet Dialect
# Date started: 07-09-22
# Date last modified: 07-09-22
# Author: Stephen Tyndel
# Description: Calculates inter-rater reliability between author (master file) and random observer (irr file)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<< HEAD
=======
library(tidyverse)
library(irr)
###Step 1 read in Simeon's data (double click in owncloud, data)
# Paths
path_base = '/home/styndel/ownCloud/monk_parakeet_dialect/ANALYSIS'

path_functions = 'ANALYSIS/CODE/functions'
random_dat = 'ANALYSIS/RESULTS/sorting spectrograms/observer reliability/random_data_2022_02_23_14_34_40.RData'
base_data = 'ANALYSIS/RESULTS/base_data_2022_08_17_10_00_03.RData'

load(random_dat)
load(base_data)

###Step 2 take two columns from list and add contact/non-contact
simeon_df <- data.frame(index = random_dat[[1]],call_type = random_dat[[7]],row.names = nrow(random_dat[[1]]))

simeon_df <- simeon_df %>% dplyr::mutate(call_type = case_when(call_type == "contact" ~ "contact - typical",
                                                               call_type == "contact - short" ~ "other",
                                                               call_type == "contact - long start" ~ "contact - typical",
                                                               call_type == "contact - low freq" ~ "other",
                                                               call_type == "contact - weird" ~ "other",
                                                               call_type == "contact - split" ~ "contact - typical",
                                                               call_type == "contact - short - ladder" ~ "other",
                                                               call_type == "contact - short - quick" ~ "other",
                                                               !grepl("contact",call_type) ~ "other",
                                                               TRUE ~ as.character(call_type)))


simeon_df <- simeon_df %>% dplyr::mutate(bin_choice = case_when(grepl("contact",call_type) ~ "contact",
                                                                !grepl("contact",call_type) ~ "other"))





simeon_df <- simeon_df[c(1:1000),]

simeon_df$index_match <- seq(1,1000)

simeon_df <- simeon_df %>% arrange(index_match)
###Step 3 read in Nina's file 

nina_df <- data.frame(list.files(path = "/ANALYSIS/RESULTS/sorting spectrograms/observer reliability/master files 2022_02_23_14_34_40_NS",pattern = ".pdf",recursive = T))
nina_df <- nina_df %>% dplyr::rename("data"="list.files.path......ownCloud.monk_parakeet_dialect.ANALYSIS.RESULTS.sorting.spectrograms.observer.reliability.master.files.2022_02_23_14_34_40_NS...")
nina_df <- as.data.frame(str_split_fixed(nina_df$data, "/", 2))
nina_df$V2 <- gsub("\\..*","",nina_df$V2)
nina_df <- nina_df %>% dplyr::rename("index_match" = "V2","call_type" = "V1")
nina_df <- nina_df %>% dplyr::mutate(bin_choice = case_when(grepl("contact",call_type) ~ "contact",
                                                            TRUE~as.character(call_type)))


nina_df$index_match <- as.integer(nina_df$index_match)
class(nina_df$index_match)
nina_df <- nina_df %>% arrange(index_match)


nina_df$file <- random_dat[[3]][c(1:1000)]
nina_df_brussels_hopefully <- nina_df %>% dplyr::filter(call_type == "contact - mix alarm")
###filter simeon's data to only include what Nina's does (should be 1000 rows)

place <- data.frame(file = base_data[[3]],city = base_data[[6]],row.names = nrow(base_data[[1]]))
place <- place %>% distinct(file)




###compares contact and non contact
>>>>>>> d2fd1405b680ceb898ee5a25dd4f901434a38e5a

library(irr)
###Step 1 read in files
master_observer_results <- read.csv("/ANALYSIS/RESULTS/sorting spectrograms/master_observer_results.csv")
irr_observer_results <- read.csv("~/ANALYSIS/RESULTS/sorting spectrograms/irr_observer_results.csv")

#interrater reliability 
#all contact calls (binned into other vs contact)
compare_df <- data.frame(master = master_observer_results$bin_choice, irr = irr_observer_results$bin_choice)
agree_contact <- agree(compare_df)
kappa_contact <- kappa2(compare_df)

#includes all specific types of contact calls 
compare_df2 <- data.frame(master = master_observer_results$call_type, irr = irr_observer_results$call_type)
agree_all <- agree(compare_df2)
kappa_all <- kappa2(compare_df2)



