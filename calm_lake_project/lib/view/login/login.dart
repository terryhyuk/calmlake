import 'package:calm_lake_project/HomeScreen.dart';
import 'package:calm_lake_project/view/login/find_pw.dart';
import 'package:calm_lake_project/vm/vm_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../model/activity.dart';
import '../../vm/login_handler.dart';
import 'find_id.dart';
import 'sign_up.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final loginHandler = Get.put(LoginHandler());
  // final vmHandler = Get.put(VmHandler());
  // final box = GetStorage();

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
                    fillColor: const Color(0xFFCCE8F9),
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
                    fillColor: const Color(0xFFCCE8F9),
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
                          backgroundColor: const Color(0xFFF9D3CC)),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        String id = idController.text.trim();
                        String pw = pwController.text.trim();
                        // await vmHandler.getUserJSONData(id);
                        // print(vmHandler.user);
                        await allowLogin(id, pw);
                        // if (vmHandler.user.isNotEmpty) {
                        //   print(vmHandler.user);
                        //   await loginHandler.box.write(
                        //       'nickname', vmHandler.user[0]['nickname']);
                        // } else {
                        //   print('User data not found');
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7EFC9)),
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Get.to(FindId());
                      },
                      child: Text('ID 찾기')),
                  TextButton(
                      onPressed: () {
                        Get.to(FindPw());
                      },
                      child: Text('Password 찾기')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Functions
  allowLogin(String id, String pw) async {
    bool isDuplicate =
        await loginHandler.checkActiveJSONData(idController.text.trim());
    print(isDuplicate);
    if (isDuplicate) {
      DateTime? lastActiveTime=await loginHandler.findActiveIdJSONData(id);
      Duration difference=DateTime.now().difference(lastActiveTime!);
      if(difference.inMinutes<5){
      Get.snackbar('Error', '이미 접속중인 ID입니다.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color.fromARGB(255, 206, 53, 42),
          colorText: Colors.white);}
          else{
            loginHandler.box.write('userId', id);
            loginHandler.logoutJSONData(id);
            await loginHandler.activeUserJSONData(id);
            await activityInsert();
            Get.to(HomeScreen());
            idController.text = '';
            pwController.text = '';            
            }
    } else {
      bool isAuthenticated = await checkUserJSONData(id, pw);
      if (isAuthenticated) {
        await loginHandler.activeUserJSONData(id);
        await activityInsert();
        Get.to(HomeScreen());
        idController.text = '';
        pwController.text = '';
      } else {
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
    await loginHandler.box.write('userId', id);
  }

  errorSnackBar() {
    Get.snackbar('Error', 'ID와 비밀번호를 다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
  }

    activityInsert()async{
    var activity=Activity(
      userId: loginHandler.box.read('userId'), 
      activity: 'login', 
      datetime: DateTime.now().toString());    
    await loginHandler.useractivityJSONData(activity);
  }
}
