import 'dart:convert';
import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:calm_lake_project/vm/comment_controller.dart';
import 'package:calm_lake_project/vm/musicinsert.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'list_handler.dart';

class VmHandler extends commentcontroller {
  var posts = [].obs;
  var user = [].obs;
  var userposts = [].obs;
  var favorite = [].obs;
  var search = ''.obs;
  var searchPost = [].obs;
  var favoritePost = [].obs;

// post page
  getJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
    print(posts);
  }

// 인기순 정렬시 가져오는 데이터
  getTopJSONData(String userId) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/query/select_top?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
    print(posts);
  }

// 검색시 나오는 데이터
  getSearchJSONData(String userId, String search) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/select_search?user_id=$userId&search=$search');
    var response = await http.get(url);
    searchPost.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    searchPost.addAll(result);
    print(searchPost);
  }

// 각 유저가 좋아요 누른 post
  getFavoriteJSONData(String userId) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/query/favorite_post?user_id=$userId');
    var response = await http.get(url);
    favoritePost.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    favoritePost.addAll(result);
    print(favoritePost);
  }

  getPostJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List<dynamic> result = dataCovertedJSON['results'];
    var post = result[0];
    posts.add({
      'seq': post[0],
      'user_id': post[1],
      'date': post[2],
      'image': post[3],
      'contents': post[4],
      'public': post[5],
      'post_nickname': post[6],
      'favorite_seq': post[7],
      'favorite_user_id': post[8],
      'favorite_post_seq': post[9],
      'favorite': post[10],
      'hate_seq': post[11],
      'hate_user_id': post[12],
      'hate_post_seq': post[13],
      'hate': post[14],
      'comment_count': post[15],
    });
  }

// 사용자의 개인 정보
  getUserJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/query/user?id=$userId');
    var response = await http.get(url);
    user.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    var userData = result[0];
    user.add({
      'id': userData[0],
      'password': userData[1],
      'email': userData[2],
      'nickname': userData[3],
      'user_image': userData[4] ?? null,
      'pw_answer': userData[5]
    });
  }

// 각 사용자의 post
  getUserPostJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/query/userpost?user_id=$userId');
    var response = await http.get(url);
    userposts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    userposts.addAll(result);
  }

// post insert 함수
  insertJSONData(String image, String contents, int public, String userId,
      String nickname) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/insert/insert?post_user_id=$userId&date=${DateTime.now()}&image=$image&contents=$contents&public=$public&post_nickname=$nickname');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    print(dataConvertedJSON);
    if (result == 'OK') {
      print('Success');
    } else {
      print('Error');
    }
  }

// 사용자가 좋아요를 누른적이 있는지 확인
  checkFavorite(String userId, int post_id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/checkfavorite?user_id=$userId&post_seq=$post_id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

// 사용자가 좋아요를 처음 누를때
  Future<void> insertFavorite(int favorite, int seq, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/insert_favorite?favorite=$favorite&user_id=$userId&post_seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    if (result == 'OK') {
      print('success');
    } else {
      print('error');
    }
  }

// 사용자가 좋아요를 다시 놀렀을때
  Future<void> updateFavorite(int favorite, int postSeq, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/update_favorite?favorite=$favorite&post_seq=$postSeq&user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
  }

// 사용자가 기존에 싫어요 누른 적이 있는지 확인
  checkHate(String userId, int post_id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/checkhate?user_id=$userId&post_seq=$post_id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

// 사용자가 싫어요 버튼을 다시 눌렀을때
  Future<void> updateHate(int hate, int postSeq, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/update_hate?hate=$hate&post_seq=$postSeq&user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
  }

// 사용자가 싫어요 버튼 눌렀을때
  Future<void> insertHate(int hate, int seq, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/insert_hate?hate=$hate&user_id=$userId&post_seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    if (result == 'OK') {
      print('success');
    } else {
      print('error');
    }
  }

// post 업데이트(사진 포함)
  updateJSONDataAll(String image, String contents, int public, int seq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/updateAll?image=$image&contents=$contents&public=$public&seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      print('Success');
    } else {
      print('Error');
    }
  }

// post 업데이트(사진 업데이트 되지 않음)
  updateJSONData(String contents, int public, int seq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/update?contents=$contents&public=$public&seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      print('Success');
    } else {
      print('Error');
    }
  }

// post 삭제
  deletePost(seq, filename) async {
    await deletePostImage(filename);
    var url = Uri.parse('http://127.0.0.1:8000/query/deletepost?seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  var selectedValue = '최신순'.obs; // 드랍다운 버튼 관리

  final List<String> dropdownItems = ['최신순', '인기순'];

  updateSelectedValue(String value, String userId) async {
    selectedValue.value = value;
    if (selectedValue.value == '최신순') {
      await getJSONData(userId);
    } else {
      await getTopJSONData(userId);
    }
  }

  reset() {
    selectedValue.value = '최신순'; // 초기값으로 재설정
    search.value = '';
    update();
  }

  updateSearchBar(String value) {
    search.value = value; // 검색어 업데이트
  }
}
