import 'package:calm_lake_project/model/addfriends.dart';
import 'package:calm_lake_project/vm/friends_controller.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Friends extends StatelessWidget {
  Friends({super.key});

  final FriendsController friendsController = Get.put(FriendsController());
  final TextEditingController textEditingController = TextEditingController();
  final LoginHandler loginHandler = Get.put(LoginHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Column(
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
                      child: Text("You can faind friends"),
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
                            margin: EdgeInsets.symmetric(horizontal: 8),
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
                        return Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(friendsController.allfriendsdata[index][0]),
                              Text(friendsController.allfriendsdata[index][1]),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Functions ---
  searchFriends() {
    if (textEditingController.text.trim().isEmpty) {
      friendsController.friends.clear(); // 검색어가 비어있으면 리스트를 비웁니다.
    } else {
      friendsController.searchFriendsJSON(textEditingController.text);
    }
  }

  showDialog(int index) {
    Get.defaultDialog(
      title: "친구추가 요청",
      middleText: "새로운 친구로 추가 합니다.",
      barrierDismissible: false,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Cencel'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  addfriend(index);
                  print(friendsController.addfriend);
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
    if (result == 'OK') {
      print('친구요청성공');
      Get.back();
    } else {
      print('Error');
    }
  }
}// END
