## china-exit-covid-19

Analysis and results from the paper...

### Technical details

This is an [orderly](https://github.com/vimc/orderly) project, though unusually it contains the results of running the analysis too.  To rerun this yourself, run the tasks

* `china_extract_new_case_data`
* `china_read_exante_data`
* `china_intervention_corr_analysis`
* `china_plot_intervention_corr`

in order.  For example:

```f
orderly::orderly_run("china_extract_new_case_data")
orderly::orderly_run("china_read_exante_data", use_draft = TRUE)
orderly::orderly_run("china_intervention_corr_analysis", use_draft = TRUE)
orderly::orderly_run("china_plot_intervention_corr", use_draft = TRUE)
```

The version of the code here is based on our monorepo at version `0aeaf79`.

orderly run china_extract_new_case_data
orderly run china_read_exante_data
orderly run china_intervention_corr_analysis
orderly run china_plot_intervention_corr
