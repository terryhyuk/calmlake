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
from datetime import datetime, timedelta

router = APIRouter()

# post 사진 업로드할 폴더
UPLOAD_FOLDER = 'uploads' 
if not os.path.exists(UPLOAD_FOLDER): # 업로드 폴더가 없으면 폴더를 만들어라
    os.makedirs(UPLOAD_FOLDER)

def connection():
    conn = pymysql.connect(
        host='192.168.50.123',
        user='root',
        password='qwer1234',
        db= 'calmlake',
        charset='utf8'
    )
    return conn

# post 페이지 가져오는 쿼리
@router.get('/select')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
    SELECT 
        p.seq, 
        p.post_user_id, 
        p.date, 
        p.image, 
        p.contents, 
        p.public,
        u.nickname,
        f.seq AS favorite_seq, 
        f.user_id AS favorite_user_id, 
        f.post_seq AS favorite_post_seq, 
        f.favorite,
        h.seq AS hate_seq, 
        h.user_id AS hate_user_id, 
        h.post_seq AS hate_post_seq, 
        h.hate,
        count(distinct c.seq) + count(distinct r.seq) as comment_count,
        u.user_image
    FROM 
        post AS p 
    LEFT JOIN 
        favorite AS f ON p.seq = f.post_seq AND f.user_id = %s 
    LEFT JOIN 
        hate AS h ON p.seq = h.post_seq AND h.user_id = %s 
    LEFT JOIN 
        comment AS c ON p.seq = c.post_seq 
    LEFT join
        reply as r ON r.post_seq = c.post_seq and r.comment_seq = c.seq
    LEFT join
        user as u ON p.post_user_id = u.id
    WHERE 
        (p.public = 0 AND p.post_user_id != %s) 
        OR (p.public = 2 AND p.post_user_id IN (
            SELECT add_id FROM addfriends WHERE user_id = %s
        )) 
        OR (p.public = 2 AND p.post_user_id IN (
            SELECT user_id FROM addfriends WHERE add_id = %s
        ))
    GROUP BY 
    p.seq, p.post_user_id, p.date, p.image, p.contents, p.public,u.nickname, 
    f.seq, f.user_id, f.post_seq, f.favorite, 
    h.seq, h.user_id, h.post_seq, h.hate
    HAVING count(f.favorite)/NULLIF(COUNT(h.hate), 0) > 0.3 OR COUNT(h.hate) = 0 or count(f.favorite) = 0
    order by
    p.date desc
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

