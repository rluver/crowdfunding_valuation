# -*- coding: utf-8 -*-
"""
Created on Tue Oct 15 14:05:11 2019

@author: caute
"""

import requests
import json
import datetime
import re
import time
import logging
import telegram
import urllib.parse
import numpy as np
from urllib.request import urlopen
from bs4 import BeautifulSoup
from selenium import webdriver
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackQueryHandler
from telegram import InlineKeyboardButton, InlineKeyboardMarkup
from datetime import datetime
from pyvirtualdisplay import Display



# 변수 정의

base_url='https://www.wadiz.kr/web/campaign/detail/{}'

##할인 이자율 ~ WAAC적용 불가~ 일반적인 스타트업 대출이자율 적용
r=float(0.095)

#와디즈 수수료
fee_rate=float(0.07)

#포장비
wrap_fee=int(300)

now = datetime.now()




# 가치평가 함수 정의

def get_bs_obj(i):
    
    url = base_url.format(i)
    result = requests.get(url)
    bs_obj = BeautifulSoup(result.content, "html.parser")
    return bs_obj

def get_total_amount(bs_obj):
    fund_box = bs_obj.find("div", {"class":"state-box"})
    fund_total = fund_box.find("p",{"class":"total-amount"})
    fund_total_amount=fund_total.text
    replace=re.sub(r'\D',"",fund_total_amount)
    return int(replace)


def get_goal_amount(bs_obj):
    fund_box = bs_obj.find("p", {"style":"color:#00cca3;font-size:13px;line-height:20px;margin-bottom:10px;"}).text
    #100만-40~9/1000만-41~10/1억-42~11
    #css태그가 불친절 ~노가다 //다른 방법 고려 필요
    if len(str(fund_box))==40:
        
        fund_box_goal=str(fund_box)[6:15]
    elif len(str(fund_box))==41:
        fund_box_goal=str(fund_box)[6:16]
    else:
        fund_box_goal=str(fund_box)[6:17]
    
    return int(fund_box_goal.replace(',',"").replace('원',""))


def get_period(bs_obj):
    fund_box = bs_obj.find("p", {"style":"color:#00cca3;font-size:13px;line-height:20px;margin-bottom:10px;"}).text
   
    fund_box_period_str=str(fund_box)[-10:].replace(".","-")
    ##연산 위해 데이트타입 타입으로
    fund_box_period_datetime=datetime.strptime(fund_box_period_str,'%Y-%m-%d')
    ##데이트타입 간 연산 --> datetime.delta
    a=fund_box_period_datetime-now
    #a.days--> 날짜만 추출
    return int(a.days)

def get_reward_pages(bs_obj):
    reward_pages=bs_obj.find("div",{"class":"wd-ui-gift"})
    reward_pages_SP=reward_pages.findAll("button")
    
    ## 2차원 배열 초기화
    info1 = []
    info2 = []
    info3 = []    
    list = [info1, info2, info3]
    for i in range(len(reward_pages_SP)): 
        list[0].append([])
        list[1].append([])
        list[2].append([])
    
    for i in range(len(reward_pages_SP)): ## range의 첫번째 값만 추출되는 것으로 미루어보아 이 쪽이 뭔가 문제가 있는데 ...... 
        globals()['reward{}'.format(i)]=reward_pages_SP[i]
        page_info1=re.sub(r'\D',"",globals()['reward{}'.format(i)].find("dt").text)
        
        ## 첫번째 나오는 숫자만 표현 
        page_info2=re.sub(r'\D',"",globals()['reward{}'.format(i)].find("li",{"class":"shipping"}).text)
        
        page_info3=re.sub(r'\D',"",globals()['reward{}'.format(i)].find("p",{"class":"reward-soldcount"}).text)
        
        
        
        # 리스트 담기
        list[0][i] = int(page_info1)
        list[1][i] = int(page_info2)
        list[2][i] = int(page_info3)
        
    return list

## 여타비용 (배송비,포장비)
def cost_estimation(fund_total,fee_rate,page_info):
    ## invalid character in identifier 오류 fee_rate를 전역변수로 설정하니 해결됨...이유는?
    wadiz_fee=fee_rate*fund_total
    
    wrap_fee=300

    delivery_fee=np.array(page_info[1])
    funding_count=np.array(page_info[2])
    
    total_fee=wadiz_fee+(delivery_fee+wrap_fee)*funding_count
    sumation=sum(total_fee)
    return sumation
###예상이익 : 총펀딩액-목표금액 (목표금액은 확실히 실행될 것을 고려 -매출액으로 )
def estimated_profit(fund_total,fund_goal):
    
    return fund_total-fund_goal
    
