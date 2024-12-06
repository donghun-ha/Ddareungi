from datetime import datetime
import pymysql
import hosts

def connect():
    conn = pymysql.connect(
        host=hosts.ip, 
        user="root", 
        password="qwer1234", 
        db="ttareunggo", 
        charset="utf8"
    )
    return conn

async def jamsil_insert(prediction_data: list, current_bikes: int):
    try:
        conn = connect()
        curs = conn.cursor()
        
        current_date = datetime.now()
        
        for data in prediction_data:
            # 월일시간을 하나의 숫자로 조합 (예: 12월 5일 17시 -> 120517)
            standard = int(f"{data['month']:02d}{data['day']:02d}{data['hour']:02d}")
            
            sql = """
            insert into manage 
            (user_id, station_code, date, standard_time, cr_count, rent, restore, fill_count)
            values 
            ('songpa', 'ST-891', %s, %s, %s, %s, %s, %s)
            """
            
            values = (
                current_date,
                standard,  # 조합된 월일시간
                current_bikes,
                int(data['predicted_rental']),
                int(data['predicted_return']),
                int(data['additional_bikes_needed'])
            )
            
            curs.execute(sql, values)
        
        conn.commit()
        return {'result': 'OK'}
        
    except Exception as e:
        if conn:
            conn.close()
        print(f'DB 저장 오류: {e}')
        return {'result': 'Error', 'message': str(e)}