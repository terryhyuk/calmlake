import 'dart:convert';
import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:calm_lake_project/vm/musicinsert.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'list_handler.dart';

class VmHandler extends Musicinsert {
  var posts = [].obs;
  var user = [].obs;
  var userposts = [].obs;
  var favorite = [].obs;

  getJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
    //print(posts);
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
      'comment_count': post[14],
    });
  }

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

  getUserPostJSONData(String userId) async {
    var url = Uri.parse('http://127.0.0.1:8000/query/userpost?user_id=$userId');
    var response = await http.get(url);
    userposts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    userposts.addAll(result);
  }

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

  checkFavorite(String userId, int post_id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/checkfavorite?user_id=$userId&post_seq=$post_id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

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

  Future<void> updateFavorite(int favorite, int postSeq, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/update_favorite?favorite=$favorite&post_seq=$postSeq&user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
  }

  checkHate(String userId, int post_id) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/checkhate?user_id=$userId&post_seq=$post_id');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['result'];
    return result;
  }

  Future<void> updateHate(int hate, int postSeq, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/update_hate?hate=$hate&post_seq=$postSeq&user_id=$userId');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
  }

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

  deletePost(seq, filename) async {
    await deletePostImage(filename);
    var url = Uri.parse('http://127.0.0.1:8000/query/deletepost?seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    if (result == 'OK') {
      print('success');
    }
  }
}