####원가 계산 (총펀딩액-여타비용)* 마진율    
def prime_cost_calculate(fund_total,cost_estimation,margin):
    prime_cost=(fund_total-cost_estimation)*margin
    
    return prime_cost
def pv(fund_period,r):
    ## 일단 약식으로 ~ 아마 타임 델타 써야 할듯
    ##이미 계산 된 줄 모르고 now 넣어서 오류 
    
    PV=1/(1+r*(fund_period/int(365)))
    return PV
 ###기업 가치평가   
def company_value_estimation(fund_goal,prime_cost_calculate,estimated_profit,PV):
    #BOOK VALUE(목표금액-원가)+예상이익*할인율
    last_estimation=fund_goal-prime_cost_calculate+estimated_profit*PV
    
    return int(last_estimation)




# bot information

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',level=logging.INFO)
logger = logging.getLogger(__name__)
token = ""
display = Display(visible = 0, size = (800, 600))
display.start()
driver = webdriver.Chrome(executable_path='usr/lib/chromium-browser/chromedriver')
    



# 버튼 메뉴 설정

def build_box(buttons, n_cols, header_buttons = None, footer_buttons = None):
    menu = [buttons[i:i + n_cols] for i in range(0, len(buttons), n_cols)]    
    return menu
 



# start

def start(bot, update):
   #사용자 name 
    print(update.message.chat.username)
    t = ("안녕하세요 %s" + "\n" + "데이터야놀자 기업가치평가 봇입니다") % update.message.chat.first_name
    bot.sendMessage(chat_id=update.message.chat_id, text=t)
    bot.sendMessage(chat_id=update.message.chat_id, text = "평가를 원하는 상품을 입력해주세요")         


    
    
# 검색어 입력

def find(bot, update):
      
    # set variable
    global url1, url2, url, image, link, name, brand, index
    
    url1 = "https://www.wadiz.kr/web/campaign/detail/"
    url2 = "https://www.wadiz.kr/web/wcampaign/search?keyword="
    bot.send_chat_action(chat_id = update.message.chat_id, action=telegram.ChatAction.TYPING)

    
    url3 = update.message.text
    url3_parsed = urllib.parse.quote_plus(url3)
    url = url2 + url3_parsed
    
    driver.get(url)
    html = driver.page_source
    parsed_html = BeautifulSoup(html, "html.parser")
    parsed_name = parsed_html.select(".card-info-section h4")
    parsed_brand = parsed_html.select(".card-info-section h5")

    image = []
    for i in parsed_html.select(".card-img-section"):
        image.append(i.get("style")[21:-1])
    link = []
    for url in parsed_html.find(id = "searchResultCard").find_all("a"):
        link.append(url.get("href").split("/")[-1])        
    name = []
    for i in parsed_name:
        name.append(i.text)
    brand = []
    for i in parsed_brand:
        brand.append(i.text)
    index = []
    for i in range(len(name)):
        if name[i].find("앵콜") != -1:
            index.append(i)

    inline_keyboard = []
    #image 입력
    if len(index) != 0:
        bot.send_chat_action(chat_id = update.message.chat_id, action=telegram.ChatAction.TYPING)
        t = "와디즈 리워드 중 앵콜이 이루어진 " + url3 + "은(는) 다음과 같습니다"
        bot.sendMessage(chat_id = update.message.chat_id, text = t)
        
        for i in range(len(index)):
            bot.send_photo(chat_id=update.message.chat_id, photo=image[index[i]])
            bot.send_message(chat_id = update.message.chat_id, text = url1 + link[index[i]])    
            inline_keyboard.append(InlineKeyboardButton(text = brand[index[i]], callback_data = brand[index[i]]))            

        keyboard = InlineKeyboardMarkup(build_box(inline_keyboard, 1))
        bot.send_message(chat_id = update.message.chat_id, text = "가치평가를 원하는 상품의 브랜드를 클릭하세요", 
                         reply_markup = keyboard)    

    else:
        bot.send_chat_action(chat_id = update.message.chat_id, action=telegram.ChatAction.TYPING)
        bot.sendMessage(chat_id = update.message.chat_id, text = "앵콜 상품이 없습니다")


    

# callback

