import 'package:calm_lake_project/vm/chating_controller.dart';
import 'package:calm_lake_project/vm/friends_controller.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AddChatroomFriends extends StatelessWidget {
  final String roomId;
  final String roomName;

  AddChatroomFriends({Key? key, required this.roomId, required this.roomName, required bool isDefaultRoom}) : super(key: key);
  
  final LoginHandler loginHandler = Get.find<LoginHandler>();
  final FriendsController friendsController = Get.find<FriendsController>();
  final ChatingController chatController = Get.find<ChatingController>();

  final RxList<String> selectedFriends = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      friendsController.selectfriendsJSONData(loginHandler.box.read('userId'));
    });
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$roomName에 친구 초대'),
      ),
      body: Obx(() {
        if (friendsController.allfriendsdata.isEmpty) {
          return const Center(child: Text('초대할 친구가 없습니다'));
        }
        return ListView.builder(
          itemCount: friendsController.allfriendsdata.length,
          itemBuilder: (context, index) {
            final friend = friendsController.allfriendsdata[index];
            final friendId = friend[0].toString();
            final friendName = friend[1].toString();
            return Obx(() => CheckboxListTile(
              title: Text(friendName),
              value: selectedFriends.contains(friendId),
              onChanged: (bool? value) {
                if (value == true) {
                  selectedFriends.add(friendId);
                } else {
                  selectedFriends.remove(friendId);
                }
                print('Selected friends: ${selectedFriends.toList()}');
              },
            ));
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedFriends.isNotEmpty) {
            await chatController.addFriendsToChatRoom(roomId, selectedFriends);
            Get.back();
            Get.snackbar('성공', '선택한 친구들을 채팅방에 추가했습니다.',
                snackPosition: SnackPosition.BOTTOM);
          } else {
            Get.snackbar('알림', '추가할 친구를 선택해주세요.',
                snackPosition: SnackPosition.BOTTOM);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
