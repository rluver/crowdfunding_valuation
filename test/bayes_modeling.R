require('dplyr')
require('MCMCpack')


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

dataf_fashion = data.frame(x, y, cat) %>% mutate(cat = as.character(cat))




# bayes regression
# model
lm_mcmc = MCMCregress(log(y) ~ log(x), 
                      data = dataf_fashion, 
                      burnin = 2000, 
                      mcmc = 100000, 
                      thin = 1, 
                      b0 = 0, 
                      B0 = 0, 
                      c0 = 0.001, 
                      d0 = 0.001)

# plot
plot(lm_mcmc)

# hpd
HPDinterval(lm_mcmc)

# summary
summary(lm_mcmc)

# effective
effectiveSize(lm_mcmc)

# acf
acf(lm_mcmc)