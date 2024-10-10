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
        return {"results": str(e)}

# 친구추가
@router.get("/insertfriends")
async def insertfriends(user_id: str, accept: str, addid: str, date: str):
    conn = connect()
    curs = conn.cursor()

    try:
        # 먼저 user 테이블에 해당 id들이 존재하는지 확인
        check_user_sql = "SELECT id FROM user WHERE id IN (%s, %s)"
        curs.execute(check_user_sql, (user_id, addid))
        if len(curs.fetchall()) != 2:
            return {'results': 'Error', 'message': 'One or both users do not exist'}

        # 중복 체크
        check_duplicate_sql = "SELECT * FROM addfriends WHERE user_id = %s AND addid = %s"
        curs.execute(check_duplicate_sql, (user_id, addid))
        if curs.fetchone() is not None:
            return {'results': 'Error', 'message': 'Friend request already exists'}

        # addfriends 테이블에 데이터 삽입
        insert_sql = "INSERT INTO addfriends(user_id, accept, addid, date) VALUES (%s, %s, %s, %s)"
        curs.execute(insert_sql, (user_id, accept, addid, date))
        conn.commit()
        return {'results': 'OK'}
    except Exception as e:
        conn.rollback()
        print("Error", e)
        return {'results': 'Error', 'message': str(e)}
    finally:
        conn.close()
        
# 신청 친구 목록
@router.get("/selectrequestfriends")
async def selectrequestfriends(seq: str = None):
    conn = connect()
    curs = conn.cursor()
    try:
        if seq:
            sql = "SELECT * FROM addfriends WHERE add_id = %s AND accept = 'false'"
            curs.execute(sql, (seq,))
        else:
            sql = "SELECT * FROM addfriends WHERE accept = 'false'"
            curs.execute(sql)
        
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

