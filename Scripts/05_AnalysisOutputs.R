######################################
# 05_AnalysisOutputs.R
######################################

# One stop shop for any analytical outputs requested as part of commission 
# template. Add to the script, don't remove unless absolutely certain 
# we aren't going to look at that again.

#### CDDO KPIs----------------------------------------------------------

### Digital Adoption
dummyDA <- as.data.frame(rnorm(60, 50, 20)) %>% rename(`Value`= 1)  %>% 
       mutate(Value = ifelse(Value < 0, 0, 
              ifelse(Value > 100, 100, Value)))
       # Calculate dummy quartile ranges and percentiles
chars <- dummyDA %>% 
       summarize(median = median(Value, na.rm=TRUE)
              , range = diff(range(Value, na.rm = TRUE)) 
              , quantile = list(quantile(Value, probs = c(.33, .66)
                     , na.rm = TRUE))) %>%
              #, quantile = list(quantile(Value, probs = seq(.1, 1, 
              #       by = .1), na.rm = TRUE))) %>%
              unnest_wider(quantile)

## Distribution
d <- ggplot(dummyDA, aes(x=Value))+
  geom_histogram(color = "#000000", fill = "#0099F8", binwidth = 5 
       , boundary = 0, closed = "right") +
  scale_x_continuous(limits = c(0, 100), breaks = c(0, seq(0, 100, 10))) +
  scale_y_continuous(breaks = c(0, seq(0, 100, 1))) +
  labs(x ="Digital Adoption %", y = "Number of Top 75 Services") +
  theme_light() +
  geom_vline(data=chars, aes(xintercept = chars$`33%`),
             linetype="twodash", color = "black", size = 1) + 
       annotate("text", x = chars$`33%` - 1.5, y = 8, label= paste0("33% = ", 
       round(chars$`33%`, 1)), angle=90, fontface = "bold") +
  geom_vline(data=chars, aes(xintercept=chars$median),
             linetype="dashed", color = "red", size = 1) + 
       annotate("text", x = chars$median + 1.5, y = 8, label= paste0("Median = ", 
       round(chars$median, 1)), angle=90, fontface = "bold") +
  geom_vline(data=chars, aes(xintercept=chars$`66%`),
             linetype="twodash", color = "black", size = 1) + 
       annotate("text", x = chars$`66%` + 1.5, y = 8, label= paste0("66% = ", 
       round(chars$`66%`, 1)), angle=90, fontface = "bold") +
       theme(text = element_text(size=14), 
       legend.key = element_rect(size = 5),
       legend.key.size = unit(2, 'lines'), 
       legend.title = element_text(face= "bold", size = 14),
       legend.text = element_text(colour="black", size=12)) +
       theme(legend.position="bottom")
       
## Box plot
b <- dummyDA %>% 
       mutate(Value.show = as.numeric(  # so ggplot doesn't complain about alpha being discrete
       between(Value, 
            quantile(Value)[2] - 1.5*IQR(Value),
            quantile(Value)[4] + 1.5*IQR(Value)))) %>% 
  ggplot(., 
       aes(x=`Value`, y = "Digital Adoption %", fill = "black")) + 
       stat_boxplot(geom ='errorbar') + 
       geom_boxplot(outlier.colour= NA) +
       geom_jitter(color="black", size=1, alpha=0.9, shape = 3) +
       scale_x_continuous(limits = c(0, 100), breaks = c(0, seq(0, 100, 10))) +
       theme_light() +
       theme(legend.position="none",
      plot.title = element_text(size=11)) + 
      labs(x ="", y = "") +
      theme(axis.ticks.y = element_blank(),
      axis.text.y = element_blank(), 
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank(), 
      text = element_text(size=14), 
       legend.key = element_rect(size = 5),
       legend.key.size = unit(2, 'lines'), 
       legend.title = element_text(face= "bold", size = 14),
       legend.text = element_text(colour="black", size=12))   

DA <- ggarrange(d, b, 
          ncol = 1, nrow = 2, 
          heights = c(2, 0.5), 
          align = "v")

