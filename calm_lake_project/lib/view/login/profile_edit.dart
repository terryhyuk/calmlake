import 'dart:io';
import 'dart:typed_data';
import 'package:calm_lake_project/model/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../vm/login_handler.dart';

class ProfileEdit extends StatelessWidget {
  ProfileEdit({super.key});
  final loginHandler = Get.put(LoginHandler());
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Edit'),
      ),
      body: GetBuilder<LoginHandler>(
        builder: (controller) {
          return FutureBuilder(
            future: controller.showProfileJSONData(loginHandler.box.read('userId')),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                Profile result = snapshot.data!;
                nickNameController.text = result.nickName;
                emailController.text = result.email;
                // newPwController.text = result.pw;
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      controller.imageFile != null 
                      ? Image.file(File(controller.imageFile!.path)): 
                      result.image != null ? Image.memory(result.image!) : 
                      const Icon(Icons.person, size: 200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () async {
                                  controller
                                      .getImageFromGallery(ImageSource.gallery);
                                  print(result.image);
                                },
                                child: const Text('갤러리')),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                controller
                                    .getImageFromGallery(ImageSource.camera);
                              },
                              child: const Text('카메라')),
                        ],
                      ),
                      Text(
                        '${result.id}님 안녕하세요.',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 23),
                      ),
                      // 중복검사 삽입하기
                      TextField(
                        controller: nickNameController,
                        decoration:
                            const InputDecoration(labelText: '수정하실 Nickname을 입력하세요.'),
                      ),
                      TextField(
                        controller: emailController,
                        decoration:
                            InputDecoration(errorText: controller.checkEmail.isNotEmpty ? controller.checkEmail : null,
                    errorStyle: TextStyle(color: controller.emailColor)),
                      ),
                      TextField(
                        controller: newPwController,
                    decoration: 
                    InputDecoration(
                    errorText: controller.checkResult.isNotEmpty ? controller.checkResult : null,
                    errorStyle: TextStyle(color: controller.pwColor)
                    ),
                  ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ElevatedButton(
                            onPressed: () {
                              controller.validatePassword(newPwController.text.trim());    
                              controller.validateEmail(emailController.text.trim());                  
                              controller.checkResult !='비밀번호는 한글 또는 영문과 숫자를 포함한 4자 이상 15자 이내로 입력하세요.' &&controller.checkEmail !='올바른 email 형식으로 입력해주세요.' ? changeUserAction(loginHandler, result.image!)
                              : errorSnackBar();
                            },
                            child: const Text('회원 정보 수정')),
                      ),
                      TextButton(
                          onPressed: () {
                            deleteAction(result.id);
                          },
                          child: const Text('회원 탈퇴')),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  //회원 정보 수정
  changeUserAction(LoginHandler loginHandler, Uint8List orignImage) async {
    if (nickNameController.text.trim().isNotEmpty &
        emailController.text.trim().isNotEmpty &
        newPwController.text.trim().isNotEmpty) {
    Uint8List getImage;
      if(loginHandler.imageFile!=null){
        File imageFile1 = File(loginHandler.imageFile!.path);
        getImage = await imageFile1.readAsBytes();
        }else{getImage=orignImage;}
      var userUpdate = Profile(
          id: loginHandler.box.read('userId'),
          pw: newPwController.text.trim(),
          email: emailController.text.trim(),
          nickName: nickNameController.text.trim(),
          image: getImage);
      var result = await loginHandler.changeUserJSONData(userUpdate);
      if (result == 'OK') {
        loginHandler.imageFile=null;
        Get.snackbar('Update', '수정이 완료되었습니다.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: const Color.fromARGB(255, 159, 184, 172),
            colorText: Colors.white);
      } else {
        errorSnackBar();
        print('Error');
      }
    } else {
      Get.snackbar('Error', '다시 확인해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 206, 53, 42),
          colorText: Colors.white);
    }
  }

  //회원 탈퇴
  deleteAction(String userId) {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        backgroundColor: Colors.red,
        title: const Text(
          '정말 탈퇴하시겠습니까?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '작성하신 게시물과 댓글, 채팅 기록은\n자동 삭제되지 않습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text(
              '탈퇴하기',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              deleteUser(userId);
              await loginHandler.logoutJSONData(userId);
              Get.back();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  deleteUser(String userId) async {
    var result = await loginHandler.deleteUserJSONData(userId);
    if (result == 'OK') {
      Get.back();
    } else {
      errorSnackBar();
      print('Error');
    }
  }

  errorSnackBar() {
    Get.snackbar('Error', '다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
  }
}
