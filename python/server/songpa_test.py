"""
author : 신정섭
Description : 송파구청 함수 테스트용
Date :  2024.12.04
"""
import joblib
from fastapi import APIRouter
import numpy as np
import pandas as pd
'''Feature
연, 월, 일 -> 오늘날짜
시간대 -> 지금 시간 + 유저 입력
03 : API(오존)
총생활인구수 : Dataframe 평균 or 
유동인구 : API

==================================================
연, 월, 일, 시간대, 기온(°C), O3, 총생활인구수,유동인구, 
휴일여부, 계절_0, 계절_1, 계절_2, 계절_3

'''


router = APIRouter()

data= joblib.load('../data/songpa_office_model.h5')
scaler = data['scaler']
model = data['model']



@router.get('/predict')
async def test():
    try:
        # 입력 데이터 준비
        input_scale = [2000, 2000]  # 총생활인구수, 유동인구 
        front_data = [2024,12,4,14,3,3]  # 연, 월, 일 , 시간대, 기온, 오존
        back_data = [1,0,0,0,0,1] # 휴일여부, 계절_0, 계절_1, 계절_2, 계절_3
        # feature 합치기
        feature = np.hstack((front_data, input_scale, back_data))
        # 스케일링 적용
        scaled_data = scaler.transform(feature.reshape(1,-1))
        
        prediction = model.predict(scaled_data)
        
        print(f'예측값 : {feature}')
        # print(f'예측값 : {prediction}')
        # return {'예측값': prediction.tolist()}
        return {'예측값': feature}
    except Exception as e:
        print(e)
        return {'Error': str(e)}



if __name__ == '__main__':
    test()
    # a()