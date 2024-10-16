import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:calm_lake_project/vm/button_controller.dart';
import 'package:calm_lake_project/vm/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioplayerHandler extends commentcontroller {
  PlayerState? playerState;
  Duration? duration;
  Duration? position;
  int musicState = 1;
  double imageLocation = 0;
  int gifImageState = 0;
  String selectCat = 'images/stopmovecat.png';
  

  StreamSubscription? durationSubscription;
  StreamSubscription? positionSubscription;
  StreamSubscription? playerCompleteSubscription;
  StreamSubscription? playerStateChangeSubscription;

  bool get isPlaying => playerState == PlayerState.playing;

  bool get isPaused => playerState == PlayerState.paused;

  String get durationText => duration?.toString().split('.').first ?? '';

  String get positionText => position?.toString().split('.').first ?? '';

  AudioPlayer player = AudioPlayer();

  checkaudioPlayer(String musicName) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await player.setSource(AssetSource('$musicName.mp3'));
      await player.setSource(UrlSource(musicName));
      // await player.resume();
    });
    player.setReleaseMode(ReleaseMode.stop);
    initStreams();
  }

  stateCheck() {
    playerState = player.state;
    player.getDuration().then((value) {
      duration = value;
      update();
    });
    player.getCurrentPosition().then((value) {
      position = value;
      update();
    });
  }

  initStreams() {
    durationSubscription = player.onDurationChanged.listen((duration) {
      this.duration = duration;
      update();
    });

    positionSubscription = player.onPositionChanged.listen((p) {
      position = p;
      update();
    });

    playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      playerState = PlayerState.stopped;
      position = Duration.zero;
      update();
    });

    playerStateChangeSubscription = player.onPlayerStateChanged.listen((state) {
      playerState = state;
      update();
    });
  }

  changeImageCat(){
    gifImageState == 0 ? selectCat = 'images/stopmovecat.png': selectCat = 'images/movecat.gif';
    update();
    return selectCat;
  }

  Future<void> play() async {
    await player.resume();
    playerState = PlayerState.playing;
    gifImageState = 1;
    update();
  }

  Future<void> pause() async {
    await player.pause();
    playerState = PlayerState.paused;
    gifImageState = 0;
    update();
  }

  Future<void> stop() async {
    await player.stop();
    playerState = PlayerState.stopped;
    position = Duration.zero;
    gifImageState = 0;
    changeImageCat();
    update();
  }
}
