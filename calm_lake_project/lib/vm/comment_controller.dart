import 'dart:convert';
import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class commentcontroller extends ButtonController {
  var comments = [].obs;
  var commentreply = [].obs;
  var replies = [].obs;
  TextEditingController textController = TextEditingController();
  int commentIndex = 0;
  TextEditingController replyTextController = TextEditingController();

  @override
  void onClose() {
    textController.dispose(); // 메모리 누수를 방지하기 위해 컨트롤러 해제
    super.onClose();
  }
/*
// Firestore 인스턴스 가져오기
  var commentss = <QueryDocumentSnapshot>[].obs;
  var repliess = <QueryDocumentSnapshot>[].obs;
  // Firestore에서 댓글 가져오기
  Future<void> fetchComments(int postSeq) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc('$postSeq')
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();
    commentss.value = snapshot.docs;
    update(); // 상태 업데이트
    //print(snapshot.docs);
  }

  Future<void> fetchReplies(int postSeq, String commentSeq) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc('$postSeq')
        .collection('comments')
        .doc(commentSeq)
        .collection('replies')
        .orderBy('createdAt', descending: true)
        .get();
    repliess.value = snapshot.docs;
    update(); // 상태 업데이트
    //print(snapshot.docs);
  }

  Future<void> addComment(
      int postSeq, String commentText, String userId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc('$postSeq')
        .collection('comments')
        .add({
      'text': commentText,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // 댓글 추가 후 업데이트
    fetchComments(postSeq);
  }

  Future<void> addReply(
      int postSeq, String commentId, String replyText, String userId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc('$postSeq')
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .add({
      'text': replyText,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 댓글을 다시 불러와서 업데이트 (필요시)
    fetchComments(postSeq);
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
    update();
  }

    deleteCommentJSONData(String userId, int seq, int commentSeq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/deletecomment?user_id=$userId&seq=$seq&comment_seq=$commentSeq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }
  
    getReply(int commentSeq, int postSeq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/reply?comment_seq=$commentSeq&post_seq=$postSeq');
    var response = await http.get(url);
    comments.clear();
    var dataCovertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataCovertedJSON['results'];
    replies.addAll(result);
    //print(replies);
  }
  
  */

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

  deleteReplyJSONData(int commentSeq) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/deletereply?comment_seq=$commentSeq');
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    var result = dataConvertedJSON['results'];
    return result;
  }

  insertCommnet(int postSeq, String text, String userId) async {
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

  insertReply(int postSeq, String userId, int commentSeq, String reply) async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/query/insert_reply?post_seq=$postSeq&reply_user_id=$userId&comment_seq=$commentSeq&reply=$reply&reply_date=${DateTime.now()}');
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
/*

    @override
  void onInit() {
    fetchComments(); // 초기화 시 댓글 가져오기
    super.onInit();
  }
  var commentss = <Comment>[].obs; // RxList를 사용하여 상태 관리

  Future<void> fetchComments() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/comments'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      commentss.value = jsonResponse.map((comment) {
        List<Reply> replies = (comment['replies'] as List).map((reply) {
          return Reply(id: reply['id'], text: reply['text']);
        }).toList();
        return Comment(id: comment['id'], text: comment['text'], replies: replies);
      }).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> addReply(int commentId, String replyText) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/add_reply'), // 답글 추가 API 엔드포인트
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'comment_id': commentId,
        'text': replyText,
      }),
    );

    if (response.statusCode == 200) {
      fetchComments(); // 댓글 목록을 다시 가져오기
    } else {
      throw Exception('Failed to add reply');
    }
  }*/
}
