import requests
import json
from datetime import datetime, timedelta
import pandas as pd

def get_real_time_data(url):
    response = requests.get(url)
    data = json.loads(response.text)
    for station in data['rentBikeStatus']['row']:
        if "롯데월드타워(잠실역2번출구 쪽)" in station['stationName']:
            return station
    return None

def get_season(month):
    # 월별 계절 반환 (봄:0, 여름:1, 가을:2, 겨울:3)
    if month in [3, 4, 5]:
        return 0  # 봄
    elif month in [6, 7, 8]:
        return 1  # 여름
    elif month in [9, 10, 11]:
        return 2  # 가을
    else:
        return 3  # 겨울

def is_holiday(date):
    # 주말(토,일) 체크
    if date.weekday() >= 5:
        return 1
    return 0

# 승하차인원 평균 구하기
def get_subway_station_jamsil(time: int, holiday: int, month: int):
    df = pd.read_csv('../data/따릉이전처리.csv', index_col=0)
    df = df[(df['월'] == month) & (df['시간대']==time) & (df['휴일여부'] == holiday)]
    return df['승하차인원'].mean()

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
