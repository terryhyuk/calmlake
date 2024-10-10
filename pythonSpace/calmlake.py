from fastapi import FastAPI
from insert import router as insert_router
from query import router as query_router
from login import router as login_router
import pymysql

app = FastAPI()
app.include_router(insert_router, prefix="/insert", tags=["insert"])
app.include_router(query_router, prefix="/query", tags=["query"])
app.include_router(login_router, prefix="/login", tags=["login"])
def connect():
    conn = pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='bar5heart',
        db='calm_lake',
        charset='utf8'
    )
    return conn

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)