import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../vm/login_handler.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final loginHandler = Get.put(LoginHandler());
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            logOut(box.read('userId'));
            Get.back();
          },
          icon: Icon(Icons.logout_outlined)
          ),
        title: Text(
          'CalmLake',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          children: [Divider()],
        ),
      ),
    );
  }
  logOut(String id)async{
    var result = await loginHandler.logoutJSONData(id);
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
