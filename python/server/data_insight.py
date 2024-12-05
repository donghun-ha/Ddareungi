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
class StationData(BaseModel):
    station_code: str
    parking_lot: int
    lat: float
    lng: float


# 특정 지역의 정류소 데이터를 가져오는 엔드포인트
@router.get("/{region}")
async def get_station_data(region: str):
    # 요청된 region 값을 출력
    print(f"Received region: {region}")  # 서버 로그에 region 값 출력
    conn = connect()
    try:
        with conn.cursor() as cursor:
            query = """
                SELECT station.code AS station_code, station.parking_lot, station.lat, station.lng
                FROM station
                WHERE station.code IN (
                    SELECT DISTINCT manage.station_code
                    FROM manage
                    WHERE user_id IN (
                        SELECT id FROM user WHERE region = %s
                    )
                )
            """
            cursor.execute(query, (region,))
            result = cursor.fetchall()

            print(f"Query result: {result}")  # 쿼리 결과 출력

            if not result:
                raise HTTPException(status_code=404, detail="No data found for the region")

            return [
                {
                    "station_code": row[0],
                    "parking_lot": row[1],
                    "lat": row[2],
                    "lng": row[3],
                }
                for row in result
            ]
    except Exception as e:
        print(f"Error: {e}")  # 예외 발생 시 로그 출력
        raise HTTPException(status_code=500, detail=f"Server error: {e}")
    finally:
        conn.close()