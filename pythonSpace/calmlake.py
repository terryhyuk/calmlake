from fastapi import FastAPI
from insert import router as insert_router
from query import router as query_router
import pymysql

app = FastAPI()
app.include_router(insert_router, prefix="/insert", tags=["insert"])
app.include_router(query_router, prefix="/query", tags=["query"])

def connect():
    conn = pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='qwer1234',
        db='calmlake',
        charset='utf8'
    )
    return conn

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)