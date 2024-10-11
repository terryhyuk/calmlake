from fastapi import APIRouter
import pymysql

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host='192.168.50.123',
        user='root',
        password='qwer1234',
        db='calmlake',
        charset='utf8'
    )
    return conn

# 전체 목록
@router.get("/selectuser")
async def selectfriends(seq : str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select * from user"
        curs.execute(sql,(seq))
        conn.commit()
        findfriends = curs.fetchall()
        conn.close()
        return{'results':findfriends}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}


#친구 리스트
@router.get("/selectfriends")
async def selectfriends(seq : str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select * from friends"
        curs.execute(sql,(seq))
        conn.commit()
        findfriends = curs.fetchall()
        conn.close()
        return{'results':findfriends}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}

# 추가할 친구 검색
@router.get("/searchfriends")
async def searchfriends(search: str = None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "select id, nickname from user where id like %s or nickname like %s"
        search_term = (f"%{search}")
        curs.execute(sql,(search_term, search_term))
        findfriends = curs.fetchall()
        conn.close()
        print(findfriends)
        return {"results": findfriends}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {"results": 'Error'}

# 친구추가
@router.get("/insertfriends")
async def insertfriends(user_id: str, accept: str, add_id: str, date: str):
    conn = connect()
    curs = conn.cursor()
    try:
        insert_sql = "insert into addfriends(user_id, accept, date, add_id) VALUES (%s, %s, %s, %s)"
        curs.execute(insert_sql, (user_id, accept, date, add_id))
        conn.commit()
        return {'results': ['OK']}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {'results': 'Error', 'message': 'Error'}
    
        
# 친구 신청 요청
@router.get("/insertfriends")
async def insertfriends(user_id: str, accept: str, add_id: str, date: str):
    conn = connect()
    curs = conn.cursor()
    try:
        insert_sql = "insert into addfriends(user_id, accept, date, add_id) VALUES (%s, %s, %s, %s)"
        curs.execute(insert_sql, (user_id, accept, date, add_id))
        conn.commit()
        return {'results': ['OK']}
    except Exception as e:
        conn.rollback()
        print("Error", e)
        return {'results': ['Error'], 'message': str(e)}
    finally:
        conn.close()

# 신청온 친구 리스트 보기
@router.get("/selectrequestfriends")
async def selectrequestfriends(add_id: str = None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "select user_id from addfriends where add_id=%s "
        curs.execute(sql, (add_id,))
        findfriends = curs.fetchall()
        conn.close()
        return {'results': findfriends}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {'results': 'Error', 'message': str(e)}
            
# 친구추가
@router.get("/addrequestfriends")
async def selectrequestfriends(add_id: str = None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "inset into friends(add_id) VALUES(%s)"
        curs.execute(sql, (add_id,))
        findfriends = curs.fetchall()
        conn.close()
        return {'results': findfriends}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {'results': 'Error', 'message': str(e)}
            
# async def insertfriends(seq: str=None, friend_id: str=None, nickname: str=None):
#     conn=connect()
#     curs=conn.cursor()

#     try:
#         sql="insert into addfriends(seq, accept, addid, nickname) values (%s,%s,%s, %s)"
#         curs.execute(sql,(seq,friend_id,nickname))
#         conn.commit()
#         conn.close()
#         return{'results':'OK'}
#     except Exception as e:
#         conn.close()
#         print("Error",e)
#         return{'results':'Error'}

