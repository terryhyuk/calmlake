import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../vm/login_handler.dart';


class FindId extends StatelessWidget {
  FindId({super.key});
  final TextEditingController nickNameController = TextEditingController();
  final loginHandler = Get.put(LoginHandler());  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID 찾기'),
      ),
      body: GetBuilder<LoginHandler>
      (builder: (controller) {
        return Center(
          child: Column(
            children: [
              TextField(
                controller: nickNameController,
                decoration: const InputDecoration(
                  labelText: '사용자 Nickname을 입력해주세요.'
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  String nickName=nickNameController.text.trim();
                  findIdJSONData(nickName);
                  nickNameController.text='';
                  print(controller.findId.value);
                },
                child: const Text('Id 찾기')),
                Text('귀하의 ID는 ${controller.findId.value}입니다.')  //
            ],
          ),
        );
      },
      ),
    );
  }
  findIdJSONData(String nickName)async{
    var result = await loginHandler.findIdJSONData(nickName);
    if(result=='Error'){
      errorSnackBar();
    }else{
      // print(result);
      result.toString();
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