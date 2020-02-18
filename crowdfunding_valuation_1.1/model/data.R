require("dplyr")
require("lubridate")
require("car")
require("zyp")
require("ggplot2")




# pet

x = c(88, 404, 221, 47, 11)
y = c(14443000, 65082000, 57084100, 3374000, 2837700)
cat = rep("pet", length(x)) %>% as.character()

end = c("2019-06-26", "2019-07-28", "2019-08-25", "2019-06-10", "2019-06-30")
start = c("2019-11-20", "2019-10-23",	"2019-10-14", "2019-07-18", "2019-10-30") 

dataf_pet = data.frame(x, y, cat) %>% mutate(cat = as.character(cat))
dayf_pet = data.frame(start, end, cat) %>% mutate(start = as_date(start), 
                                                  end = as_date(end),
                                                  cat = as.character(cat))




# homeliving

x = c(55, 594, 204, 136, 16, 
      36, 557, 38, 15, 18,
      129, 137, 18, 20, 25,
      97, 173, 21, 53, 88,
      96)
y = c(15240000, 180220000, 33459800, 2.73141e+07, 5.03e+06,
      5.38185e+06, 4.5176e+07, 8.0402e+06, 3.31e+06, 2.2867e+07,
      1.74036e+07, 3.00283e+07, 1.6789e+07, 2.6514e+06, 2.8962e+06,
      9.8204e+06, 5.44395e+07, 1.28054e+07, 1.3099e+07, 3.76665e+07,
      2.0438e+07)
cat = rep("homeliving", length(x))

end = c("2019-09-30", "2019-07-14", "2019-06-23", "2019-09-15", "2019-07-21", 
        "2019-08-20", "2019-08-03", "2019-06-09", "2019-06-09", "2019-08-25", 
        "2019-06-16", "2019-10-20", "2019-09-08", "2019-09-22", "2019-08-04", 
        "2019-07-19", "2019-09-22", "2019-06-30", "2019-09-22", "2019-08-18",
        "2019-10-06")
start = c("2019-11-04", "2019-09-14",	"2019-10-30", "2019-11-07", "2019-11-15", 
          "2019-10-31", "2019-10-25", "2019-08-16", "2019-07-16", "2019-10-16", 
          "2019-09-27", "2019-11-18", "2019-10-10", "2019-10-24", "2019-09-18", 
          "2019-09-27", "2019-10-28", "2019-08-22", "2019-10-29", "2019-09-20",
          "2019-11-12") 

dataf_homeliving = data.frame(x, y, cat) %>% mutate(cat = as.character(cat))
dayf_homeliving = data.frame(start, end, cat) %>% mutate(start = as_date(start), 
                                                         end = as_date(end),
                                                         cat = as.character(cat))




# food

x = c(42, 266, 76, 61, 83, 
      67, 63, 118, 214, 131,
      60, 37, 12, 56, 30,
      20, 29, 27, 17)
y = c(7598400, 105219900, 38765100, 21531800, 36812000,
      13081600, 22949700, 30569800, 23045700, 19297300,
      13354700, 9960900, 6056500, 3317400, 5341500,
      2081800, 9402500, 3823000, 1854000)
cat = rep("food", length(x))

end = c("2019-08-18", "2019-08-08", "2019-08-29", "2019-08-25", "2019-07-29", 
        "2019-06-17", "2019-09-02", "2019-08-18", "2019-08-11", "2019-07-14", 
        "2019-09-22", "2019-09-29", "2019-07-21", "2019-10-07", "2019-07-17", 
        "2019-06-10", "2019-09-02", "2019-06-10", "2019-09-23")
start = c("2019-11-22", "2019-09-13",	"2019-10-01", "2019-10-28", "2019-08-21", 
          "2019-08-14", "2019-10-31", "2019-09-17", "2019-11-06", "2019-08-29", 
          "2019-11-14", "2019-11-14", "2019-09-06", "2019-11-12", "2019-08-16", 
          "2019-08-02", "2019-10-14", "2019-08-19", "2019-10-21") 

dataf_food = data.frame(x, y, cat) %>% mutate(cat = as.character(cat))
dayf_food = data.frame(start, end, cat) %>% mutate(start = as_date(start), 
                                                   end = as_date(end),
                                                   cat = as.character(cat))




# beauty 

x = c(39, 17, 15, 17, 101, 183, 383, 32, 26, 15, 10, 61, 172, 27, 50, 99, 945, 15, 66)
y = c(5649200, 5037000, 8973500, 5063200, 12962000, 37560000, 178093000, 5032200,
      5543800, 1670400, 6898000, 21826400, 30781600, 5712000, 19367000, 25560300,
      142438600, 3517500, 24671100)
cat = rep("beauty", length(x))

end = c("2019-09-15", "2019-09-15", "2019-06-25", "2019-09-16", "2019-07-07", "2019-10-13", 
        "2019-08-20", "2019-09-22", "2019-06-17", "2019-06-23", "2019-07-21", "2019-10-20",
        "2019-06-08", "2019-10-30", "2019-07-28", "2019-07-26", "2019-09-15", "2019-10-13",
        "2019-10-06")
