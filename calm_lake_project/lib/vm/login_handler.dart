import 'dart:convert';
import 'dart:typed_data';
import 'package:calm_lake_project/model/activity.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/profile.dart';
import 'package:http/http.dart' as http;
import 'validate_check.dart';

class LoginHandler extends ValidateCheck {
  final box = GetStorage();
  //Property
  // var users = <Profile>[].obs;
  RxString id = ''.obs;
  RxString findId = ''.obs;
  RxString findPw = ''.obs;
  String idLabel = '';
  String nickLabel = '';

  iniStorage() {
    box.write('userId', '');
    box.write('nickname', '');
  }

  @override
  void dispose() {
    disposeSave();
    super.dispose();
  }

  disposeSave() {
    box.erase();
  }

  //회원가입
  insertJSONData(Profile profile) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/insertuserid?id=${profile.id}&password=${profile.pw}&email=${profile.email}&nickname=${profile.nickName}&pw_answer=${profile.pwAnswer}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    String result = dataConvertedJSON['results'];
    return result;
  }

  //ID 중복체크
  checkIdJSONData(String insertId) async {
    var url = Uri.parse('http://127.0.0.1:8000/login/checkuserid?id=$insertId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result > 0;
  }

  idDoublecheck(String insertId) async {
    try {
      await checkIdJSONData(insertId);
      if (insertId.isEmpty) {
        idLabel = '';
      } else {
        bool isDuplicate = await checkIdJSONData(insertId);
        if (isDuplicate) {
          idLabel = '사용할 수 없는 ID입니다.';
        } else {
          idLabel = '사용 가능한 ID입니다.';
        }
      }
    } catch (e) {
      idLabel = '다시 시도해주세요.';
    }
    update();
  }

  //Nickname 중복체크
  checkNickJSONData(String insertNick) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/checkusernick?nickname=$insertNick');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result > 0;
  }

  nickDoublecheck(String insertNick) async {
    try {
      await checkNickJSONData(insertNick);
      if (insertNick.isEmpty) {
        nickLabel = '';
      } else {
        bool isDuplicate = await checkNickJSONData(insertNick);
        if (isDuplicate) {
          nickLabel = '사용할 수 없는 Nickname입니다.';
        } else {
          nickLabel = '사용 가능한 Nickname입니다.';
        }
      }
    } catch (e) {
      nickLabel = '다시 시도해주세요.';
    }
    update();
  }

  //회원 확인
  checkUserJSONData(String id, String pw) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/login/checkuser?id=$id&password=$pw');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  //ID 찾기
  findIdJSONData(String nickName) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/login/findid?nickname=$nickName');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    findId.value = result;
    update();
  }

  //Password 찾기
  findPwJSONData(String id) async {
    var url = Uri.parse('http://127.0.0.1:8000/login/findpw?id=$id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    findPw.value = result.toString();
    update();
  }

  findAwJSONData(String answer) async {
    var url = Uri.parse('http://127.0.0.1:8000/login/findid?nickname=$answer');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    findPw.value = result.toString();
    update();
  }

  //Password 재설정
  changePwJSONData(String newPw, String id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/changepw?password=$newPw&id=$id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  //활동 유저 확인
  Future<bool> checkActiveJSONData(String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/checkactiveuser?user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    if (result > 0) {
      return result > 0;
    } else {
      return false;
    }
  }

  activeUserJSONData(String userId) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/login/activeuser?user_id=$userId');
    var response = await http.post(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  //활동 유저 삭제(logout)
  logoutJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/login/logout?user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  //유저 로그
  useractivityJSONData(Activity activity) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/login/useractivity?user_id=${activity.userId}&activity=${activity.activity}&datetime=${activity.datetime}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  //유저 로그 datetime 반환(active_user에 insert_id 있을 경우 사용)
  findActiveIdJSONData(String insertId) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/login/findactiveid?user_id=$insertId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result != 'Not found' ? DateTime.parse(result) : result;
  }

  //유저 프로필 확인
  Future<Profile> showProfileJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/login/showprofile?id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return Profile(
      id: userId,
      pw: result[0] ?? '',
      email: result[1] ?? '',
      nickName: result[2] ?? '',
      image: result[3],
    );
  }

  //유저 정보 수정
  changeUserJSONData(Profile profile) async {
    var url = Uri.parse(
        'http://10.0.2.2:8000/login/changeuser?nickname=${profile.nickName}&email=${profile.email}&password=${profile.pw}&user_image=${profile.image}&id=${profile.id}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  //회원 탈퇴
  deleteUserJSONData(String userId) async {
    var url = Uri.parse('http://10.0.2.2:8000/login/deleteuser?id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }
}
