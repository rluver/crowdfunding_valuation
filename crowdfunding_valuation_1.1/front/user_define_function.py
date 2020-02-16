from db_info import conn

import re
import math
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer




# overlap delete

def index_select(x):
    
    # permutation list
    l = []
    for i in range(len(x)):
        for j in range(i):
            l.append([i,j])

    # overlap delete            
    i = 0
    l_deleted = []           
    while i < len(l):
        a, b = l[i]                
        if len(set(x[a]) & set(x[b])) == 2:            
            l_deleted.append(l[i])
        i += 1
        
    return l_deleted




# index_binding    
    
def index_bind(x):    
    tfidf_vectorizer = TfidfVectorizer(min_df = 1)
    tfidf_matrix = tfidf_vectorizer.fit_transform(x)
    document_distances = (tfidf_matrix * tfidf_matrix.T)
    document_distances[np.diag_indices_from(document_distances)] = 0        
    tem = np.where(document_distances.toarray() > 0.5)                
    tem = list(zip(tem[0], tem[1]))    
    
    j = 0
    for i in list(map(lambda x: x[0], index_select(tem))):        
        tem.pop(i - j)
        j += 1
    
    if len(tem) > 1:                            
        l = []
        for i in range(len(tem)):
            for j in range(i):
                l.append([i,j])
        
        i = 0
        j = len(tem)
            
        # 합치면서 len이 줄어 index 오류 발생 but 모든 값이 유일할 경우를 위해 에러를 감안하고 사용            
        while True:
            x, y = l[i]                
            if len(set(tem[x]) & set(tem[y])) != 0:
                tem.append(set(tem[x]) | set(tem[y]))
                tem.remove(tem[x])
                tem.remove(tem[y])
                i = 0
                j -= 1
            else:
                i += 1
                            
            if i == j:                    
                break;
    
    tem = list(map(list, tem))
                
    return tem




# Cal FV
    
def FV_CAL(encore, cat):
    model = re.split("[= | * | +]", pd.read_sql("SELECT model FROM model WHERE cat = " + "'" + cat + "'", conn)['model'].iloc[0].replace(" ", ""))
    y = float(model[1]) * math.log(encore) + float(model[3])
    
    return math.exp(y)




# build button menu

def build_box(buttons, n_cols, header_buttons = None, footer_buttons = None):
    menu = [buttons[i:i + n_cols] for i in range(0, len(buttons), n_cols)]    
    return menu