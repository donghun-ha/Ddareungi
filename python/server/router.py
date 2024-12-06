from fastapi import FastAPI
import pymysql
import hosts
from fastapi.middleware.cors import CORSMiddleware
from model import router as model_router
from weather_API import router as weather_router
from songpa_office import router as songpa_router
from jamsil.jamsil import router as jamsil_router
from data_insight import router as data_insight_router
from login import router as login_router
from map import router as map_router


app = FastAPI()


app.include_router(songpa_router, prefix="/songpa", tags=["model"])
app.include_router(jamsil_router, prefix="/jamsil", tags=["model"])
app.include_router(login_router, tags=["login"])
app.include_router(data_insight_router, prefix="/data_insight", tags=["data_insight"])
app.include_router(map_router, prefix="/map", tags=["map"])
app.include_router(weather_router, prefix="/weather", tags=['weather']),
app.include_router(model_router, prefix="/model", tags=['model']),


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
    uvicorn.run(app, host='127.0.0.1', port=8000, reload=True)

