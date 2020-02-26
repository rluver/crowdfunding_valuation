require("stringr")
require("rvest")
require("dplyr")




# user define function

get_start = function(link){
  
  link %>% read_html() %>% html_nodes("div.wd-ui-cont p") %>% 
    html_text() %>% str_extract("펀딩기간.+") %>% 
    str_extract_all("\\d{4}\\.\\d{2}\\.\\d{2}", simplify = T) %>% 
    as.vector() %>% stringi::stri_remove_empty() %>% 
    sort() %>% head(1) %>% 
    return()
}



get_end = function(link){
  
  link %>% read_html() %>% html_nodes("div.wd-ui-cont p") %>% 
    html_text() %>% str_extract("펀딩기간.+") %>% 
    str_extract_all("\\d{4}\\.\\d{2}\\.\\d{2}", simplify = T) %>% 
    as.vector() %>% stringi::stri_remove_empty() %>% 
    sort() %>% tail(1) %>% 
    return()
}



get_encore = function(link){
  
  link %>% read_html() %>% html_nodes(".project-state-info p span") %>% 
    html_text() %>% unique() %>% 
    return()
}



get_brandlink = function(link){
  
  str_c("https://www.wadiz.kr/web/wmypage/myprofile/makinglist/",
        link %>% read_html() %>% html_nodes(".maker-info button") %>% 
          html_attr("onclick") %>% stringi::stri_remove_na() %>% 
          str_extract("[\\d]+")) %>% 
    return()
}



replace_empty = function(string){
  
  if(rlang::is_empty(string) == T){
    return(string = NA)
  } else{
    return(string)
  }
}



get_fundinginfo_url = function(link){
  
  link %>% str_replace_all("\\/(?=[\\d]+)", "/fundingInfo/") %>% 
    return()
}



get_name = function(link){
  
  index = link %>% get_fundinginfo_url() %>%  
    read_html() %>% 
    html_nodes("#reward-static-product-content-app") %>% 
    html_attr("data-product-content-list") %>% 
    str_split(",", simplify = T) %>% str_subset("itemName") %>% 
    str_split(":", simplify = T) %>% str_replace_all('^\\"|\\"$', "") %>% 
    str_detect("품명|모델명")
  
  if(index %>% sum() != 0){
    (link %>% get_fundinginfo_url() %>% read_html() %>% 
      html_nodes("#reward-static-product-content-app") %>% 
      html_attr("data-product-content-list") %>% 
      str_split(",", simplify = T) %>% str_subset("itemValue") %>% 
      str_split(":", simplify = T) %>% str_replace_all('^\\"|\\"$', ""))[index] %>%
      str_replace_all("\\\\r\\\\n", " ") %>% 
      str_replace_all("\\\\r|\\\\n", " ") %>% 
      stringi::stri_remove_empty() %>% 
      str_c(collapse = "|") %>% 
      return()
  }
}