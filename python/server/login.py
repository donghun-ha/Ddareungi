from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
import pymysql
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


# 요청 데이터 모델
class LoginRequest(BaseModel):
    id: str
    pw: str


# 로그인 엔드포인트
@router.post("/login")
async def login(request: LoginRequest):
    conn = connect()
    try:
        with conn.cursor() as cursor:
            query = "SELECT id, pw, region FROM user WHERE id = %s AND pw = %s"
            cursor.execute(query, (request.id, request.pw))
            user = cursor.fetchone()

            if not user:
                raise HTTPException(
                    status_code=401, detail="Invalid username or password"
                )

            return {
                "message": "Login successful",
                "id": user[0],
                "region": user[2],
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {e}")
    finally:
        conn.close()


# 프로필 엔드포인트
@router.get("/profile/{user_id}")
async def get_profile(user_id: str):
    conn = connect()
    try:
        with conn.cursor() as cursor:
            query = "SELECT id, region FROM user WHERE id = %s"
            cursor.execute(query, (user_id,))
            user = cursor.fetchone()

            if not user:
                raise HTTPException(status_code=404, detail="User not found")

            return {
                "id": user[0],
                "region": user[1],
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {e}")
    finally:
        conn.close()
