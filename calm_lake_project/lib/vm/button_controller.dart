import 'package:calm_lake_project/vm/post_imange_handler.dart';
import 'package:get/get.dart';

class ButtonController extends PostImageHandler {
  var selectedButton = (-1).obs; // -1은 아직 버튼이 선택되지 않을때
  var isButtonEnabled = true.obs; // 버튼이 클릭되었는지

  void selectButton(int value) {
    selectedButton.value = value;
  }
}