start = c("2019-11-12", "2019-10-18",	"2019-10-31", "2019-11-05", "2019-08-05", "2019-11-21",
          "2019-10-01", "2019-11-01", "2019-07-11", "2019-07-18", "2019-08-14", "2019-11-22",
          "2019-08-14", "2018-11-15", "2019-10-07", "2019-09-16", "2019-10-21", "2019-11-21",
          "2019-11-21")

dataf_beauty = data.frame(x, y, cat) %>% mutate(cat = as.character(cat))
dayf_beauty = data.frame(start, end, cat) %>% mutate(start = as_date(start), 
                                                     end = as_date(end),
                                                     cat = as.character(cat))




# fashion

x = c(149, 11, 15, 27, 74,
      1246, 11, 11, 19, 40,
      61, 186, 101, 77, 56, 
      146, 17, 34, 27, 27,
      10, 151, 145, 43, 189,
      10, 15, 40, 54, 11,
      165, 85, 42, 11, 34,
      134, 186, 28, 454, 11,
      37, 10, 17, 11, 200)
y = c(3.7627e+07, 1.982e+06, 6.589e+06, 2.8965e+06, 8.1018e+06,
      3.19708e+08, 1.38745e+07, 1.5365e+06, 1.089e+06, 1.92035e+07,
      1.9355e+07, 6.1578e+07, 8.86427e+07, 8.062e+06, 1.03745e+07,
      3.5283e+07, 9.68e+06, 1.326e+06, 4.743e+06, 1.3741e+07, 
      3.468e+06, 8.4443e+07, 3.32053e+07, 1.98649e+07, 4.7994e+07,
      2.751e+06, 5.386e+06, 1.75754e+07, 6.2839e+06, 1.5285e+06,
      6.4545e+07, 4.453e+06, 7.6485e+06, 982000, 6.4556e+06,
      2.3625e+06, 6.7603e+07, 4.235e+06, 1.14226e+08, 9.8124e+06,
      6.0832e+06, 4.6974e+06, 7.9015e+06, 2.04e+06, 6.6184e+07)
cat = rep("fashion", length(x))

end = c("2019-06-09", "2019-10-13", "2019-08-25", "2019-06-24", "2019-06-30", 
        "2019-08-18", "2019-07-17", "2019-09-29", "2019-06-30", "2019-07-21", 
        "2019-09-02", "2019-07-07", "2019-06-30", "2019-09-02", "2019-08-26",
        "2019-06-09", "2019-06-09", "2019-07-15", "2019-06-23", "2019-06-23",
        "2019-08-11", "2019-09-09", "2019-10-21", "2019-08-04", "2019-06-12",
        "2019-07-01", "2019-08-05", "2019-06-20", "2019-06-18", "2019-08-19",
        "2019-07-10", "2019-06-09", "2019-08-13", "2019-11-03", "2019-06-09",
        "2019-06-13", "2019-09-22", "2019-06-11", "2019-06-16", "2019-07-07",
        "2019-09-09", "2019-08-18", "2019-08-04", "2019-09-10", "2019-07-21")
start = c("2019-09-27", "2019-11-14",	"2019-11-04", "2019-07-26", "2019-07-26", 
          "2019-09-12", "2019-10-01", "2019-11-20", "2019-10-28", "2019-08-21", 
          "2019-11-18", "2019-08-29", "2019-09-05", "2019-10-29", "2019-10-14",
          "2019-08-05", "2019-06-14", "2019-10-15", "2019-07-16", "2019-07-25",
          "2019-10-04", "2019-10-06", "2019-11-22", "2019-09-11", "2019-09-16",
          "2019-07-19", "2019-08-26", "2019-07-24", "2019-09-17", "2019-10-01",
          "2019-10-10", "2019-11-15", "2019-10-11", "2019-11-26", "2019-07-04",
          "2019-10-31", "2019-11-01", "2019-07-02", "2019-09-12", "2019-08-21",
          "2019-10-17", "2019-10-11", "2019-09-17", "2019-10-14", "2019-10-15")

dataf_fashion = data.frame(x, y, cat) %>% mutate(cat = as.character(cat))
dayf_fashion = data.frame(start, end, cat) %>% mutate(start = as_date(start), 
                                                      end = as_date(end),
                                                      cat = as.character(cat))




# tech

x = c(337, 465, 78, 80, 21, 892, 159, 85, 127, 92, 65, 138, 440, 72)
y = c(89436300, 80038100, 9188900, 27745500, 3965000, 459485000, 37961160, 33339340,
      15847000, 5853000, 13161700, 38237000, 23822200, 29048000)
cat = rep("tech", length(x))

end = c("2019-08-18", "2019-09-16", "2019-08-01", "2019-10-13", "2019-07-25", "2019-07-21", 
        "2019-06-16", "2019-08-18", "2019-06-24", "2019-09-16", "2019-10-13", "2019-07-14",
        "2019-09-24", "2019-07-17")
