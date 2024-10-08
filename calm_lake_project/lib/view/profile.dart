import 'package:calm_lake_project/view/ws/profile_edit.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            child: Text('data'),
          ),
          Expanded(
            child: GetBuilder<VmHandler>(
              builder: (controller) {
                return FutureBuilder(
                  future: controller.getUserPostJSONData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error : ${snapshot.error}'),
                      );
                    } else {
                      return Obx(
                        () {
                          return ListView.builder(
                            itemCount: controller.posts.length,
                            itemBuilder: (context, index) {
                              final post = vmHandler.posts[index];
                              return Card(
                                child: Row(
                                  children: [
                                    Image.network(
                                      'http://127.0.0.1:8000/query/view/${post[3]}',
                                      width: 100,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(ProfileEdit());
            }, 
            child: Text('Profile Edit'))
        ],
      ),
    );
  }
}
