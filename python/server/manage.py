from fastapi import APIRouter, HTTPException
import pymysql
import hosts

# 라우터 생성
router = APIRouter()

def connect():
    try:
        conn = pymysql.connect(
            host=hosts.ip,
            user="root",
            password="qwer1234",
            db="ttareunggo",  # 데이터베이스 이름
            charset="utf8",
        )
        return conn
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {e}")

# station_name으로 station_code 반환
@router.get("/get-station-code/{station_name}")
def get_station_code(station_name: str):
    conn = connect()
    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute(
                """
                SELECT station_code
                FROM station
                WHERE stationName = %s
                """,
                (station_name,),
            )
            station = cursor.fetchone()

            if not station:
                raise HTTPException(status_code=404, detail="Station not found")

        return {"station_code": station["station_code"]}
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Query failed: {e}")
    finally:
        conn.close()

# station_code로 manage 데이터 반환
@router.get("/get-manage-data/{station_code}")
def get_manage_data(station_code: str):
    conn = connect()
    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute(
                """
                SELECT standard_time, cr_count, rent, restore, fill_count
                FROM manage
                WHERE station_code = %s
                ORDER BY standard_time ASC
                """,
                (station_code,),
            )
            results = cursor.fetchall()

            if not results:
                raise HTTPException(
                    status_code=404, detail="No data found for this station code"
                )

        return {"station_code": station_code, "data": results}
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Query failed: {e}")
    finally:
        conn.close()