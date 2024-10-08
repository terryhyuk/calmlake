import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view/chat.dart';
import 'view/friends.dart';
import 'view/home.dart';
import 'view/post.dart';
import 'view/profile.dart';
import 'vm/NavigationController.dart';

class HomeScreen extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller.tabController,
        children: [Home(), const Friends(), const Chat(), const Post(), const Profile()],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,

            //showSelectedLabels: F,
            //showUnselectedLabels: F,
            iconSize: 25,
            selectedFontSize: 14,
            selectedItemColor: const Color.fromARGB(255, 58, 186, 159),
            currentIndex: controller.currentIndex.value,
            onTap: (index) {
              controller.tabController.index = index;
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people), label: 'Friends'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.format_list_bulleted), label: 'Posting'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          )),
    );
  }
}
