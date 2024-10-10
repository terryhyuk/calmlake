import 'dart:convert';

import 'package:camlake_test_app/model/requestedfriends.dart';
import 'package:camlake_test_app/vm/serchfriends_controller.dart';
import 'package:http/http.dart' as http;

import 'package:camlake_test_app/vm/login_handler.dart';
import 'package:get/get.dart';

class FriendsController extends SearchFriendsController {
  List allfriendsdata = [].obs;
  List requestedFriends = <RequestedFriend>[].obs;
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

// 신청한 친구 보기
  requstfriendsJSONData()async{
    try {
      if (loginHandler.box.read('userId') == null) {
        throw Exception('User not logged in');
      }

      var url = Uri.parse('http://127.0.0.1:8000/friends/selectrequestfriends?seq=${loginHandler.box.read('userId')}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
        if (dataConvertedJSON['results'] is List) {
          requestedFriends.assignAll((dataConvertedJSON['results'] as List)
              .map((item) => RequestedFriend.fromMap(item)));
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load friend requests');
      }
    } catch (e) {
      print("Error fetching friend requests: $e");
      requestedFriends.clear();
    }
  }
  //   var url = Uri.parse('http://127.0.0.1:8000/friends/selectrequestfriends?seq=${loginHandler.box.read('userId')}');
  //   var response = await http.get(url);
  //   allfriendsdata.clear();
  //   var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
  //   List results = dataConvertedJSON['results'];
  //   requestedFriends.addAll(results);
  // }
}
