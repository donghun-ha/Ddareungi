from fastapi import FastAPI
import pymysql
import hosts
from fastapi.middleware.cors import CORSMiddleware
from songpa_office import router as test_router
from login import router as login_router
from profile import router as profile_router


app = FastAPI()


app.include_router(test_router, prefix="/test", tags=["test"])
app.include_router(login_router, prefix="/login", tags=["login"])
app.include_router(profile_router, prefix="/profile", tags=["profile"])


def connect():
    conn = pymysql.connect(
        host=hosts.ip, user="root", password="qwer1234", db="ttareunggo", charset="utf8"
    )
    return conn


# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용 : 테스트 할 때만 사용하기
    allow_credentials=True,
    allow_methods=["*"],  # 모든 http 메서드 허용
    allow_headers=["*"],  # 모든 헤더 사용
)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000, reload=True)
