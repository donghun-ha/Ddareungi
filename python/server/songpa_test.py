"""
author : 신정섭
Description : 송파구청 함수 테스트용
Date :  2024.12.04
"""
import joblib
from fastapi import APIRouter
import numpy as np
'''Feature
연, 월, 일 -> 오늘날짜
시간대 -> 지금 시간 + 유저 입력
03 : API(오존)
총생활인구수 : Dataframe 평균 or 
유동인구 : API

==================================================
연, 월, 일, 시간대, 기온(°C), O3, 총생활인구수,유동인구, 
휴일여부_평일, 휴일여부_휴일, 계절_봄, 계절_여름, 계절_가을, 계절_겨울

'''


router = APIRouter()

data= joblib.load('../data/songpa_office_model.h5')
scaler = data['scaler']
model = data['model']





@router.get('/predict')
async def test():
    try:
        input = np.array([2024, 12, 4, 12, 4, 1, 2000, 2000, 1, 0, 0, 0, 0, 1]).reshape(1, -1)
        feature=scaler.transform(input)
        print(f'예측값 : {model.predict(feature)}')
        return {'예측값': model.predict(feature)}
    except Exception as e:
        print(e)
        return{'Error': e}






if __name__ == '__main__':
    test()
    # a()