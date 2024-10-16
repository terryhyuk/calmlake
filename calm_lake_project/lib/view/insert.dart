import 'dart:io';

import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class Insert extends StatelessWidget {
  Insert({super.key});
  final GetStorage box = GetStorage();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(VmHandler());
    String userId = box.read('userId');
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
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
                                  child: controller.imageFile == null
                                      ? const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "        What’s a photo\nthat makes you feel good?",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54),
                                            ),
                                          ],
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
                                        onPressed: controller
                                                .isButtonEnabled.value
                                            ? () => controller.selectButton(0)
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
                                        onPressed: controller
                                                .isButtonEnabled.value
                                            ? () => controller.selectButton(1)
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
                                    // 친구만 공유 버튼
                                    Obx(() => ElevatedButton(
                                        onPressed: controller
                                                .isButtonEnabled.value
                                            ? () => controller.selectButton(2)
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
                                  onPressed: () {
                                    controller.getImageFromGallery(
                                        ImageSource.gallery);
                                  },
                                  child: const Icon(
                                    Icons.image,
                                  )),
                              ElevatedButton(
                                  onPressed: () async {
                                    insertAction(controller, userId);
                                  },
                                  child: const Text(
                                    'Post',
                                  )),
                              ElevatedButton(
                                  onPressed: () {
                                    controller.getImageFromGallery(
                                        ImageSource.camera);
                                  },
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                  )),
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

  insertAction(controller, userId) async {
    if (controller.imageFile != null &&
        contentController.text.trim() != '' &&
        controller.selectedButton.value != -1) {
      await controller.getUserJSONData(userId);
      await controller.uploadImage();
      await controller.insertJSONData(
          controller.image,
          contentController.text.trim(),
          controller.selectedButton.value,
          controller.user[0]['id'],
          controller.user[0]['nickname']);
      controller.imageFile = null;
      controller.selectedButton.value = -1;
      controller.isButtonEnabled.value = true;
      Get.back();
    } else {
      Get.snackbar('Error', 'please complete the form',
          duration: const Duration(seconds: 2));
    }
  }
}
