import 'package:calm_lake_project/view/insert.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Post extends StatelessWidget {
  final GetStorage box = GetStorage();

  Post({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    String userId = box.read('userId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posting'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼을 없앰
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => Insert())!
            .then((value) => vmHandler.getJSONData(userId)),
      ),
      body: GetBuilder<VmHandler>(
        builder: (controller) {
          return FutureBuilder(
            future: controller.getJSONData(userId),
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
                      itemCount: vmHandler.posts.length,
                      itemBuilder: (context, index) {
                        final post = vmHandler.posts[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [CircleAvatar(), Text(post[1])],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              child: Container(
                                child: Image.network(
                                  'http://127.0.0.1:8000/query/view/${post[3]}',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 300,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                // 좋아요 아이콘
                                GestureDetector(
                                  onTap: () async {
                                    bool check = await vmHandler.checkFavorite(
                                            post[8] ?? 'null', post[9] ?? 0) ==
                                        post[7];
                                    print(await vmHandler.checkFavorite(
                                        post[8] ?? 'null', post[9] ?? 0));
                                    int newFavoriteValue =
                                        post[10] == '1' ? 0 : 1;
                                    // favorite 테이블이 있고 hate 테이블이 있는경우
                                    // favorite 1이고 hate가 0이면 updateFavorite
                                    // favorite 1이고 hate가 1이면 updatehate, updatefavorite
                                    // favorite 0이고 hate가 0이면 updateFavorite
                                    // favorite 0이고 hate가 1이면 updateFavorite
                                    // favorite 테이블이 있고 hate 테이블이 없는경우 updateFavorite
                                    if (check) {
                                      if (newFavoriteValue == 1 &&
                                          post[14] == '1') {
                                        await vmHandler.updateHate(
                                            0, post[13], userId);
                                        await vmHandler.updateFavorite(
                                            newFavoriteValue, post[9], userId);
                                      }
                                      await vmHandler.updateFavorite(
                                          newFavoriteValue, post[9], userId);
                                      // favorite 테이블이 없고 hate 테이블이 없는경우 inserFavorite 1
                                      // favorite 테이블이 없고 hate 테이블이 있는경우
                                      // hate가 1이면 insertfavorite 1, updatehate
                                      // hate가 0이면 insertfavofite 1
                                    } else {
                                      if (post[14] == '1') {
                                        await vmHandler.updateHate(
                                            0, post[13], userId);
                                        await vmHandler.insertFavorite(
                                            1, post[0], userId);
                                      } else {
                                        await vmHandler.insertFavorite(
                                            1, post[0], userId);
                                      }
                                    }
                                    await vmHandler.getJSONData(userId);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: post[10] == '1'
                                        ? Icon(Icons.favorite)
                                        : Icon(Icons.favorite_border),
                                  ),
                                ),
                                // 싫어요 아이콘
                                GestureDetector(
                                  onTap: () async {
                                    bool check = await vmHandler.checkHate(
                                            post[12] ?? 'null',
                                            post[13] ?? 0) ==
                                        post[11];
                                    int newHateValue = post[14] == '1' ? 0 : 1;
                                    if (check) {
                                      if (newHateValue == 1 &&
                                          post[10] == '1') {
                                        await vmHandler.updateFavorite(
                                            0, post[9], userId);
                                        await vmHandler.updateHate(
                                            newHateValue, post[13], userId);
                                      }
                                      await vmHandler.updateHate(
                                          newHateValue, post[13], userId);
                                    } else {
                                      if (post[10] == '1') {
                                        await vmHandler.updateFavorite(
                                            0, post[9], userId);
                                        await vmHandler.insertHate(
                                            1, post[0], userId);
                                      } else {
                                        await vmHandler.insertHate(
                                            1, post[0], userId);
                                      }
                                    }
                                    await vmHandler.getJSONData(userId);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: post[14] == '1'
                                        ? Icon(Icons.thumb_down)
                                        : Icon(Icons.thumb_down_alt_outlined),
                                  ),
                                ),
                                // 코멘트 아이콘
                                GestureDetector(
                                  onTap: () {
                                    controller.getComment(post[0]);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled:
                                          true, // 키보드가 나타날 때 modal 크기를 조정
                                      builder: (context) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.9 -
                                                MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom *
                                                    1,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15, bottom: 10),
                                                  child: Text(
                                                    'Commnet',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Divider(),
                                                Expanded(
                                                  child: Obx(() {
                                                    return ListView.builder(
                                                      shrinkWrap: true,
                                                      //physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                                                      itemCount: controller
                                                          .comments.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Column(
                                                          children: [
                                                            GestureDetector(
                                                              onLongPress: () {
                                                                if (controller.comments[
                                                                            index]
                                                                        [1] ==
                                                                    userId) {
                                                                  _showDefaultDialog(
                                                                      context,
                                                                      index,
                                                                      vmHandler,
                                                                      userId,
                                                                      post);
                                                                } else {
                                                                  Get.snackbar(
                                                                    '권한 없음',
                                                                    '댓글 작성자만 삭제할 수 있습니다.',
                                                                    snackPosition:
                                                                        SnackPosition
                                                                            .BOTTOM,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    colorText:
                                                                        Colors
                                                                            .white,
                                                                  );
                                                                }
                                                              },
                                                              child: ListTile(
                                                                leading:
                                                                    CircleAvatar(),
                                                                title: Text(controller
                                                                    .comments[
                                                                        index]
                                                                        [1]
                                                                    .toString()),
                                                                subtitle: Text(
                                                                    controller
                                                                        .comments[
                                                                            index]
                                                                            [3]
                                                                        .toString()),
                                                                trailing: TextButton(
                                                                    onPressed:
                                                                        () {},
                                                                    child: Text(
                                                                        'reply')),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }),
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: TextField(
                                                          controller: controller
                                                              .textController,
                                                          maxLines: 1,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Enter comment',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 20),
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          if (controller
                                                              .textController
                                                              .text
                                                              .trim()
                                                              .isNotEmpty) {
                                                            await controller
                                                                .insertCommnet(
                                                                    post[0],
                                                                    controller
                                                                        .textController
                                                                        .text
                                                                        .trim(),
                                                                    userId);
                                                            await controller
                                                                .getComment(
                                                                    post[0]);
                                                            controller
                                                                .textController
                                                                .text = '';
                                                          }
                                                          await vmHandler
                                                              .getJSONData(
                                                                  userId);
                                                        },
                                                        child: Icon(
                                                            Icons.arrow_upward),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  height: 40,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: Icon(Icons.chat_bubble_outline),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  child:
                                      Text(post[15] == 0 ? "" : "${post[15]}"),
                                )
                              ],
                            ),
                            // posting 내용
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${post[6]}\t${post[4]}'),
                                  Text(
                                      '${DateFormat("MMMM d").format(DateTime.parse(post[2]))}',
                                      style: TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
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
    );
  }

  _showDefaultDialog(context, index, vmHandler, userId, post) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                Align(alignment: Alignment.center, child: const Text('Delete')),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300), // 최대 너비 설정
              child: Text(
                'Do you want to delete\nthe comment?',
                textAlign: TextAlign.center, // 텍스트 중앙 정렬
              ),
            ),
            actions: [
              // 액션으로 버튼 추가
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      var result =
                          await vmHandler.deleteCommentJSONData(userId);
                      if (result == 'OK') {
                        Get.back();
                        await vmHandler.getComment(post[0]);
                        await vmHandler.getJSONData(userId);
                      } else {
                        Get.snackbar('Error', 'error');
                      }
                    }, // alert 없애기
                    child: Text(
                      'OK',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ],
              ))
            ],
          );
        });
  }
}
