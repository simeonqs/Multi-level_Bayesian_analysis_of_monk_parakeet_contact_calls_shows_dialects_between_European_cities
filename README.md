# Overview

This repo is associated with the following article: 

```
Reference
```
------------------------------------------------

# Reproducing results

To reproduce the results, scripts have to be run in the following order:

1. First create the base data set with `00_create_base_data.R`. This creates the object `base_data_2022_08_17_10_00_03.RData` that contains the basic information for each call. Calls are named with a file name and a selection integer from the selection table. These are concatenated into file_sel.  

2. To produce the distance matrix between parks run `01_dist_parks.R`. This creates the object `dist_parks.RData`. 

3. Then run the code in the `luscinia` folder:

	- Run `00_find_jumps.R` to check if there are any problematic jumps in the traces. 
	
	- Run `01_create_traces.R` to create the smoothened traces. NOTE: This script requires the raw audio data which is not available. This is only used to plot the spectrograms that are shared. Also note that the plotting take a while. You can skip this part as it is not required for the next steps. 

	- Run `02_list_missing_files.R` to list the contact calls that are not in the Luscinia traces file. 
	
	- Then run the code in the `cc` folder to reproduce the results from cross correlation (see supplemental materials):
	
		- Run `00_run_cc.R` to run the cross correlation on the traces. Note that this script runs on 4 threads. This setting can be adjusted. Windows users can only run on a single thread. 
		
		
		
	- Then run the code in the `dtw` folder to reproduce the results from dynamic time warping (main text):
	
		- Run `00_run_dtw.R` to run dynamic time warping on the traces.  

------------------------------------------------

# Requirements


------------------------------------------------

# Meta data



------------------------------------------------

# Session info

R version 4.1.0 (2021-05-18)

Platform: x86_64-apple-darwin17.0 (64-bit)

Running under: macOS Catalina 10.15.7

Packages: 

------------------------------------------------

# Maintainers and contact

Please contact Simeon Q. Smeele, <ssmeele@ab.mpg.de> or Stephen A. Tyndel <stydel@ab.mpg.de>, if you have any questions or suggestions. 