ggsave(paste0("Outputs/DigitalAdoption_", format(Sys.time(), "%Y%m%d"), ".jpeg"), width = 24, height = 16, units = "cm")

## Digital Completion
dummyDC <- as.data.frame(rnorm(60, 50, 20)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, 
                        ifelse(Value > 100, 100, Value)))

# Calculate dummy quartile ranges and percentiles
chars <- dummyDC %>% 
  summarize(median = median(Value, na.rm=TRUE)
            , range = diff(range(Value, na.rm = TRUE)) 
            , quantile = list(quantile(Value, probs = c(.33, .66)
                                       , na.rm = TRUE))) %>%
  #, quantile = list(quantile(Value, probs = seq(.1, 1, 
  #       by = .1), na.rm = TRUE))) %>%
  unnest_wider(quantile)

## Distribution
dc <- ggplot(dummyDC, aes(x=Value))+
  geom_histogram(color = "#000000", fill = "#0099F8", binwidth = 5 
                 , boundary = 0, closed = "right") +
  scale_x_continuous(limits = c(0, 100), breaks = c(0, seq(0, 100, 10))) +
  scale_y_continuous(breaks = c(0, seq(0, 100, 1))) +
  labs(x ="Digital Completion %", y = "Number of Top 75 Services") +
  theme_light() +
  geom_vline(data=chars, aes(xintercept = chars$`33%`),
             linetype="twodash", color = "black", size = 1) + 
  annotate("text", x = chars$`33%` - 1.5, y = 3, label= paste0("33% = ", 
  round(chars$`33%`, 1)), angle=90, fontface = "bold") +
  geom_vline(data=chars, aes(xintercept=chars$median),
             linetype="dashed", color = "red", size = 1) + 
  annotate("text", x = chars$median + 1.5, y = 5, label= paste0("Median = ", 
  round(chars$median, 1)), angle=90, fontface = "bold") +
  geom_vline(data=chars, aes(xintercept=chars$`66%`),
             linetype="twodash", color = "black", size = 1) + 
  annotate("text", x = chars$`66%` + 1.5, y = 7, label= paste0("66% = ", 
  round(chars$`66%`, 1)), angle=90, fontface = "bold") +
  theme(text = element_text(size=14), 
        legend.key = element_rect(size = 5),
        legend.key.size = unit(2, 'lines'), 
        legend.title = element_text(face= "bold", size = 14),
        legend.text = element_text(colour="black", size=12)) +
  theme(legend.position="bottom")

## Box plot
bc <- dummyDC %>% 
       mutate(Value.show = as.numeric(  # so ggplot doesn't complain about alpha being discrete
       between(Value, 
            quantile(Value)[2] - 1.5*IQR(Value),
            quantile(Value)[4] + 1.5*IQR(Value)))) %>% 
  ggplot(., 
            aes(x=`Value`, y = "Digital Completion %", fill = "black")) + 
  stat_boxplot(geom ='errorbar') + 
  geom_boxplot(outlier.colour= "red") +
  geom_jitter(aes(alpha =Value.show), color="black", size=1, shape = 3) +
  scale_x_continuous(limits = c(0, 100), breaks = c(0, seq(0, 100, 10))) +
  theme_light() +
  theme(legend.position="none",
        plot.title = element_text(size=11)) + 
  labs(x ="", y = "") +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank(), 
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank(), 
        text = element_text(size=14), 
        legend.key = element_rect(size = 5),
        legend.key.size = unit(2, 'lines'), 
        legend.title = element_text(face= "bold", size = 14),
        legend.text = element_text(colour="black", size=12))   

DC <- ggarrange(dc, bc, 
                ncol = 1, nrow = 2, 
                heights = c(2, 0.5), 
                align = "v")

ggsave(paste0("Outputs/DigitalCompletion_", format(Sys.time(), "%Y%m%d"), ".jpeg"), width = 24, height = 16, units = "cm")


## User Satisfaction


## Negative Outcomes


## Timeliness


## Transaction Cost


## Staff time


## Straight-through processing/automation


## Failure demand

