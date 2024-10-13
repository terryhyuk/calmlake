import 'dart:io';

import 'package:calm_lake_project/vm/volume_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Musicinsert extends VolumeHandler {
  final FirebaseStorage storage = FirebaseStorage.instance;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  File? imgFile;
  String downloadMp3URL = '';
  Future uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    result == null ? print('not Search File') : fileSelect(result);
  }

  fileSelect(FilePickerResult result) async {
    String filePath = result.files.single.path!;
    File file = File(filePath);
    // Firebase Storage에 업로드
    var uploadTask =
        await storage.ref('mp3/${result.files.single.name}').putFile(file);
    print('File uploaded successfully');

    downloadMp3URL = await uploadTask.ref.getDownloadURL();
  }

  showImage() {
    return imageFile == null
        ? const Text('Image is not selected')
        : Image.file(File(imageFile!.path));
  }

  galleryImage() {
    getImageFromGallery2(ImageSource.gallery);
    update();
  }

  reload() {
    update();
  }

  preparingImage() async {
    final firebaseStorage =
        FirebaseStorage.instance.ref().child('images').child(imageFile!.name);
    await firebaseStorage.putFile(imgFile!);
    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  getImageFromGallery2(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    imgFile = File(imageFile!.path);
    update();
  }
}
