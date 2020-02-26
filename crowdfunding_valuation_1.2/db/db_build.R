require("stringr")



# load data & db

source("crowdfunding_valuation_1.2/db/db_info.R")
source("crowdfunding_valuation_1.2/data/crawling_data.R")
source("crowdfunding_valuation_1.2/data/model_data.R")




# user function

set_utf8 <- function(x) {
  chr = sapply(x, is.character)
  x[, chr] <- lapply(x[, chr, drop = FALSE], `Encoding<-`, "UTF-8")
  Encoding(names(x)) = "UTF-8"
  x
}




# db build

# data write

dbWriteTable(con, 'wadiz', table %>% 
               mutate(funding = str_replace_all(funding, "[원,\\,]", "")) %>% as.numeric(), 
             row.names = F)



# model

table_model = data.frame(matrix(0, nc = 5)) %>% 
  setNames(c("cat", "built_date", "model", "model_file", "mean_date"))

category = c("테크·가전", "패션·잡화", "소셜·캠페인", "디자인소품", "뷰티",
             "푸드", "홈리빙", "여행·레저", "반려동물", "스포츠·모빌리티",
             "공연·컬쳐", "교육·키즈", "게임·취미", "출판")

# model table

for(i in 1:14){
  table_model[i, ] = c(category[i], 
                       "2019-12-11",
                       ifelse((dayf %>% group_by(cat) %>% tally() %>% 
                                  filter(cat == (dayf$cat %>% unique())[i]) %>% select(n) > 1)[1, ] %>% as.vector(),
                               str_c("log(y) = ",
                                     lm(log(y) ~ log(x), data = dataf %>% 
                                          filter(cat == (dayf$cat %>% unique())[i]))$coefficients[2],
                                     "*log(x) + ",
                                     lm(log(y) ~ log(x), data = dataf %>% 
                                          filter(cat == (dayf$cat %>% unique())[i]))$coefficients[1]),
                               "NA"),
                       NA,
                       ifelse((dataf %>% group_by(cat) %>% tally() %>% 
                                 filter(cat == (dataf$cat %>% unique())[i]) %>% select(n) > 1)[1, ],
                              dayf %>% filter(cat == (dataf$cat %>% unique())[i]) %>% 
                                summarise(mean = mean(start - end)) %>% as.numeric(),
                               "NA")
                       )
}

# model write

dbWriteTable(con, 'model', table_model, row.names = F)