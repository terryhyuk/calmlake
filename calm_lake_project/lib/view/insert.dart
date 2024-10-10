import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../vm/vm_handler.dart';

class Insert extends StatelessWidget {
  Insert({super.key});
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    @override
    final VmHandler vmHandler = Get.put(VmHandler());
    return Scaffold(
      appBar: AppBar(
        title: Text("New Post"),
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
                                  child: controller.imageFile == null
                                      ? Column(
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
                                        onPressed: controller
                                                .isButtonEnabled.value
                                            ? () => controller.selectButton(0)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              controller.selectedButton.value ==
                                                      0
                                                  ? Colors.green
                                                  : Colors.blue,
                                        ),
                                        child: Text('all'))),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Obx(() => ElevatedButton(
                                        onPressed: controller
                                                .isButtonEnabled.value
                                            ? () => controller.selectButton(1)
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
                                        onPressed: controller
                                                .isButtonEnabled.value
                                            ? () => controller.selectButton(2)
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
                                  onPressed: () {
                                    controller.getImageFromGallery(
                                        ImageSource.gallery);
                                  },
                                  child: Icon(Icons.image)),
                              ElevatedButton(
                                  onPressed: () async {
                                    if (controller.imageFile != null &&
                                        contentController.text.trim() != '' &&
                                        controller.selectedButton.value != -1) {
                                      await controller.uploadImage();
                                      await controller.insertJSONData(
                                          controller.image,
                                          contentController.text.trim(),
                                          controller.selectedButton.value);
                                      controller.imageFile = null;
                                      controller.selectedButton.value = -1;
                                      controller.isButtonEnabled.value = true;
                                      Get.back();
                                    } else {
                                      Get.snackbar(
                                          'Error', 'please complete the form',
                                          duration: Duration(seconds: 2));
                                    }
                                  },
                                  child: Text('입력')),
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
