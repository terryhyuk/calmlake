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
    final VmHandler vmHandler = Get.put(VmHandler());
    return Scaffold(
      appBar: AppBar(
        title: Text("Insert Data"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              GetBuilder<VmHandler>(
                builder: (controller) {
                  return Column(
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 176, 193, 200),
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        child: Center(
                          child: controller.imageFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image),
                                    Text(
                                      'No image selected',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              Color.fromARGB(255, 1, 24, 26)),
                                    ),
                                  ],
                                )
                              : Image.file(
                                  File(controller.imageFile!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 250,
                                ),
                        ),
                      ),
                      TextField(
                        controller: contentController,
                        maxLines: null,
                      ),
                      Row(
                        children: [
                          Obx(() => ElevatedButton(
                              onPressed: controller.isButtonEnabled.value
                                  ? () => controller.selectButton(0)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    controller.selectedButton.value == 0
                                        ? Colors.green
                                        : Colors.blue,
                              ),
                              child: Text('all'))),
                          Obx(() => ElevatedButton(
                              onPressed: controller.isButtonEnabled.value
                                  ? () => controller.selectButton(1)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    controller.selectedButton.value == 1
                                        ? Colors.green
                                        : Colors.blue,
                              ),
                              child: Text('Me'))),
                          Obx(() => ElevatedButton(
                              onPressed: controller.isButtonEnabled.value
                                  ? () => controller.selectButton(2)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    controller.selectedButton.value == 2
                                        ? Colors.green
                                        : Colors.blue,
                              ),
                              child: Text('Friends'))),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                controller
                                    .getImageFromGallery(ImageSource.gallery);
                              },
                              child: Icon(Icons.image)),
                          ElevatedButton(
                              onPressed: () {
                                controller
                                    .getImageFromGallery(ImageSource.camera);
                              },
                              child: Icon(Icons.add_a_photo_outlined)),
                          ElevatedButton(
                              onPressed: () async {
                                await controller.uploadImage();
                                await controller.insertJSONData(
                                    controller.image,
                                    contentController.text,
                                    controller.selectedButton.value,
                                    'user');
                                controller.imageFile = null;
                                Get.back();
                              },
                              child: Text('입력')),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