# post 인기순으로 정렬
@router.get('/select_top')
async def selecttop(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
    SELECT 
        p.seq, 
        p.post_user_id, 
        p.date, 
        p.image, 
        p.contents, 
        p.public,
        u.nickname,
        f.seq AS favorite_seq, 
        f.user_id AS favorite_user_id, 
        f.post_seq AS favorite_post_seq, 
        f.favorite,
        h.seq AS hate_seq, 
        h.user_id AS hate_user_id, 
        h.post_seq AS hate_post_seq, 
        h.hate,
        count(distinct c.seq) + count(distinct r.seq) as comment_count,
        u.user_image
    FROM 
        post AS p 
    LEFT JOIN 
        favorite AS f ON p.seq = f.post_seq AND f.user_id = %s 
    LEFT JOIN 
        hate AS h ON p.seq = h.post_seq AND h.user_id = %s 
    LEFT JOIN 
        comment AS c ON p.seq = c.post_seq 
    LEFT join
        reply as r ON r.post_seq = c.post_seq and r.comment_seq = c.seq
    LEFT join
        user as u ON p.post_user_id = u.id
    LEFT JOIN 
        favorite AS ff ON p.seq = ff.post_seq  -- 모든 사용자에 대한 좋아요
    WHERE 
        (p.public = 0 AND p.post_user_id != %s) 
        OR (p.public = 2 AND p.post_user_id IN (
            SELECT add_id FROM addfriends WHERE user_id = %s
        )) 
        OR (p.public = 2 AND p.post_user_id IN (
            SELECT user_id FROM addfriends WHERE add_id = %s
        ))
    GROUP BY 
    p.seq, p.post_user_id, p.date, p.image, p.contents, p.public, u.nickname, 
    f.seq, f.user_id, f.post_seq, f.favorite, 
    h.seq, h.user_id, h.post_seq, h.hate
    HAVING count(f.favorite)/NULLIF(COUNT(h.hate), 0) > 0.3 OR COUNT(h.hate) = 0 or count(f.favorite) = 0
    order by
    sum(ff.favorite) desc, p.date desc
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

# post search 페이지
@router.get('/select_search')
async def selectsearch(user_id: str=None, search: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
    SELECT 
        p.seq, 
        p.post_user_id, 
        p.date, 
        p.image, 
        p.contents, 
        p.public,
        u.nickname,
        f.seq AS favorite_seq, 
        f.user_id AS favorite_user_id, 
        f.post_seq AS favorite_post_seq, 
        f.favorite,
        h.seq AS hate_seq, 
        h.user_id AS hate_user_id, 
        h.post_seq AS hate_post_seq, 
        h.hate,
        count(distinct c.seq) + count(distinct r.seq) as comment_count,
        u.user_image
    FROM 
        post AS p 
    LEFT JOIN 
        favorite AS f ON p.seq = f.post_seq AND f.user_id = %s 
    LEFT JOIN 
        hate AS h ON p.seq = h.post_seq AND h.user_id = %s 
    LEFT JOIN 
        comment AS c ON p.seq = c.post_seq 
    LEFT join
        reply as r ON r.post_seq = c.post_seq and r.comment_seq = c.seq
    LEFT join
        user as u ON p.post_user_id = u.id
    WHERE 
        p.contents like %s and p.post_user_id != %s
    GROUP BY 
    p.seq, p.post_user_id, p.date, p.image, p.contents, p.public,u.nickname, 
    f.seq, f.user_id, f.post_seq, f.favorite, 
    h.seq, h.user_id, h.post_seq, h.hate
    HAVING count(f.favorite)/NULLIF(COUNT(h.hate), 0) > 0.3 OR COUNT(h.hate) = 0 or count(f.favorite) = 0
    order by
    p.date desc
"""
        search_term = (f"%{search}%")
        curs.execute(sql, (user_id,user_id,search_term, user_id))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}

# 각 user post 가져오는 쿼리
@router.get('/userpost')
async def userpost(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
    SELECT 
        p.seq, 
        p.post_user_id, 
        p.date, 
        p.image, 
        p.contents, 
        p.public,
        p.post_nickname,
        f.seq AS favorite_seq, 
        f.user_id AS favorite_user_id, 
        f.post_seq AS favorite_post_seq, 
        f.favorite,
        h.seq AS hate_seq, 
        h.user_id AS hate_user_id, 
        h.post_seq AS hate_post_seq, 
        h.hate,
        count(distinct c.seq) + count(distinct r.seq) as comment_count,
        u.user_image
    FROM 
        post AS p 
    LEFT JOIN 
        favorite AS f ON p.seq = f.post_seq AND f.user_id = %s 
    LEFT JOIN 
        hate AS h ON p.seq = h.post_seq AND h.user_id = %s 
    LEFT JOIN 
        comment AS c ON p.seq = c.post_seq 
    LEFT join
        reply as r ON r.post_seq = c.post_seq and r.comment_seq = c.seq
    LEFT join
        user as u ON p.post_user_id = u.id
    WHERE 
        post_user_id =%s
    GROUP BY 
    p.seq, p.post_user_id, p.date, p.image, p.contents, p.public,p.post_nickname, 
    f.seq, f.user_id, f.post_seq, f.favorite, 
    h.seq, h.user_id, h.post_seq, h.hate
    order by
    p.date desc
            """
        curs.execute(sql, (user_id, user_id, user_id))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)

# 각 user 좋아요 한 post
@router.get('/favorite_post')
async def favorite_post(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
    SELECT 
        p.seq, 
        p.post_user_id, 
        p.date, 
        p.image, 
        p.contents, 
        p.public,
        u.nickname,
        f.seq AS favorite_seq, 
        f.user_id AS favorite_user_id, 
        f.post_seq AS favorite_post_seq, 
        f.favorite,
        h.seq AS hate_seq, 
        h.user_id AS hate_user_id, 
        h.post_seq AS hate_post_seq, 
        h.hate,
        count(distinct c.seq) + count(distinct r.seq) as comment_count,
        u.user_image
    FROM 
        post AS p 
    LEFT JOIN 
        favorite AS f ON p.seq = f.post_seq AND f.user_id = %s 
    LEFT JOIN 
        hate AS h ON p.seq = h.post_seq AND h.user_id = %s 
    LEFT JOIN 
        comment AS c ON p.seq = c.post_seq 
    LEFT join
        reply as r ON r.post_seq = c.post_seq and r.comment_seq = c.seq
    LEFT join
        user as u ON p.post_user_id = u.id
    WHERE 
        f.user_id = %s and f.favorite = '1' and p.post_user_id != %s
    GROUP BY 
    p.seq, p.post_user_id, p.date, p.image, p.contents, p.public,u.nickname, 
    f.seq, f.user_id, f.post_seq, f.favorite, 
    h.seq, h.user_id, h.post_seq, h.hate
    order by
    p.date desc
            """
        curs.execute(sql, (user_id, user_id, user_id, user_id))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)

# 유저 정보 가져오는 쿼리
@router.get('/user')
async def user(id: str=None):
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

@router.get('/comment')
async def comment(post_seq: str=None):
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

# 댓글과 답글 가져오는 쿼리
@router.get('/commentreply')
def commentsreplies(post_seq: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = """
        SELECT 
        c.seq AS comment_seq,
        cu.nickname as comment_user_nickname,
        c.post_seq AS comment_post_seq,
        c.text AS comment_text,
        c.comment_date,
        cu.user_image as comment_user_image,
        c.user_id as comment_user_id,
        r.seq AS reply_seq,
        r.post_seq AS reply_post_seq,
        ru.nickname as reply_user_nickname,
        r.comment_seq as reply_comment_seq,
        r.reply AS reply_text,
        r.reply_date,
        ru.user_image as reply_user_imange,
        r.user_id as reply_user_id
        FROM 
        comment c
        left join
        user cu on c.user_id = cu.id
        LEFT JOIN 
        reply r ON r.comment_seq = c.seq and r.post_seq = c.post_seq
        Left join 
        user ru on r.user_id = ru.id
        where c.post_seq = %s;
            """
        curs.execute(sql, (post_seq,))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        formatted_comments = []
        comment_map = {}

        def format_time_ago(time):
            comment_time = time
            now = datetime.now()
            diff = now - comment_time

            if diff.total_seconds() < 60:
                return "Just now"
            elif diff.total_seconds() < 3600:
                return f"{int(diff.total_seconds() / 60)}m"
            elif diff.total_seconds() < 86400:
                return f"{int(diff.total_seconds() / 3600)}h"
            elif diff.total_seconds() < 604800:
                return f"{int(diff.total_seconds() / 86400)}d"
            else:
                return comment_time.strftime('%Y-%m-%d')
            
        for row in rows:
            comment_time = format_time_ago(row[4])
            reply_time = format_time_ago(row[12]) if row[2] and row[12]else None
            comment_seq = row[0]  # comment_seq
            if comment_seq not in comment_map:
                comment_data = [
                    comment_seq,
                    row[1],  # user_nickname
                    row[2],  # post_seq
                    row[3],  # text
                    comment_time,  # comment_date 
                    row[5],  # comment_user_image
                    row[6],  # comment_user_id
                    []  # 답글 리스트
                ]
                comment_map[comment_seq] = comment_data
                formatted_comments.append(comment_data)
            # 답글 데이터 추가
            if row[7] is not None:  # 답글이 있을 경우
                reply_data = [
                    row[7],  # reply_seq
                    row[8],  # reply_post_seq
                    row[9],  # reply_user_nickname
                    row[10],  # reply_comment_seq
                    row[11],   # reply_text
                    reply_time,   # reply_date
                    row[13],   # reply_user_image
                    row[14],   # reply_user_id
                ]
                comment_map[comment_seq][7].append(reply_data)

        return {'results': formatted_comments}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results': "Error"}
        
# 답글 insert
@router.get('/insert_reply')
async def insertreply(post_seq: int=None, user_id: str=None, comment_seq: str=None, reply: str=None, reply_date: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "insert into reply(post_seq, user_id, comment_seq, reply, reply_date) values (%s,%s,%s,%s, %s)"
        curs.execute(sql, (post_seq, user_id, comment_seq, reply, reply_date))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}

# 댓글 insert
@router.get('/insert_comment')
async def insertcomment(user_id: str=None, post_seq: int=None, text: str=None, comment_date: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "insert into comment(user_id, post_seq, text,comment_date) values (%s,%s,%s,%s)"
        curs.execute(sql, (user_id, post_seq, text, comment_date))
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
    
# post사진 업로드
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

# user가 해당 post에 좋아요 누른적 있는지 확인
@router.get('/checkfavorite')
async def checkfavorite(user_id: str=None, post_seq: str=None):
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

# user가 해당 post에 싫어요 누른적 있는지 확인
@router.get('/checkhate')
async def checkhate(user_id: str=None, post_seq: str=None):
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
    
# 이미지 삭제
@router.delete('/deleteimage/{file_name}')
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

# post 삭제
@router.get('/deletepost')
async def deletepost(seq: int=None):
    conn = connection()
    curs = conn.cursor()
    try:
        sql ="delete from post where seq =%s"
        curs.execute(sql, (seq,))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :" , e)
        return {'results': 'Error'}


@router.get('/deletecommentreply')
async def deletecomment(user_id: str=None, seq: str=None):
    conn = connection()
    curs = conn.cursor()
    try:
        delete_comment_sql = "delete from comment where user_id = %s and seq =%s"
        curs.execute(delete_comment_sql, (user_id, seq))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results': 'Error'}

@router.get('/deletecomment')
async def deletecomment(user_id: str=None, seq: int=None):
    conn = connection()
    curs = conn.cursor()
    try:
        sql = "delete from comment where user_id = %s and seq = %s"
        curs.execute(sql, (user_id, seq))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results': 'Error'}
    
@router.get('/deletereply')
async def deletereply(user_id: str=None, seq: int=None):
    conn = connection()
    curs = conn.cursor()
    try:
        delete_reply_sql = "delete from reply where user_id = %s and seq = %s"
        curs.execute(delete_reply_sql, (user_id, seq))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results': 'Error'}

# user가 좋아요 누를때마다 업데이트 
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

# insert 좋아요 
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

# user가 싫어요 누를때마다 update
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

# 싫어요 insert
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
    
# 이미지를 바꿨을때 수정하는 부분
@router.get('/updateAll')
async def insert(image: str=None, contents: str=None, public: int=None, seq: int=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "update post set image = %s, contents = %s, public = %s where seq = %s"
        curs.execute(sql, (image, contents, public, seq))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
# 이미지를 바꾸지 않고 수정하는 부분
@router.get('/update')
async def insert(contents: str=None, public: int=None, seq: int=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "update post set contents = %s, public = %s where seq = %s"
        curs.execute(sql, (contents, public, seq))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    