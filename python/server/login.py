from fastapi import APIRouter, HTTPException
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


# 로그인 요청 데이터 모델
class LoginRequest(BaseModel):
    id: str
    pw: str


# 로그인 엔드포인트
@router.post("/")
async def login(request: LoginRequest):
    conn = connect()
    try:
        with conn.cursor() as cursor:
            # 사용자 인증 쿼리
            query = "SELECT id, pw, region FROM user WHERE id = %s AND pw = %s"
            cursor.execute(query, (request.id, request.pw))
            user = cursor.fetchone()

            if not user:
                # 인증 실패 시 HTTP 401 반환
                raise HTTPException(
                    status_code=401, detail="Invalid username or password"
                )

            # 인증 성공 시 사용자 정보 반환
            return {
                "message": "Login successful",
                "id": user[0],
                "region": user[2],
            }
    except Exception as e:
        # 데이터베이스 오류 처리
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")
    finally:
        conn.close()
