######################################
# 05_AnalysisOutputs.R
######################################

# One stop shop for any analytical outputs requested as part of commission 
# template. Add to the script, don't remove unless absolutely certain 
# we aren't going to look at that again.

#### Custom analysis functions------------------------------------------

### DistributedBoxing
# Designed to just take a data frame and create an output jpeg file combining
# a histogram and box plot. The x value MUST BE CALLED VALUE.
DistributedBoxing <- function(df, xname = "GIVE ME AN X-TITLE", yname = "Number of Top 75 Services"
                              , binw = 5
                              , x_limits = c(0,100)
                              , x_breaks = c(0, seq(0, 100, 10))
                              , y_breaks = c(0, seq(0, 100, 1))
                              , outputname = "GIVE ME AN OUTPUT NAME") {

       # Create characteristics table
       chars <- df %>% 
       summarize(median = median(Value, na.rm=TRUE)
              , range = diff(range(Value, na.rm = TRUE)) 
              , quantile = list(quantile(Value, probs = c(.33, .66)
                     , na.rm = TRUE))) %>%
              #, quantile = list(quantile(Value, probs = seq(.1, 1, 
              #       by = .1), na.rm = TRUE))) %>%
              unnest_wider(quantile)
       
       # Create annotations table with characteristics required
       annotations <- data.frame(
           xpos = c(-Inf, -Inf, -Inf),
           ypos =  c(Inf, Inf, Inf),
           text = c(paste0("  33% = ", round(chars$`33%`, 1))
                    , paste0("  Median = ", round(chars$median, 1))
                    , paste0("  66% = ", round(chars$`66%`, 1))
           )
           , angle = c(90, 90, 90)
           , x_adjust = c(0, 0, 0)
           , y_adjust = c(2.5, 4, 5.5)
           , fonts = c("bold", "bold", "bold"))


       # Create distribution plot
       dist <- ggplot(df, aes(x=Value)) +
       geom_histogram(color = "#000000", fill = "#0099F8", binwidth = binw
       , boundary = 0, closed = "right") +
       scale_x_continuous(limits = x_limits, breaks = x_breaks) +
       scale_y_continuous(breaks = y_breaks) +
       labs(x = xname, y = yname) +
       theme_light() +

       geom_vline(data=chars, aes(xintercept = chars$`33%`),
             linetype="twodash", color = "black", size = 1) + 
         geom_text(data = annotations, aes(x = xpos, y = ypos
                   , hjust = x_adjust, vjust = y_adjust, 
                   label = text, fontface = fonts)) +
       #annotate("text", x = chars$`33%` - 1.5, y = labelpositions[1], label= paste0("33% = ", round(chars$`33%`, 1)),, angle=90, fontface = "bold") +

       geom_vline(data=chars, aes(xintercept=chars$median),
             linetype="dashed", color = "red", size = 1) + 
         #annotate("text", x = chars$median + 1.5, y = labelpositions[2], label= paste0("Median = ", round(chars$median, 1)), angle=90, fontface = "bold") +
       
       geom_vline(data=chars, aes(xintercept=chars$`66%`),
             linetype="twodash", color = "black", size = 1) + 
       #annotate("text", x = chars$`66%` + 1.5, y = labelpositions[3], label= paste0("66% = ", round(chars$`66%`, 1)), angle=90, fontface = "bold") +

       theme(text = element_text(size=14), 
       legend.key = element_rect(size = 5),
       legend.key.size = unit(2, 'lines'), 
       legend.title = element_text(face= "bold", size = 14),
       legend.text = element_text(colour="black", size=12)) +
       theme(legend.position="bottom")

       ## Box plot
       box <- df %>% 
       mutate(Value.show = as.numeric(  # so ggplot doesn't complain about alpha being discrete
       between(Value, 
            quantile(Value)[2] - 1.5*IQR(Value),
            quantile(Value)[4] + 1.5*IQR(Value)))) %>% 
            
            ggplot(., 
            aes(x=`Value`, y = yname, fill = "black")) + 
            stat_boxplot(geom ='errorbar') + 
            geom_boxplot(outlier.colour= NA) +
            geom_jitter(color="black", size=1, alpha=0.9, shape = 3) +
            scale_x_continuous(limits = x_limits, breaks = x_breaks) +
            
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
       
       # Combine plots
       plot <- ggarrange(dist, box, 
                       ncol = 1, nrow = 2, 
                       heights = c(2, 0.5), 
                       align = "v")

       # Output to file     
       ggsave(paste0("Outputs/", outputname, "_", format(Sys.time(), "%Y%m%d")
       , ".jpeg"), width = 24, height = 16, units = "cm")
}



