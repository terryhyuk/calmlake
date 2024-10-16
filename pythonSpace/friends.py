"""
author      : 용혁
Description : 친구 신청, 추가, 삭제
Date        :
Usage       :
"""
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
async def selectfriends(user_id: str = None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        select f.seq, f.add_id, u.nickname
        from friends f, user u
        where f.add_id = u.id and f.user_id = %s
        """
        curs.execute(sql, (user_id,))
        findfriends = curs.fetchall()
        return {'results': findfriends}
    except Exception as e:
        print("Error", e)
        return {'results': 'Error'}
    finally:
        conn.close()

# 추가할 친구 검색
@router.get("/searchfriends")
async def searchfriends(search: str = None, id: str = None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "select id, nickname from user where id like %s or nickname like %s and id != %s"
        search_term = (f"%{search}%")
        curs.execute(sql,(search_term, search_term, id))
        findfriends = curs.fetchall()
        conn.close()
        print(findfriends)
        return {"results": findfriends}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {"results": 'Error'}
        
# 친구 신청 요청
@router.get("/insertfriends")
async def insertfriends(user_id: str, accept: str, add_id: str, date: str):
    conn = connect()
    curs = conn.cursor()
    try:
        # 중복 체크
        check_sql = "select * from addfriends where user_id = %s and add_id = %s"
        curs.execute(check_sql, (user_id, add_id))
        if curs.fetchone():
            return {'results': ['Error'], 'message': '이미 친구 요청을 보냈습니다.'}
        
        insert_sql = "insert into addfriends(user_id, accept, date, add_id) VALUES (%s, %s, %s, %s)"
        curs.execute(insert_sql, (user_id, accept, date, add_id))
        conn.commit()
        return {'results': ['OK'], 'message': '친구 요청이 성공적으로 전송되었습니다.'}
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
        sql = "select user_id from addfriends where add_id=%s and accept='false'"
        curs.execute(sql, (add_id,))
        findfriends = curs.fetchall()
        return {'results': findfriends, 'message': 'Success'}
    except Exception as e:
        print("Error", e)
        return {'results': [], 'message': str(e)}
    finally:
        conn.close()

# 요청온 친구추가
@router.get("/addrequestfriends")
async def addrequestfriends(user_id: str, add_id: str):
    conn = connect()
    curs = conn.cursor()
    try:
        # addfriends 테이블에서 요청 확인 및 수정
        check_sql = "select * from addfriends where user_id = %s and add_id = %s and accept = 'false'"
        curs.execute(check_sql, (add_id, user_id))
        if not curs.fetchone():
            return {'results': ['Error'], 'message': '유효하지 않은 친구 요청입니다.'}
        
        # addfriends 테이블 업데이트
        update_sql = "update addfriends SET accept = 'true' where user_id = %s and add_id = %s"
        curs.execute(update_sql, (add_id, user_id))
        
        # friends 테이블에 양방향으로 추가
        insert_sql = "insert into friends(add_id, user_id) values (%s, %s)"
        curs.execute(insert_sql, (user_id, add_id))
        curs.execute(insert_sql, (add_id, user_id))
        
        conn.commit()
        return {'results': ['Success'], 'message': '친구 요청이 수락되었습니다.'}
    except Exception as e:
        conn.rollback()
        print("Error", e)
        return {'results': ['Error'], 'message': str(e)}
    finally:
        conn.close()

# 친구 삭제
@router.delete("/deletefriend")
async def delete_friend_relationship(user_id, add_id):
    conn = connect()
    curs = conn.cursor()
    try:
        # 관련된 seq
        sql_select = "select seq from friends where (user_id = %s and add_id = %s) or (user_id = %s and add_id = %s)"
        curs.execute(sql_select, (user_id, add_id, add_id, user_id))
        seq_values = curs.fetchall()

        if not seq_values:
            print("No friendship found to delete.")
            return

        # 찾은 seq 값들을 사용하여 레코드들을 삭제
        sql_delete = "delete from friends where seq in (%s)" % ','.join(['%s'] * len(seq_values))
        flattened_seq_values = [item for sublist in seq_values for item in sublist]
        curs.execute(sql_delete, flattened_seq_values)

        conn.commit()
        print(f"Deleted {curs.rowcount} friendship records.")

    except Exception as e:
        conn.rollback()
        print(f"An error occurred: {e}")
    finally:
        curs.close()


