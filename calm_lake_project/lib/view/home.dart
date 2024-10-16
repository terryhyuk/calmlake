import 'package:calm_lake_project/view/musiclist.dart';
import 'package:calm_lake_project/vm/friends_controller.dart';
import 'package:calm_lake_project/vm/music_handler.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vm/login_handler.dart';
import '../model/activity.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final vmHandler = Get.put(VmHandler());
  final musicHandler = Get.put(MusicHandler());
  final friendsController = Get.put(FriendsController());
  final loginHandler = Get.put(LoginHandler());
  final value = Get.arguments ?? '__';

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
        musicHandler.fetchDocumentFields(musicHandler.musicSelete.toString());
    musicHandler.checkaudioPlayer(musicHandler.firebaseMusic);
    musicHandler.stateCheck();
    musicHandler.addlistMusic();
    friendsController.requstfriendsJSONData(loginHandler.box.read('userId'));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              logOut(loginHandler.box.read('userId'));
              musicHandler.isPlaying || musicHandler.isPaused ? musicHandler.stop : null;
              Get.back();
            },
            icon: const Icon(Icons.logout_outlined)),
        title: const Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CalmLake',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // // 친구 추가 버튼
                  // IconButton(
                  //     onPressed: () {
                  //       print(friendsController.addfriend);
                  //     },
                  //     icon: const Icon(Icons.person_add_alt))
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
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
            ),
            GetBuilder<MusicHandler>(
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
                                '${friendsController.addfriend.length} Request',
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
                        SizedBox(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          child: Obx(
                            () => friendsController.addfriend.isEmpty
                                ? const Center(
                                    child: Text(''),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        friendsController.addfriend.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        // width: 100,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        friendsController
                                                                .addfriend[
                                                            index][0]),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      //
                                                    },
                                                    icon: const Icon(
                                                      Icons.cancel,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      _showDialog(index);
                                                    },
                                                    icon: const Icon(
                                                        Icons.check_circle),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
                              NetworkImage(musicHandler.selectImage),
                          radius: 130,
                        ),
                                                Image.asset(
                          musicHandler.changeImageCat(),
                          width: 100,
                          height: 100,
                          )
                      ],
                    ),
                    // 음악 이름 출력
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        musicHandler.selectMusic,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Slider
                    Slider(
                      thumbColor: Colors.lightBlue,
                      activeColor: Colors.lightBlue,
                      onChanged: (value) {
                        final duration = musicHandler.duration;
                        if (duration == null) {
                          return;
                        }
                        final position = value * duration.inMilliseconds;
                        musicHandler.player
                            .seek(Duration(milliseconds: position.round()));
                      },
                      value: (musicHandler.position != null &&
                              musicHandler.duration != null &&
                              musicHandler.position!.inMilliseconds > 0 &&
                              musicHandler.position!.inMilliseconds <
                                  musicHandler.duration!.inMilliseconds)
                          ? musicHandler.position!.inMilliseconds /
                              musicHandler.duration!.inMilliseconds
                          : 0.0,
                    ),
                    Text(
                      musicHandler.position != null
                          ? '${musicHandler.positionText} / ${musicHandler.durationText}'
                          : musicHandler.duration != null
                              ? musicHandler.durationText
                              : '',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    // 음악 변경 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //사운드바
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  musicHandler.soundMute();
                                },
                                icon: musicHandler.changeIcon()),
                            Slider(
                              min: 0,
                              max: 1,
                              onChanged: (double value) {
                                musicHandler.setVolumeValue = value;
                                musicHandler
                                    .soundControll(musicHandler.setVolumeValue);
                              },
                              value: musicHandler.setVolumeValue,
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              Get.to(() => Musiclist())!.then(
                                (value) => reloadData(musicHandler),
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
                          onPressed: musicHandler.backMusicSelect,
                          iconSize: 50.0,
                          icon: const Icon(
                            Icons.skip_previous_outlined,
                            color: Colors.black,
                          ),
                          color: color,
                        ),
                        IconButton(
                          key: const Key('play_button'),
                          onPressed:
                              musicHandler.isPlaying ? null : musicHandler.play,
                          iconSize: 70,
                          icon: const Icon(
                            Icons.play_circle,
                            color: Colors.black,
                          ),
                          color: color,
                        ),
                        IconButton(
                          key: const Key('pause_button'),
                          onPressed: musicHandler.isPlaying
                              ? musicHandler.pause
                              : null,
                          iconSize: 70.0,
                          icon: const Icon(Icons.pause),
                          color: Colors.black,
                        ),
                        IconButton(
                          key: const Key('skip_next'),
                          onPressed: musicHandler.nextMusicSelect,
                          iconSize: 50.0,
                          icon: const Icon(
                            Icons.skip_next_outlined,
                            color: Colors.black,
                          ),
                          color: color,
                        ),
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

// --- Functions ---
  _showDialog(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('친구 추가'),
        content:
            Text('${friendsController.addfriend[index][0]}님을 친구로 추가하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('추가'),
            onPressed: () async {
              bool success = await friendsController
                  .acceptFriendRequest(friendsController.addfriend[index][0]);
              Get.back();
              if (success) {
                Get.snackbar('성공', '친구 추가가 완료되었습니다.',
                    snackPosition: SnackPosition.BOTTOM);
              } else {
                Get.snackbar('실패', '친구 추가에 실패했습니다. 다시 시도해주세요.',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
          ),
        ],
      ),
    );
  }

  logOut(String id) async {
    await activityInsert();
    var result = await loginHandler.logoutJSONData(id);
    await vmHandler.reset();
    if (result == 'OK') {
      Get.back();
    } else {
      errorSnackBar();
      // print('Error');
    }
  }

  errorSnackBar() {
    Get.snackbar('Error', '다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
  }

  reloadData(MusicHandler musicHandler) {
    musicHandler.checkaudioPlayer(musicHandler.firebaseMusic);
    musicHandler.stateCheck();
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
