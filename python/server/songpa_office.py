from fastapi import APIRouter
import requests
import hosts
import json
"""
author : 신정섭
Description : 송파구청 feature - api & flutter 연결
Date :  2024.12.04
Usage : http://openapi.seoul.go.kr:8088/API_Key/json/citydata/1/5/잠실 관광특구
Usage : http://openapi.seoul.go.kr:8088/API_Key/json/ListAvgOfSeoulAirQualityService/1/5/
"""


# router = APIRouter()
def get_weather_population(name : str):
    key = hosts.js_key
    url=f'http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/{name}'
    response = requests.get(url)
    try :
        data=response.json()
        area_ppltn_min = data['CITYDATA']['LIVE_PPLTN_STTS'][0]['AREA_PPLTN_MIN']
        area_ppltn_max = data['CITYDATA']['LIVE_PPLTN_STTS'][0]['AREA_PPLTN_MAX']
        print(f'실시간 인구 지표 최소값 : {area_ppltn_min}') 
        print(f'실시간 인구 지표 최대값 : {area_ppltn_max}')
    except Exception as e :
        print('Error',e)

def get_air():
    key = hosts.js_key
    url = f'http://openapi.seoul.go.kr:8088/{key}/json/ListAvgOfSeoulAirQualityService/1/5/'
    response = requests.get(url)
    try :
        data = response.json()
        # pm10 = data['ListAvgOfSeoulAirQualityService']['row'][0]['PM10']
        # pm25 = data['ListAvgOfSeoulAirQualityService']['row'][0]['PM25']
        ozone = data['ListAvgOfSeoulAirQualityService']['row'][0]['OZONE']
        # carbon = data['ListAvgOfSeoulAirQualityService']['row'][0]['CARBON']
        # print(f'PM10 : {pm10}')
        # print(f'PM25 : {pm25}')
        print(f'오존 : {ozone}')
        # print(f'일산화탄소 : {carbon}')
    except Exception as e:
        print("Error ", e)



if __name__ =='__main__':
    get_weather_population('잠실 관광특구')
    get_air()