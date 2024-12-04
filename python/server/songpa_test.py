import holidays
import requests
import hosts
import numpy as np
import pandas as pd
import os
import h5py
from datetime import timedelta,datetime


def get_temp(time : int): # 0 : 1시간후, 1 = 2시간후, 2 = 3시간후
    try:
        key = hosts.js_key
        url=f'http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/잠실 관광특구'
        response = requests.get(url)
        citydata = response.json()['CITYDATA']['WEATHER_STTS'][0]['FCST24HOURS']
        temp =citydata[time]['TEMP'] 
        print(time)
        print(temp) 
        return temp
    except Exception as e:
        print('get_temp', e)


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

if __name__ =="__main__":
    get_temp(1)
    get_air()

