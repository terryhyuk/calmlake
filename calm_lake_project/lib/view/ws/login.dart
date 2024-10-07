import 'dart:convert';
import 'package:calm_lake_project/HomeScreen.dart';
import 'package:calm_lake_project/view/ws/find_pw.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../vm/login_handler.dart';
import '../home.dart';
import 'find_id.dart';
import 'sign_up.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final loginHandler = Get.put(LoginHandler());
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: TextField(
                  controller: idController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    fillColor: const Color.fromARGB(255, 253, 228, 155),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 2),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    hintText: 'User ID',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 15, bottom: 10),
                child: TextField(
                  controller: pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                    fillColor: const Color.fromARGB(255, 253, 228, 155),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black54, width: 2),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    hintText: 'Password',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () {
                        idController.text = "";
                        pwController.text = "";
                        Get.to(
                          () => SignUp(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC06044)),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        String id = idController.text.trim();
                        String pw = pwController.text.trim();
                        await allowLogin(id, pw);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF748D65)),
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.to(FindId());
                    }, 
                    child: Text('ID 찾기')
                    ),
                  TextButton(
                    onPressed: () {
                      Get.to(FindPw());
                    }, 
                    child: Text('Password 찾기')
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Functions
  allowLogin(String id, String pw)async{
    bool isDuplicate=await loginHandler.checkActiveJSONData(idController.text.trim());
    print(isDuplicate);  
    if(isDuplicate){
    Get.snackbar('Error', '이미 접속중인 ID입니다.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
    }else{
      bool isAuthenticated= await checkUserJSONData(id, pw);
      if(isAuthenticated){
      await loginHandler.activeUserJSONData(id);        
      Get.to(HomeScreen());
      idController.text='';
      pwController.text='';            
      }else{
    Get.snackbar('Error', '로그인 실패',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);        
      }
    }
  }
  checkUserJSONData(String id, String pw) async {
    var result = await loginHandler.checkUserJSONData(id, pw);
    if (result == 1) {
      await saveStorage(id);
      return true;
      // _showDialog();
    } else {
      errorSnackBar();
      return false;
    }
  }
  saveStorage(String id) async{
    await box.write('userId', id);
  }
  errorSnackBar() {
    Get.snackbar('Error', 'ID와 비밀번호를 다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
  }
}
