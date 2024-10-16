import 'dart:io';
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.png'),
          fit: BoxFit.fill
          ),
      ),      
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
          ),
        ),
        body: GetBuilder<LoginHandler>(
          builder: (controller) {
            return FutureBuilder(
              future:
                  controller.showProfileJSONData(loginHandler.box.read('userId')),
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                              width: 200,
                              height: 200,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: controller.imageFile != null
                                    ? Image.file(File(controller.imageFile!.path),
                                    fit: BoxFit.fitWidth,)
                                    : result.image != null && result.image != 'null'
                                        ? Image.network(
                                            'http://127.0.0.1:8000/login/view/${result.image}',
                                            fit: BoxFit.fitWidth,)
                                        : const Icon(Icons.person, size: 200),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCCE8F9),
                                    foregroundColor: Colors.black
                                  ),
                                    onPressed: () async {
                                      await controller
                                          .getImageFromGallery(ImageSource.gallery);
                                      print(result.image);
                                    },
                                    child: const Text('갤러리')),
                              const SizedBox(width: 20,),      
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 255, 250, 198),
                                    foregroundColor: Colors.black
                                  ),                                
                                  onPressed: () async{
                                    await controller
                                        .getImageFromGallery(ImageSource.camera);
                                  },
                                  child: const Text('카메라')),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              '${result.id}님 안녕하세요.',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 23),
                            ),
                          ),
                          // 중복검사 삽입하기
                          TextField(
                            controller: nickNameController,
                            decoration: const InputDecoration(
                                labelText: '수정하실 Nickname을 입력하세요.'),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                                labelText: 'email을 입력하세요.',
                                errorText: controller.checkEmail.isNotEmpty
                                    ? controller.checkEmail
                                    : null,
                                errorStyle:
                                    TextStyle(color: controller.emailColor)),
                          ),
                          TextField(
                            controller: newPwController,
                            decoration: InputDecoration(
                                labelText: '비밀번호를 입력하세요.',
                                errorText: controller.checkResult.isNotEmpty
                                    ? controller.checkResult
                                    : null,
                                errorStyle: TextStyle(color: controller.pwColor)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD7EFC9),
                                    foregroundColor: Colors.black
                                  ),                              
                                onPressed: () {
                                  String? selectedImage;
                                  loginHandler.imageFile != null
                                      ? selectedImage = loginHandler.imageFile!.path
                                      : result.image != null &&
                                              result.image != 'null'
                                          ? selectedImage = result.image
                                          : selectedImage = result.image;
                                  controller.validatePassword(
                                      newPwController.text.trim());
                                  controller
                                      .validateEmail(emailController.text.trim());
                                  controller.checkResult !=
                                              '비밀번호는 한글 또는 영문과 숫자를 포함한 4자 이상 15자 이내로 입력하세요.' &&
                                          controller.checkEmail !=
                                              '올바른 email 형식으로 입력해주세요.'
                                      ? changeUserAction(
                                          loginHandler, selectedImage, result.image)
                                      : errorSnackBar();
                                },
                                child: const Text('회원 정보 수정')),
                          ),
                          TextButton(
                              onPressed: () {
                                deleteAction(result.id, result.image!);
                              },
                              child: const Text('회원 탈퇴',
                              style: TextStyle(
                                color: Colors.black54
                              ),
                              )),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  //회원 정보 수정

  changeUserAction(LoginHandler loginHandler, String? selectedImage,
      String? filename) async {
    if (nickNameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        newPwController.text.trim().isNotEmpty) {
      String? imageFilename;
      if (selectedImage != null) {
        if (selectedImage != loginHandler.image) {
          imageFilename = await loginHandler.editImage();
          print(imageFilename);
        } else {
          imageFilename = selectedImage;
        }
      } else if (selectedImage == null && filename != null) {
        imageFilename = filename;
      } else {
        imageFilename = null;
      }
      var userUpdate = Profile(
          id: loginHandler.box.read('userId'),
          pw: newPwController.text.trim(),
          email: emailController.text.trim(),
          nickName: nickNameController.text.trim(),
          image: imageFilename);
      var result = await loginHandler.changeUserJSONData(userUpdate);
      if (result == 'OK') {
        loginHandler.imageFile = null;
        if (imageFilename != filename && filename != null) {
          await deleteImage(filename);
        }
        Get.snackbar('Update', '수정이 완료되었습니다.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
            backgroundColor: const Color.fromARGB(255, 159, 184, 172),
            colorText: Colors.white);
      } else {
        await loginHandler.nickDoublecheck(nickNameController.text.trim());
        if(loginHandler.nickLabel=='사용할 수 없는 Nickname입니다.'){
          await deleteImage(imageFilename);
          loginHandler.imageFile=null;       
          nickErrorSnackBar();
        print('nickname 중복');}
      }
    } else {
      Get.snackbar('Error', '다시 확인해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 243, 130, 122),
          colorText: Colors.white);
    }
  }

  deleteImage(String? filename) async {
    await loginHandler.deleteImage(filename!);
  }

  //회원 탈퇴
  deleteAction(String userId, String? filename) async{
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        backgroundColor: const Color.fromARGB(255, 243, 130, 122),
        title: const Text(
          '정말 탈퇴하시겠습니까?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '작성하신 게시물과 댓글, 채팅 기록은\n자동 삭제되지 않습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
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
              await deleteUser(userId);
              await deleteImage(filename);
              await loginHandler.logoutJSONData(userId);
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
        backgroundColor: const Color.fromARGB(255, 243, 130, 122),
        colorText: Colors.white);
  }
  nickErrorSnackBar() {
    Get.snackbar('Nickname 중복', '사용할 수 없는 Nickname입니다.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 243, 130, 122),
        colorText: Colors.white);
  }
}
