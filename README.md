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
	
	- Run `01_create_traces.R` to create the smoothened traces. **NOTE**: This script requires the raw audio data which is not available. This is only used to plot the spectrograms that are shared. Also note that the plotting take a while. You can skip this part as it is not required for the next steps. 

	- Run `02_list_missing_files.R` to list the contact calls that are not in the Luscinia traces file. 
	
	- Then run the code in the `cc` folder to reproduce the results from cross correlation (see supplemental materials):
	
		- Run `00_run_cc.R` to run the cross correlation on the traces. Note that this script runs on 4 threads. This setting can be adjusted. Windows users can only run on a single thread. This creates the RData objects with the results of PCO, PCA and UMAP.
		
		- Run `01_run_models.R` to run the Bayesian multilevel models. This creates the model results for two dimensions from PCO, PCA and UMAP.
		
	- Then run the code in the `dtw` folder to reproduce the results from dynamic time warping (main text):
	
		- Run `00_run_dtw.R` to run dynamic time warping on the traces.  
		
		- Run `01_run_models.R` to run the Bayesian multilevel models. This creates the model results for two dimensions from PCO, PCA and UMAP.
		
	- Then run the code in the `trace measurements` folder to run the measurements on the traces (see supplemental materials):

		- Run `00_measure_traces.R` to run the measurements. This creates `trace_measurements.RData` with the measurements and a pdf with examples. 
		
		- Run `01_run_univariate_models.R` to run the Bayesian multilevel models. This creates the model results for each measurement. 
		
4 . Then run the code in the `spcc` to reproduce the results of spectrographic cross correlation (see supplemental materials):

	- Run `00_create_spec_objects.R` to create the spec objects (modified spectrograms). **NOTE**: This script requires the raw audio data which is not available. This creates `spec_objects - contact 2019.RData` with the spec objects. 
	
	- Run `01_run_spcc.R` to run the actual spectrorgraphic cross correlation. **NOTE**: This step takes a lot of computing power and is best done on a HPC. This script runs on 40 threads. This setting can be adjusted. Windows users can only run on a single thread. This creates `o - contact 2019.RData` with all the distances in a vector. 
	
	- Run `02_prepare_data.R` to prepare the results for the model. This creates the RData objects with the results of PCO, PCA and UMAP.
	
	- Run `03_run_models.R` to run the Bayesian multilevel models. This creates the model results for two dimensions from PCO, PCA and UMAP.
	
5. To plot the final figures run `02_plot_final_figures.R`. 

6. To create the table with sample effort run `03_create_table_effort.R`. 

7. To plot spectrograms of examples of the contact call variants run `04_variants.R`. **NOTE**: This script requires the raw audio data which is not available. 

8. To check if any models had issues fitting the data run `05_run_model_checks.R`. It will output the diagnostics in the console. 
	
9. To reproduce the sensitivity analysis run the code in the `univariate model` folder:

	- Run `00_simulate_clean.R` to simulate data with perfect labelling (individual ID known) and analyse the results with the multilevel Bayesian model. 
	
	- Run `01_simulate_noisy.R` to simulate data with imperfect labelling (individual ID partially unknown) and analyse the results with the multilevel Bayesian model. 
	
	- Run `03_plot_results.R` to plot the results of the sensitivity analysis. 

10. To reproduce the inter-rate reliability analysis run `06_inter_rater_reliability.R` script in the CODE folder. All 1000 files for the sorting were randomly selected. 


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

