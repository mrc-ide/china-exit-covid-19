#####################################################
### COVID19 spread with Chinese movement patterns ###
#####################################################
# 1. Estimating R_t over time for each province in China using EpiEstim
# 2. Determining most highly correlated lag time
# 3. Determine rolling correlation using runCor (at weekly and biweekly resolution)

incidence_dat <- all_dat1 %>% rename(I = New_Confirmed, dates = Date_Reporting_End) %>% select(Province, dates, I)  

### 1. Estimating R_t with EpiEstim
estimate_R <- function(dat, si_mean = 3.96, si_std = 4.75){
# serial interval estimate used: mean = 3.96, sd =  4.75
# from Du et al. from The University of Texas at Austin and University of Hong Kong 
# (https://www.medrxiv.org/content/10.1101/2020.01.28.20019299v4.full.pdf)
# (https://www.medrxiv.org/content/10.1101/2020.02.19.20025452v2.full.pdf)

res_parametric_si <- estimate_R(dat, method="parametric_si",config = make_config(list(mean_si = si_mean, std_si = si_std)))
return(res_parametric_si$R)
}

R_t <- incidence_dat %>% 
          group_by(province) %>% 
          group_map(~ estimate_R(.x, si_mean = 3.96, si_std = 4.75))
        
### rename EpiEstim's default column names and add lagged date column
rt_hubei <- res_parametric_si$R %>% 
  rename(R_mean = `Mean(R)`, R_q2.5 = `Quantile.0.025(R)`, R_q97.5 = `Quantile.0.975(R)`,
         R_median = `Median(R)`) %>%
  mutate(date = res_parametric_si$dates[t_end],
         date_lag = date - 8)

# add movement data for hubei
hubei_move <- movement2020 %>% filter(province == "Hubei")
hubei_all <- left_join(rt_hubei, hubei_move, by=c("date_lag" = "date")) %>%
              filter(!is.na(R_mean)) %>% select(date_lag, R_mean, movement)

### correlation
# using ccf function to determine correlation between different lags in case counts and Rt
rhos <- ccf(hubei_all$movement, hubei_all$R_mean, lag.max = 20)
max(rhos$acf) # a lag of 8 days has highest correlation

# rolling correlation
#rolling_corr <- runCor(hubei_all$movement, hubei_all$R_mean, n=7) # weekly correlations

rolling_corr <- hubei_all %>%
  tq_transmute_xy(x          = movement, 
                  y          = R_mean,
                  mutate_fun = runCor,
                  n          = 14,
                  col_rename = "rolling.corr.biweekly")
# plot of correlation
rolling_corr %>%
  ggplot(aes(x = date_lag, y = rolling.corr.biweekly)) +
  geom_hline(yintercept = 0, color = palette_light()[[1]]) +
  geom_line(size = 1) +
  labs(title = "Biweekly Rolling Correlation of R and Movement",
       x = "", y = "Correlation", color = "") +
  #facet_wrap(~ symbol, ncol = 2) +
  theme_tq() + 
  scale_color_tq()

### calculate R_t by province - buggy, starting with Hubei first
# R_t <- list()
# # loop through provinces
# for(p in 1:length(names(provinces))){
#   print(names(provinces)[p])
#   temp_inc <- incidence_dat %>% filter(Province == names(provinces)[p])
#   temp_inc <- temp_inc[order(temp_inc$dates),-1] # order by date and remove Province column
#   temp_inc <- temp_inc[!rev(duplicated(rev(temp_inc$dates))),] # keep only last row for dates with multiple entries
#   res_parametric_si <- estimate_R(temp_inc[-1,], method="parametric_si",config = make_config(list(mean_si = 8.4, std_si = 3.8)))
#   R_t[[p]] <- res_parametric_si$R
# }





