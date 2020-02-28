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




# split data
ind = sample(2, nrow(table_end), replace = T, prob = c(0.8, 0.2))

train = table_end %>% filter(ind == 1) %>% select(title) %>% unlist() %>% as.vector() %>% str_replace_all("\\W", " ")
label_train = table_end %>% filter(ind == 1) %>% select(cat) %>% unlist() %>% 
  as.vector() %>% str_replace_all("\\W", "") %>% as.factor() %>% as.numeric()

test = table_end %>% filter(ind == 2) %>% select(title) %>% unlist() %>% as.vector() %>% str_replace_all("\\W", " ")
label_test = table_end %>% filter(ind == 2) %>% select(cat) %>% unlist() %>% 
  as.vector() %>% str_replace_all("\\W", "") %>% as.factor() %>% as.numeric()




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
                              family = "multinomial",
                              type.measure = "class",
                              trace.it = T)




# result
plot(classifier_glmnet)

caret::confusionMatrix((classifier_glmnet %>% predict(test_tfidf, type = "response"))[, , 1] %>% 
                         max.col() %>% as.factor(),
                       label_test %>% as.factor())