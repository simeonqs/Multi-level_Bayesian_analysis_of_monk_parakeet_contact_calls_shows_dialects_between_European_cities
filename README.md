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

To run the Bayesian models *Stan* needs to be installed. This is not an R package, but *Stan* can be run from R. For installation see: https://mc-stan.org/users/interfaces/. 

The R code requires three libraries: *cmdstanr* to run the Stan engine, *scales* for transparent colours and *knitr* for the compilation of the pdf. All three can be installed from CRAN. To finish installing *cmdstanr* see: https://mc-stan.org/cmdstanr/. 

All other packages will be automatically installed when running the R scripts. 

------------------------------------------------

# Meta data

- .gitignore
	- the invisible file telling git which files should not be synced (large or useless files)
- README
	- the file you are reading now, everything that you need to know, or at least as much as we remembered to document
	
- ANALYSIS/CODE
	- the folder with all scripts needed to reproduce the results, note that each script has a description in the header, for details see also "Reproducing results" in the README, see below for the files not explicitly described in that section
	
- ANALYSIS/CODE/functions
	- the folder with all home-made functions needed, these are automatically loaded by the scripts that require them
	
- ANALYSIS/CODE/markdowns/bibliography.bib
	- the bib files that contains all references for the markdowns
- ANALYSIS/CODE/markdowns/sensitivity analysis.Rmd
	- the Rmarkdown file needed to reproduce the sensitivity analysis, description of steps within
- ANALYSIS/CODE/markdowns/sensitivity-analysis.pdf
	- the pdf with the compiled results of the sensitivity analysis
- ANALYSIS/CODE/markdowns/supplemental results.Rmd
	- the markdown file needed to reproduced the supplemental results, description of steps within
- ANALYSIS/CODE/markdowns/supplemental-results.pdf
	- the pdf with the compiled supplemental results
	
- ANALYSIS/CODE/univariate model/00_simulate_clean.R
	- R script to simulate dialect data for sensitivity analysis
- ANALYSIS/CODE/univariate model/01_simulate_noisy.R
	- R script to simulate noisy dialect data for sensitivity analysis
- ANALYSIS/CODE/univariate model/03_plot_results.R
	- R script to plot the output
- ANALYSIS/CODE/univariate model/m_4.stan
	- Stan script with the multilevel model, description within
	
- ANALYSIS/DATA/overview parks/overview parks SAT.csv
	- data on parks collected by SAT
	- park_name: name of park
	- park_shorthand: which shorthand was used to make nest names
	- city: city
	- notes: whatever
	- nr_xxx: how many recording I have in each situation, not so important anymore
	- grass_present: if there is a patch of grass, yes = 1, no = 0
	- park_type: general description
	- palms: present = 1, not = 0
	- pine: same for pines
	- decidious: same for deciduous (just me spelling it wrong)
	- fruit_decidious: if there are fruit bearing deciduous trees
	- fruit_palms: if there are fruit bearing palms
- ANALYSIS/DATA/overview parks/overview parks SQS.csv
	- data on parks collected by SQS
	- for meta data see above
- ANALYSIS/DATA/overview parks/README.txt
	- meta data for files
- ANALYSIS/DATA/overview recordings/overview recordings SAT.csv
	- meta data per recording collected by SAT
	- video_file_name: the name of the file
	- selected: whether or not I have done the selection table in Raven
	- situation: general what the recording is about
	- nr_individuals: nr of individual present if I have said that in the recording
	- park: which park
	- city: which city
	- notes: whatever you want
	- UTM: UTM separated by a space
	- nest: if recorded from one nest the nest code, if multiple all separated by /
	- gain: gain
	- video: if I have used video to annotate
- ANALYSIS/DATA/overview recordings/overview recordings SQS.csv
	- meta data per recording collected by SQS
	- for meta data see above
- ANALYSIS/DATA/overview recordings/README.txt
	- meta data for files
- ANALYSIS/DATA/selection tables
	- folder with all selection tables from Raven Lite
	- file names is the file name of the audio file concatenated with `.Table.1.selections.txt`
	- Selection: index of selection
	- View: where the selection was made (this is always duplicated across waveform and spectrogram)
	- Channel: not relevant
	- Begin Time (s): the begin time of the selection in seconds
	- End Time (s): the end time of the selection in seconds
	- Low Freq (Hz): not relevant
	- High Freq (Hz): not relevant
	- Annotation: three bit of information if available: ID_behaviour_NumberOfIndividuals, ID: if the calling individual could be identified this is a unique ID (but as individuals were not marked, individuals can have multiple ID's across recordings), behaviour: the behaviour of the focal individual during or right before vocalising, NumberOfIndividuals: how many individuals were around during vocalisation
- ANALYSIS/DATA/18_11_traces_luscinia.csv
	- csv file with the traces from Luscinia, the following column headers are output:
	- Individual: individual ID name
	- Song: specific recording track name
	- Syllable: not needed for this analysis
	- Phrase: not needed for this analysis
	- Element: not needed for this analysis
	- Time: Time step of fundamental frequency
	- Fundamental Frequency: point of fundamental frequency 
- ANALYSIS/DATA/Bad_Files_17_11.xlsx
	- excel file with the names for the traces that were not good enough to be analysed
	- Bad Files: the Luscinia file names (Individual) for the bad traces
	- Comment: info on what was bad or potentially still usefull
	- Remove: not used, all files were removed
- ANALYSIS/DATA/Bad_Files_version_old_before_adjusted.xlsx
	- excel file with some names of poor traces that were also removed from the Luscinia database (only used to make sure we were not forgetting some traces
	- meta data not relevant
	
- ANALYSIS/RESULTS/figures/compositeXXX
	- pdfs for all composite figures for the combination of a method and a dimension reduction analysed with the Bayesian multilevel model
- ANALYSIS/RESULTS/figures/fig_pco_paper.pdf
	- pdf for the main composite figure
- ANALYSIS/RESULTS/figures/sensitivity analysis figure.pdf
	- pdf for the simulated data, can be compared to the composite figures to see how incorrect pooling can create spurious results
- ANALYSIS/RESULTS/figures/sigmasXXX
	- pdfs for the sigma parameters, can be compared to the sensitivity analysis
- ANALYSIS/RESULTS/figures/figures_log.txt
	- txt file with log to keep track of which base data was used to generate the figures

------------------------------------------------

# Session info

R version 4.1.0 (2021-05-18)

Platform: x86_64-apple-darwin17.0 (64-bit)

Running under: macOS Catalina 10.15.7

------------------------------------------------

# Maintainers and contact

Please contact Simeon Q. Smeele, <ssmeele@ab.mpg.de> or Stephen A. Tyndel <stydel@ab.mpg.de>, if you have any questions or suggestions. 

