
"""
author : yh
Description : 잠실
Date :  2024.12.04
"""
'''Feature
연, 월, 일 -> 오늘날짜
시간대 -> 지금 시간 + 유저 입력
승하차인원 : Dataframe 평균
휴일여부 0,1
==================================================
# '시간대', '월', '일', '휴일여부', '계절', '요일', '승하차인원'
'''
from fastapi import APIRouter
import joblib
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import requests
import json

router = APIRouter()

# 모델 로드
rental_data = joblib.load('../data/rental_model_lotte.h5')
rental_model = rental_data['model']
scaler = rental_data['scaler']

return_data = joblib.load('../data/return_model_lotte.h5')
return_model = return_data['model']

def get_real_time_data(url):
    response = requests.get(url)
    data = json.loads(response.text)
    for station in data['rentBikeStatus']['row']:
        if "롯데월드타워(잠실역2번출구 쪽)" in station['stationName']:
            return station
    return None

# 모델을 사용하여 자전거 수요 예측
def predict_demand(model, hour, month, day, is_holiday, season, weekday, passenger_count):
    input_data = np.array([[hour, month, day, is_holiday, season, weekday, passenger_count]])
    scaled_input = scaler.transform(input_data)
    return model.predict(scaled_input)[0]

def calculate_recommended_bikes(current_bikes, predicted_rental, predicted_return, min_bikes=15, max_bikes=24):
    # 현재 자전거 수에서 예상 대여-반납 차이를 계산
    net_change = predicted_return - predicted_rental
    recommended = current_bikes + net_change
    
    # 추가로 필요한 자전거 수 계산
    if recommended < min_bikes:
        additional_needed = min_bikes - recommended
    elif recommended > max_bikes:
        additional_needed = max_bikes - recommended
    else:
        additional_needed = 0
        
    return max(0, int(recommended)), int(additional_needed)

@router.get("/predict_demand")
async def predict_demand_api():
    url = "http://openapi.seoul.go.kr:8088/4d4578666b64696e3738416348554e/json/bikeList/1/1000"
    station_data = get_real_time_data(url)
    
    if station_data:
        current_bikes = int(station_data['parkingBikeTotCnt'])
        results = []
        base_bikes = current_bikes
        needbike= []
        
        now = datetime.now()
        for i in range(24):
            future_time = now + timedelta(hours=i)
            predicted_rental = predict_demand(
                rental_model,
                future_time.hour,
                future_time.month,
                future_time.day,
                0, # 계절
                (future_time.month % 12 + 3) // 3,
                future_time.weekday(),
                1000 # 지하철승하차인원 우선 디폴드값
            )
            predicted_return = predict_demand(
                return_model,
                future_time.hour,
                future_time.month,
                future_time.day,
                0,
                (future_time.month % 12 + 3) // 3,
                future_time.weekday(),
                1000
            )
            
            recommended_bikes, additional_needed = calculate_recommended_bikes(base_bikes, predicted_rental, predicted_return)
            
            results.append({
                "hour": future_time.hour,
                "predicted_rental": predicted_rental,
                "predicted_return": predicted_return,
                "recommended_bikes": recommended_bikes,
                "base_bikes": base_bikes,
                "additional_bikes_needed": additional_needed
            })
            needbike.append(
                {
                    "hour": future_time.hour,
                    "predicted_rental": predicted_rental,
                    "predicted_return": predicted_return,
                    "additional_bikes_needed": additional_needed
                }
            )
            base_bikes = recommended_bikes
        return {
            "current_available_bikes": current_bikes,
            "station_capacity": 30,
            "min_required_bikes": 15,
            "max_required_bikes": 24,
            "predictions": results,
            "need_bike" : needbike
        }
        
    else:
        return {"error": "스테이션 정보를 찾을 수 없습니다."}