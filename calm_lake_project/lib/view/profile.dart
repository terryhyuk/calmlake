import 'package:calm_lake_project/view/login/profile_edit.dart';
import 'package:calm_lake_project/view/my_post.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Profile extends StatelessWidget {
  final GetStorage box = GetStorage();

  Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    String userId = box.read('userId');
    vmHandler.getUserPostJSONData(userId);
    vmHandler.getUserJSONData(userId);

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 15, top: 10),
          child: Text('Profile',
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w500, letterSpacing: 1)),
        ),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼을 없앰
        centerTitle: false,
      ),
      body: Obx(() {
        var user = vmHandler.user.isNotEmpty ? vmHandler.user[0] : null;
        print(user);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      offset: Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                      color: const Color.fromARGB(255, 204, 204, 204)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: CircleAvatar(
                            radius: 40,
                          ),
                        ),
                        Text(
                          user != null ? user['nickname'] : 'Loading...',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Text(
                                '${vmHandler.userposts.length}',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text('Posts'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.white),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Favorite'),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: Size(110, 50)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(ProfileEdit());
                          },
                          child: Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: Size(130, 50)),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Logout'),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: Size(110, 50)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Obx(() {
                  if (vmHandler.userposts.isEmpty) {
                    return Center(child: Text('No posts available.'));
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: vmHandler.userposts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1 / 1,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final post = vmHandler.userposts[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => MyPost())!.then((value) =>
                                vmHandler.getUserPostJSONData(userId));
                          },
                          child: Image.network(
                            'http://127.0.0.1:8000/query/view/${post[3]}',
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(child: Icon(Icons.error));
                            },
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
