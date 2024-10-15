import 'package:calm_lake_project/view/chat/chatroom.dart';
import 'package:calm_lake_project/vm/chating_controller.dart';
import 'package:calm_lake_project/vm/friends_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Chat extends StatelessWidget {
  Chat({Key? key}) : super(key: key);

  final ChatingController chatController = Get.put(ChatingController());
  final FriendsController friendsController = Get.put(FriendsController());
  final TextEditingController roomNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      chatController.initializeDefaultRooms();
    });

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
                  onPressed: () => _showCreateRoomDialog(context),
                  child: const Text('채팅방 생성'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (chatController.chatRooms.isEmpty) {
                return Center(child: Text('채팅방이 없습니다.'));
              }
              return ListView.builder(
                itemCount: chatController.chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatController.chatRooms[index];
                  bool isDefaultRoom = ChatingController.defalult_rooms.contains(room['roomId']);
                  return ListTile(
                    title: Text(room['roomName'] ?? 'Unnamed Room'),
                    subtitle: Text(room['lastMessage'] ?? ''),
                    trailing: Text(chatController
                        .formatTimestamp(room['lastMessageTime'])),
                    onTap: () {
                      Get.to(
                        () => Chatroom(
                          roomId: room['roomId'] ?? '',
                          roomName: room['roomName'] ?? 'Unnamed Room',
                          isDefaultRoom: isDefaultRoom,
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  _showCreateRoomDialog(BuildContext context) {
    List<String> selectedFriends = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('채팅방 생성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomNameController,
                decoration: InputDecoration(hintText: '채팅방 이름'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('생성'),
              onPressed: () {
                if (roomNameController.text.isNotEmpty) {
                  chatController.createChatRoom(
                      roomNameController.text, selectedFriends); // false는 기본 채팅방이 아님을 의미
                  roomNameController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}