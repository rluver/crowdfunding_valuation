require("RPostgreSQL")




# db

db = dbDriver("PostgreSQL")
con = dbConnect(db, 
                dbname = '', 
                host = '', 
                port = , 
                user = '', 
                password = '')