import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/profile.dart';
import '../../vm/login_handler.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController pwcheckController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController pwAnswerController = TextEditingController();
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
          leading: IconButton(
            onPressed: () {
              loginHandler.idLabel='';
              loginHandler.nickLabel='';
              loginHandler.pwColor=Colors.black;
              loginHandler.emailColor=Colors.black;
              loginHandler.doublePwColor=Colors.black;
              Get.back();
            }, 
            icon: Icon(Icons.arrow_back_ios_new)),
          backgroundColor: Colors.transparent,
          title: const Text('Create Account',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
        ),
        body: GetBuilder<LoginHandler>(
          builder: (controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20,0,20,0),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: 230,
                              child: TextField(
                                controller: idController,
                                decoration: const InputDecoration(labelText: 'ID를 입력하세요.'),
                              ),
                            ),
                            Text(controller.idLabel.toString(),
                            style: TextStyle(
                              color: controller.idLabel.toString()=='사용할 수 없는 ID입니다.' ? Colors.red : Colors.green
                            ),)
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15,0,0,0),
                          child: ElevatedButton(
                            onPressed: () async{
                              await controller.idDoublecheck(idController.text.trim());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9D3CC),
                              foregroundColor: Colors.black
                            ), 
                            child: const Text('중복검사'),
                            ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,10,0,10),
                      child: TextField(
                        controller: pwController,
                        decoration: InputDecoration(labelText: pwController.text=='' ? 'Password를 입력하세요.' : controller.checkResult, labelStyle: TextStyle(
                          color: controller.pwColor
                        )),
                        onChanged: (value) {
                          controller.validatePassword(pwController.text.trim());
                        },
                      ),
                    ),
                    TextField(
                      controller: pwcheckController,
                      decoration: InputDecoration(labelText: pwcheckController.text=='' ? 'Password를 다시 입력하세요.':controller.doublePw, 
                      labelStyle: TextStyle(
                        color: controller.doublePwColor
                      )),
                      onChanged: (value) {
                        controller.doublecheckPw(pwController.text.trim(), pwcheckController.text.trim());
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,10,0,10),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: emailController.text=='' ? 'Email을 입력하세요.' : controller.checkEmail,
                        labelStyle: TextStyle(
                          color: controller.emailColor
                        )),
                        onChanged: (value) {
                          controller.validateEmail(emailController.text.trim());
                        },
                      ),
                    ),
                    Column(
                      children: [
                        TextField(
                          controller: nickNameController,
                          decoration:
                              const InputDecoration(labelText: 'Nickname을 입력하세요.'),
                              onChanged: (value) async {
                                await controller.nickDoublecheck(nickNameController.text.trim());
                              },
                        ),
                        Text(controller.nickLabel,
                        style: TextStyle(
                          color: controller.nickLabel=='사용할 수 없는 Nickname입니다.' ? Colors.red : Colors.green
                        ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0,30,0,5),
                      child: Text('다음은 비밀번호 재설정에 사용될 질문입니다.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                      ),
                    ),
                    TextField(
                      controller: pwAnswerController,
                      decoration:
                          const InputDecoration(labelText: '가장 기억에 남는 스승의 이름은 무엇입니까?'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,70,0,0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7EFC9),
                          foregroundColor: Colors.black
                        ),
                          onPressed: () {
                            insertAction();
                            controller.idLabel='';
                            controller.nickLabel='';
                            controller.pwColor=Colors.black;
                            controller.doublePwColor=Colors.black;
                          },
                          child: const Text('Sign Up')),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  //Functions
  insertAction() async {
    if(idController.text.trim().isNotEmpty&&pwController.text.trim().isNotEmpty&&emailController.text.trim().isNotEmpty&&nickNameController.text.trim().isNotEmpty&&pwAnswerController.text.trim().isNotEmpty){
    var profileInsert = Profile(
        id: idController.text.trim(),
        pw: pwController.text.trim(),
        email: emailController.text.trim(),
        nickName: nickNameController.text.trim(),
        pwAnswer: pwAnswerController.text.trim()
        );
    var result = await loginHandler.insertJSONData(profileInsert);
    if (result == 'OK') {
      Get.back();
      }else{
        errorSnackBar();
      }
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
