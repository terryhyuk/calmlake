
import 'package:calm_lake_project/model/message.dart';
import 'package:calm_lake_project/view/chat/add_chatroom_friends.dart';
import 'package:calm_lake_project/vm/chating_controller.dart';
import 'package:calm_lake_project/vm/friends_controller.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class Chatroom extends StatelessWidget {
  final FriendsController friendsController = Get.put(FriendsController());
  final String roomId;
  final String roomName;
  final bool isDefaultRoom;

  Chatroom(
      {Key? key,
      required this.roomId,
      required this.roomName,
      required this.isDefaultRoom})
      : super(key: key);

  final ChatingController chatController = Get.find<ChatingController>();
  final loginhandler = Get.find<LoginHandler>();
  final TextEditingController sendController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    chatController.loadMessages(roomId, isDefaultRoom);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(roomName),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => AddChatroomFriends(
                    roomId: roomId,
                    roomName: roomName,
                    isDefaultRoom: isDefaultRoom,
                  ));
            },
            icon: const Icon(Icons.group_add_outlined),
          )
        ],
      ),
      body: Column(
        children: [
                DateChip(
                  date: DateTime.now(),
                  color: const Color.fromARGB(255, 221, 241, 194),
                  ),          
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  Message message = chatController.messages[index];
                  bool isCurrentUser =
                      message.userID == loginhandler.box.read('userId');
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.nickname, // 닉네임사용
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            BubbleSpecialThree(
                              text: message.contents,
                              color: isCurrentUser
                                  ? const Color.fromARGB(255, 71, 168, 248)
                                  : const Color.fromARGB(255, 172, 172, 172),
                              tail: true,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('h:mm a').format(message.timestamp),
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Color.fromARGB(8, 0, 0, 0), blurRadius: 10)
                ],
              ),
              child: TextField(
                controller: sendController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    iconSize: 25,
                  ),
                  hintText: "Type your message here",
                ),
              ),
            ),
          ),
          SizedBox(height: 5,)
        ],
      ),
    );
  }

  sendMessage() {
    if (sendController.text.isNotEmpty) {
      String userId = loginhandler.box.read('userId');
      String userNickname = loginhandler.box.read('nickname') ?? 'Anonymous';

      chatController.addMessage(
        roomId,
        userId,
        userNickname,
        sendController.text,
        isDefaultRoom,
      );
      sendController.clear();
    }
  }
}
