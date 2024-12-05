from fastapi import APIRouter
from joblib import load
from pydantic import BaseModel
import numpy as np
import pandas as pd

router = APIRouter()

# 모델 로드
rentModel = load('./rf/rent_best.joblib')
returnModel = load('./rf/return_best.joblib')

# rent_x=rent[['계절','month','day','time','기온(°C)','강수량(mm)']]
# return_x=grouped_return[['계절','month','day','return_time','기온(°C)','강수량(mm)']]

# 입력 데이터 스키마 정의
class RentFeatures(BaseModel):
    계절: int
    month: int
    day: int    # 요일
    time: int
    기온: float
    # pm10: float
    # pm25: float
    강수량: float

class ReturnFeatures(BaseModel):
    계절: int
    month: int
    day: int
    time: int
    기온: float
    # pm10: float
    # pm25: float
    강수량: float

@router.get("/asan_rent")
async def predict(계절: int, month: int, day: int, time: int, 기온: float, 강수량: float):
    # 입력 데이터를 모델 입력 형식으로 변환
    features = [[
        계절,
        month,
        day,
        time,
        기온,
        강수량,
    ]]

    
    # 예측 수행
    rent_count = rentModel.predict(features)

    return {"predicted_value": float(rent_count[0])}

@router.get("/asan_return")
async def predict(계절: int, month: int, day: int, time: int, 기온: float, 강수량: float):
    # 입력 데이터를 모델 입력 형식으로 변환
    features = [[
        계절,
        month,
        day,
        time,
        기온,
        강수량,
    ]]
    
    # 예측 수행
    return_count = returnModel.predict(features)
    
    return {"predicted_value": float(return_count[0])}
