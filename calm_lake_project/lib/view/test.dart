import 'package:calm_lake_project/model/favorite.dart';
import 'package:calm_lake_project/view/insert.dart';
import 'package:calm_lake_project/vm/commentController.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    final vmHandler = Get.put(VmHandler());
    final box = GetStorage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posting'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => Insert())!
            .then((value) => vmHandler.getPostJSONData()),
      ),
      body: GetBuilder<VmHandler>(
        builder: (controller) {
          return FutureBuilder(
            future: controller.getPostJSONData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                  child: Text('Error : ${snapshot.error}'),
                );
              } else {
                return Obx(
                  () {
                    return ListView.builder(
                      itemCount: controller.posts.length,
                      itemBuilder: (context, index) {
                        print(controller.posts[index].seq);
                        final post = controller.posts[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [CircleAvatar(), Text(post.user_id)],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              child: Container(
                                child: Image.network(
                                  'http://127.0.0.1:8000/query/view/${post.image}',
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
                                    bool check = await controller.checkFavorite(
                                            post.favorite_user_id ?? 'null',
                                            post.favorite_post_seq ?? 0) ==
                                        post.favorite_seq;
                                    print(await controller.checkFavorite(
                                        post.favorite_user_id ?? 'null',
                                        post.favorite_post_seq ?? 0));
                                    int newFavoriteValue =
                                        post.favorite == '1' ? 0 : 1;
                                    // favorite 테이블이 있고 hate 테이블이 있는경우
                                    // favorite 1이고 hate가 0이면 updateFavorite
                                    // favorite 1이고 hate가 1이면 updatehate, updatefavorite
                                    // favorite 0이고 hate가 0이면 updateFavorite
                                    // favorite 0이고 hate가 1이면 updateFavorite
                                    // favorite 테이블이 있고 hate 테이블이 없는경우 updateFavorite
                                    if (check) {
                                      if (newFavoriteValue == 1 &&
                                          post.hate == '1') {
                                        await vmHandler.updateHate(
                                            0, post.hate_seq);
                                        await vmHandler.updateFavorite(
                                            newFavoriteValue,
                                            post.favorite_post_seq);
                                      }
                                      await vmHandler.updateFavorite(
                                          newFavoriteValue,
                                          post.favorite_post_seq);
                                      // favorite 테이블이 없고 hate 테이블이 없는경우 inserFavorite 1
                                      // favorite 테이블이 없고 hate 테이블이 있는경우
                                      // hate가 1이면 insertfavorite 1, updatehate
                                      // hate가 0이면 insertfavofite 1
                                    } else {
                                      if (post.hate == '1') {
                                        await vmHandler.updateHate(
                                            0, post.hate_post_seq);
                                        await vmHandler.insertFavorite(
                                            1, post.seq!);
                                      } else {
                                        await vmHandler.insertFavorite(
                                            1, post.seq!);
                                      }
                                    }
                                    await vmHandler.getPostJSONData();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: post.favorite == '1'
                                        ? Icon(Icons.favorite)
                                        : Icon(Icons.favorite_border),
                                  ),
                                ),
                                // 싫어요 아이콘
                                GestureDetector(
                                  onTap: () async {
                                    bool check = await controller.checkHate(
                                            post.hate_user_id ?? 'null',
                                            post.hate_post_seq ?? 0) ==
                                        post.hate_seq;
                                    int newHateValue = post.hate == '1' ? 0 : 1;
                                    if (check) {
                                      if (newHateValue == 1 &&
                                          post.favorite == '1') {
                                        await vmHandler.updateFavorite(
                                            0, post.favorite_seq);
                                        await vmHandler.updateHate(
                                            newHateValue, post.hate_post_seq);
                                      }
                                      await vmHandler.updateHate(
                                          newHateValue, post.hate_post_seq);
                                    } else {
                                      if (post.favorite == '1') {
                                        await vmHandler.updateFavorite(
                                            0, post.favorite_post_seq);
                                        await vmHandler.insertHate(
                                            1, post.seq!);
                                      } else {
                                        await vmHandler.insertHate(
                                            1, post.seq!);
                                      }
                                    }
                                    await vmHandler.getPostJSONData();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 10),
                                    child: post.hate == '1'
                                        ? Icon(Icons.thumb_down)
                                        : Icon(Icons.thumb_down_alt_outlined),
                                  ),
                                ),
                                // 코멘트 아이콘
                                GestureDetector(
                                  onTap: () {
                                    controller.getComment(post.seq!);
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
                                                            ListTile(
                                                              leading:
                                                                  CircleAvatar(),
                                                              title: Text(
                                                                  controller
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
                                                                    post.seq!,
                                                                    controller
                                                                        .textController
                                                                        .text
                                                                        .trim());
                                                            await controller
                                                                .getComment(
                                                                    post.seq!);
                                                            controller
                                                                .textController
                                                                .text = '';
                                                          }
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
                                  child: Text(post.comment_count == 0
                                      ? ""
                                      : "${post.comment_count}"),
                                )
                              ],
                            ),
                            // posting 내용
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('${post.user_id}')),
                                  Text('${post.contents}'),
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

  showModal(vmHandler, context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '메시지를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  //chatController.sendMessage(value);
                  //Navigator.pop(context); // 메시지를 전송 후 시트를 닫음
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 시 메시지 전송
                  //commentcontroller.comments();
                  Navigator.pop(context); // 메시지를 전송 후 시트를 닫음
                },
                child: Text('메시지 전송'),
              ),
              SizedBox(height: 10),
              Obx(() {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: vmHandler.comments.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(vmHandler.comments[index]),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
