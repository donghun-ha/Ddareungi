from fastapi import APIRouter, HTTPException
import pymysql
import hosts
from pydantic import BaseModel

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


# 프로필 요청 데이터 모델
class ProfileResponse(BaseModel):
    id: str
    region: str


# 프로필 조회 엔드포인트
@router.get("/", response_model=ProfileResponse)
async def get_profile():
    conn = connect()
    try:
        with conn.cursor() as cursor:
            # 사용자 정보 가져오기
            query = "SELECT id, region FROM user WHERE id = %s"
            # 로그인된 사용자 ID를 예로 지정 (이 부분은 실제 구현 시 토큰 인증을 통해 얻어와야 함)
            user_id = "johndoe@example.com"  # 예시 사용자 ID
            cursor.execute(query, (user_id,))
            user = cursor.fetchone()

            if not user:
                raise HTTPException(status_code=404, detail="User not found")

            return {"id": user[0], "region": user[1]}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")
    finally:
        conn.close()
