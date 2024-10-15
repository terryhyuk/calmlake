import 'dart:convert';

import 'package:calm_lake_project/model/addfriends.dart';
import 'package:calm_lake_project/vm/serchfriends_controller.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';

class FriendsController extends SearchFriendsController {
  List allfriendsdata = [].obs; // 전체친구보기
  List addfriend = [].obs;  // 친구추가요청 리스트

// 전체 친구보기
selectfriendsJSONData(String userId) async {
  var url = Uri.parse('http://127.0.0.1:8000/friends/selectfriends?user_id=$userId');
  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      if (dataConvertedJSON['results'] != 'Error') {
        allfriendsdata.clear();
        List results = dataConvertedJSON['results'];
        allfriendsdata.addAll(results);
        print("친구 목록: $allfriendsdata");  // 디버깅용
      } else {
        print("Error fetching friends");
      }
    } else {
      print("HTTP Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception: $e");
  }
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

// 친구신청 요청
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
  }

  //친구요청 수락
acceptFriendRequest(String add_id) async {
  String user_id = loginHandler.box.read('userId') ?? ''; // 현재 로그인한 사용자의 ID
  var url = Uri.parse('http://127.0.0.1:8000/friends/addrequestfriends?user_id=$user_id&add_id=$add_id');
  
  try {
    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      
      if (dataConvertedJSON['results'][0] == 'Success') {
        print(dataConvertedJSON['message']);
        await requstfriendsJSONData(user_id); 
        return true;
      } else {
        print('Error: ${dataConvertedJSON['message']}');
        return false;
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Exception: $e');
    return false;
  }
}
}
