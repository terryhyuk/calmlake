import 'package:calm_lake_project/vm/list_handler.dart';
import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeHandler extends ListHandler {
  double volumeListenerValue = 0;
  double getVolume = 0;
  double setVolumeValue = 0;
  int muteState = 1;
  volumeBar() {
    VolumeController().getVolume().then((volume) => setVolumeValue = volume);
    VolumeController().listener((volume) {
      volumeListenerValue = volume;
    });
    VolumeController().showSystemUI = false;
    update();
  }

  soundControll(double value) {
    setVolumeValue = value;
    VolumeController().setVolume(setVolumeValue);
    update();
  }

  soundMute() {
    VolumeController().muteVolume();
    muteState == 1 ? muteState = 0 : muteState = 1;
    update();
  }

  changeIcon() {
    update();
    return muteState == 1 ? Icon(Icons.volume_up) : Icon(Icons.volume_off);
  }
}
