"""
작성자: 하동훈
작성일시: 2024-11-21
파일 내용: 실시간 데이터를 FastAPI로 처리하여 Flutter로 전달.
usage: 'http://127.0.0.1:8000/hanriver/citydata/{pname}'
"""

# 아산병원: pname=광나루한강공원

import requests
import json
import time
from fastapi import APIRouter, Query
from fastapi.responses import JSONResponse
from model import rentModel
from model import returnModel

router = APIRouter()


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
        "최고기온": weather_info.get("MAX_TEMP", "정보 없음"),
        "최저기온": weather_info.get("MIN_TEMP", "정보 없음"),
        "습도": weather_info.get("HUMIDITY", "정보 없음"),
        "풍향": weather_info.get("WIND_DIRCT", "정보 없음"),
        "풍속": weather_info.get("WIND_SPD", "정보 없음"),
        "강수량": weather_info.get("PRECIPITATION", "정보 없음"),
        "강수형태": weather_info.get("PRECPT_TYPE", "정보 없음"),
        "하늘상태": weather_info.get("SKY_STTS", "정보 없음"),
        "날씨 메시지": weather_info.get("AIR_MSG", "정보 없음"),
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


from datetime import datetime

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
    
    try:
        # 4. 데이터 전처리 및 feature 구성
        features = [[
            1 if 3 < current_time.month < 7 or current_time.month == 10 else 0,  # 계절
            int(current_time.month),  # month
            0 if current_time.weekday()<5 else 1,  # day (0-6, 월-일)
            int(current_time.hour + time),   # time
            float(weather_info["기온"]) if weather_info["기온"] != "정보 없음" else 0,  # 기온
            # float(weather_info["PM10"]) if weather_info["PM10"] != "정보 없음" else 0,  # pm10
            # float(weather_info["PM25"]) if weather_info["PM25"] != "정보 없음" else 0,  # pm25
            float(weather_info["강수량"]) if (weather_info["강수량"] != "정보 없음") and (weather_info["강수량"] != "-") else 0,  # 강수량
        ]]
        
        # 5. 대여 및 반납 예측 수행
        rent_prediction = rentModel.predict(features)
        return_prediction = returnModel.predict(features)
        
        return {
            "rent_prediction": float(rent_prediction[0]),
            "return_prediction": float(return_prediction[0]),
            # "current_weather": weather_info
        }
        
    except Exception as e:
        return JSONResponse(
            content={"error": f"예측 중 오류 발생: {str(e)}"},
            status_code=500
        )
    
async def accumPred(t):
    c
    for i in range(0, t):
        pred=predict_from_weather(pname='광나루한강공원', time=i)
        rent=pred['rent_prediction']
        retu=pred['return_prediction']
        c=c-rent+retu
    return c