import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../vm/login_handler.dart';

class FindPw extends StatelessWidget {
  FindPw({super.key});
  final TextEditingController idController = TextEditingController();
  final TextEditingController awController = TextEditingController();
  final TextEditingController newPwController = TextEditingController();
  final loginHandler = Get.put(LoginHandler());  

  @override
  Widget build(BuildContext context) {
    bool screen=false;
    bool answer=false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password 찾기'),
      ),
      body: GetBuilder<LoginHandler>
      (builder: (controller) {
        return Center(
          child: Column(
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: '사용자 ID를 입력해주세요.'
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  String id=idController.text.trim();
                  findPwJSONData(id);
                  screen = id.isNotEmpty&&controller.findPw.value!='Error';            
                  // controller.findIdJSONData(nickName);
                  // idController.text='';
                  // print(controller.findId.value);
                },
                child: const Text('ID 확인')),
                screen
                ? Column(
                  children: [
                    TextField(
                    controller: awController,
                    decoration: const InputDecoration(
                      labelText: '가장 기억에 남는 스승의 이름은 무엇입니까?'
                    ),
                    ),
                ElevatedButton(
                onPressed: () {
                  String id=idController.text.trim();
                  findPwJSONData(id);                  
                  String aw=awController.text.trim();
                  print(aw);
                  answer = aw==controller.findPw.value;
                  print(answer);
                },
                child: const Text('확인')),                                  
                  ],
                )
                : const Text(''),
                answer
                ? Column(
                  children: [
                    TextField(
                    controller: newPwController,
                    decoration: const InputDecoration(
                      labelText: '새로운 Password를 입력해주세요.'
                    ),
                    ),
                ElevatedButton(
                onPressed: () {
                  changePwAction(newPwController.text.trim(), idController.text.trim());
                },
                child: const Text('Password 재설정')),
            ],
          )
          : const Text(''),
          ]
          )
        );
      },
      ),
    );
  }
  findPwJSONData(String id)async{
    var result = await loginHandler.findPwJSONData(id);
    if(result=='Error'){
      errorSnackBar();
    }else{
      // print(result);
      result.toString();
    }
  }
  changePwAction(String newPw, String id) async {
    var result = await loginHandler.changePwJSONData(newPw, id);
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