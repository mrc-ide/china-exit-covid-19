## Evidence of initial success for China exiting COVID-19 social distancing policy after achieving containment

### Overview
This repository provides the data and code to perform the analyses and recreate the results from the paper.

### Data
The data consists of daily confirmed cases from 16 January to 24 March 2020 from the dashboard maintained by Chinese Center for Disease Prevention and Control (CCDC) [1](http://2019ncov.chinacdc.cn/2019-nCoV/). The CCDC dashboard collates numbers of confirmed cases reported by national and local health commissions in each province in mainland China, and Hong Kong SAR and Macau SAR. Confirmed cases are defined as suspected cases, who have epidemiological links and/or clinical symptoms, and are detected with SARS-CoV-2 by PCR tests. However, in Hubei province, clinically diagnosed cases were additionally included between 12 and 19 February.

We also used daily within-city movement data, used as a proxy for economic activity, from 1 January to 24 March 2020 for major metropolitan cities within each province in mainland China, Hong Kong SAR, and Macau SAR. These data, provided by Exante Data Inc [2](https://www.exantedata.com/), measured travel activity relative to the 2019 average (excluding Lunar New Year). The underlying data are based on near real-time people movement statistics from Baidu.

### Technical details

The analyses are organised as an [orderly](https://github.com/vimc/orderly) project. The project also contains the code to both run the analyses and generate the results of those analyses.  The project is divided into different tasks: 

* `china_extract_new_case_data`
* `china_read_exante_data`
* `china_intervention_corr_analysis`
* `china_plot_intervention_corr`

Later tasks depend on earlier tasks, so when running the code, the tasks should be run sequentially. The following will show how to run each task and give a brief description of the output

1. To read in the China case data, run:
```f
orderly::orderly_run("china_extract_new_case_data")
```
This task reads in the case data and performs data cleaning, then outputs a csv file with number of new daily cases for each province in mainland China, Hong Kong SAR, and Macau SAR.

2. To read in the Exante movement data, run:
```f
orderly::orderly_run("china_read_exante_data", use_draft = TRUE)
```
This task reads in the orginal movement data file and perfoms data cleaning. The tasks produces rds and csv files of the full movement data as well as a subset of the movement data for Hubei, Beijing, Guangdong, Henan, Hunan, Zhejiang, and Hong Kong SAR.

3. To estimate the reproduction number (Rt) over time from the case data and determine the correlation between estimated Rt and movement, run:
```f
orderly::orderly_run("china_intervention_corr_analysis", use_draft = TRUE)
```
This task will produce a csv file with the biweekly rolling correlations between Rt and movement for Hubei, Beijing, Guangdong, Henan, Hunan, Zhejiang, and Hong Kong SAR for a single lag. It also produces a csv file for the rolling biweekly correlations using different lags for each region.

4. Finally, to recreate the figures in the paper, run:
```f
orderly::orderly_run("china_plot_intervention_corr", use_draft = TRUE)
```
This will output all of the figures in the paper as png files).

The version of the code here is based on our monorepo at version `0aeaf79`.
