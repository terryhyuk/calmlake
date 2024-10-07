import 'dart:convert';
import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VmHandler extends ButtonController {
  var posts = [].obs;
  String userId = 'user';

  getJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/select?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
  }

  getUserJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/user?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
    print(posts);
  }

  getUserPostJSONData() async {
    var url = Uri.parse('http://127.0.0.1:8000/query/userpost?user_id=$userId');
    var response = await http.get(url);
    posts.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    posts.addAll(result);
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
}
