import 'dart:convert';

import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class commentcontroller extends ButtonController {
  var comments = [].obs;
  TextEditingController textController = TextEditingController();
  final box = GetStorage();
  //box.read('userId')
  String userId = 'angie';
  @override
  void onClose() {
    textController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러 해제
    super.onClose();
  }

  getComment(int postSeq) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/query/comment?post_seq=$postSeq');
    var response = await http.get(url);
    comments.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    comments.addAll(result);
    print(comments);
  }

  insertCommnet(int postSeq, String text) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/insert_comment?user_id=$userId&post_seq=$postSeq&text=$text');
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
