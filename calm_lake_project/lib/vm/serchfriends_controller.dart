import 'dart:convert';

import 'package:get/state_manager.dart';
import 'package:http/http.dart' as http;

class SearchFriendsController extends GetxController {

  List friends = [].obs;
  

  searchFriendsJSON(String searchText) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/friends/searchfriends?search=$searchText');
    var response = await http.get(url);
    friends.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    friends.addAll(results);
  }

}
