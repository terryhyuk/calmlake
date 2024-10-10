import 'dart:convert';
import 'package:firebase_list2_app/vm/list_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'button_controller.dart';

class VmHandler extends ListHandler{
  var posts = [].obs;
  String userId = 'user';

  getJSONData() async {
    var url = Uri.parse('http://10.0.2.2:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
  }

  getUserJSONData() async {
    var url = Uri.parse('http://10.0.2.2:8000/query/user?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
    print(posts);
  }

  getUserPostJSONData() async {
    var url = Uri.parse('http://10.0.2.2:8000/query/userpost?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
  }

  insertJSONData(
      String image, String contents, int public, String userId) async {
    var url = Uri.parse(
        'http://10.0.2.2:8000/insert/insert?date=${DateTime.now()}&image=$image&contents=$contents&public=$public&user_id=$userId');
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
}
