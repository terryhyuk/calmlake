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
        title: Text("Edit Post"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
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
                              /*
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],*/
                              border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 204, 203, 203))),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                                child: Center(
                                  child: controller.firstDisp == 0
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.only(
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
                                          borderRadius: BorderRadius.only(
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
                                    Obx(() => ElevatedButton(
                                        onPressed:
                                            controller.isButtonEnabled.value
                                                ? () {
                                                    controller.selectButton(0);
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: controller
                                                      .selectedButton.value ==
                                                  0
                                              ? Colors.green // 선택된 버튼은 녹색
                                              : Colors.blue, // 선택되지 않은 버튼은 파란색
                                        ),
                                        child: Text('All'))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
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
                                                  ? Colors.green
                                                  : Colors.blue,
                                        ),
                                        child: Text('Me'))),
                                    SizedBox(
                                      width: 10,
                                    ),
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
                                                  ? Colors.green
                                                  : Colors.blue,
                                        ),
                                        child: Text('Friends'))),
                                  ],
                                ),
                              ),
                              Container(
                                child: TextField(
                                  controller: contentController,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(20),
                                      hintText: '오늘 힐링되었던 내용을 입력해주세요',
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none),
                                ),
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
                                  child: Icon(Icons.image)),
                              ElevatedButton(
                                  onPressed: () async {
                                    print("firstDisp ${controller.firstDisp}");
                                    if (controller.firstDisp == 0 &&
                                        contentController.text.trim() != '') {
                                      await controller.updateJSONData(
                                          contentController.text.trim(),
                                          controller.selectedButton.value,
                                          post_seq);
                                      print('update');
                                      Get.back();
                                    } else if (controller.firstDisp != 0 &&
                                        contentController.text.trim() != '') {
                                      await controller
                                          .deletePostImage(value[3]);
                                      await controller.uploadImage();
                                      await controller.updateJSONDataAll(
                                          controller.image,
                                          contentController.text.trim(),
                                          controller.selectedButton.value,
                                          post_seq);
                                      controller.firstDisp = 0;
                                      print('updateall');
                                      Get.back();
                                    } else {
                                      Get.snackbar(
                                          'Error', 'please complete the form',
                                          duration: Duration(seconds: 1));
                                    }
                                    print(value);
                                    await vmHandler.getUserPostJSONData(userId);
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
}
