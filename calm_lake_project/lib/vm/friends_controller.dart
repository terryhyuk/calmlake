import 'dart:convert';

import 'package:camlake_test_app/model/addfriends.dart';
import 'package:camlake_test_app/vm/serchfriends_controller.dart';
import 'package:http/http.dart' as http;

import 'package:camlake_test_app/vm/login_handler.dart';
import 'package:get/get.dart';

class FriendsController extends SearchFriendsController {
  List allfriendsdata = [].obs; // 전체친구보기
  List addfriend = [].obs;  // 친구추가요청 리스트
  final loginHandler = Get.find<LoginHandler>();

  // 전체 친구보기
  selectfriendsJSONData()async{
    var url = Uri.parse('http://127.0.0.1:8000/friends/selectfriends');
    var response = await http.get(url);
    allfriendsdata.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    allfriendsdata.addAll(results);
  }

// 신청온 친구 보기
  requstfriendsJSONData(String userId)async{
      var url = Uri.parse('http://127.0.0.1:8000/friends/selectrequestfriends?add_id=$userId');
    var response = await http.get(url);
    addfriend.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    addfriend.addAll(results);
  }

// 친구추가
addfriendsJSONData(Addfriends addfriends)async{
var url = Uri.parse('http://127.0.0.1:8000/friends/insertfriends')
                  .replace(queryParameters: {
    'user_id': addfriends.user_id,
    'accept': addfriends.accept,
    'date': addfriends.date,
    'add_id': addfriends.add_id,
  });

  try {
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    
    if (dataConvertedJSON['results'] is List) {
      List results = dataConvertedJSON['results'];
      if (results.isNotEmpty && results[0] == 'OK') {
        print("Friend added successfully");
        return 'OK';
      } else {
        print("Error: ${dataConvertedJSON['message']}");
        return 'Error';
      }
    } else {
      print("Unexpected response format");
      return 'Error';
    }
  } catch (e) {
    print("Exception occurred: $e");
    return 'Error';
  }
   // var response = await http.get(url);
    // addfriend.clear();
    // var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    // List results = dataConvertedJSON['results'];
    // addfriend.addAll(results);
  }

  //   var url = Uri.parse('http://127.0.0.1:8000/friends/selectrequestfriends?seq=${loginHandler.box.read('userId')}');
  //   var response = await http.get(url);
  //   allfriendsdata.clear();
  //   var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  //   List results = dataConvertedJSON['results'];
  //   requestedFriends.addAll(results);
  // }
}
