import 'package:calm_lake_project/view/chat.dart';
import 'package:calm_lake_project/view/home.dart';
import 'package:calm_lake_project/view/friends.dart';
import 'package:calm_lake_project/view/post.dart';
import 'package:calm_lake_project/view/profile.dart';
import 'package:calm_lake_project/vm/NavigationController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller.tabController,
        children: const [Home(), Friends(), Chat(), Post(), Profile()],
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
