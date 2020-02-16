from telegram_chatbot import token, start, stop, search, callback_get, error

from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackQueryHandler




# command & function 활성화 하기

def main():
    updater = Updater(token = token)
    dp = updater.dispatcher
    updater.start_polling(timeout = 3)
    echo_handler = MessageHandler(Filters.text, search)    
    dp.add_handler(echo_handler)   
    dp.add_handler(CommandHandler('start', start))
    dp.add_handler(CommandHandler('stop', stop))
    dp.add_handler(CallbackQueryHandler(callback_get))
    # log all errors
    dp.add_error_handler(error)
    updater.idle()

    
    
       
if __name__ == "__main__":
    main()