"""
작성자: 정우선
작성일시: 2024-12-03~2024-12-05
파일 내용: 실시간 API와 Model 연동 DB 연결
usage: 'http://127.0.0.1:8000/hanriver/citydata/{pname}'
"""

# 아산병원 pname = 잠실 관광특구
# 아산병원 station_code: ST-2574
# fill_count: 관리자가 채워넣어야하는 대수

import requests
import json
import time
import pymysql
import numpy as np
import holidays
import hosts as hosts
from fastapi import APIRouter, Query
from fastapi.responses import JSONResponse
from model import rentModel
from model import returnModel

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host=hosts.ip,
        user='root',
        password='qwer1234',
        db='ttareunggo',
        charset='utf8'
    )
    return conn

@router.get("/insertlog")
async def insertlog(user_id: str=None, station_code: str=None, date: str=None, standard_time: str=None, cr_count: str=None, rent: str=None, restore: str=None, fill_count: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="insert into manage(user_id, station_code, date, standard_time, cr_count, rent, restore, fill_count) values (%s,%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql,(user_id, station_code, date, standard_time, cr_count, rent, restore, fill_count))
        conn.commit()
        conn.close()
        return{'results':'OK'}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}

# API 데이터 요청 함수
def fetch_data(url: str):
    """
    지정된 URL로 GET 요청을 보내고 JSON 데이터를 반환합니다.
    :param url: 요청할 API URL
    :return: 응답 JSON 데이터 또는 None
    """
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code}")
        return None

# 날씨 현황 정보 추출 함수
def extract_weather_info(city_data: dict):
    """
    날씨 정보를 추출합니다.
    :param city_data: CITYDATA 키로부터 가져온 데이터
    :return: 정리된 날씨 정보 딕셔너리
    """
    weather_data = city_data.get('WEATHER_STTS', [])
    weather_info = weather_data[0] if weather_data else {}
    
    return {
        "기온": weather_info.get("TEMP", "정보 없음"),        
        "최저기온": weather_info.get("MIN_TEMP", "정보 없음"),
        "강수형태": weather_info.get("PRECPT_TYPE", "정보 없음"),
        "하늘상태": weather_info.get("SKY_STTS", "정보 없음"),
        "강수량": weather_info.get("PRECIPITATION", "정보 없음"),        
        "PM25": weather_info.get("PM25", "정보 없음"),
        "PM10": weather_info.get("PM10", "정보 없음")
    }


# 전체 데이터 처리 함수
def process_city_data(data: dict):
    """
    CITYDATA 키에서 필요한 데이터를 처리합니다.
    :param data: API에서 반환된 전체 JSON 데이터
    :return: 정리된 데이터 딕셔너리
    """
    city_data = data.get('CITYDATA', {})
    weather_info = extract_weather_info(city_data)

    return {
        **weather_info
    }

# FastAPI 엔드포인트
@router.get("/citydata/{pname}")
async def get_city_data(pname: str):
    """
    특정 지역의 실시간 데이터를 반환합니다.
    :param pname: 요청할 지역 이름
    :return: 실시간 데이터 (JSON 형식)
    """
    start_time = time.time()
    url = f'http://openapi.seoul.go.kr:8088/434675486868617235394264587a4e/json/citydata/1/1000/{pname}'
    data = fetch_data(url)

    if data:
        processed_data = process_city_data(data)
        end_time = time.time()
        print(f"코드 실행 시간: {end_time - start_time:.4f}초")
        return JSONResponse(content=processed_data, status_code=200)
    else:
        return JSONResponse(content={"error": "데이터를 가져오는 데 실패했습니다."}, status_code=500)


from datetime import datetime, timedelta

# rent_x=rent[['계절','month','day','time','기온(°C)','강수량(mm)']]
# return_x=grouped_return[['계절','month','day','return_time','기온(°C)','강수량(mm)']]

@router.get("/predict_from_weather/{pname}")
async def predict_from_weather(pname: str,time: int = Query(
        default=0)):
    # 1. 날씨 데이터 가져오기
    url = f'http://openapi.seoul.go.kr:8088/434675486868617235394264587a4e/json/citydata/1/1000/{pname}'
    data = fetch_data(url)
    
    if not data:
        return JSONResponse(
            content={"error": "날씨 데이터를 가져오는데 실패했습니다."},
            status_code=500
        )

    # 2. 날씨 정보 추출
    city_data = data.get('CITYDATA', {})
    weather_info = extract_weather_info(city_data)
    
    # 3. 현재 시간 정보 가져오기
    current_time = datetime.now()
    kr_holidays = holidays.KR()
    try:
        # 4. 데이터 전처리 및 feature 구성
        features = [[
            1 if 3 < current_time.month < 7 or current_time.month == 10 else 0,  # 계절
            int(current_time.month),  # month
            1 if current_time.weekday()>4 or current_time in kr_holidays else 0,  # day (0-6, 월-일)
            int(current_time.hour + time),   # time
            float(weather_info["기온"]) if weather_info["기온"] != "정보 없음" else 0,  # 기온
            float(''.join(c for c in weather_info["강수량"] if c.isdigit())) if (weather_info["강수량"] != "정보 없음") and (weather_info["강수량"] != "-") else 0,  # 강수량
        ]]
        
        # 5. 대여 및 반납 예측 수행
        rent_prediction = rentModel.predict(features)
        return_prediction = returnModel.predict(features)
        
        return {
            "rent_prediction": np.round(float(rent_prediction[0])),
            "return_prediction": np.round(float(return_prediction[0])),
            # "current_weather": weather_info
        }
        
    except Exception as e:
        return JSONResponse(
            content={"error": f"예측 중 오류 발생: {str(e)}"},
            status_code=500
        )
    
    
async def accumPred(t):
    currinfo = "http://openapi.seoul.go.kr:8088/6e4a4c49456a77733834745a496e4d/json/bikeList/2001/3000"
    # API 요청
    response = requests.get(currinfo)
    # JSON 형식으로 데이터 파싱
    data = json.loads(response.text)
    target_station = None
    for station in data['rentBikeStatus']['row']:
        if station['stationId']=='ST-2574':
            target_station = station
            break
    # 결과 출력
    if target_station: 
        c=int(target_station['parkingBikeTotCnt'])
        for i in range(0, t+1):
            pred=await predict_from_weather(pname='잠실 관광특구', time=i)
            rent=pred['rent_prediction']
            retu=pred['return_prediction']
            fill_c=20-c+rent-retu
            future_time=datetime.now()+timedelta(hours=i)
            current_datetime = future_time.strftime('%Y-%m-%d')
            time=future_time.hour
            await insertlog(
                user_id='songpa',
                station_code='ST-2574',
                date=current_datetime,
                standard_time=time,
                cr_count=c,
                rent=rent,
                restore=retu,
                fill_count=fill_c
            )
            c=c-rent+retu
    return rent, retu, c, fill_c

@router.get("/accumulate_prediction/{hours}")
async def test_accumulate_prediction(hours: int):
    try:
        result = await accumPred(hours)
        return {
            "predicted_bikes_count_after1": int(result[2]),
            "recommend_fill_count": int(result[3]),
            "hours_ahead": hours
        }
    except Exception as e:
        return JSONResponse(
            content={"error": f"예측 중 오류 발생: {str(e)}"},
            status_code=500
        )