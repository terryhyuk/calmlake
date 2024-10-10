import 'dart:convert';

import 'package:calm_lake_project/model/addfriends.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart' as http;

class SearchFriendsController extends GetxController {

  List friends = [].obs;
  List addfriend = [].obs;

  searchFriendsJSON(String searchText) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/friends/searchfriends?search=$searchText');
    var response = await http.get(url);
    friends.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    friends.addAll(results);
  }

  // 친구추가
  addfriendsJSONData(Addfriends addfriends)async{
    var url = Uri.parse('http://127.0.0.1:8000/friends/insertfriends')
                    .replace(queryParameters: {
      'user_id': addfriends.user_id,
      'accept': addfriends.accept,
      'addid': addfriends.addid,
      'date': addfriends.date
    });
    
    var response = await http.get(url);
    addfriend.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    addfriend.addAll(results);
  }
}
