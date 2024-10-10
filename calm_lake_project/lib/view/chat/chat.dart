import 'package:calm_lake_project/view/chat/chatroom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => Chatroom());
              },
              child: Text('채팅룸1'),
            ),
          ],
        ),
      ),
    );
  }
}// END