def callback_get(bot, update):
    for i in range(len(index)):
        if update.callback_query.data == brand[index[i]]:
            val_url3 = brand[index[i]]
    
    val_url3_parsed = urllib.parse.quote_plus(val_url3)
    val_url = url2 + val_url3_parsed
    driver.get(val_url)
    html = driver.page_source
    parsed_html = BeautifulSoup(html, "html.parser")
    code = []
    for url in parsed_html.find(id = "searchResultCard").find_all("a"):
        code.append(url.get("href").split("/")[-1])      


    margin = float(0.3)

    for i in code:
        bs_obj = get_bs_obj(i)     
        Fund_total = get_total_amount(bs_obj)    
        Fund_goal=get_goal_amount(bs_obj)
        Fund_period=get_period(bs_obj)
        Page_info=get_reward_pages(bs_obj)
        Cost_estimation=cost_estimation(Fund_total,fee_rate,Page_info)
        Prime_cost_calculate=prime_cost_calculate(Fund_total,Cost_estimation,margin)
        Estimated_profit=estimated_profit(Fund_total,Fund_goal)
        PV=pv(Fund_period,r)    
        Company_value_estimation=company_value_estimation(Fund_goal,Prime_cost_calculate,Estimated_profit,PV)


    ##일단 0.3넣고 가정  마진율 딕셔너리 값 고려 필요
   
   
    # 튜플을 리스트로 변환하려니 NON타입 에러가 뜬다--> 논타입이다--> 왜 논타입일까? 인트가 아닌데 데이터 프레임 씌워서
    
def callback_get(bot, update):
    for i in range(len(index)):
        if update.callback_query.data == brand[index[i]]:
            bot.send_chat_action(chat_id = update.callback_query.message.chat_id, action=telegram.ChatAction.TYPING)
            val_url3 = brand[index[i]]
            z = i
    
    val_url3_parsed = urllib.parse.quote_plus(val_url3)
    val_url = url2 + val_url3_parsed
    driver.get(val_url)
    html = driver.page_source
    parsed_html = BeautifulSoup(html, "html.parser")
    code = []
    for url in parsed_html.find(id = "searchResultCard").find_all("a"):
        code.append(url.get("href").split("/")[-1])      


    margin = float(0.3)

    for i in code:
        bs_obj = get_bs_obj(i)     
        Fund_total = get_total_amount(bs_obj)    
        Fund_goal=get_goal_amount(bs_obj)
        Fund_period=get_period(bs_obj)
        Page_info=get_reward_pages(bs_obj)
        Cost_estimation=cost_estimation(Fund_total,fee_rate,Page_info)
        Prime_cost_calculate=prime_cost_calculate(Fund_total,Cost_estimation,margin)
        Estimated_profit=estimated_profit(Fund_total,Fund_goal)
        PV=pv(Fund_period,r)    
        Company_value_estimation=company_value_estimation(Fund_goal,Prime_cost_calculate,Estimated_profit,PV)


    ##일단 0.3넣고 가정  마진율 딕셔너리 값 고려 필요
   
   
    # 튜플을 리스트로 변환하려니 NON타입 에러가 뜬다--> 논타입이다--> 왜 논타입일까? 인트가 아닌데 데이터 프레임 씌워서
      
    if(update.callback_query.data == "CCC COMPANY"):
         bot.edit_message_text(text = "해당 기업의 가치는 다음과 같습니다",
                               chat_id = update.callback_query.message.chat_id,
                               message_id = update.callback_query.message.message_id)        
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("기업명 : %s" % brand[index[z]]))
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("펀딩 횟수 : %d" % len(code)))
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("평가 금액 : %s" % format(Company_value_estimation, ",")))
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = "상품을 다시 입력해주세요")
    else:
         bot.edit_message_text(text = "해당 기업의 가치는 다음과 같습니다",
                               chat_id = update.callback_query.message.chat_id,
                               message_id = update.callback_query.message.message_id)
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("기업명 : %s" % brand[index[z]]))
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("펀딩 횟수 : %d" % len(code)))
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = ("평가 금액은 준비 중입니다"))
         bot.sendMessage(chat_id = update.callback_query.message.chat_id, text = "상품을 다시 입력해주세요")

        
        

# err or 처리

def error(bot, update, error):
    logger.warning('Update "%s" caused error "%s"', update, error)




# command & function 활성화 하기

def main():
    updater = Updater(token = token)
    dp = updater.dispatcher
    updater.start_polling(timeout = 3)
    echo_handler = MessageHandler(Filters.text, find)
    dp.add_handler(echo_handler)
    dp.add_handler(CommandHandler('start', start))
    dp.add_handler(CallbackQueryHandler(callback_get))
    # log all errors
    dp.add_error_handler(error)
    updater.idle()
    
    
    
    
if __name__ == "__main__":
    main()
     

