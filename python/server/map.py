from fastapi import APIRouter, HTTPException
import pymysql
import hosts

# 라우터 생성
router = APIRouter()

def connect():
    try:
        conn = pymysql.connect(
            host= hosts.ip,
            user="root",  
            password="qwer1234",
            db="ttareunggo",  # 데이터베이스 이름
            charset="utf8",
        )
        return conn
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {e}")

@router.get("/stations")
def get_stations():
    """
    MySQL에서 station 데이터를 가져오는 API
    """
    conn = connect()
    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:
            cursor.execute("SELECT * FROM station")
            result = cursor.fetchall()
        return result
    except pymysql.MySQLError as e:
        raise HTTPException(status_code=500, detail=f"Query failed: {e}")
    finally:
        conn.close()