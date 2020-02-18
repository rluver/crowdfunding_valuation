require("RSelenium")
require("rvest")
require("stringr")
require("dplyr")




# load driver

remDr = remoteDriver(remoteServerAddr = 'localhost',
                     port = 4445L,
                     browserName = "chrome")
remDr$open()




# user define

"%!in%" = Negate("%in%")
j = 0




# data table

table = as.data.frame(matrix(0, nc = 13))
colnames(table) = c("cat", "name", "title", "sf", "se", "image", "brand", "funding", "link", "start", "end", "encore", "brandlink")




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
  
  
  # parsing
  
  card = remDr$getPageSource()[[1]] %>% read_html() %>% html_nodes(".ProjectCardList_item__1owJa")
  
  
  
  # crawling
  
  for(i in 1:length(card)){
    
    j = i + 1
    
    if((card[[i]] %>% html_nodes("span"))[2] %>% html_text() %!in% "마감임박"){
      cat = (card[[i]] %>% html_nodes("span"))[2] %>% html_text() # 분류
      title = card[[i]] %>% html_node("strong") %>% html_text()  # 제목
      sf = (card[[i]] %>% html_nodes("span"))[9] %>% html_text() # SF
      se = (card[[i]] %>% html_nodes("span"))[8] %>% html_text() # SF
      image = str_split((card[[i]] %>% html_nodes("span"))[1] %>% html_attr("style"), '"')[[1]][2] # 이미지
      brand = (card[[i]] %>% html_nodes("span"))[3] %>% html_text() # 상호
      funding = (card[[i]] %>% html_nodes("span"))[6] %>% html_text() # 펀딩액
      link = str_c("https://wadiz.kr", (card[[i]] %>% html_nodes("a") %>% html_attr("href"))[1])
      
      remDr$navigate(link) 
      html = read_html(remDr$getPageSource()[[1]])
      dec = str_detect(html %>% html_node(".wd-ui-cont") %>% html_nodes("p"), "펀딩기간")
      day = (html %>% html_node(".wd-ui-cont") %>% html_nodes("p"))[dec] %>% html_text()
      day_split = str_split(day, " ")
      start = str_split(day_split[[1]][7], "-")[[1]][1] # start
      finish = str_split(day_split[[1]][7], "-")[[1]][2] # end
      encore = html %>% html_node(".project-state-info") %>% html_node("p > span") %>% html_text() # 앵콜 
      brandlink = str_c("https://www.wadiz.kr/web/wmypage/myprofile/makinglist/", str_split((html %>% html_node(".maker-info") %>% html_nodes("dt")), "'")[[1]][2]) # 브랜드링크 
      
      link = str_c("https://www.wadiz.kr/web/campaign/detail/fundingInfo/", str_split(link, "/")[[1]][7])
      remDr$navigate(link)
      html = read_html(remDr$getPageSource()[[1]])
      name = html %>% html_node(".RewardProductInfoContentItem_value__2JrsZ") %>% html_text()
      
      table[j, ] = c(cat, name, title, sf, se, image, brand, funding, link, start, finish, encore, brandlink)
    
    } 
    else {
      cat = (card[[i]] %>% html_nodes("span"))[3] %>% html_text() # 분류
      title = card[[i]] %>% html_node("strong") %>% html_text()  # 제목
      sf = (card[[i]] %>% html_nodes("span"))[9] %>% html_text() # SF
      se = (card[[i]] %>% html_nodes("span"))[8] %>% html_text() # SF
      image = str_split((card[[i]] %>% html_nodes("span"))[1] %>% html_attr("style"), '"')[[1]][2] # 이미지
      brand = (card[[i]] %>% html_nodes("span"))[3] %>% html_text() # 상호
      funding = (card[[i]] %>% html_nodes("span"))[7] %>% html_text() # 펀딩액
      link = str_c("https://wadiz.kr", (card[[i]] %>% html_nodes("a") %>% html_attr("href"))[1])
      
      remDr$navigate(link) 
      html = read_html(remDr$getPageSource()[[1]])
      dec = str_detect(html %>% html_node(".wd-ui-cont") %>% html_nodes("p"), "펀딩기간")
      day = (html %>% html_node(".wd-ui-cont") %>% html_nodes("p"))[dec] %>% html_text()
      day_split = str_split(day, " ")
      start = str_split(day_split[[1]][7], "-")[[1]][1] # start
      finish = str_split(day_split[[1]][7], "-")[[1]][2] # end
      encore = html %>% html_node(".project-state-info") %>% html_node("p > span") %>% html_text() # 앵콜 
      brandlink = str_c("https://www.wadiz.kr/web/wmypage/myprofile/makinglist/", str_split((html %>% html_node(".maker-info") %>% html_nodes("dt")), "'")[[1]][2]) # 브랜드링크 
      
      link = str_c("https://www.wadiz.kr/web/campaign/detail/fundingInfo/", str_split(link, "/")[[1]][7])
      remDr$navigate(link)
      html = read_html(remDr$getPageSource()[[1]])
      name = html %>% html_node(".RewardProductInfoContentItem_value__2JrsZ") %>% html_text()
      
      table[j, ] = c(cat, name, title, sf, se, image, brand, funding, link, start, finish, encore, brandlink)
    }
  }
  
}
