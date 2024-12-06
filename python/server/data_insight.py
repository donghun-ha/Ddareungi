from fastapi import APIRouter, HTTPException
import pymysql
from pydantic import BaseModel
import hosts

router = APIRouter()


# 데이터베이스 연결
def connect():
    return pymysql.connect(
        host=hosts.ip,
        user="root",
        password="qwer1234",
        db="ttareunggo",
        charset="utf8",
    )


# 데이터 응답 모델
class StationPrediction(BaseModel):
    time: str
    cr_count: int
    fill_count: int


# 특정 지역의 정류소 데이터를 가져오는 엔드포인트
@router.get("/{region}/station_predictions")
async def get_station_predictions(region: str):
    print(f"Received region: {region}")  # 요청된 region 출력
    conn = connect()
    try:
        with conn.cursor() as cursor:
            # 각 station_code 및 standard_time에 대해 최신 데이터를 가져옴
            query = """
                SELECT 
                    m.station_code, 
                    m.standard_time, 
                    m.cr_count,
                    m.fill_count
                FROM manage m
                JOIN user u ON m.user_id = u.id
                WHERE u.region = %s
                AND (m.date, m.seq) IN (
                    SELECT MAX(date), MAX(seq)
                    FROM manage
                    WHERE station_code = m.station_code
                    AND standard_time = m.standard_time
                )
                ORDER BY m.station_code, m.standard_time
            """
            cursor.execute(query, (region,))
            result = cursor.fetchall()

            print(f"Query result: {result}")  # 쿼리 결과 출력

            if not result:
                raise HTTPException(
                    status_code=404, detail="No data found for the region"
                )

            # 데이터 변환
            predictions = {}
            for row in result:
                station_code = row[0]
                standard_time = str(row[1])  # 정수를 문자열로 변환
                cr_count = row[2]
                fill_count = row[3]

                # 시간 추출: standard_time에서 HH 부분 추출
                hour = standard_time[-2:]  # 마지막 두 자리 시간 추출
                time = f"{hour}시"

                if station_code not in predictions:
                    predictions[station_code] = []
                predictions[station_code].append(
                    {
                        "time": time,
                        "cr_count": cr_count,
                        "fill_count": fill_count,
                    }
                )

            return predictions
    except Exception as e:
        print(f"Error: {e}")  # 예외 발생 시 로그 출력
        raise HTTPException(status_code=500, detail=f"Server error: {e}")
    finally:
        conn.close()
