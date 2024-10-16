import 'dart:io';

import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditPost extends StatelessWidget {
  EditPost({super.key});
  final GetStorage box = GetStorage();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    @override
    final VmHandler vmHandler = Get.put(VmHandler());
    var value = Get.arguments ?? '__';
    vmHandler.selectButton(value[5]);
    vmHandler.isButtonEnabled.value = true;
    contentController.text = value[4];
    int post_seq = value[0];
    String userId = box.read('userId');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Get.delete<VmHandler>(); // 컨트롤러 삭제
            Get.back(); // 페이지 뒤로가기
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                GetBuilder<VmHandler>(
                  builder: (controller) {
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 204, 203, 203))),
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                child: Center(
                                  child: controller.firstDisp == 0
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20)),
                                          child: Image.network(
                                            "http://127.0.0.1:8000/query/view/${value[3]}",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 300,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20)),
                                          child: Image.file(
                                            File(controller.imageFile!.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 300,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // 전체 공유 버튼
                                    Obx(() => ElevatedButton(
                                        onPressed:
                                            controller.isButtonEnabled.value
                                                ? () {
                                                    controller.selectButton(0);
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              controller.selectedButton.value ==
                                                      0
                                                  ? const Color.fromARGB(
                                                      255, 70, 99, 150)
                                                  : const Color.fromARGB(
                                                      255, 116, 169, 171),
                                        ),
                                        child: const Text(
                                          'All',
                                          style: TextStyle(color: Colors.white),
                                        ))),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    // 나만 보기 버튼
                                    Obx(() => ElevatedButton(
                                        onPressed:
                                            controller.isButtonEnabled.value
                                                ? () {
                                                    controller.selectButton(1);
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              controller.selectedButton.value ==
                                                      1
                                                  ? const Color.fromARGB(
                                                      255, 70, 99, 150)
                                                  : const Color.fromARGB(
                                                      255, 116, 169, 171),
                                        ),
                                        child: const Text('Me',
                                            style: TextStyle(
                                                color: Colors.white)))),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    // 친구만 보기 버튼
                                    Obx(() => ElevatedButton(
                                        onPressed:
                                            controller.isButtonEnabled.value
                                                ? () {
                                                    controller.selectButton(2);
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              controller.selectedButton.value ==
                                                      2
                                                  ? const Color.fromARGB(
                                                      255, 70, 99, 150)
                                                  : const Color.fromARGB(
                                                      255, 116, 169, 171),
                                        ),
                                        child: const Text('Friends',
                                            style: TextStyle(
                                                color: Colors.white)))),
                                  ],
                                ),
                              ),
                              TextField(
                                controller: contentController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(20),
                                    hintText: '오늘 힐링되었던 내용을 입력해주세요',
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    await controller.changeImageFromGallery(
                                        ImageSource.gallery);
                                  },
                                  child: const Icon(Icons.image)),
                              ElevatedButton(
                                  onPressed: () async {
                                    // 수정 할때 버튼 액션
                                    editAction(controller, post_seq, value,
                                        vmHandler, userId);
                                  },
                                  child: Text('Edit')),
                              ElevatedButton(
                                  onPressed: () {
                                    controller.getImageFromGallery(
                                        ImageSource.camera);
                                  },
                                  child: Icon(Icons.add_a_photo_outlined)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  editAction(controller, post_seq, value, vmHandler, userId) async {
    if (controller.firstDisp == 0 && contentController.text.trim() != '') {
      await controller.updateJSONData(contentController.text.trim(),
          controller.selectedButton.value, post_seq);
      Get.back();
    } else if (controller.firstDisp != 0 &&
        contentController.text.trim() != '') {
      await controller.deletePostImage(value[3]);
      await controller.uploadImage();
      await controller.updateJSONDataAll(
          controller.image,
          contentController.text.trim(),
          controller.selectedButton.value,
          post_seq);
      controller.firstDisp = 0;
      Get.back();
    } else {
      Get.snackbar('Error', 'please complete the form',
          duration: const Duration(seconds: 1));
    }
    await vmHandler.getUserPostJSONData(userId);
  }
}
