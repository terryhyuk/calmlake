"""
author      : ws
Description : 회원 관리
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

# 입력한 id, pw와 일치하는 유저가 있는지 확인
@router.get("/checkuser")
async def checkuser(id: str=None, password: str=None):
    print(id, password)
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select count(*) from user where id=%s and password=%s"
        curs.execute(sql,(id, password))
        conn.commit()
        user_check = curs.fetchone()[0]
        conn.close()
        return{'results': user_check}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}
    
# nickname과 일치하는 id가 있는지 확인    
@router.get("/findid")
async def findid(nickname: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select id from user where nickname=%s"
        curs.execute(sql,(nickname,))
        conn.commit()
        result=curs.fetchone()[0]
        conn.close()
        return{'results': result}
    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results':'Not found'}
    
# 입력한 id와 일치하는 answer 반환
@router.get("/findpw")
async def findpw(id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select pw_answer from user where id=%s"
        curs.execute(sql,(id,))
        conn.commit()
        result=curs.fetchone()[0]
        conn.close()
        return{'results': result}
    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results':'Error'}

# id 중복체크
@router.get("/checkuserid")
async def checkuserid(id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select count(*) from user where id=%s"
        curs.execute(sql,(id,))
        conn.commit()
        result = curs.fetchone()[0]
        conn.close()
        return{'results': result}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}
    
# nickname 중복체크
@router.get("/checkusernick")
async def checkusernick(nickname: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select count(*) from user where nickname=%s"
        curs.execute(sql,(nickname,))
        conn.commit()
        result = curs.fetchone()[0]
        conn.close()
        return{'results': result}
    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results':'Error'}

# 회원가입
@router.get("/insertuserid")
async def insertuser(id: str=None, password: str=None, email: str=None, nickname: str=None, pw_answer: str=None):
    conn=connect()
    curs=conn.cursor()

    try:
        sql="insert into user(id, password, email, nickname, pw_answer) values (%s,%s,%s,%s,%s)"
        curs.execute(sql,(id,password,email,nickname,pw_answer))
        conn.commit()
        conn.close()
        return{'results':'OK'}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}
    
# Password 재설정
@router.get('/changepw')
async def changepw(password: str=None, id: str=None):
    conn=connect()
    curs=conn.cursor()
    try: 
        sql='update user set password=%s where id=%s'
        curs.execute(sql, (password, id))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results':'Error'}    
    
# 접속 user 확인
@router.get("/checkactiveuser")
async def checkuserid(user_id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select count(*) from active_user where user_id=%s"
        curs.execute(sql,(user_id,))
        result = curs.fetchone()[0]
        print(result)
        conn.close()
        return{'results': result}
    except Exception as e:
        result=0
        conn.close()
        print("Error",e)
        return{'results': result}

# 접속 user 삽입
@router.post("/activeuser")
async def activeuser(user_id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="insert into active_user(user_id) values (%s)"
        curs.execute(sql,(user_id,))
        conn.commit()
        conn.close()
        return{'results':'OK'}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}
    
# 접속 user activity log
@router.get("/useractivity")
async def useractivity(user_id: str=None, activity: str=None, datetime: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="insert into activity(user_id, activity, datetime) values (%s,%s,%s)"
        curs.execute(sql,(user_id, activity, datetime))
        conn.commit()
        conn.close()
        return{'results':'OK'}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}
    
# 접속 user 삭제(logout)
@router.get("/logout")
async def logout(user_id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="delete from active_user where user_id=%s"
        curs.execute(sql,(user_id,))
        conn.commit()
        conn.close()
        return{'results':'OK'}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}

# active_user에 login insert_id가 있는 경우 -> 
# insert_id activity[datetime] - datetime.now()가 5min 이상이면 logout시키고, allowLogin
@router.get("/findactiveid")
async def findactiveid(user_id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select datetime from activity where user_id=%s order by datetime desc limit 1"
        curs.execute(sql,(user_id,))
        conn.commit()
        result=curs.fetchone()[0]
        conn.close()
        return{'results': result}
    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results':'Not found'}
    
# 회원 정보 확인
@router.get("/showprofile")
async def showprofile(id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select password, email, nickname, user_image from user where id=%s"
        curs.execute(sql,(id,))
        conn.commit()
        result=curs.fetchone()
        conn.close()
        return{'results': result}
    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results':'Error'}
    
# 회원 정보 변경
@router.get('/changeuser')
async def changeuser(nickname: str=None, email: str=None, password: str=None, user_image: str=None, id: str=None):
    conn=connect()
    curs=conn.cursor()
    try: 
        sql='update user set nickname=%s, email=%s, password=%s, user_image=%s where id=%s'
        curs.execute(sql, (nickname, email, password, user_image, id))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results':'Error'}

# 회원 탈퇴
@router.get("/deleteuser")
async def deleteuser(id: str=None):
    conn=connect()
    curs=conn.cursor()
    try:
        sql="delete from user where id=%s"
        curs.execute(sql,(id,))
        conn.commit()
        conn.close()
        return{'results':'OK'}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'results':'Error'}
    
# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(router, host="127.0.0.1", port=8000)    