import 'dart:convert';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class SearchFriendsController extends GetxController {
  List friends = [].obs;
  final loginHandler = Get.find<LoginHandler>();
  

  searchFriendsJSON(String searchText) async {
    String userId = loginHandler.box.read('userId')??'';
    var url =
        Uri.parse('http://10.0.2.2:8000/friends/searchfriends?search=$searchText&id=$userId');
    var response = await http.get(url);
    friends.clear();
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertedJSON['results'];
    friends.addAll(results);
  }

}
