import 'package:calm_lake_project/vm/image_handler.dart';
import 'package:flutter/material.dart';

class ValidateCheck extends ImageHandler{
  String checkResult='';
  Color pwColor=Colors.black;
  String checkEmail='';
  Color emailColor=Colors.black;
  String doublePw='';
  Color doublePwColor=Colors.black;

validatePassword(String value) {
  // 정규식 패턴 (한글 또는 영문+숫자 조합, 4자 이상 15자 이하)
  String pattern = r'^[가-힣a-zA-Z0-9]{4,15}$';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    pwColor=Colors.black;    
    checkResult='비밀번호를 입력하세요';
  } else if (!regExp.hasMatch(value)) {
    pwColor=Colors.red;
    checkResult='비밀번호는 한글 또는 영문과 숫자를 포함한 4자 이상 15자 이내로 입력하세요.';
  } else {
    checkResult=''; // 유효한 비밀번호
  }update();
}
validateEmail(String value) {
  String email = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  RegExp mailExp = RegExp(email);
  if (value.isEmpty) {
    emailColor=Colors.black;
    checkEmail='email을 입력하세요.';
  } else if (!mailExp.hasMatch(value)) {
    emailColor=Colors.red;
    checkEmail='올바른 email 형식으로 입력해주세요.';
  } else {
    emailColor=Colors.black;
    checkEmail=''; // 올바른 Email
  }update();
}
doublecheckPw(String pw1, String pw2){
  if(pw2.isEmpty){
    doublePwColor=Colors.red;    
    doublePw='비밀번호를 한 번 더 입력하세요.';
  }else if(pw1!=pw2){
    doublePwColor=Colors.red;      
    doublePw='비밀번호가 일치하지 않습니다.';
  }else{
    doublePwColor=Colors.green;
    doublePw='OK✅'; //비밀번호 일치
  }update();
}
}
