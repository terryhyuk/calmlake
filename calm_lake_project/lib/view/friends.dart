import 'package:calm_lake_project/model/addfriends.dart';
import 'package:calm_lake_project/view/chat/chatroom.dart';
import 'package:calm_lake_project/vm/chating_controller.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Friends extends StatelessWidget {
  Friends({super.key});

  final ChatingController friendsController = Get.put(ChatingController());
  final TextEditingController textEditingController = TextEditingController();
  final LoginHandler loginHandler = Get.put(LoginHandler());

  @override
  Widget build(BuildContext context) {
    friendsController.selectfriendsJSONData(loginHandler.box.read('userId'));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Friends'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼을 없앰
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Search friends',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchFriends(),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Obx(
                () => friendsController.friends.isEmpty
                    ? const Center(
                        child: Text("You can find friends"),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friendsController.friends.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(index);
                              print(friendsController.addfriend);
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(friendsController.friends[index][0]),
                                  Text(friendsController.friends[index][1]),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            Expanded(
              flex: 5,
              child: Obx(
                () => friendsController.allfriendsdata.isEmpty
                    ? const Center(
                        child: Text('No friends'),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10),
                        itemCount: friendsController.allfriendsdata.length,
                        itemBuilder: (context, index) {
                          final friend = friendsController.allfriendsdata[index];
                          return Card(
                            color: index%2==1?const Color.fromARGB(255, 223, 240, 255):const Color.fromARGB(255, 255, 226, 244),
                            child: PopupMenuButton<String>(
                              onSelected: (String choice) async {
                                if (choice == '1:1 대화하기') {
                                  String friendId = friend[1]; // 친구 ID
                                  String friendName = friend[2]; // 친구 닉네임
                                  String userNickname =
                                      loginHandler.box.read('nickname') ??
                                          'Anonymous'; // 사용자의 닉네임
                                  // 채팅방 생성 또는 기존 채팅방 가져오기
                                  String roomId =
                                      await friendsController.createOrGetChatRoom(
                                          friendId,
                                          friendName,
                                          false, // isDefaultRoom
                                          userNickname);
                                  // 채팅방 화면으로 이동
                                  Get.to(() => Chatroom(
                                        roomId: roomId,
                                        roomName: friendName,
                                        isDefaultRoom: false,
                                      ));
                                } else if (choice == '친구 삭제') {
                                  // 친구 삭제 확인 다이얼로그 표시
                                  bool confirmDelete = await Get.dialog<bool>(
                                        AlertDialog(
                                          title: const Text('친구 삭제'),
                                          content: Text(
                                              '정말로 ${friend[1]}님을 친구 목록에서 삭제하시겠습니까?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('취소'),
                                              onPressed: () =>
                                                  Get.back(result: false),
                                            ),
                                            TextButton(
                                              child: const Text('삭제'),
                                              onPressed: () =>
                                                  Get.back(result: true),
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                  if (confirmDelete) {
                                    // 친구 삭제 API 호출
                                    await friendsController.deletefriendsJSONData(
                                        loginHandler.box.read('userId'),
                                        friend[1]);
                                    // 친구 목록 새로고침
                                    await friendsController.selectfriendsJSONData(
                                        loginHandler.box.read('userId'));
                                    Get.snackbar(
                                        '알림', '${friend[1]}님이 친구 목록에서 삭제되었습니다.');
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: '1:1 대화하기',
                                  child: Text('1:1 대화하기'),
                                ),
                                const PopupMenuItem<String>(
                                  value: '친구 삭제',
                                  child: Text('친구 삭제'),
                                ),
                              ],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(friend[1].toString()), // 친구 닉네임
                                  Text(friend[2].toString()), // 친구 ID
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Functions ---
  searchFriends() {
    if (textEditingController.text.trim().isEmpty) {
      friendsController.friends.clear(); // 검색어가 비어있으면 리스트를 비움
    } else {
      friendsController.searchFriendsJSON(textEditingController.text);
    }
  }

  showDialog(int index) {
    Get.defaultDialog(
      backgroundColor: Color.fromARGB(255, 223, 240, 255),
      title: "친구추가 요청",
      middleText: "새로운 친구로 추가 합니다.",
      barrierDismissible: false,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text('Cencel'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white
                ),
                onPressed: () {
                  addfriend(index);
                  Get.back();
                },
                child: const Text('add'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  addfriend(int index) async {
    var addfriends = Addfriends(
      user_id: loginHandler.box.read('userId'),
      accept: 'false',
      date: DateTime.now().toString(),
      add_id: friendsController.friends[index][0],
    );
    var result = await friendsController.addfriendsJSONData(addfriends);
    return result;
  }
}// END
