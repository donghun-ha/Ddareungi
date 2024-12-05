
"""
author : yh
Description : 잠실 테스트
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
def predict_demand(model, hour, month, day, is_holiday, season, weekday):
    input_data = np.array([[hour, month, day, is_holiday, season, weekday]])
    scaled_input = scaler.transform(input_data)
    return model.predict(scaled_input)[0]

# 현재 사용 가능한 자전거 수와 예측된 수요를 비교하여 추가필요한 자전거 수 계산
def calculate_additional_bikes(current_bikes, predicted_demand):
    return max(0, int(predicted_demand - current_bikes))

@router.get("/predict_demand")
# 각 시간대별로 대여 예측, 반납예측, 필요한 자전거 수 계산
async def predict_demand_api():
    url = "http://openapi.seoul.go.kr:8088/4d4578666b64696e3738416348554e/json/bikeList/1/1000"
    station_data = get_real_time_data(url)
    
    if station_data:
        current_bikes = int(station_data['parkingBikeTotCnt'])
        results = []
        
        now = datetime.now()
        for i in range(24):  # 24시간 동안의 예측
            future_time = now + timedelta(hours=i)
            predicted_rental = predict_demand(
                rental_model,
                future_time.hour,
                future_time.month,
                future_time.day,
                0,  # 휴일 여부는 별도로 확인 필요
                (future_time.month % 12 + 3) // 3,  # 계절 계산
                future_time.weekday()
            )
            predicted_return = predict_demand(
                return_model,
                future_time.hour,
                future_time.month,
                future_time.day,
                0,
                (future_time.month % 12 + 3) // 3,
                future_time.weekday()
            )
            additional_bikes = calculate_additional_bikes(current_bikes, predicted_rental)
            results.append({
                "hour": future_time.hour,
                "predicted_rental": predicted_rental,
                "predicted_return": predicted_return,
                "additional_bikes_needed": additional_bikes
            })
        
        return {
            "current_available_bikes": current_bikes,
            "predictions": results
        }
    else:
        return {"error": "스테이션 정보를 찾을 수 없습니다."}