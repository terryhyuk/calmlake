from fastapi import FastAPI
from insert import router as insert_router
from query import router as query_router
from login import router as login_router
from update import router as update_router
import pymysql

app = FastAPI()
app.include_router(insert_router, prefix="/insert", tags=["insert"])
app.include_router(query_router, prefix="/query", tags=["query"])
app.include_router(login_router, prefix="/login", tags=["login"])
app.include_router(update_router, prefix="/update", tags=["update"])

def connect():
    conn = pymysql.connect(
        host='192.168.50.123',
        user='root',
        password='qwer1234',
        db='calmlake',
        charset='utf8'
    )
    return conn

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)