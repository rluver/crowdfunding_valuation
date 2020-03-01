require("data.table")
require("dplyr")
require("stringr")
require("text2vec")
require("glmnet")




# data load
table_end = bind_rows(list.files("d:/table", pattern = "*.csv", full.names = T) %>% 
                        purrr::map_df(~fread(., header = T, encoding = "UTF-8"))) %>% 
  filter(se == "종료") %>% 
  mutate(start = ymd(start),
         end = ymd(end),
         sf = str_replace_all(sf, "^$", "실패"))




# success ratio
# ratio by cat
table_end %>% filter(se == "종료") %>% 
  group_by(cat, sf) %>% tally() %>% 
  mutate(ratio = n/sum(n)) %>% 
  filter(sf == "성공") %>% 
  select(cat, ratio)

# total ratio
table_end %>% filter(se == "종료") %>% 
  group_by(sf) %>% tally() %>% 
  mutate(ratio = n/sum(n))
  



# split data
ind = sample(2, nrow(table_end), replace = T, prob = c(0.8, 0.2))

train = table_end %>% filter(ind == 1) %>% select(title) %>% unlist() %>% as.vector() %>% str_replace_all("\\W", " ")
label_train = table_end %>% filter(ind == 1) %>% select(sf) %>% unlist() %>% 
  as.vector() %>% as.factor() %>% as.numeric()

test = table_end %>% filter(ind == 2) %>% select(title) %>% unlist() %>% as.vector() %>% str_replace_all("\\W", " ")
label_test = table_end %>% filter(ind == 2) %>% select(sf) %>% unlist() %>% 
  as.vector() %>% as.factor() %>% as.numeric()




# tokenization
i_train = itoken(train,
                 str_to_lower,
                 tokenizer = word_tokenizer,
                 progressbar = T)

i_test = itoken(test,
                str_to_lower,
                tokenizer = word_tokenizer,
                progressbar = T)

# create vocab vector
vectorizer = create_vocabulary(i_train) %>% 
  vocab_vectorizer()

# create tfidf matrix
train_tfidf = create_dtm(i_train, vectorizer) %>% 
  fit_transform(TfIdf$new())

test_tfidf = create_dtm(i_test, vectorizer) %>% 
  fit_transform(TfIdf$new())




# training
classifier_glmnet = cv.glmnet(x = train_tfidf,
                              y = label_train,
                              family = "binomial",
                              type.measure = "auc",
                              trace.it = T)




# result
# plot
plot(classifier_glmnet)

# confusion matrix
caret::confusionMatrix(classifier_glmnet %>% predict(test_tfidf, type = "class") %>% as.factor(),
                       label_test %>% as.factor())




' below code can check result by category but data are not sufficient to check
# expect by cat
cat = table_end$cat %>% unique()

for(i in cat){
  
  data = table_end %>% filter(cat == i)
  
  # split data
  ind = sample(2, nrow(data), replace = T, prob = c(0.8, 0.2))
  
  train = data %>% filter(ind == 1) %>% select(title) %>% unlist() %>% as.vector() %>% str_replace_all("\\W", " ")
  label_train = data %>% filter(ind == 1) %>% select(sf) %>% unlist() %>% 
    as.vector() %>% as.factor() %>% as.numeric()
  
  test = data %>% filter(ind == 2) %>% select(title) %>% unlist() %>% as.vector() %>% str_replace_all("\\W", " ")
  label_test = data %>% filter(ind == 2) %>% select(sf) %>% unlist() %>% 
    as.vector() %>% as.factor() %>% as.numeric()
  
  
  
  
  # tokenization
  i_train = itoken(train,
                   str_to_lower,
                   tokenizer = word_tokenizer,
                   progressbar = T)
  
  i_test = itoken(test,
                  str_to_lower,
                  tokenizer = word_tokenizer,
                  progressbar = T)
  
  # create vocab vector
  vectorizer = create_vocabulary(i_train) %>% 
    vocab_vectorizer()
  
  # create tfidf matrix
  train_tfidf = create_dtm(i_train, vectorizer) %>% 
    fit_transform(TfIdf$new())
  
  test_tfidf = create_dtm(i_test, vectorizer) %>% 
    fit_transform(TfIdf$new())
  
  
  
  
  # training
  classifier_glmnet = cv.glmnet(x = train_tfidf,
                                y = label_train,
                                family = "binomial",
                                type.measure = "auc",
                                trace.it = T)
  
  
  
  
  # result
  # plot
  plot(classifier_glmnet)
  
  # confusion matrix
  caret::confusionMatrix(classifier_glmnet %>% predict(test_tfidf, type = "class") %>% as.factor(),
                         label_test %>% as.factor())
}
'