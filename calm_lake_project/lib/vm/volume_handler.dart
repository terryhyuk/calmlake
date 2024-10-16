import 'package:calm_lake_project/vm/list_handler.dart';
import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeHandler extends ListHandler {
  double volumeListenerValue = 0;
  double getVolume = 0;
  double setVolumeValue = 0;
  int muteState = 1;
  // VolumeController 생성
  volumeBar() {
    VolumeController().getVolume().then((volume) => setVolumeValue = volume);
    VolumeController().listener((volume) {
      volumeListenerValue = volume;
    });
    VolumeController().showSystemUI = false;
    update();
  }
  // 볼륨 조절 바
  soundControll(double value) {
    setVolumeValue = value;
    VolumeController().setVolume(setVolumeValue);
    update();
  }
  // 음소거 Icon바꾸는 변수 설정
  soundMute() {
    VolumeController().muteVolume();
    muteState == 1 ? muteState = 0 : muteState = 1;
    update();
  }
  // 변수를 기준으로 아이콘 변경
  changeIcon() {
    update();
    return muteState == 1 ? const Icon(Icons.volume_up) : const Icon(Icons.volume_off);
  }
}
