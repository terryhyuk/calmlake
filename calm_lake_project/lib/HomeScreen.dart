import 'package:calm_lake_project/view/chat/chat.dart';
import 'package:calm_lake_project/view/home.dart';
import 'package:calm_lake_project/view/friends.dart';
import 'package:calm_lake_project/view/post.dart';
import 'package:calm_lake_project/view/profile.dart';
import 'package:calm_lake_project/vm/NavigationController.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/activity.dart';

class HomeScreen extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());
  final LoginHandler loginHandler=Get.put(LoginHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: controller.tabController,
        children: [Home(), Friends(), Chat(), Post(), Profile()],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,

            //showSelectedLabels: F,
            //showUnselectedLabels: F,
            iconSize: 25,
            selectedFontSize: 14,
            selectedItemColor: const Color.fromARGB(255, 101, 186, 255),
            currentIndex: controller.currentIndex.value,
            onTap: (index) {
              controller.tabController.index = index;
              activityInsert(index);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home',),
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
  activityInsert(int index)async{
    var activity=Activity(
      userId: loginHandler.box.read('userId'), 
      activity: index==0? 'home': index==1 ? 'friends' : index==2 ? 'chat' : index==3 ? 'posting' : 'my profile', 
      datetime: DateTime.now().toString());    
    await loginHandler.useractivityJSONData(activity);
  }
}
