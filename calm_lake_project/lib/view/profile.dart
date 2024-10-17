import 'package:calm_lake_project/model/activity.dart';
import 'package:calm_lake_project/view/favorite_list.dart';
import 'package:calm_lake_project/view/insert.dart';
import 'package:calm_lake_project/view/login/login.dart';
import 'package:calm_lake_project/view/login/profile_edit.dart';
import 'package:calm_lake_project/view/my_post.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Profile extends StatelessWidget {
  final GetStorage box = GetStorage();
  final loginHandler = Get.put(LoginHandler());
  Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    String userId = box.read('userId');
    vmHandler.getUserPostJSONData(userId);
    vmHandler.getUserJSONData(userId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 15, top: 10),
          child: Text('Profile',
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w500, letterSpacing: 1)),
        ),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼을 없앰
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: const Color.fromARGB(255, 104, 136, 190),
        onPressed: () => Get.to(() => Insert())!
            .then((value) => vmHandler.getUserPostJSONData(userId)),
        label: const Text(
          'Post',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Obx(() {
        var user = vmHandler.user.isNotEmpty ? vmHandler.user[0] : null;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 210,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 204, 219, 238),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: user != null &&
                                    user['user_image'] != null
                                ? NetworkImage(
                                    'http://127.0.0.1:8000/login/view/${user['user_image']}')
                                : null,
                          ),
                        ),
                        Text(
                          user != null ? user['nickname'] : 'Loading...',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Text(
                                '${vmHandler.userposts.length}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              const Text('Posts'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Get.to(FavoriteList()),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: const Size(110, 50)),
                          child: const Text(
                            'Favorite',
                            style: TextStyle(
                                color: Color.fromARGB(255, 49, 88, 154),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(ProfileEdit())!.then(
                                (value) => vmHandler.getUserJSONData(userId));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 220, 235, 202),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: const Size(130, 50)),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                                color: Color.fromARGB(255, 49, 88, 154),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            logOut(loginHandler.box.read('userId'), vmHandler);
                            Get.offAll(Login());
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 234, 165, 165),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              fixedSize: const Size(110, 50)),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                                color: Color.fromARGB(255, 49, 88, 154),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Obx(() {
                  if (vmHandler.userposts.isEmpty) {
                    return const Center(child: Text('No posts available.'));
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: vmHandler.userposts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                              return const Center(child: Icon(Icons.error));
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

  logOut(String id, vmHandler) async {
    await activityInsert();
    var result = await loginHandler.logoutJSONData(id);
    await vmHandler.reset();
    if (result == 'OK') {
      Get.back();
    } else {
      errorSnackBar();
    }
  }

  errorSnackBar() {
    Get.snackbar('Error', '다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
  }

  activityInsert() async {
    var activity = Activity(
        userId: loginHandler.box.read('userId'),
        activity: 'logout',
        datetime: DateTime.now().toString());
    await loginHandler.useractivityJSONData(activity);
    await loginHandler.disposeSave();
  }
}
