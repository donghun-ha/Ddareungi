from fastapi import APIRouter
import requests
import hosts
import joblib
import numpy as np
from datetime import datetime, timedelta
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


# data= joblib.load('../data/songpa_office_model.h5')
# scaler = data['scaler']
# model = data['model']


router = APIRouter()


# 날씨 불러오는 함수
def get_population(name: str):
    key = hosts.js_key
    url = f"http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/{name}"
    response = requests.get(url)
    data = response.json()
# 롯데타워 잠실역 2번출구 따릉이 스테이션 정보 찾기
    target_station = None
    for station in data['rentBikeStatus']['row']:
        if "ST-1681" in station['stationId']:
            target_station = station
            print(f'대여소 명 {target_station}')
            break
    # 결과 출력
    if target_station:
        # print(f"스테이션 이름: {target_station['stationName']}")
        # print(f"현재 사용 가능한 자전거 수: {target_station['parkingBikeTotCnt']}")
        # print(f"거치대 개수: {target_station['rackTotCnt']}")
        # print(f"거치율: {target_station['shared']}%")
        # print(f'LCD + QR 거치율 : {int(target_station['parkingBikeTotCnt']) / (int(target_station['rackTotCnt'])+15)}')
        return int(target_station['parkingBikeTotCnt']), (int(target_station['rackTotCnt'])+15) #현재 , 거치대 
    else:
        print(" 송파구청 데이터 없음")


# 오존 불러오는 함수
def get_air():
    key = hosts.js_key
    url = f"http://openapi.seoul.go.kr:8088/{key}/json/ListAvgOfSeoulAirQualityService/1/5/"
    response = requests.get(url)
    try:
        data = response.json()
        ozone = data["ListAvgOfSeoulAirQualityService"]["row"][0]["OZONE"]
        # print(f'O3 : {ozone}') # 영어 O
        return ozone
    except Exception as e:
        print("air ", e)


def songpa_cal(total, count):
    # 30%, 80% 
    min_count = np.trunc(total * 0.7)
    max_count = np.trunc(total * 1.5)
    # d_count = total * 0.7
    # 미래 
    # if (count - d_count) > 0 : # 최대보다 예상치가 크면 +
    #     result=-(count - d_count) # result 만큼 빼기
    # elif (count - d_count) < 0 : # 최소보다 작으면 -
    #     result = -(count - d_count) # result 만큼 채우기
    # else:
    #     result = 0
    # return result
    if (count - max_count) > 0 : # 최대보다 예상치가 크면 +
        result=-(count - max_count) # result 만큼 빼기
    elif (count - min_count) < 0 : # 최소보다 작으면 -
        result = -(count - min_count) # result 만큼 채우기
    else:
        result = 0
    return result

def insert_songpa(date, current, rent, restore, fill_count,standard_time):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into manage (user_id, station_code,date,cr_count,rent,restore,fill_count,standard_time) values (%s,%s ,%s, %s, %s,%s,%s,%s)'
        curs.execute(sql,('songpa','ST-1681',date, current,rent, restore, fill_count, standard_time))
        conn.commit()
        conn.close()
        print('ok')
        
    except Exception as e:
        print('insert_Error',e)

# 기온 예보
def get_temp(time: int):  # 0 : 1시간후, 1 = 2시간후, 2 = 3시간후
    key = hosts.js_key
    url = f"http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/잠실 관광특구"
    response = requests.get(url)
    citydata = response.json()["CITYDATA"]["WEATHER_STTS"][0]["FCST24HOURS"]
    temp = citydata[time - 1]["TEMP"]
    # print(citydata[time]['TEMP'])
    return temp


# 주말 여부
def is_holiday():
    now = datetime.now()
    kr_holidays = holidays.KR()
    if now.weekday() >= 5 or now in kr_holidays:
        # print([0,1])
        return [0, 1]
    else:
        # print([1,0])
        return [1, 0]


def get_date(time: int):
    now = datetime.now()
    add = timedelta(hours=time)
    result = now + add
    return result.year, result.month, result.day, result.hour


