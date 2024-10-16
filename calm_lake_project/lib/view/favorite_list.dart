import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class FavoriteList extends StatelessWidget {
  final GetStorage box = GetStorage();
  FavoriteList({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    String userId = box.read('userId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite',
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.w500, letterSpacing: 1)),
        centerTitle: false,
      ),
      body: GetBuilder<VmHandler>(
        builder: (controller) {
          return FutureBuilder(
            future: controller.getFavoriteJSONData(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error : ${snapshot.error}'),
                );
              } else if (controller.favoritePost.isNotEmpty) {
                return Obx(
                  () {
                    return ListView.builder(
                      itemCount: vmHandler.favoritePost.length,
                      itemBuilder: (context, index) {
                        final userpost = vmHandler.favoritePost[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: userpost != null &&
                                            userpost[16] != null
                                        ? NetworkImage(
                                            'http://127.0.0.1:8000/login/view/${userpost[16]}')
                                        : null,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    userpost[6],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              child: Image.network(
                                'http://127.0.0.1:8000/query/view/${userpost[3]}',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 300,
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
                                    await vmHandler.getFavoriteJSONData(userId);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 10),
                                    child: userpost[10] == '1'
                                        ? const Icon(Icons.favorite)
                                        : const Icon(Icons.favorite_border),
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
                                    await vmHandler.getFavoriteJSONData(userId);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: userpost[14] == '1'
                                        ? const Icon(Icons.thumb_down)
                                        : const Icon(
                                            Icons.thumb_down_alt_outlined),
                                  ),
                                ),
                                // 코멘트 아이콘
                                GestureDetector(
                                  onTap: () async {
                                    await controller
                                        .getCommentReply(userpost[0]);
                                    await showModalBottomSheet(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      isScrollControlled:
                                          true, // 키보드가 나타날 때 modal 크기를 조정
                                      builder: (context) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: SizedBox(
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
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 15, bottom: 10),
                                                  child: Text(
                                                    'Commnets',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                const Divider(),
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
                                                                  child:
                                                                      const Align(
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
                                                                  const NeverScrollableScrollPhysics(), // 부모 스크롤만 사용
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
                                                                        if (comment[6] ==
                                                                            userId) {
                                                                          _showDefaultDialog(
                                                                              context,
                                                                              index,
                                                                              vmHandler,
                                                                              userId,
                                                                              userpost,
                                                                              comment,
                                                                              isComment: T);
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
                                                                            CircleAvatar(
                                                                          backgroundImage:
                                                                              NetworkImage('http://127.0.0.1:8000/login/view/${comment[5]}'),
                                                                        ),
                                                                        title:
                                                                            Row(
                                                                          children: [
                                                                            Text(
                                                                              comment[1],
                                                                              style: const TextStyle(fontSize: 14),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              comment[4],
                                                                              style: const TextStyle(fontSize: 13),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        subtitle:
                                                                            Text(
                                                                          comment[
                                                                              3],
                                                                          style: const TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.black),
                                                                        ),
                                                                        trailing: TextButton(
                                                                            onPressed: () {
                                                                              controller.commentIndex = index;
                                                                              controller.replyTextController.text = '';
                                                                              showBottomeSheet(context, index, vmHandler, userpost, comment, userId);
                                                                            },
                                                                            child: const Text('reply')),
                                                                      ),
                                                                    ),
                                                                    // Replies List
                                                                    if (comment[
                                                                            7]
                                                                        .isNotEmpty) ...[
                                                                      for (var reply
                                                                          in comment[
                                                                              7]) ...[
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 40.0),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Expanded(
                                                                                  child: GestureDetector(
                                                                                onLongPress: () {
                                                                                  if (reply[7] == userId) {
                                                                                    _showDefaultDialog(context, index, vmHandler, userId, userpost, reply, isComment: F);
                                                                                  } else {
                                                                                    Get.snackbar(
                                                                                      '권한 없음',
                                                                                      '댓글 작성자만 삭제할 수 있습니다.',
                                                                                      snackPosition: SnackPosition.BOTTOM,
                                                                                      backgroundColor: Colors.red,
                                                                                      colorText: Colors.white,
                                                                                    );
                                                                                  }
                                                                                },
                                                                                child: ListTile(
                                                                                  leading: CircleAvatar(
                                                                                    backgroundImage: NetworkImage('http://127.0.0.1:8000/login/view/${reply[6]}'),
                                                                                    radius: 18,
                                                                                  ),
                                                                                  title: Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        reply[2],
                                                                                        style: const TextStyle(
                                                                                          fontSize: 14,
                                                                                        ), // reply nickname
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        width: 10,
                                                                                      ),
                                                                                      Text(
                                                                                        reply[5],
                                                                                        style: const TextStyle(
                                                                                          fontSize: 12,
                                                                                        ), // reply nickname
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  subtitle: Text(
                                                                                    reply[4], // reply text
                                                                                    style: const TextStyle(fontSize: 16, color: Colors.black),
                                                                                  ),
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
                                                const SizedBox(height: 10),
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
                                                              const InputDecoration(
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
                                                              .getFavoriteJSONData(
                                                                  userId);
                                                          await vmHandler
                                                              .getCommentReply(
                                                                  userpost[0]);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary),
                                                        child: Icon(
                                                          Icons.arrow_upward,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                        ),
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
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 10, top: 10),
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
                                  ExpandableText(
                                    '${userpost[4]}',
                                    prefixText: '${userpost[6]}',
                                    prefixStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    expandText: '더보기',
                                    collapseText: '접기',
                                    maxLines: 3,
                                    expandOnTextTap: true,
                                    collapseOnTextTap: true,
                                    linkColor: Colors.grey,
                                  ),
                                  Text(
                                      DateFormat("MMMM d")
                                          .format(DateTime.parse(userpost[2])),
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(child: Text('No favorite posts yet.'));
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
              padding: const EdgeInsets.all(8),
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
                          const Text(
                            'Reply',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                            child: Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: vmHandler.replyTextController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        enabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide()),
                      ),
                    ),
                    const SizedBox(
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

  _showDefaultDialog(context, index, controller, userId, userpost, comment,
      {bool isComment = false}) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                const Align(alignment: Alignment.center, child: Text('Delete')),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300), // 최대 너비 설정
              child: isComment
                  ? const Text(
                      'Do you want to delete\nthe comment?',
                      textAlign: TextAlign.center,
                    )
                  : const Text(
                      'Do you want to delete\nthe reply?',
                      textAlign: TextAlign.center,
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
                      child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      if (isComment) {
                        // comment 삭제
                        var result = await controller.deleteComment(
                            comment[6], comment[0]);
                        if (result == 'OK') {
                          await controller.getCommentReply(userpost[0]);
                          await controller.getFavoriteJSONData(userId);
                          Get.back();
                        } else {
                          Get.snackbar('Error', 'error');
                        }
                      } else {
                        // reply 삭제
                        var result = await controller.deleteReply(
                            comment[7], comment[0]);
                        if (result == 'OK') {
                          await controller.getCommentReply(userpost[0]);
                          await controller.getFavoriteJSONData(userId);
                          Get.back();
                        } else {
                          Get.snackbar('Error', 'error');
                        }
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
