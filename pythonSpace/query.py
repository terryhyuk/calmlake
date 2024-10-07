"""
author : ppochcco
Description : query 홈 화면
Date : 0926
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
        host='127.0.0.1',
        user='root',
        password='qwer1234',
        db= 'calmlake',
        charset='utf8'
    )
    return conn

@router.get('/select')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From post 
            where (public = 0 and user_id != %s)
            or (public = 2 AND user_id IN (
            select add_id FROM friends WHERE user_id = %s))
            or (public = 2 AND user_id IN (
            select user_id FROM friends WHERE add_id = %s))
            """
        curs.execute(sql, (user_id,user_id,user_id))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}
    
@router.get('/userpost')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From post 
            where user_id = %s
            """
        curs.execute(sql, (user_id))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}
    
@router.get('/user')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From user
            where id = %s
            """
        curs.execute(sql, (user_id))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}

@router.get("/view/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'results' : 'Error'}
    

@router.post('/upload') # post 방식
async def upload_file(file: UploadFile=File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename) # 업로드 폴더 경로에 파일네임을 만들겠다
        with open(file_path, "wb") as buffer:  # wb: write binary
            shutil.copyfileobj(file.file, buffer)   # buffer가 destination
        return {'results' : 'OK'}
    except Exception as e:
        print("Error:", e)
        return ({'results' : 'Error'})

# 이미지 폴더에서 삭제된 목록의 이미지 삭제
@router.delete('/deleteFile/{file_name}')
async def delete_file(file_name: str):
    # print("delete file :", file_name) 
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'results' : 'OK'}
    except Exception as e:
        print('Error:', e)
        return {'results' : 'Error'}

@router.get('/delete')
async def delete(seq: str=None):
    conn = connection()
    curs = conn.cursor()

    try:
        sql ="delete from post where seq = %s"
        curs.execute(sql, (seq,))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results': 'Error'}