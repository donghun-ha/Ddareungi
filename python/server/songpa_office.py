from fastapi import APIRouter
import requests
import hosts
import joblib
import numpy as np
from datetime import datetime,timedelta
import holidays
import pandas as pd
"""
author : 신정섭
Description : 송파구청 feature - api & flutter 연결
Date :  2024.12.04
Usage : http://openapi.seoul.go.kr:8088/API_Key/json/citydata/1/5/잠실 관광특구
Usage : http://openapi.seoul.go.kr:8088/API_Key/json/ListAvgOfSeoulAirQualityService/1/5/


<Feature>
연, 월, 일 -> 오늘날짜
시간대 -> 지금 시간 + 유저 입력
03 : get_air
총생활인구수 : Dataframe 평균 or 
유동인구 : get_weather_poplulation

==================================================
연, 월, 일, 시간대, 기온(°C), O3, 총생활인구수,유동인구, 
휴일여부, 계절_0, 계절_1, 계절_2, 계절_3

"""




data= joblib.load('../data/songpa_office_model.h5')
scaler = data['scaler']
model = data['model']




router = APIRouter()



# 날씨 불러오는 함수
def get_population(name : str):
    key = hosts.js_key
    url=f'http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/{name}'
    response = requests.get(url)
    try :
        data=response.json()
        area_ppltn_min = data['CITYDATA']['LIVE_PPLTN_STTS'][0]['AREA_PPLTN_MIN']
        area_ppltn_max = data['CITYDATA']['LIVE_PPLTN_STTS'][0]['AREA_PPLTN_MAX']
        # print(f'실시간 인구 지표 최소값 : {area_ppltn_min}') 
        # print(f'실시간 인구 지표 최대값 : {area_ppltn_max}')
        result = np.mean(area_ppltn_max, area_ppltn_min)
        return{'result' : result}
    except Exception as e :
        print('Error',e)


# 오존 불러오는 함수
def get_air():
    key = hosts.js_key
    url = f'http://openapi.seoul.go.kr:8088/{key}/json/ListAvgOfSeoulAirQualityService/1/5/'
    response = requests.get(url)
    try :
        data = response.json()
        ozone = data['ListAvgOfSeoulAirQualityService']['row'][0]['OZONE']
        # print(f'O3 : {ozone}') # 영어 O
        return(ozone)
    except Exception as e:
        print("Error ", e)






# 계절 원 핫 인코딩 형식으로 만들기
def season(month : int):
    try:
        if month in [3,4,5]:
            input_season ='봄'
        elif month in [6,7,8]:
            input_season ='여름'
        elif month in [9,10,11]:
            input_season ='가을'
        else:
            input_season ='겨울'
        seasons = ['봄','여름','가을','겨울']
        result = [0]*4
        # print(result)
        result[seasons.index(input_season)] =1
        # print(result)
        return result
    except Exception as e:
        print('get_season', e)


# 기온 예보
def get_temp(time : int): # 0 : 1시간후, 1 = 2시간후, 2 = 3시간후
    try:
        key = hosts.js_key
        url=f'http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/잠실 관광특구'
        response = requests.get(url)
        citydata = response.json()['CITYDATA']['WEATHER_STTS'][0]['FCST24HOURS']
        temp =citydata[time-1]['TEMP'] 
        print(time)
        print(temp) 
        return temp
    except Exception as e:
        print('get_temp', e)


# 주말 여부
def is_holiday(time : int):
    try:
        now=datetime.now()
        add = timedelta(hours=time)
        result = now + add
        kr_holidays = holidays.KR()
        if result.weekday() >= 5 or result in kr_holidays : 
        # print([0,1])
            return [0,1]
        else :
            # print([1,0])
            return [1,0]
    except Exception as e:
        print('is_holiday', e)

# 년, 월, 일, 시간 가져오기
def get_date(time : int):
    try:
        now = datetime.now()
        add = timedelta(hours=time)
        result = now + add
        return result.year, result.month, result.day, result.hour
    except Exception as e:
        print('get_date', e)


# 총생활인구, 유동인구 가져오기
def get_population(time : int, holiday : int, month : int):
    df=pd.read_csv('../data/songpa_station_final.csv',index_col=0)
    try :
        if holiday == 1:
            holiday ='평일'
        else :
            holiday ='휴일'
        df=df[(df['월'] == month) & (df['시간대']==time) &(df['휴일여부'] == holiday)]
    # print(df['총생활인구수'].mean())
    # print(df['유동인구'].mean())
        return df['총생활인구수'].mean(), df['유동인구'].mean()
    except Exception as e:
        print('get_population',e)


# 연, 월, 일, 시간대, 기온(°C), O3, 총생활인구수,유동인구, 휴일여부_0,휴일여부_1, 계절_0, 계절_1, 계절_2, 계절_3
# 대여대수, 반납대수 불러오는 함수
@router.get('/predict/')
async def test(time : int):
    try:
        # 입력 데이터 준비
        temp = get_temp(time)
        year,month, day, hour =  get_date(time=time)# 년, 월, 일, 시간대
        o3 =get_air()  # 오존
        holiday = is_holiday(time=time)  # 휴일여부_0,휴일여부_1
        total_population ,floating_population = get_population(time= hour, holiday=holiday[0], month=month) # 유동인구, 총생활인구수
        seasons = season(month=month) # 계절0~3
        # feature 합치기
        feature = np.hstack((year,month, day, hour,temp,o3,total_population, floating_population, holiday, seasons))
        # 스케일링 적용
        scaled_data = scaler.transform(feature.reshape(1, -1))
        prediction = model.predict(scaled_data)[0]
        print(f'년 {year}')
        print(f'월 {month}')
        print(f'일 {day}')
        print(f'시간 {hour}')
        print(f'기온 {temp}')
        print(f'오존 {o3}')
        print(f'총 생활인구 {total_population}')
        print(f'유동인구 {floating_population}')
        print(f'휴일 여부 {holiday}')
        print(f'계절 {seasons}')

        return {'result': {'rent' : np.round(prediction[0]), 'restore' : np.round(prediction[1])}}
    except Exception as e:
        print(e)
        return {'Error': str(e)}

