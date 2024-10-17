import 'package:calm_lake_project/view/login/login.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppLifecycleController extends LoginHandler with WidgetsBindingObserver {
  final Rx<DateTime> _lastInteraction = DateTime.now().obs;
  final Duration autoLogoutDuration = const Duration(minutes: 5);
  final LoginHandler loginHandler=Get.put(LoginHandler());

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      loginHandler.logoutJSONData(loginHandler.box.read('userId'));
      loginHandler.disposeSave();
      Get.offAll(()=> Login());
    } else if (state == AppLifecycleState.paused) {
      resetTimer();
    }
  }

  void resetTimer() {
    _lastInteraction.value = DateTime.now();
  }

  // void checkAutoLogout() {
  //   if (DateTime.now().difference(_lastInteraction.value) > autoLogoutDuration) {
  //     // 자동 로그아웃 실행
  //     Get.offAll(() => Login()); // Login화면으로 이동
  //   }
  // }
}