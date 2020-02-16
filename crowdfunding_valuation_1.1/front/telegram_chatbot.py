from user_define_function import index_bind, FV_CAL, build_box, conn

import logging
import numpy as np
import pandas as pd
import telegram
import urllib.parse
from bs4 import BeautifulSoup
from selenium import webdriver
from telegram import InlineKeyboardButton, InlineKeyboardMarkup
from sklearn.feature_extraction.text import TfidfVectorizer




# information

token = ""
driver = webdriver.Firefox(executable_path = '')




# log

logging.basicConfig(format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s', level = logging.INFO)
logger = logging.getLogger(__name__)




# variable

find_exe = 0
fstart = 0




# start

def start(bot, update):
    
    global fstart, find_exe
    
    fstart = 1
    
    if fstart == 1 and find_exe == 0:
        bot.sendMessage(chat_id = "890804203", text = ("안녕하세요" + "\n" + "\n" + 
                                                        "20191221 아시아경제 프로젝트 기업가치평가 봇입니다" + "\n" + "\n" +
                                                        "이 봇은 앵콜 요청 서포터즈가 존재하는 상품과 기업에 대한 가치를 평가합니다"))
        bot.sendMessage(chat_id = update.message.chat_id, text = "평가를 원하는 상품을 입력해주세요")        
        find_exe = 1

        
        
        
# stop

def stop(bot, update):
    
    global fstart, find_exe
    
    fstart = 0
    find_exe = 0
    

    
# Search

def search(bot, update):
    
    global find_exe, fstart        
    
    if find_exe == 1:                  
        
        # set variable
        global image, link, name, brand, category
    
        # parsing
        bot.send_chat_action(chat_id = update.message.chat_id, action = telegram.ChatAction.TYPING)             
        driver.get("https://www.wadiz.kr/web/wcampaign/search?keyword=" + urllib.parse.quote_plus(update.message.text))
        parsed_html = BeautifulSoup(driver.page_source, "html.parser")    
        
        
        # value arrange
        name = np.array(list(map(lambda x: x.text, parsed_html.select(".card-info-section h4"))))
        index = np.where((np.array(list(map(lambda x: x.find("앵콜"), name))) > 0))
        
        name = list(np.array(name)[index])
        brand = np.array(list(map(lambda x: x.text, parsed_html.select(".card-info-section h5"))))[index]
        image = np.array(list(map(lambda x: BeautifulSoup.get(x, "style")[21:-1], parsed_html.select(".card-img-section"))))[index]
        link = np.array(list(map(lambda x: BeautifulSoup.get(x, "href").split("/")[-1], parsed_html.find(id = "searchResultCard").find_all("a"))))[index]    
        category = np.array(list(map(lambda x: x.text, parsed_html.select(".card-category > .category1"))))[index]
        
        # drop value
        del parsed_html, index
        
        # del empty category
        name = np.array(name)[np.where(category != "")]
        brand = np.array(brand)[np.where(category != "")]
        image = np.array(image)[np.where(category != "")]
        link = np.array(link)[np.where(category != "")]
        category = np.array(category)[np.where(category != "")]
        
        # overlap delete
        index = list(set(range(len(name))) - (set(sum(index_bind(name), [])) - set(map(lambda x: x[0] if len(x) >= 2 else -1, index_bind(name)))))
        
        # value select        
        name = np.array(name)[index]
        brand = np.array(brand)[index]
        image = np.array(image)[index]
        link = np.array(link)[index]
        category = np.array(category)[index]

                
    
        
        # keyboard & select
        inline_keyboard = []        
        if len(index) != 0:
            bot.send_chat_action(chat_id = update.message.chat_id, action = telegram.ChatAction.TYPING)        
            txt = ("%s님께서 입력하신 " + update.message.text + "에 대한 결과는 다음과 같습니다") % (update.message.chat.first_name)
            bot.sendMessage(chat_id = update.message.chat_id, text = txt)
            
            
            for i in range(len(index)):
                bot.send_chat_action(chat_id = update.message.chat_id, action = telegram.ChatAction.TYPING)
                bot.send_photo(chat_id = update.message.chat_id, photo = image[i])
                bot.send_message(chat_id = update.message.chat_id, 
                                 text = "https://www.wadiz.kr/web/campaign/detail/" + link[i])
                inline_keyboard.append(InlineKeyboardButton(text = brand[i], callback_data = brand[i]))
                
            keyboard = InlineKeyboardMarkup(build_box(inline_keyboard, 1))
            
            bot.send_chat_action(chat_id = update.message.chat_id, action = telegram.ChatAction.TYPING)                 
            bot.send_message(chat_id = update.message.chat_id, 
                             text = "가치평가를 원하는 상품의 브랜드를 클릭하세요", 
                             reply_markup = keyboard)        

        else:
            bot.send_chat_action(chat_id = update.message.chat_id, action = telegram.ChatAction.TYPING)
            bot.sendMessage(chat_id = update.message.chat_id, text = "앵콜 상품이 없습니다")        
                
    else:
        bot.sendMessage(chat_id = update.message.chat_id, text = "명령어 /start 를 클릭 또는 입력해주세요")




# callback

def callback_get(bot, update):
    
    global name, brand, find_exe
       
    name_selected = name[list(brand).index(update.callback_query.data)]            
    
    
    if pd.read_sql("SELECT encore FROM wadiz WHERE title = " + "'" + name_selected + "'", conn)["encore"].iloc[0] != None:
        table = pd.read_sql("SELECT title, funding, encore, cat, start FROM wadiz where brand = '" + update.callback_query.data + "'", conn)
                        
    
#----------------------------------------------------------------------------------------------------------------    

    ##할인 이자율 ~ WAAC적용 불가~ 일반적인 스타트업 대출이자율 적용
        r = 0.095
    
    # 와디즈 수수료 0.07    
        wadiz_fee_rate = 0.07
    
    # margin rate
        margin_rate_total = {"테크·가전" : 0.5, "패션·잡화" : 0.3, "뷰티" : 0.6, "푸드" : 0.7,
                             "홈리빙" : 0.5, "디자인소품" : 0.7, "여행·레저" : 0.8, "스포츠·모빌리티" : 0.5,
                             "반려동물" : 0.4, "모임" : 0.5, "공연·컬쳐" : 0.4, "소셜·캠페인" : 0.3,
                             "교육·키즈" : 0.5, "게임·취미" : 0.3, "출판" : 0.3, "기부·후원" : 0.3}
    
    
    # 상품가치평가
        item_book_value = 0    
        
        name = table["title"].tolist()
    
        tfidf_vectorizer = TfidfVectorizer(min_df = 1)
        tfidf_matrix = tfidf_vectorizer.fit_transform(name)
    
        ind_item = np.where(name_selected == np.array(table["title"].tolist()))    
        document_distances = (tfidf_matrix * tfidf_matrix.T)    
        ind_item = np.where(document_distances.toarray()[(ind_item[0].tolist())[0]] > 0.5)[0].tolist()
    
        similiar_list = []
        category = []
        for i in ind_item:
            similiar_list.append(name[i])
            category.append(table["cat"].iloc[i])
        
            margin_rate = margin_rate_total.get(table["cat"].iloc[i])
            
            book_value = ((1 - wadiz_fee_rate) * table["funding"].iloc[i]) * margin_rate
            item_book_value += book_value
    
        period_mean = float(pd.read_sql("SELECT mean_date FROM model WHERE cat = " + "'" + category[0] + "'", conn)['mean_date'])                
        FV = FV_CAL(float(table["encore"].iloc[ind_item[0]]), table["cat"].iloc[ind_item[0]])
        discounted_FV = FV / round(pow((1 + r), (period_mean/365)), 2)
                
        value_item = item_book_value + discounted_FV
        
    

    # 기업가치평가
        value_total = 0
        ind_total = list(set(range(len(table["title"].array))) - set(sum(index_bind(table["title"].array), []))) + index_bind(table["title"].array)
        for i in ind_total:
        
            if type(i) == int:
                margin_rate = margin_rate_total.get(table["cat"].iloc[i])
                book_value = ((1 - wadiz_fee_rate) * table["funding"].iloc[i]) * margin_rate
        
                value_total += book_value
                
            elif len(i) >= 2:
                for j in i:
                        margin_rate = margin_rate_total.get(table["cat"].iloc[j])
                        book_value = ((1 - wadiz_fee_rate) * table["funding"].iloc[j]) * margin_rate
        
                        value_total += book_value
                    
                
                # 미래 예상 이익                
                if table["encore"].iloc[i[0]] != None:
                        period_mean = float(pd.read_sql("SELECT mean_date FROM model WHERE cat = " + "'" + category[[i][0]] + "'", conn)['mean_date'])                
                        FV = FV_CAL(float(table["encore"].iloc[i[0]]), table["cat"].iloc[i[0]])
                        discounted_FV = FV / round(pow((1 + r), (period_mean/365)), 2)
                
                        value_total += discounted_FV

    

#--------------------------------------------------------------------------------------------------------    
    # value send
    
        if True:
            bot.edit_message_text(text = ("%s의 기업 가치는 다음과 같습니다") % update.callback_query.data,
                                  chat_id = update.callback_query.message.chat_id,
                                  message_id = update.callback_query.message.message_id)  
            bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("선택하신 상품에 대한 가치입니다" + "\n" + "\n" +
                                                                                     "앵콜 횟수 : %d" % len(ind_item) + "\n" +
                                                                                     "평가 금액 : %s원" % format(int(value_item), ",")))
            bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("선택하신 기업에 대한 가치입니다" + "\n" "\n" +
                                                                                     "전체 판매 상품 : %d개" % table.shape[0] + "\n" +
                                                                                     "전체 앵콜 횟수 : %d개" % len(np.where(np.array(list(map(lambda x: x.find("앵콜"), table["title"].tolist()))) > 0)) + "\n" +
                                                                                     "총 평가 금액 : %s원" % format(int(value_total), ",")))
            bot.sendMessage(chat_id = update.callback_query.message.chat_id, 
                            text = ("다른 상품을 검색하시려면 계속 입력을" + "\n" +
                                    "원치 않으시면 /stop 을 클릭 또는 입력해주세요"))
        else:
            bot.send_chat_action(chat_id = update.callback_query.message.chat_id, action = telegram.ChatAction.TYPING)            
            bot.send_message(chat_id = update.callback_query.message.chat_id, 
                             text = "해당 제품은 앵콜이 없어 평가진행이 불가합니다")
            bot.send_Message(chat_id = update.callback_query.message.chat_id, 
                            text = ("다른 상품을 검색하시려면 계속 입력을" + "\n" +
                                    "원치 않으시면 /stop 을 클릭 또는 입력해주세요"))
            
            
            
            
# error 처리

def error(bot, update, error):
    logger.warning('Update "%s" caused error "%s"', update, error)
