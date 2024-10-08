import 'package:calm_lake_project/model/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../vm/login_handler.dart';

class ProfileEdit extends StatelessWidget {
  ProfileEdit({super.key});
  final loginHandler = Get.put(LoginHandler());
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Edit'),
      ),
      body: GetBuilder<LoginHandler>(
        builder: (controller) {
          print(box.read('userId'));
          return FutureBuilder(
            future: controller.showProfileJSONData(box.read('userId')), 
            builder: (context, snapshot) {
              Profile result=snapshot.data;
              return Column(
                children: [
                  Text(result.id)
                ],
              );
            },
            );
        },
        ),
    );
  }
}