require("data.table")
require("dplyr")
require("stringr")
require("text2vec")




# data load
table = bind_rows(list.files("d:/table", pattern = "*.csv", full.names = T) %>% 
                    purrr::map_df(~fread(., header = T, encoding = "UTF-8"))) %>% 
  filter(se == "종료") %>% 
  mutate(start = start %>% ymd(),
         end = end %>% ymd(),
         sf = sf %>% str_replace_all("^$", "실패"),
         title = title %>% str_replace_all("\\W", " ") %>% 
           str_replace_all(" {2,}", " "))




# data set
# tokenization
i_train = itoken(table %>% select(title) %>% unlist() %>% as.vector(),
                 str_to_lower,
                 tokenizer = word_tokenizer,
                 progressbar = T)

# create vocab vector
vectorizer = create_vocabulary(i_train) %>% 
  vocab_vectorizer()

# create tfidf matrix
train_tfidf = create_dtm(i_train, vectorizer) %>% 
  fit_transform(TfIdf$new())


# set test sentence
i_sentence = itoken('제주도힐링여행 제주도한달살기 프로젝트',
                    tokenizer = word_tokenizer,
                    progressbar = T)

sen_tfidf = create_dtm(i_sentence, vectorizer) %>% 
  fit_transform(TfIdf$new())




# tfidf cosine distance
similarity_table = data.frame(index = seq(sim2(train_tfidf, sen_tfidf, method = 'cosine', norm = 'l2')@Dim[1])) %>% 
  bind_cols(sim2(train_tfidf, sen_tfidf, method = 'cosine', norm = 'l2') %>% as.matrix() %>% as.data.frame()) %>% 
  rename(similarity = '1')



# extract
similarity_table %>% arrange(desc(similarity)) %>% head(5) %>% select(similarity) %>% 
  bind_cols(
    table_end %>% slice(similarity_table %>% arrange(desc(similarity)) %>% head(5) %>% select(index) %>% unlist()) %>% 
      select(title)
    )




# tfidf lsa
# create tfidf with lsa matrix
train_tfidf_lsa = create_dtm(i_train, vectorizer) %>% 
  fit_transform(TfIdf$new()) %>% 
  fit_transform(LSA$new(n_topics = 100))


# tfidf with lsa cosine distance
distance_table_lsa = data.frame(index = seq(sim2(train_tfidf, sen_tfidf, method = 'cosine', norm = 'l2')@Dim[1])) %>% 
  bind_cols(dist2(train_tfidf_lsa, train_tfidf_lsa, method = 'euclidean', norm = 'l2')[12072, ] %>% as.data.frame()) %>% 
  rename(distance = '.')


# extract
distance_table_lsa %>% arrange(distance) %>% head(5) %>% select(distance) %>% 
  bind_cols(
    table_end %>% slice(distance_table_lsa %>% arrange(distance) %>% head(5) %>% select(index) %>% unlist()) %>% 
      select(title)
  )



# tfidf with lsa cosine similarity
similarity_table_lsa = data.frame(index = seq(sim2(train_tfidf, sen_tfidf, method = 'cosine', norm = 'l2')@Dim[1])) %>% 
  bind_cols(sim2(train_tfidf_lsa, train_tfidf_lsa, method = 'cosine', norm = 'l2')[12072, ] %>% as.data.frame()) %>% 
  rename(similarity = '.')


# extract
similarity_table_lsa %>% arrange(desc(similarity)) %>% head(5) %>% select(similarity) %>% 
  bind_cols(
    table_end %>% slice(similarity_table_lsa %>% arrange(desc(similarity)) %>% head(5) %>% select(index) %>% unlist()) %>% 
      select(title)
  )