def get_population(time: int, holiday: int, month: int):
    df = pd.read_csv("python/data/songpa_station_final.csv", index_col=0)
    df = df[(df["월"] == month) & (df["시간대"] == time) & (df["휴일여부"] == holiday)]
    print(df["총생활인구수"].mean())
    print(df["유동인구"].mean())


# 연, 월, 일, 시간대, 기온(°C), O3, 총생활인구수,유동인구, 휴일여부_0,휴일여부_1, 계절_0, 계절_1, 계절_2, 계절_3
# 대여대수, 반납대수 불러오는 함수
@router.get("/predict/")
async def test(time: int):
    try:
        # 초기값 설정
        station_init, total_rack = get_station()  # 스테이션 초기 상태
        temp_data = get_temp()  # 24시간 기온 데이터
        o3 = get_air()  # 대기질 데이터 (한 번만 호출)
        results= []
        count = station_init  # 초기 자전거 수
        
        # print(f'구획수 {total_rack}')
            
        for i in range(24):  # 24시간 예측
            year, month, day, hour, standard_time = get_date(i)
            holiday = get_holiday(i)
            temp = temp_data[i]
            seasons = get_season(month)
            total_population, floating_population = get_population(i, holiday[0], month)
            feature=[]
            # 특징(feature) 생성
            feature = np.hstack((year, month, day, hour, temp, o3,
                                total_population, floating_population,
                                holiday, seasons))
            print(f'년 월 일{year, month, day}')
            print(f'시간 {standard_time}')
            print(f'기온 {temp}')
            print(f'오존 {o3}')
            print(f'총 생활인구 {total_population}')
            print(f'총 유동인구 {floating_population}')
            print(f'휴일 여부 {holiday}')
            print(f'계절 {seasons}')
            scaled_data = scaler.transform(feature.reshape(1, -1))
            prediction = model.predict(scaled_data)[0]  # 대여/반납 예측
            # 첫 번째 반복과 이후 반복 처리
            fill_count = songpa_cal(total_rack,count)
            count = count - np.round(prediction[0]) + np.round(prediction[1])  # 이후 값 업데이트
            insert_songpa(datetime.now(), count, prediction[0], prediction[1],fill_count, standard_time) # DB입력
            hour_result = {
                'hour': hour,
                'standard_time' : standard_time,
                'cr_current': count,
                'rent_predict': np.round(prediction[0]),  # 대여 예측
                'return_predict': np.round(prediction[1]),   # 반납 예측
                'fill_count' : fill_count
            }
        }
    except Exception as e:
        print(e)
        return {'predict_results': str(e)}
    




# @router.get('/predict')
# async def test(time : int):
#     try:
#         # 입력 데이터 준비
#         temp = get_temp(time)
#         year,month, day, hour =  get_date(time=time)# 년, 월, 일, 시간대
#         o3 =get_air()  # 오존
#         holiday = get_holiday(time=time)  # 휴일여부_0,휴일여부_1
#         total_population ,floating_population = get_population(time= hour, holiday=holiday[0], month=month) # 유동인구, 총생활인구수
#         seasons = get_season(month=month) # 계절0~3
#         # feature 합치기
#         feature = np.hstack((year,month, day, hour,temp,o3,total_population, floating_population, holiday, seasons))
#         # 스케일링 적용
#         scaled_data = scaler.transform(feature.reshape(1, -1))
#         prediction = model.predict(scaled_data)[0]
#         print(f'년 {year}')
#         print(f'월 {month}')
#         print(f'일 {day}')
#         print(f'시간 {hour}')
#         print(f'기온 {temp}')
#         print(f'오존 {o3}')
#         print(f'총 생활인구 {total_population}')
#         print(f'유동인구 {floating_population}')
#         print(f'휴일 여부 {holiday}')
#         print(f'계절 {seasons}')

#         return {'result': {'rent' : np.round(prediction[0]), 'restore' : np.round(prediction[1])}}
#     except Exception as e:
#         print(e)
#         return {'Error': str(e)}

