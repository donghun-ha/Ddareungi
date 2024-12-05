from fastapi import FastAPI
from weather_API import router as weather_router
from model import router as model_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],    # '*': 모든 도메인 허용
    allow_credentials=True,
    allow_methods=['*'],    # '*': 모든 http method 허용
    allow_headers=['*'],    # '*': 모든 header 허용
)

# 라우터 등록
app.include_router(weather_router, prefix="/weather")
app.include_router(model_router, prefix="/model")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000)