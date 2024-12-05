
"""
author : yh
Description : 잠실
Date :  2024.12.04
"""
'''Feature
연, 월, 일 -> 오늘날짜
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
from jamsil.jamsil_functions import get_real_time_data,get_season,calculate_recommended_bikes,get_subway_station_jamsil,is_holiday
from jamsil.jamsil_insert import jamsil_insert

router = APIRouter()

# 모델 로드
rental_data = joblib.load('../data/rental_model_lotte.h5')
rental_model = rental_data['model']
scaler = rental_data['scaler']

return_data = joblib.load('../data/return_model_lotte.h5')
return_model = return_data['model']

# 모델을 사용하여 자전거 수요 예측
def predict_demand(model, hour, month, day, is_holiday, season, weekday, passenger_count):
    input_data = np.array([[hour, month, day, is_holiday, season, weekday, passenger_count]])
    scaled_input = scaler.transform(input_data)
    return model.predict(scaled_input)[0]

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
            passenger_count = get_subway_station_jamsil(
                future_time.hour,
                is_holiday(future_time),
                future_time.month
            )

            predicted_rental = predict_demand(
                rental_model,
                future_time.hour,
                future_time.month,
                future_time.day,
                is_holiday(future_time),
                get_season(future_time.month),
                future_time.weekday(),
                passenger_count
            )

            predicted_return = predict_demand(
                return_model,
                future_time.hour,
                future_time.month,
                future_time.day,
                is_holiday(future_time),  # 휴일여부 자동 계산
                get_season(future_time.month),  # 계절 자동 계산
                future_time.weekday(),
                passenger_count
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
            needbike.append({
                "month":future_time.month,
                "day":future_time.day,
                "hour": future_time.hour,
                "predicted_rental": predicted_rental,
                "predicted_return": predicted_return,
                "additional_bikes_needed": additional_needed
            })
            base_bikes = recommended_bikes
            
        await jamsil_insert(needbike, current_bikes)
        
        return {
            "current_available_bikes": current_bikes,
            "station_capacity": 30,
            "min_required_bikes": 15,
            "max_required_bikes": 24,
            "predictions": results,
            "need_bike": needbike
        }
    else:
        return {"error": "스테이션 정보를 찾을 수 없습니다."}