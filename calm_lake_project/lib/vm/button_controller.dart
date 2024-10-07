import 'package:calm_lake_project/vm/image_handler.dart';
import 'package:get/get.dart';

class ButtonController extends ImageHandler {
  var selectedButton = (-1).obs; // -1은 아직 버튼이 선택되지 않았다는 의미
  var isButtonEnabled = true.obs; // 버튼이 활성화 상태인지 여부

  void selectButton(int value) {
    selectedButton.value = value;
  }
}
