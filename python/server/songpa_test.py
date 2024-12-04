import holidays
import requests
import hosts
import numpy as np



def get_weather_population(name : str):
    key = hosts.js_key
    url=f'http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/{name}'
    response = requests.get(url)
    
    # try :
    #     data=response.json()
    #     area_ppltn_min = data['CITYDATA']['LIVE_PPLTN_STTS'][0]['AREA_PPLTN_MIN']
    #     area_ppltn_max = data['CITYDATA']['LIVE_PPLTN_STTS'][0]['AREA_PPLTN_MAX']
    #     time_test = data['CITYDATA']['WEATHER_STTS']
    #     result = np.mean(area_ppltn_max, area_ppltn_min)
    #     print(time_test)
    #     return{'result' : result}
    # except Exception as e :
    #     print('Error',e)




if __name__ =='__main__':
    # get_weather_population('잠실 관광특구')
    time_temp()