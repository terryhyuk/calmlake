import 'package:camlake_test_app/view/musiclist.dart';
import 'package:camlake_test_app/vm/friends_controller.dart';
import 'package:camlake_test_app/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vm/login_handler.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final vmHandler = Get.put(VmHandler());
  final friendsController = Get.put(FriendsController());
  final loginHandler = Get.put(LoginHandler());
  final value = Get.arguments ?? '__';

  @override
  Widget build(BuildContext context) {
    print(loginHandler.box.read('userId'));
    print(loginHandler.box.read('nickname'));
    final color = Theme.of(context).primaryColor;
    vmHandler.checkaudioPlayer(vmHandler.firebaseMusic);
    vmHandler.stateCheck();
    vmHandler.addlistMusic();
    friendsController.requstfriendsJSONData(loginHandler.box.read('userId'));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            logOut(loginHandler.box.read('userId'));
            Get.back();
          },
          icon: Icon(Icons.logout_outlined)
          ),
        title: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CalmLake',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // 친구 추가 버튼
                IconButton(
                  onPressed: () {
                    print(friendsController.addfriend);
                  print(vmHandler.musicList[0][0]);
                  }, 
                  icon: Icon(Icons.person_add_alt)
                  )
              ],
            ),
          ],
        ),
      ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
            ),
            GetBuilder<VmHandler>(
              builder: (controller) {
                return Center(
                  child: Column(children: <Widget>[
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Text(
                                '${vmHandler.firendList} Request',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                                ),
                            ),
                          ],
                          
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                          child: Divider(
                            thickness: 1.5,
                            color: Color.fromARGB(255, 201, 201, 201),
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 50,
                          child: Expanded(
                            child: Row(
                              children: [
                                Obx(
                                ()=> friendsController.addfriend.isEmpty
                                ? const Center(
                                  child: Text('data'),
                                )
                                : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: friendsController.addfriend.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 100,
                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            friendsController.addfriend[index][0]
                                          )
                                        ],
                                      ),
                                    );
                                  },)
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
                          child: Divider(
                            thickness: 1.5,
                            color: Color.fromARGB(255, 201, 201, 201),
                          ),
                        ),
                        // 음악 이미지
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(vmHandler.selectImage),
                          radius: 130,
                        )
                      ],
                    ),
                    // 음악 이름 출력
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        vmHandler.selectMusic,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Slider
                    Slider(
                      thumbColor: Colors.lightBlue,
                      activeColor: Colors.lightBlue,
                      onChanged: (value) {
                        final duration = vmHandler.duration;
                        if (duration == null) {
                          return;
                        }
                        final position = value * duration.inMilliseconds;
                        vmHandler.player
                            .seek(Duration(milliseconds: position.round()));
                      },
                      value: (vmHandler.position != null &&
                              vmHandler.duration != null &&
                              vmHandler.position!.inMilliseconds > 0 &&
                              vmHandler.position!.inMilliseconds <
                                  vmHandler.duration!.inMilliseconds)
                          ? vmHandler.position!.inMilliseconds /
                              vmHandler.duration!.inMilliseconds
                          : 0.0,
                    ),
                    Text(
                      vmHandler.position != null
                          ? '${vmHandler.positionText} / ${vmHandler.durationText}'
                          : vmHandler.duration != null
                              ? vmHandler.durationText
                              : '',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    // 음악 변경 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              Get.to(() => Musiclist())!.then(
                                (value) => reloadData(vmHandler),
                              );
                            },
                            icon: const Icon(
                              Icons.menu,
                              size: 40,
                              ))
                      ],
                    ),
                    // 음악 버튼
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: const Key('skip_previous'),
                          onPressed: vmHandler.isPlaying ? null : vmHandler.play,
                          iconSize: 50.0,
                          icon: const Icon(
                            Icons.skip_previous_outlined,
                            color: Colors.black,
                          ),
                          color: color,
                        ),
                        // vmHandler.musicState == 0 ?
                        IconButton(
                          key: const Key('play_button'),
                          onPressed: vmHandler.isPlaying ? null : vmHandler.play,
                          iconSize: 70,
                          icon: const Icon(
                            Icons.play_circle,
                            color: Colors.black,
                          ),
                          color: color,
                        ),
                        IconButton(
                          key: const Key('pause_button'),
                          onPressed: vmHandler.isPlaying ? vmHandler.pause : null,
                          iconSize: 70.0,
                          icon: const Icon(Icons.pause),
                          color: Colors.black,
                        ),
                        IconButton(
                          key: const Key('skip_next'),
                          onPressed: vmHandler.isPlaying ? null : vmHandler.play,
                          iconSize: 50.0,
                          icon: const Icon(
                            Icons.skip_next_outlined,
                            color: Colors.black,
                          ),
                          color: color,
                        ),
            
                        // 멈춤 버튼
                        // IconButton(
                        //   key: const Key('stop_button'),
                        //   onPressed: vmHandler.isPlaying || vmHandler.isPaused ? vmHandler.stop : null,
                        //   iconSize: 48.0,
                        //   icon: const Icon(Icons.stop),
                        //   color: color,
                        // ),
                      ],
                    ),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  logOut(String id)async{
    var result = await loginHandler.logoutJSONData(id);
    if (result == 'OK') {
      Get.back();
    } else {
      errorSnackBar();
      print('Error');
    }
  }
  errorSnackBar() {
    Get.snackbar('Error', '다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
  }  

    reloadData(VmHandler vmHandler) {
    vmHandler.checkaudioPlayer(vmHandler.firebaseMusic);
    vmHandler.stateCheck();
  }


}