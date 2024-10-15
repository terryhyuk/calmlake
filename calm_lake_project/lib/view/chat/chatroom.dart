
import 'package:calm_lake_project/model/message.dart';
import 'package:calm_lake_project/view/chat/add_chatroom_friends.dart';
import 'package:calm_lake_project/vm/chating_controller.dart';
import 'package:calm_lake_project/vm/friends_controller.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class Chatroom extends StatelessWidget {
  final FriendsController friendsController = Get.put(FriendsController());
  final String roomId;
  final String roomName;
  final bool isDefaultRoom;

  Chatroom({
    Key? key, 
    required this.roomId, 
    required this.roomName, 
    required this.isDefaultRoom
  }) : super(key: key);

  final ChatingController chatController = Get.find<ChatingController>();
  final loginhandler = Get.find<LoginHandler>();
  final TextEditingController sendController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    chatController.loadMessages(roomId, isDefaultRoom);

    return Scaffold(
      appBar: AppBar(
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
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  Message message = chatController.messages[index];
                  return ListTile(
                    title: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              message.userID == loginhandler.box.read('userId')
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            BubbleSpecialThree(
                              text: message.contents,
                              color: message.userID ==
                                      loginhandler.box.read('userId')
                                  ? const Color(0xFF90CAF9)
                                  : const Color(0xFF2196F3),
                              tail: true,
                              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              message.userID == loginhandler.box.read('userId')
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(message.timestamp),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
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
                  BoxShadow(color: Color.fromARGB(18, 0, 0, 0), blurRadius: 10)
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

