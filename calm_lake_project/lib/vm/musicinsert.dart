import 'dart:io';

import 'package:calm_lake_project/vm/volume_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Musicinsert extends VolumeHandler {
  final FirebaseStorage storage = FirebaseStorage.instance;

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  // musicinsert부분 텍스트 설정 변수(지금은 사용 불가능)
  // String mp3UploadOk = '선택안함';
  // String imageUploadOk = '선택안함';
  // 마지막 docId 가져와서 저장
  int lastDocId = 0;
  bool isUploading = false;
  String? downloadUrl;

  File? imgFile;

  // showImage() {
  //   return imageFile == null
  //       ? const Text('Image is not selected')
  //       : Image.file(File(imageFile!.path));
  // }

  galleryImage() {
    getImageFromGallery2(ImageSource.gallery);
    update();
  }
  // android가 외부로 나가게 되면 초기화면으로 돌아가서 지금은 쓸 수 없음
  // changemp3State() {
  //   mp3UploadOk = 'OK';
  //   update();
  // }

  // changeimageState() {
  //   imageUploadOk = 'OK';
  //   update();
  // }

  // changelastState() {
  //   mp3UploadOk = '선택안함';
  //   imageUploadOk = '선택안함';
  //   update();
  // }

  reload() {
    update();
  }

  preparingImage() async {
    final firebaseStorage =
        FirebaseStorage.instance.ref().child('image').child(imageFile!.name);
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

  Future getLastDocumentId() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('music') // 문서 ID 기준 정렬
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocId = int.parse(querySnapshot.docs.last.id);
      lastDocId += 1;
      update();
      print("마지막 문서 + 1 ID: $lastDocId");
    } else {
      print("문서가 없습니다.");
    }
  }

  // new
  Future uploadMp3File() async {
    // 파일 선택
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

        isUploading = true;
        update();
      try {
        // Firebase Storage 참조 생성
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child('mp3/${result.files.single.name}');

        // 파일 업로드
        await ref.putFile(file);

        // 다운로드 URL 가져오기
        String url = await ref.getDownloadURL();

          downloadUrl = url;
          isUploading = false;
          update();

        print('파일 업로드 성공: $url');
      } catch (e) {
        print('파일 업로드 실패: $e');
          isUploading = false;
          update();
      }
    }
}
}