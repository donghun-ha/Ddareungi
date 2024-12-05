import holidays
import requests
import hosts
import numpy as np
import pandas as pd
from datetime import timedelta,datetime
import joblib
from fastapi import FastAPI
import pymysql


songpa= joblib.load('../data/송파구청.h5')
scaler = songpa['scaler']
model = songpa['model']
app = FastAPI()

def connect():
    conn = pymysql.connect(
        host=hosts.ip,
        user='root',
        password='qwer1234',
        db='ttareunggo',
        charset='utf8'
    )
    return conn

def get_date(time : int):
        
        try:
            now = datetime.now()
            add = timedelta(hours=time) # 
            result = now + add
            # print(result.year, result.month, result.day, result.hour)
            return result.year, result.month, result.day, result.hour
        except Exception as e:
            print('get_date', e)


def get_temp(): # 0 : 1시간후, 1 = 2시간후, 2 = 3시간후
    try:
        key = hosts.js_key
        url=f'http://openapi.seoul.go.kr:8088/{key}/json/citydata/1/5/잠실 관광특구'
        response = requests.get(url)
        citydata = response.json()['CITYDATA']['WEATHER_STTS'][0]['FCST24HOURS']
        # for count in range(23):
        result = [citydata[count]['TEMP'] for count in range(24)]
        # temp =citydata[count]['TEMP']  # [0]값 +1 해줘야함
        # print(f'{time}시간 후 ')
            # print(f'기온 {temp}') 
        # print(result)
        return result
    except Exception as e:
        print('get_temp', e)


def get_holiday(time : int):
    try:
        now=datetime.today()
        add = timedelta(hours=time) # time : 유저가 선택한 시간
        result = now + add  # 현재 시간 + 유저가 선택한 시간
        kr_holidays = holidays.KR()
        if result.weekday() >= 5 or result in kr_holidays : 
            # print([0,1])
            return [0,1]
        else :
            # print([1,0])
            return [1,0]
    except Exception as e:
        print('is_holiday', e)


def get_season(month : int):
    try:
        if month in [3,4,5]:
            input_season ='봄'
        elif month in [6,7,8]:
            input_season ='여름'
        elif month in [9,10,11]:
            input_season ='가을'
        else:
            input_season ='겨울'
        seasons = ['봄','여름','가을','겨울']
        result = [0]*4
        # print(result)
        result[seasons.index(input_season)] =1
        # print(result)
        return result
    except Exception as e:
        print('get_season', e)





def get_population(time : int, holiday : int, month : int):
    try :
        df=pd.read_csv('../data/songpa_station_final.csv')
        if holiday == 1:
            holiday ='평일'
        else :
            holiday ='휴일'
        df=df[(df['월'] == month) & (df['시간대']==time) &(df['휴일여부'] == holiday)]
        # print(df['총생활인구수'].mean())
        # print(df['유동인구'].mean())

        return df['총생활인구수'].mean(), df['유동인구'].mean()
    except Exception as e:
        print('get_population',e)

def get_station():
    key =hosts.js_key
    url = f"http://openapi.seoul.go.kr:8088/{key}/json/bikeList/1001/2000"
    response = requests.get(url)
    data = response.json()
# 롯데타워 잠실역 2번출구 따릉이 스테이션 정보 찾기
    target_station = None
    for station in data['rentBikeStatus']['row']:
        if "ST-1681" in station['stationId']:
            target_station = station
            print(f'대여소 명 {target_station}')
            break
    # 결과 출력
    if target_station:
        # print(f"스테이션 이름: {target_station['stationName']}")
        # print(f"현재 사용 가능한 자전거 수: {target_station['parkingBikeTotCnt']}")
        # print(f"거치대 개수: {target_station['rackTotCnt']}")
        # print(f"거치율: {target_station['shared']}%")
        return int(target_station['parkingBikeTotCnt']), int(target_station['rackTotCnt']) #현재 , 거치대 
    else:
        print(" 송파구청 데이터 없음")

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



@app.get('/test')
def test():
    try:
        # 초기값 설정
        station_init, total_rack = get_station()  # 스테이션 초기 상태
        temp_data = get_temp()  # 24시간 기온 데이터
        o3 = get_air()  # 대기질 데이터 (한 번만 호출)
        results= []
        count = station_init  # 초기 자전거 수
        print(f'구획수 {total_rack}')
            
        for i in range(24):  # 24시간 예측
            year, month, day, hour = get_date(i)
            holiday = get_holiday(i)
            temp = temp_data[i]
            seasons = get_season(month)
            total_population, floating_population = get_population(i, holiday[0], month)
            feature=[]
            # 특징(feature) 생성
            feature = np.hstack((year, month, day, hour, temp, o3,
                                 total_population, floating_population,
                                 holiday, seasons))
            
            scaled_data = scaler.transform(feature.reshape(1, -1))
            prediction = model.predict(scaled_data)[0]  # 대여/반납 예측
            # 첫 번째 반복과 이후 반복 처리
            fill_count = songpa_cal(total_rack,count,np.round(prediction[0]), np.round(prediction[1]))
            insert_songpa(datetime.now().date(), count, prediction[0], prediction[1],fill_count, hour) # DB입력
            if i == 0:
                count -= (np.round(prediction[0]) - np.round(prediction[1]))  # 초기값 계산
                # print(f'{i}시간 후 초기값 설정: {count}')
            else:
                count -= (np.round(prediction[0]) - np.round(prediction[1]))  # 이후 값 업데이트
                # print(f'{i}시간 후 결과: {count}')
            hour_result = {
                'hour': hour,
                'cr_current': count,
                'rent_predict': np.round(prediction[0]),  # 대여 예측
                'return_predict': np.round(prediction[1]),   # 반납 예측
                'fill_count' : fill_count
            }
            results.append(hour_result)
        
        return {'results': results} 
        
    except Exception as e:
        print(e)
        return {'Error': str(e)}



def songpa_cal(total, rent, restore, count):
    # 30%, 80% 
    min_count = total * 0.3
    max_count = total * 0.8

    # 예측에 따른 미래 대수 계산 (순 변화량 방향 뒤집기)
    future_count = count + (rent - restore)

    # 미래 대수가 30% 임계값 미만일 경우 조정
    if future_count < min_count:
        cal = min_count - future_count
        future_count += cal

    # 미래 대수가 80% 임계값 초과일 경우 조정
    elif future_count > max_count:
        cal = future_count - max_count
        future_count -= cal

    return future_count

def insert_songpa(date, current, rent, restore, need, hour):
    try:
        conn = connect()
        curs = conn.cursor()
        sql = 'insert into manage (user_id, station_code,date,current,rent,restore,need,hour) values (%s,%s ,%s, %s, %s, %s,%s,%s)'
        curs.execute(sql,('qwer1234','ST-1681',date, current,rent, restore, need, hour))
        conn.commit()
        conn.close()
        print('ok')
        
    except Exception as e:
        print(e)

# 특징 배열 길이 조정
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)
    # test()
    # test()
