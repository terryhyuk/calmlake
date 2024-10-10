"""
author : tj
Description : MySQL을 이용한 musteat 만들기
Date : 2024-09-25~2024-09-26
Usage : 
"""

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil

router = APIRouter()

UPLOAD_FOLDER = 'uploads' 
if not os.path.exists(UPLOAD_FOLDER): # 업로드 폴더가 없으면 폴더를 만들어라
    os.makedirs(UPLOAD_FOLDER)

def connection():
    conn = pymysql.connect(
        host='192.168.50.123',
        user='root',
        password='qwer1234',
        db='calmlake',
        charset='utf8'
    )
    return conn
# 쿼리 부분
@router.get('/select')
async def select():
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "select seq, date, image, contents, public, user_id from post order by name"
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
# 이미지 가져오는 부분
@router.get("/view/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'results' : 'Error'}

# 데이터 삽입 부분
@router.get('/insert')
async def insert(name: str=None, image: str=None, phone: str=None, long: str=None, lat: str=None, evaluate: str=None, favorite: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "insert into post(name, image, phone, long, lat, evaluate, favorite) values (%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql, (name, image, phone, long, lat, evaluate, favorite))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
# 이미지를 바꿨을때 수정하는 부분
@router.get('/updateAll')
async def insert(seq: str=None, name: str=None, image: str=None, phone: str=None, favorite: str=None, comment: str=None,  evaluate: str=None, user_id: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "update addmusteat set name = %s, image = %s, phone = %s, favorite = %s, comment = %s, evaluate = %s where seq = %s and user_id = %s"
        curs.execute(sql, (name, image, phone, favorite, comment ,evaluate,  seq, user_id))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
# 이미지를 바꾸지 않고 수정하는 부분
@router.get('/update')
async def insert(seq: int=None, name: str=None, phone: str=None, favorite: int=None, comment: str=None, evaluate: float=None, user_id: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "update addmusteat set name = %s, phone = %s, favorite = %s, comment = %s, evaluate = %s where seq = %s and user_id = %s"
        curs.execute(sql, (name, phone, favorite, comment, evaluate, seq, user_id))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
# post방식 업로드
@router.post('/upload') # post 방식
async def upload_file(file: UploadFile=File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename) # 업로드 폴더 경로에 파일네임을 만들겠다
        with open(file_path, "wb") as buffer:  # write binery
            shutil.copyfileobj(file.file, buffer)
        return {'result' : 'OK'}
    except Exception as e:
        print("Error:", e)
        return ({'result' : 'Error'})

@router.delete('/deleteFile/{file_name}')
async def delete_file(file_name: str):
    print("delete file :", file_name)
    print("--------------------------------")
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'result' : 'OK'}
    except Exception as e:
        print('result:' 'Error')
        return ({'result' : 'Error'})

@router.get('/delete')
async def delete(seq: int=None):
    conn = connection()
    curs = conn.cursor()

    try:
        sql ="delete from address where seq =%s"
        curs.execute(sql, (seq,))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :" , e)
        return {'results': 'Error'}
