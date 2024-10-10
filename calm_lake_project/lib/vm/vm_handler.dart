import 'dart:convert';
import 'package:calm_lake_project/model/favorite.dart';
import 'package:calm_lake_project/model/post.dart';
import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:calm_lake_project/vm/commentController.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class VmHandler extends commentcontroller {
  var posts = [].obs;
  var user = [].obs;
  var userposts = [].obs;
  var favorite = [].obs;
  final box = GetStorage();

  //box.read('userId')
  String userId = 'angie';

  getJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
    print(posts);
  }

  getPostJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List<dynamic> result = dataCovertedJSON['results'];
    for (var item in result) {
      posts.add(Post(
        seq: item[0],
        user_id: item[1],
        date: DateTime.parse(item[2]),
        image: item[3],
        contents: item[4],
        public: item[5],
        favorite_seq: item[6] ?? -1,
        favorite_user_id: item[7] ?? "",
        favorite_post_seq: item[8] ?? -1,
        favorite: item[9] ?? "",
        hate_seq: item[10] ?? -1,
        hate_user_id: item[11] ?? "",
        hate_post_seq: item[12] ?? -1,
        hate: item[1] ?? "",
        comment_count: item[14] ?? 0,
      ));
    }
  }

  getUserJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/user?id=$userId');
    var response = await http.get(url);
    user.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));

    List result = dataCovertedJSON['results'];
    var userData = result[0];
    user.add({
      'id': userData[0],
      'password': userData[1],
      'name': userData[2],
      'email': userData[3],
      'nickname': userData[4],
      'image': userData[5] ?? null
    });
    update();
  }

  getUserPostJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/userpost?user_id=$userId');
    var response = await http.get(url);
    userposts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    userposts.addAll(result);
  }

  insertJSONData(
      String image, String contents, int public, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/insert/insert?date=${DateTime.now()}&image=$image&contents=$contents&public=$public&user_id=$userId');
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

  checkFavorite(String user_id, int post_id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/checkfavorite?user_id=$userId&post_seq=$post_id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

  Future<void> insertFavorite(int favorite, int seq) async {
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

  Future<void> updateFavorite(int favorite, int postSeq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/update_favorite?favorite=$favorite&post_seq=$postSeq&user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
  }

  checkHate(String user_id, int post_id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/checkhate?user_id=$userId&post_seq=$post_id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

  Future<void> updateHate(int hate, int postSeq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/update_hate?hate=$hate&post_seq=$postSeq&user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
  }

  Future<void> insertHate(int hate, int seq) async {
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
/*
  updateJSONDataAll(date) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/update/updateAll?seq=${value[0]}&name=${nameControl.text}&image=$filename&phone=${phoneControl.text}&favorite=$favorite&comment=${commentControl.text}&evaluate=$evaluate&user_id=${value[10]}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      print('Success');
    } else {
      print('Error');
    }
  }

  updateJSONData(date) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/update/update?seq=${value[0]}&name=${nameControl.text}&phone=${phoneControl.text}&favorite=$favorite&comment=${commentControl.text}&evaluate=$evaluate&user_id=${value[10]}');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    if (result == 'OK') {
      print('Success');
    } else {
      print('Error');
    }
  }
  */
}
