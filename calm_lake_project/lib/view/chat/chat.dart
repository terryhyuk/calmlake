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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.initializeDefaultRooms();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           controller: roomNameController,
          //           decoration: const InputDecoration(
          //             hintText: '새 채팅방 이름',
          //             border: OutlineInputBorder(),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       ElevatedButton(
          //         onPressed: () => _showCreateRoomDialog(context),
          //         child: const Text('채팅방 생성'),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Obx(() {
              if (chatController.chatRooms.isEmpty) {
                return const Center(child: Text('채팅방이 없습니다.'));
              }
              return ListView.builder(
                itemCount: chatController.chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatController.chatRooms[index];
                  bool isDefaultRoom =
                      ChatingController.defalult_rooms.contains(room['roomId']);
                  return GestureDetector(
                    onLongPress: () {
                      _showDeleteDialog(context, room['roomId'], isDefaultRoom);
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: chatController
                                  .getRoomImageProvider(room['roomName']),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room['roomName'] ?? 'Unnamed Room',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          room['lastMessage'] ?? '',
                                          style: TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        chatController.getRoomDescription(
                                                    room['roomName']) !=
                                                ''
                                            ? chatController.getRoomDescription(
                                                room['roomName'])
                                            : chatController.formatTimestamp(
                                                room['lastMessageTime']),
                                        style: chatController
                                            .getRoomDescriptionStyle(
                                                room['roomName']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

  // _showCreateRoomDialog(BuildContext context) {
  //   List<String> selectedFriends = [];
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('채팅방 생성'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: roomNameController,
  //               decoration: const InputDecoration(hintText: '채팅방 이름'),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             child: const Text('취소'),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: const Text('생성'),
  //             onPressed: () {
  //               if (roomNameController.text.isNotEmpty) {
  //                 chatController.createChatRoom(roomNameController.text,
  //                     selectedFriends); // false는 기본 채팅방이 아님을 의미
  //                 roomNameController.clear();
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  _showDeleteDialog(BuildContext context, String roomId, bool isDefaultRoom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('채팅방 나가기'),
          content: const Text('이 채팅방에서 나가시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('나가기'),
              onPressed: () {
                chatController.deleteChatRoom(roomId, isDefaultRoom);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
