import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NavigationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final RxInt currentIndex = 0.obs;
  final box = GetStorage();
  String userId = '';
  String nickname = '';

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      currentIndex.value = tabController.index;
    });
    userId = box.read('userId') ?? ''; // userId가 없으면 빈 문자열로 초기화
    nickname = box.read('nickname') ?? '';
    print('Stored userId: $userId');
    print('Stored usernickname: $nickname');
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
