import 'dart:convert';
import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class commentcontroller extends ButtonController {
  var commentreply = [].obs; // comment와 reply 함께 저장
  TextEditingController textController =
      TextEditingController(); // comment controlloer
  int commentIndex = 0; // reply 입력시 comment index 가져옴
  TextEditingController replyTextController =
      TextEditingController(); // reply controller
/*
  @override
  void onClose() {
    textController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러 해제
    replyTextController.dispose();
    super.onClose();
  }
*/
  // comment 와 reply 가져오는 함수
  getCommentReply(int postSeq) async {
    var url =
        Uri.parse('http://127.0.0.1:8000/query/commentreply?post_seq=$postSeq');
    var response = await http.get(url);
    commentreply.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    commentreply.addAll(result);
    print(commentreply);
    update();
  }

  // comment 입력 함수
  insertCommnet(int postSeq, String text, String userId) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/insert_comment?user_id=$userId&post_seq=$postSeq&text=$text&comment_date=${DateTime.now()}');
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

// reply 입력
  insertReply(int postSeq, String userId, int commentSeq, String reply) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/insert_reply?post_seq=$postSeq&user_id=$userId&comment_seq=$commentSeq&reply=$reply&reply_date=${DateTime.now()}');
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

  deleteComment(String userId, int seq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/deletecomment?user_id=$userId&seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    print(result);
    return result;
  }

  deleteReply(String userId, int seq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/deletereply?user_id=$userId&seq=$seq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    print(result);
    return result;
  }
}
