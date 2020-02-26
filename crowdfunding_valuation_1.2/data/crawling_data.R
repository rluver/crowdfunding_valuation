require("RSelenium")
require("data.table")
require("rvest")
require("stringr")
require("dplyr")




# load function

source("crowdfunding_valuation_1.2/data/user_function.R")




# load driver

remDr = remoteDriver(remoteServerAddr = 'localhost',
                     port = 4445L,
                     browserName = "chrome")
remDr$open()




# data table

table = data.frame()




# code

# tech, fashion, beauty, food, homeliving, design, travel, sports, pet, stage, social, edu, game, publish
cat_num = c(287, 288, 311, 289, 310, 290, 296, 297, 308, 294, 295, 309, 292, 293)
cat_time = c(3, 8, 3, 4, 4, 3, 1.5, 1.5, 3, 1.5, 2, 1.5, 1.5, 1.5)




# main

for(k in length(cat_num)){
  
  # navigate 
  
  remDr$navigate(str_c("https://www.wadiz.kr/web/wreward/category/",
                       cat_num[k],
                       "?keyword=&endYn=ALL&order=recommend", sep = ""))
  
  webElem = remDr$findElement("css", "body")
  
  t = Sys.time() - 61
  
  
  
  # page down
  
  while(timestamp(Sys.time() - t, prefix = "", suffix = "", quiet = T) %>% 
        as.numeric() <= cat_time[k]){
    
    webElem$sendKeysToElement(list(key = "page_down"))

  }
  
  
  
  # crawling
   
  source_page = remDr$getPageSource()[[1]]
   
  table = table %>% 
    bind_rows(
      data_frame(cat = source_page %>% read_html() %>% html_nodes(".ProjectCardList_item__1owJa") %>% html_nodes(".RewardProjectCard_category__2muXk") %>% html_text(),
                 title = source_page %>% read_html() %>% html_nodes(".CardLink_link__1k83H strong") %>% html_text(),
                 sf = ifelse(source_page %>% read_html() %>% html_nodes(".CommonCard_info__1f4kq span.RewardProjectCard_remainingDay__2TqyN") %>% html_text() == "종료",
                             source_page %>% read_html() %>% html_nodes(".CommonCard_info__1f4kq .RewardProjectCard_isAchieve__1LcUu em") %>% html_text(),
                             source_page %>% read_html() %>% html_nodes(".CommonCard_info__1f4kq .RewardProjectCard_remainingDayText__2sRLV") %>% html_text()),
                 se = source_page %>% read_html() %>% html_nodes(".CommonCard_info__1f4kq span.RewardProjectCard_remainingDay__2TqyN") %>% html_text(),
                 image = source_page %>% read_html() %>% html_nodes(".CommonCard_rect__2wpm4 span") %>% html_attr("style") %>% str_extract_all("https://[A-z\\./0-9]+", simplify = T) %>% as.vector(),
                 brand = source_page %>% read_html() %>% html_nodes(".CommonCard_info__1f4kq .RewardProjectCard_makerName__2q4oH") %>% html_text(),
                 funding = source_page %>% read_html() %>% html_nodes(".CommonCard_info__1f4kq .RewardProjectCard_amount__2AyJF") %>% html_text(),
                 link = source_page %>% read_html() %>% html_nodes(".RewardProjectCard_infoTop__3QR5w > a") %>% html_attr("href"),
                 start = mapply(get_start, str_c("https://www.wadiz.kr", link), USE.NAMES = F, SIMPLIFY = T),
                 finish = mapply(get_end, str_c("https://www.wadiz.kr", link), USE.NAMES = F, SIMPLIFY = T),
                 encore = mapply(get_encore, str_c("https://www.wadiz.kr", link), USE.NAMES = F, SIMPLIFY = T) %>% mapply(replace_empty, ., SIMPLIFY = T),
                 brandlink = mapply(get_brandlink, str_c("https://www.wadiz.kr", link), USE.NAMES = F, SIMPLIFY = T),
                 name = mapply(get_name, str_c("https://www.wadiz.kr", link), USE.NAMES = F, SIMPLIFY = T) %>% mapply(replace_empty, ., USE.NAMES = F)
                ) %>% 
        select(cat, title, name, sf, se, image, brand, funding, link, start, finish, encore, brandlink)
    )
}




# remove var

rm(source_page, t, webElem, remDr, cat_num, cat_title)