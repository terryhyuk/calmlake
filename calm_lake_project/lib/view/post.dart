import 'package:calm_lake_project/view/search.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class Post extends StatelessWidget {
  final GetStorage box = GetStorage();
  Post({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    String userId = box.read('userId');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Posting',
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.w500, letterSpacing: 1)),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼을 없앰
        centerTitle: false,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                  onPressed: () {
                    Get.to(Search());
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 25,
                  )))
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Align(
                alignment: Alignment.topRight,
                child: DropdownButton<String>(
                  // 최신순, 인기순 drop down button
                  value: vmHandler.selectedValue.value,
                  items: vmHandler.dropdownItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    vmHandler.updateSelectedValue(newValue!, userId);
                  },
                ),
              ),
            );
          }),
          Expanded(
            child: GetBuilder<VmHandler>(
              builder: (controller) {
                return FutureBuilder(
                  future: vmHandler.selectedValue == '최신순'
                      ? controller.getJSONData(userId)
                      : controller.getTopJSONData(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      //print(snapshot.error);
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 8),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: post != null &&
                                                  post[16] != null
                                              ? NetworkImage(
                                                  'http://127.0.0.1:8000/login/view/${post[16]}')
                                              : null,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          post[6],
                                          style: const TextStyle(fontSize: 15),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 300,
                                    child: Container(
                                      child: Image.network(
                                        // 포스팅 사진
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
                                          // 좋아요 아이콘 눌렀을때 실행
                                          favoriteAction(vmHandler, post,
                                              userId, controller);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 10),
                                          child: post[10] == '1'
                                              ? const Icon(Icons.favorite)
                                              : const Icon(
                                                  Icons.favorite_border),
                                        ),
                                      ),
                                      // 싫어요 아이콘
                                      GestureDetector(
                                        onTap: () async {
                                          // 싫어요 아이콘 눌렀을때 실행
                                          hateAction(vmHandler, post, userId,
                                              controller);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: post[14] == '1'
                                              ? const Icon(Icons.thumb_down)
                                              : const Icon(Icons
                                                  .thumb_down_alt_outlined),
                                        ),
                                      ),
                                      // 코멘트 아이콘
                                      GestureDetector(
                                        onTap: () async {
                                          // 데이터 베이스에서 코멘트값 가져옴
                                          await controller
                                              .getCommentReply(post[0]);
                                          // modalBottomSheet에서 댓글을 보여줌
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled:
                                                true, // 키보드가 나타날 때 modal 크기를 조정
                                            builder: (context) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 15,
                                                                bottom: 10),
                                                        child: Text(
                                                          'Commnets',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      const Divider(),
                                                      Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              GetBuilder<
                                                                  VmHandler>(
                                                                builder:
                                                                    (controller) {
                                                                  if (controller
                                                                      .commentreply
                                                                      .isEmpty) {
                                                                    return Center(
                                                                      child:
                                                                          SizedBox(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.7,
                                                                        child:
                                                                            const Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            'No comments yet',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  return ListView
                                                                      .builder(
                                                                    shrinkWrap:
                                                                        true,
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
                                                                              .commentreply[index];
                                                                      return Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          GestureDetector(
                                                                            onLongPress:
                                                                                () {
                                                                              // 댓글 길게 눌렀을때 유저 확인 후 삭제 가능
                                                                              if (comment[6] == userId) {
                                                                                _showDefaultDialog(context, index, vmHandler, userId, post, comment, isComment: T);
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
                                                                            child:
                                                                                ListTile(
                                                                              leading: CircleAvatar(
                                                                                backgroundImage: NetworkImage('http://127.0.0.1:8000/login/view/${comment[5]}'),
                                                                              ),
                                                                              title: Row(
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
                                                                              ), // nickname
                                                                              subtitle: Text(
                                                                                comment[3],
                                                                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                                                              ), // text
                                                                              trailing: TextButton(
                                                                                  onPressed: () {
                                                                                    // reply 버튼 누르면 새로운 bottomSheet가 나옴
                                                                                    controller.commentIndex = index;
                                                                                    controller.replyTextController.text = '';
                                                                                    showBottomeSheet(context, index, vmHandler, post, comment, userId);
                                                                                  },
                                                                                  child: const Text('reply')),
                                                                            ),
                                                                          ),
                                                                          // Replies List가 있는 확인 후 댓글 리스트 생성
                                                                          if (comment[7]
                                                                              .isNotEmpty) ...[
                                                                            for (var reply
                                                                                in comment[7]) ...[
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 40.0),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                        child: GestureDetector(
                                                                                      onLongPress: () {
                                                                                        if (reply[7] == userId) {
                                                                                          _showDefaultDialog(context, index, vmHandler, userId, post, reply, isComment: F);
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
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 20),
                                                              child: TextField(
                                                                controller:
                                                                    controller
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
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10,
                                                                    right: 20),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                // comment 입력 버튼 누르면 실행
                                                                commnetInsertAction(
                                                                    controller,
                                                                    post,
                                                                    userId,
                                                                    vmHandler);
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary),
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_upward,
                                                                color: Theme.of(
                                                                        context)
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
                                          padding: EdgeInsets.only(
                                              left: 10, top: 10),
                                          child:
                                              Icon(Icons.chat_bubble_outline),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, top: 10),
                                        child: Text(
                                            post[15] == 0 ? "" : "${post[15]}"),
                                      )
                                    ],
                                  ),
                                  // posting 내용
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 15, top: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ExpandableText(
                                          '${post[4]}',
                                          prefixText: '${post[6]}',
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
                                            DateFormat("MMMM d").format(
                                                DateTime.parse(post[2])),
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
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  hateAction(vmHandler, post, userId, controller) async {
    bool check = await vmHandler.checkHate(post[12] ?? 'null', post[13] ?? 0) ==
        post[11];
    int newHateValue = post[14] == '1' ? 0 : 1;
    if (check) {
      if (newHateValue == 1 && post[10] == '1') {
        await vmHandler.updateFavorite(0, post[9], userId);
        await vmHandler.updateHate(newHateValue, post[13], userId);
      }
      await vmHandler.updateHate(newHateValue, post[13], userId);
    } else {
      if (post[10] == '1') {
        await vmHandler.updateFavorite(0, post[9], userId);
        await vmHandler.insertHate(1, post[0], userId);
      } else {
        await vmHandler.insertHate(1, post[0], userId);
      }
    }
    vmHandler.selectedValue == '최신순'
        ? controller.getJSONData(userId)
        : controller.getTopJSONData(userId);
  }

  favoriteAction(vmHandler, post, userId, controller) async {
    bool check =
        await vmHandler.checkFavorite(post[8] ?? 'null', post[9] ?? 0) ==
            post[7];
    int newFavoriteValue = post[10] == '1' ? 0 : 1;
    // favorite 테이블이 있고 hate 테이블이 있는경우
    // favorite 1이고 hate가 0이면 updateFavorite
    // favorite 1이고 hate가 1이면 updatehate, updatefavorite
    // favorite 0이고 hate가 0이면 updateFavorite
    // favorite 0이고 hate가 1이면 updateFavorite
    // favorite 테이블이 있고 hate 테이블이 없는경우 updateFavorite
    if (check) {
      if (newFavoriteValue == 1 && post[14] == '1') {
        await vmHandler.updateHate(0, post[13], userId);
        await vmHandler.updateFavorite(newFavoriteValue, post[9], userId);
      }
      await vmHandler.updateFavorite(newFavoriteValue, post[9], userId);
      // favorite 테이블이 없고 hate 테이블이 없는경우 inserFavorite 1
      // favorite 테이블이 없고 hate 테이블이 있는경우
      // hate가 1이면 insertfavorite 1, updatehate
      // hate가 0이면 insertfavofite 1
    } else {
      if (post[14] == '1') {
        await vmHandler.updateHate(0, post[13], userId);
        await vmHandler.insertFavorite(1, post[0], userId);
      } else {
        await vmHandler.insertFavorite(1, post[0], userId);
      }
    }
    vmHandler.selectedValue == '최신순'
        ? controller.getJSONData(userId)
        : controller.getTopJSONData(userId);
  }

  commnetInsertAction(controller, post, userId, vmHandler) async {
    if (controller.textController.text.trim().isNotEmpty) {
      await controller.insertCommnet(
          post[0], controller.textController.text.trim(), userId);
      controller.textController.text = '';
    }
    vmHandler.selectedValue == '최신순'
        ? controller.getJSONData(userId)
        : controller.getTopJSONData(userId);
    await vmHandler.getCommentReply(post[0]);
  }

// 답글 달때 나오는 bottomSheet
  showBottomeSheet(context, index, vmHandler, post, comment, userId) {
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
                                    post[0],
                                    userId,
                                    comment[0],
                                    vmHandler.replyTextController.text.trim());
                                vmHandler.replyTextController.text = '';
                                //await controller.getComment(post[0]);
                                await vmHandler.getCommentReply(post[0]);
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

// 댓글과 답글 삭제시 나오는 dialog
  _showDefaultDialog(context, index, controller, userId, post, comment,
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
                        var result =
                            await controller.deleteComment(userId, comment[0]);
                        if (result == 'OK') {
                          await controller.getCommentReply(post[0]);
                          controller.selectedValue == '최신순'
                              ? controller.getJSONData(userId)
                              : controller.getTopJSONData(userId);
                          Get.back();
                        } else {
                          Get.snackbar('Error', 'error');
                        }
                      } else {
                        // reply 삭제
                        var result =
                            await controller.deleteReply(userId, comment[0]);
                        if (result == 'OK') {
                          await controller.getCommentReply(post[0]);
                          controller.selectedValue == '최신순'
                              ? controller.getJSONData(userId)
                              : controller.getTopJSONData(userId);
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
