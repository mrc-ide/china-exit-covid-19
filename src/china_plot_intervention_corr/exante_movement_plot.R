# quick copy over of the plotting code.  have not set up .yml to read in the data.

# require the file 'exante_movement_data.csv' or .rds.
# then change the data argument in the ggplot function below.

movement_data <- readRDS("top_six_pop_weighted_exante_movement_data.rds")


ggplot(data = movement_data %>% filter(province == "hubei") , 
       aes(x = month_day, y = movement, group = year,
           col = as.factor(year))) +
  geom_line(size = 1) + 
  geom_vline(xintercept = "01-23", linetype = "longdash") +
  xlab("date") + 
  ylab("movement index") + 
  facet_wrap(vars(province)) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(angle = 90, hjust = 1)) + 
  labs(col = "year") +
scale_x_discrete( breaks = c("01-01", "01-16", "01-23", "02-01", "02-16", "03-01", "03-16")) +
  theme(legend.position="bottom")
  

 unique(movement_data$month_day)
 

#############################################################
# generate plots for all provinces
#############################################################

# choose which x-axis tick marks to use.  Note not equally spaced.
#  plan to change to x-axis as integers with 0 at lunar new year. Probably follow
#  HF's suggestion of lining up LNY for both 2019 and 2020.
mm_dd <- unique(movement_province_level$month_day)
x_ticks <- mm_dd[seq(1, length(mm_dd), 15)]



movement_data_plots <- ggplot(data = movement_province_level , 
                              aes(x = month_day, y = movement, group = year,
                                  col = as.factor(year))) +
  geom_line() + 
  xlab("date") + 
  ylab("movement index") + 
  facet_wrap(vars(province)) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(angle = 90, hjust = 1)) + 
  labs(col = "year") +
  scale_x_discrete(breaks = x_ticks)