start = c("2019-09-24", "2019-10-06",	"2019-11-11", "2019-11-12", "2019-09-06", "2019-10-22",
          "2019-07-24", "2019-10-11", "2019-08-23", "2019-10-30", "2019-11-13", "2019-08-14",
          "2019-10-23", "2019-08-14")

dataf_tech = data.frame(x, y, cat) %>% mutate(cat = as.character(cat))
dayf_tech = data.frame(start, end) %>% mutate(start = as_date(start), 
                                              end = as_date(end),
                                              cat = as.character(cat))




# combining

dataf = bind_rows(dataf_tech, dataf_fashion) %>% 
   bind_rows(dataf_beauty) %>% 
   bind_rows(dataf_food) %>% 
   bind_rows(dataf_homeliving) %>% 
   bind_rows(dataf_pet)

dayf = bind_rows(dayf_tech, dayf_fashion) %>%
   bind_rows(dayf_beauty) %>% 
   bind_rows(dayf_food) %>% 
   bind_rows(dayf_homeliving) %>% 
   bind_rows(dayf_pet)




# verification & visualization

# tech

model = lm(log(y) ~ log(x), data = dataf %>% filter(cat == "tech"))

model$residuals %>% shapiro.test() # normality
durbinWatsonTest(model) # independence
ncvTest(model) # homoskedasticity
outlierTest(model) # outlier

ggplot(dataf %>% filter(cat == "tech"), aes(x = log(x), y = log(y))) +
  geom_point() + stat_smooth(method = "lm")

summary(model)

# mean 

dayf %>% group_by(cat) %>% summarise(mean = mean(start - end)) %>% 
  filter(cat == "tech")



# fashion

model = lm(log(y) ~ log(x), data = dataf %>% filter(cat == "fashion"))

model$residuals %>% shapiro.test() # normality
durbinWatsonTest(model) # independence
ncvTest(model) # homoskedasticity
outlierTest(model) # outlier

ggplot(dataf %>% filter(cat == "fashion"), aes(x = log(x), y = log(y))) +
  geom_point() + stat_smooth(method = "lm")

ggplot(dataf %>% filter(cat == "fashion"), aes(x = log(x), y = log(y))) +
  geom_point() + stat_smooth(method = "loess")

summary(model)

# mean 

dayf %>% group_by(cat) %>% summarise(mean = mean(start - end)) %>% 
  filter(cat == "fashion")



# beauty

model = lm(log(y) ~ log(x), data = dataf %>% filter(cat == "beauty"))

model$residuals %>% shapiro.test() # normality
durbinWatsonTest(model) # independence
ncvTest(model) # homoskedasticity
outlierTest(model) # outlier

ggplot(dataf %>% filter(cat == "beauty"), aes(x = log(x), y = log(y))) +
  geom_point() + stat_smooth(method = "lm")

summary(model)

# mean 

dayf %>% group_by(cat) %>% summarise(mean = mean(start - end)) %>% 
  filter(cat == "beauty")



# food

model = lm(log(y) ~ log(x), data = dataf %>% filter(cat == "food"))

model$residuals %>% shapiro.test() # normality
durbinWatsonTest(model) # independence
ncvTest(model) # homoskedasticity
outlierTest(model) # outlier

ggplot(dataf %>% filter(cat == "food"), aes(x = log(x), y = log(y))) +
  geom_point() + stat_smooth(method = "lm")

summary(model)

# mean 

dayf %>% group_by(cat) %>% summarise(mean = mean(start - end)) %>% 
  filter(cat == "food")



# homeliving

model = lm(log(y) ~ log(x), data = dataf %>% filter(cat == "homeliving"))

model$residuals %>% shapiro.test() # normality
durbinWatsonTest(model) # independence
ncvTest(model) # homoskedasticity
outlierTest(model) # outlier

ggplot(dataf %>% filter(cat == "homeliving"), aes(x = log(x), y = log(y))) +
  geom_point() + stat_smooth(method = "lm")

summary(model)

# mean 

dayf %>% group_by(cat) %>% summarise(mean = mean(start - end)) %>% 
  filter(cat == "homeliving")



# pet

# parametric

model = lm(log(y) ~ log(x), data = dataf %>% filter(cat == "pet"))

model$residuals %>% shapiro.test() # normality
durbinWatsonTest(model) # independence
ncvTest(model) # homoskedasticity
outlierTest(model) # outlier

ggplot(dataf %>% filter(cat == "pet"), aes(x = log(x), y = log(y))) +
  geom_point() + stat_smooth(method = "lm")

summary(model)

# nonparametric

model = zyp.sen(y ~ x, data = dataf %>% filter(cat == "pet") %>% mutate(x = log(x), y = log(y)))

Kendall(dataf %>% filter(cat == "pet") %>% select(x) %>% log() %>% unlist(), 
        dataf %>% filter(cat == "pet") %>% select(y) %>% log() %>% unlist())

print(model)

# mean 

dayf %>% group_by(cat) %>% summarise(mean = mean(start - end)) %>% 
  filter(cat == "pet")