# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: Monk Parakeet Dialect
# Date started: 07-09-22
# Date last modified: 07-09-22
# Author: Stephen Tyndel
# Description: Calculates inter-rater reliability between author (master file) and random observer (irr file)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

library(irr)
###Step 1 read in files
master_observer_results <- read.csv("ANALYSIS/RESULTS/sorting spectrograms/master_observer_results.csv")
irr_observer_results <- read.csv("ANALYSIS/RESULTS/sorting spectrograms/irr_observer_results.csv")

#interrater reliability 
#all contact calls (binned into other vs contact)
compare_df <- data.frame(master = master_observer_results$bin_choice, irr = irr_observer_results$bin_choice)
agree_contact <- agree(compare_df)
kappa_contact <- kappa2(compare_df)

#includes all specific types of contact calls 
compare_df2 <- data.frame(master = master_observer_results$call_type, irr = irr_observer_results$call_type)
agree_all <- agree(compare_df2)
kappa_all <- kappa2(compare_df2)