#### CDDO KPIs----------------------------------------------------------

### Distribution Analysis
## Digital Adoption
dummyDA <- as.data.frame(rnorm(60, 50, 20)) %>% rename(`Value`= 1)  %>% 
       mutate(Value = ifelse(Value < 0, 0, 
              ifelse(Value > 100, 100, Value)))

DistributedBoxing(dummyDA, xname = "Digital Adoption (%)", outputname = "DigitalAdoption")

## Digital Completion
dummyDC <- as.data.frame(rnorm(60, 50, 20)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, 
                        ifelse(Value > 100, 100, Value)))
DistributedBoxing(dummyDC, xname = "Digital Completion (%)", outputname = "DigitalCompletion")

## User Satisfaction
dummyUS <- as.data.frame(rnorm(60, 50, 20)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, 
                        ifelse(Value > 100, 100, Value)))
DistributedBoxing(dummyUS, xname = "User Satisfaction (%)", outputname = "UserSatisfaction")

## Negative Outcomes
dummyNEG <- as.data.frame(rnorm(60, 500, 150)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, Value))
DistributedBoxing(dummyNEG, xname = "Number of Complaints (through any channel)", binw = 25, 
                  x_limits = c(100, 800), x_breaks = c(0, seq(0, 1000, 100))
                  , outputname = "NegativeOutcomes")

## Timeliness
dummyTIME <- as.data.frame(rnorm(60, 2000, 300)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, Value))
DistributedBoxing(dummyTIME, xname = "Average elapsed time (hours)", binw = 50, 
                  x_limits = c(1000, 3000), x_breaks = c(0, seq(0, 5000, 500))
                  , outputname = "Timeliness")

## Transaction Cost
dummyTRANSACT<- as.data.frame(rnorm(60, 6000, 800)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, Value))
DistributedBoxing(dummyTRANSACT, xname = "Transaction Cost (£)", binw = 200, 
                  x_limits = c(4000, 9000), x_breaks = c(0, seq(0, 10000, 1000))
                  , outputname = "TransactionCost")

## Staff time
dummyST<- as.data.frame(rnorm(60, 200, 25)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, Value))
DistributedBoxing(dummyST, xname = "Staff time per transaction (hours)", binw = 5, 
                  x_limits = c(140, 260), x_breaks = c(0, seq(0, 500, 20))
                  , outputname = "StaffTime")

## Straight-through processing/automation
dummyPRO<- as.data.frame(rnorm(60, 50, 10)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, Value))
DistributedBoxing(dummyPRO, xname = "Completed Transactions without human activity (%)", binw = 5, 
                  x_limits = c(0, 100), x_breaks = c(0, seq(0, 100, 10))
                  , outputname = "ProcessingAutomation")

## Failure demand
dummyFD<- as.data.frame(rnorm(60, 60, 20)) %>% rename(`Value`= 1)  %>% 
  mutate(Value = ifelse(Value < 0, 0, Value))
DistributedBoxing(dummyFD, xname = "Failure Demand (%)", binw = 5, 
                  x_limits = c(0, 100), x_breaks = c(0, seq(0, 100, 10))
                  , outputname = "FailureDemand")
