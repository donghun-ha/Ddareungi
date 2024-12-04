from fastapi import FastAPI
import pymysql
import hosts
from songpa_test import router as test_router


app = FastAPI()


app.include_router(test_router, prefix="/test", tags=["test"])


def connect():
    conn = pymysql.connect(
        host=hosts.ip, user="root", password="qwer1234", db="parking", charset="utf8"
    )
    return conn


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000, reload=True)
