import 'package:calm_lake_project/view/chat/chatroom.dart';
import 'package:calm_lake_project/vm/chating_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Chat extends StatelessWidget {
  Chat({Key? key}) : super(key: key);

  final ChatingController chatController = Get.put(ChatingController());
  final TextEditingController roomNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: roomNameController,
                    decoration: const InputDecoration(
                      hintText: '새 채팅방 이름',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (roomNameController.text.isNotEmpty) {
                      await chatController
                          .createChatRoom(roomNameController.text);
                      roomNameController.clear();
                      print(chatController.chatRooms);
                    }
                  },
                  child: const Text('채팅방 생성'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: chatController.chatRooms.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(chatController.chatRooms[index]),
                      onTap: () {
                        Get.to(
                          Chatroom(
                            roomId: chatController.chatRooms[index],
                            roomName: roomNameController.text,
                          ),
                        );
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
