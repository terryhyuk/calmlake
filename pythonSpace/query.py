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
        host='192.168.50.123',
        user='root',
        password='qwer1234',
        db='calmlake',
        charset='utf8'
    )
    return conn

@router.get('/select')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
    SELECT 
        p.seq, 
        p.user_id, 
        p.date, 
        p.image, 
        p.contents, 
        p.public, 
        f.seq AS favorite_seq, 
        f.user_id AS favorite_user_id, 
        f.post_seq AS favorite_post_seq, 
        f.favorite,
        h.seq AS hate_seq, 
        h.user_id AS hate_user_id, 
        h.post_seq AS hate_post_seq, 
        h.hate,
        count(c.seq) as comment_count
    FROM 
        post AS p 
    LEFT JOIN 
        favorite AS f ON p.seq = f.post_seq AND f.user_id = %s 
    LEFT JOIN 
        hate AS h ON p.seq = h.post_seq AND h.user_id = %s 
    LEFT JOIN 
        comment AS c ON p.seq = c.post_seq
    WHERE 
        (p.public = 0 AND p.user_id != %s) 
        OR (p.public = 2 AND p.user_id IN (
            SELECT add_id FROM friends WHERE user_id = %s
        )) 
        OR (p.public = 2 AND p.user_id IN (
            SELECT user_id FROM friends WHERE add_id = %s
        ))
    GROUP BY 
    p.seq, p.user_id, p.date, p.image, p.contents, p.public, 
    f.seq, f.user_id, f.post_seq, f.favorite, 
    h.seq, h.user_id, h.post_seq, h.hate
"""
        curs.execute(sql, (user_id,user_id,user_id,user_id,user_id))
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


@router.get('/user')
async def select(id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From user
            where id = %s
            """
        curs.execute(sql, (id,))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}

@router.get('/favorite')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From favorite
            where user_id = %s
            """
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}

@router.get('/comment')
async def select(post_seq: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From comment
            where post_seq = %s
            """
        curs.execute(sql, (post_seq,))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}


@router.get('/insert_comment')
async def insert(user_id: str=None, post_seq: int=None, text: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "insert into comment(user_id, post_seq, text) values (%s,%s,%s)"
        curs.execute(sql, (user_id, post_seq, text))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
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

@router.get('/checkfavorite')
async def select(user_id: str=None, post_seq: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From favorite
            where user_id = %s and post_seq = %s
            """
        curs.execute(sql, (user_id, post_seq ))
        conn.commit()
        favorite_check = curs.fetchone()  
        if favorite_check is None:
            favorite_check = 0
        else:
            favorite_check = favorite_check[0]
        conn.close()
        print(favorite_check)
        return{'result': favorite_check}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}

@router.get('/checkhate')
async def select(user_id: str=None, post_seq: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
            select * 
            From hate
            where user_id = %s and post_seq = %s
            """
        curs.execute(sql, (user_id, post_seq ))
        conn.commit()
        hate_check = curs.fetchone()  
        if hate_check is None:
            hate_check = 0
        else:
            hate_check = hate_check[0]
        conn.close()
        print(hate_check)
        return{'result': hate_check}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}
    
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
    
    # Update favorite 추가
@router.get('/update_favorite')
async def update(favorite: int = None, post_seq: int = None, user_id: str = None):  
    conn = connection()
    curs = conn.cursor()
    try:
        sql = "UPDATE favorite SET favorite = %s WHERE user_id = %s AND post_seq = %s"
        curs.execute(sql, (favorite, user_id, post_seq)) 
        conn.commit()
        conn.close()
        return {'results': 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results': "Error"}

@router.get('/insert_favorite')
async def insert(favorite: int=None, post_seq: int=None, user_id: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "insert into favorite(favorite, post_seq, user_id) values (%s,%s,%s)"
        curs.execute(sql, (favorite,post_seq, user_id))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
@router.get('/update_hate')
async def update(hate: int = None, post_seq: int = None, user_id: str = None):  
    conn = connection()
    curs = conn.cursor()
    try:
        sql = "UPDATE hate SET hate = %s WHERE user_id = %s AND post_seq = %s"
        curs.execute(sql, (hate, user_id, post_seq)) 
        conn.commit()
        conn.close()
        return {'results': 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results': "Error"}

@router.get('/insert_hate')
async def insert(hate: int=None, post_seq: int=None, user_id: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "insert into hate(hate, post_seq, user_id) values (%s,%s,%s)"
        curs.execute(sql, (hate,post_seq, user_id))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}