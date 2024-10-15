import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../vm/login_handler.dart';


class FindId extends StatelessWidget {
  FindId({super.key});
  final TextEditingController nickNameController = TextEditingController();
  final loginHandler = Get.put(LoginHandler());  

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
          title: const Text('ID 찾기'),
        ),
        body: GetBuilder<LoginHandler>
        (builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nickNameController,
                      decoration: const InputDecoration(
                        labelText: '사용자 Nickname을 입력해주세요.'
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD7EFC9),
                                    foregroundColor: Colors.black
                                  ),                             
                        onPressed: () {
                          String nickName=nickNameController.text.trim();
                          findIdJSONData(nickName);
                          // print(controller.findId.value);
                        },
                        child: const Text('Id 찾기')),
                    ),
                      nickNameController.text.trim().isNotEmpty ?
                      Text(controller.findId.value != 'Not found' ? '귀하의 ID는 ${controller.findId.value} 입니다.': '',
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                      )
                      : const Text('')
                  ],
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
  findIdJSONData(String nickName)async{
    var result = await loginHandler.findIdJSONData(nickName);
    if(nickNameController.text.trim().isEmpty||result=='Error'||loginHandler.findId.value=='Not found'){
      // print(result);
      errorSnackBar();
    }else{
      print(loginHandler.findId.value);
    }
  }
  errorSnackBar() {
    Get.snackbar('Error', '다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 243, 130, 122),
        colorText: Colors.white);
  }  
}