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
    conn = connect()
    try:
        with conn.cursor() as cursor:
            query = """
                SELECT 
                    m.station_code, 
                    m.standard_time, 
                    m.rent,
                    m.restore,
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

            if not result:
                raise HTTPException(
                    status_code=404, detail="No data found for the region"
                )

            predictions = {}
            for row in result:
                station_code = row[0]
                standard_time = str(row[1])
                rent = row[2]
                restore = row[3]
                fill_count = row[4]

                hour = standard_time[-2:]
                time = f"{hour}시"

                if station_code not in predictions:
                    predictions[station_code] = []
                predictions[station_code].append(
                    {
                        "time": time,
                        "rent": rent,
                        "restore": restore,
                        "fill_count": fill_count,
                    }
                )

            return predictions
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {e}")
    finally:
        conn.close()
