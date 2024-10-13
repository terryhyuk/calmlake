import 'package:calm_lake_project/view/edit_post.dart';
import 'package:calm_lake_project/view/insert.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class MyPost extends StatelessWidget {
  final GetStorage box = GetStorage();
  MyPost({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    String userId = box.read('userId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => Insert())!
            .then((value) => vmHandler.getUserPostJSONData(userId)),
      ),
      body: GetBuilder<VmHandler>(
        builder: (controller) {
          return FutureBuilder(
            future: controller.getUserPostJSONData(userId),
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
                      itemCount: vmHandler.userposts.length,
                      itemBuilder: (context, index) {
                        final userpost = vmHandler.userposts[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(),
                                Text(userpost[1]),
                                Spacer(),
                                PopupMenuButton(
                                  onSelected: (value) {
                                    if (value == 'Edit') {
                                      Get.to(EditPost(), arguments: userpost);
                                    } else {
                                      Get.defaultDialog(
                                          title: 'Delete',
                                          titleStyle: TextStyle(fontSize: 20),
                                          content: Text(
                                              'Do you want to delete the post?'),
                                          onConfirm: () async {
                                            /* var result = await vmHandler.deletePost(seq, filename)
                                            if (result == 'OK') {
                                              Get.back();
                                              await vmHandler
                                                  .getComment(userpost[0]);
                                            } else {
                                              Get.snackbar('Error', 'error');
                                            }*/
                                          },
                                          buttonColor: Colors.grey,
                                          contentPadding: EdgeInsets.all(10));
                                    }
                                  },
                                  itemBuilder: (BuildContext bc) {
                                    return const [
                                      PopupMenuItem(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Edit"),
                                            Icon(Icons.edit)
                                          ],
                                        ),
                                        value: 'Edit',
                                      ),
                                      PopupMenuItem(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Delete"),
                                            Icon(Icons.delete)
                                          ],
                                        ),
                                        value: 'Delete',
                                      ),
                                    ];
                                  },
                                )
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              child: Container(
                                child: Image.network(
                                  'http://127.0.0.1:8000/query/view/${userpost[3]}',
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
                                            userpost[8] ?? 'null',
                                            userpost[9] ?? 0) ==
                                        userpost[7];
                                    print(await vmHandler.checkFavorite(
                                        userpost[8] ?? 'null',
                                        userpost[9] ?? 0));
                                    int newFavoriteValue =
                                        userpost[10] == '1' ? 0 : 1;
                                    // favorite 테이블이 있고 hate 테이블이 있는경우
                                    // favorite 1이고 hate가 0이면 updateFavorite
                                    // favorite 1이고 hate가 1이면 updatehate, updatefavorite
                                    // favorite 0이고 hate가 0이면 updateFavorite
                                    // favorite 0이고 hate가 1이면 updateFavorite
                                    // favorite 테이블이 있고 hate 테이블이 없는경우 updateFavorite
                                    if (check) {
                                      if (newFavoriteValue == 1 &&
                                          userpost[14] == '1') {
                                        await vmHandler.updateHate(
                                            0, userpost[13], userId);
                                        await vmHandler.updateFavorite(
                                            newFavoriteValue,
                                            userpost[9],
                                            userId);
                                      }
                                      await vmHandler.updateFavorite(
                                          newFavoriteValue,
                                          userpost[9],
                                          userId);
                                      // favorite 테이블이 없고 hate 테이블이 없는경우 inserFavorite 1
                                      // favorite 테이블이 없고 hate 테이블이 있는경우
                                      // hate가 1이면 insertfavorite 1, updatehate
                                      // hate가 0이면 insertfavofite 1
                                    } else {
                                      if (userpost[14] == '1') {
                                        await vmHandler.updateHate(
                                            0, userpost[13], userId);
                                        await vmHandler.insertFavorite(
                                            1, userpost[0], userId);
                                      } else {
                                        await vmHandler.insertFavorite(
                                            1, userpost[0], userId);
                                      }
                                    }
                                    await vmHandler.getUserPostJSONData(userId);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 10),
                                    child: userpost[10] == '1'
                                        ? Icon(Icons.favorite)
                                        : Icon(Icons.favorite_border),
                                  ),
                                ),
                                // 싫어요 아이콘
                                GestureDetector(
                                  onTap: () async {
                                    bool check = await vmHandler.checkHate(
                                            userpost[12] ?? 'null',
                                            userpost[13] ?? 0) ==
                                        userpost[11];
                                    int newHateValue =
                                        userpost[14] == '1' ? 0 : 1;
                                    if (check) {
                                      if (newHateValue == 1 &&
                                          userpost[10] == '1') {
                                        await vmHandler.updateFavorite(
                                            0, userpost[9], userId);
                                        await vmHandler.updateHate(
                                            newHateValue, userpost[13], userId);
                                      }
                                      await vmHandler.updateHate(
                                          newHateValue, userpost[13], userId);
                                    } else {
                                      if (userpost[10] == '1') {
                                        await vmHandler.updateFavorite(
                                            0, userpost[9], userId);
                                        await vmHandler.insertHate(
                                            1, userpost[0], userId);
                                      } else {
                                        await vmHandler.insertHate(
                                            1, userpost[0], userId);
                                      }
                                    }
                                    await vmHandler.getUserPostJSONData(userId);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: userpost[14] == '1'
                                        ? Icon(Icons.thumb_down)
                                        : Icon(Icons.thumb_down_alt_outlined),
                                  ),
                                ),
                                // 코멘트 아이콘
                                GestureDetector(
                                  onTap: () async {
                                    await controller
                                        .getCommentReply(userpost[0]);
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
                                                    'Commnets',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Divider(),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        GetBuilder<VmHandler>(
                                                          builder:
                                                              (controller) {
                                                            if (controller
                                                                .commentreply
                                                                .isEmpty) {
                                                              return Center(
                                                                child: SizedBox(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.7,
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      'No comments yet',
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }

                                                            return ListView
                                                                .builder(
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(), // 부모 스크롤만 사용
                                                              itemCount: controller
                                                                  .commentreply
                                                                  .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                var comment =
                                                                    controller
                                                                            .commentreply[
                                                                        index];
                                                                return Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onLongPress:
                                                                          () {
                                                                        if (comment[1] ==
                                                                            userId) {
                                                                          _showDefaultDialog(
                                                                              context,
                                                                              index,
                                                                              vmHandler,
                                                                              userId,
                                                                              userpost,
                                                                              comment);
                                                                        } else {
                                                                          Get.snackbar(
                                                                            '권한 없음',
                                                                            '댓글 작성자만 삭제할 수 있습니다.',
                                                                            snackPosition:
                                                                                SnackPosition.BOTTOM,
                                                                            backgroundColor:
                                                                                Colors.red,
                                                                            colorText:
                                                                                Colors.white,
                                                                          );
                                                                        }
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        leading:
                                                                            CircleAvatar(),
                                                                        title: Text(
                                                                            comment[1]),
                                                                        subtitle:
                                                                            Text(comment[3]),
                                                                        trailing: TextButton(
                                                                            onPressed: () {
                                                                              controller.commentIndex = index;
                                                                              controller.replyTextController.text = '';
                                                                              showBottomeSheet(context, index, vmHandler, userpost, comment, userId);
                                                                            },
                                                                            child: Text('reply')),
                                                                      ),
                                                                    ),
                                                                    // Replies List
                                                                    if (comment[
                                                                            4]
                                                                        .isNotEmpty) ...[
                                                                      for (var reply
                                                                          in comment[
                                                                              4]) ...[
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 40.0),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Expanded(
                                                                                  child: ListTile(
                                                                                leading: CircleAvatar(
                                                                                  radius: 18,
                                                                                ),
                                                                                title: Text(reply[2]),
                                                                                subtitle: Text(
                                                                                  reply[4], // Reply text
                                                                                  style: TextStyle(color: Colors.grey[700]),
                                                                                ),
                                                                              )),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ], // for
                                                                    ], // if
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
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
                                                                    userpost[0],
                                                                    controller
                                                                        .textController
                                                                        .text
                                                                        .trim(),
                                                                    userId);
                                                            //await controller.getComment(userpost[0]);
                                                            controller
                                                                .textController
                                                                .text = '';
                                                          }
                                                          await vmHandler
                                                              .getUserPostJSONData(
                                                                  userId);
                                                          await vmHandler
                                                              .getCommentReply(
                                                                  userpost[0]);
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
                                  child: Text(userpost[15] == 0
                                      ? ""
                                      : "${userpost[15]}"),
                                )
                              ],
                            ),
                            // posting 내용
                            Padding(
                              padding: const EdgeInsets.only(top: 5, left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${userpost[6]}\t${userpost[4]}'),
                                  Text(
                                      '${DateFormat("MMMM d").format(DateTime.parse(userpost[2]))}',
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

  showBottomeSheet(context, index, vmHandler, userpost, comment, userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Wrap(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reply',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (vmHandler.replyTextController.text
                                  .trim()
                                  .isNotEmpty) {
                                await vmHandler.insertReply(
                                    userpost[0],
                                    userId,
                                    comment[0],
                                    vmHandler.replyTextController.text.trim());
                                vmHandler.replyTextController.text = '';
                                //await controller.getComment(post[0]);
                                await vmHandler.getCommentReply(userpost[0]);
                                Get.back();
                              }
                            },
                            child: Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                          )
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: vmHandler.replyTextController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        enabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide()),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  _showDefaultDialog(
      context, index, vmHandler, userId, userpost, comment) async {
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
                      /*var result = await vmHandler.deleteCommentJSONData(
                          userId,
                          comment[0],
                          comment[4].length == 0 ? -1 : comment[4][0][3]);
                      if (result == 'OK') {
                        Get.back();
                        await vmHandler.getCommentReply(userpost[0]);
                        await vmHandler.getJSONData(userId);
                      } else {
                        Get.snackbar('Error', 'error');
                      }*/
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
