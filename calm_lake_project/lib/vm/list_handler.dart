import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_list2_app/model/music.dart';
import 'package:firebase_list2_app/vm/audioplayer_handler.dart';

class ListHandler extends AudioplayerHandler{
  String firebaseMusic = 'https://firebasestorage.googleapis.com/v0/b/calmlake-f513a.appspot.com/o/mp3%2FVivaldi_Spring.mp3?alt=media&token=2f669228-bb52-4e2d-b337-c4ed52316839';
  String selectMusic = 'Spring';
  String selectImage = 'https://firebasestorage.googleapis.com/v0/b/calmlake-f513a.appspot.com/o/image%2FVivaldi_Spring.jpg?alt=media&token=0013d406-df24-4b48-b146-4c5499a99ac4';
  int firendList = 0;
  int musicCount = 0;
  List<String> musicList = [];

  changeMusic(String musicName){
    selectMusic = musicName;
    selectImage = musicName;
  }
  firebaseMusicFunction(String musicname, String musicimage, String musictitle){
    firebaseMusic = musicname;
    selectImage = musicimage;
    selectMusic = musictitle;
    update();
  }

  getDocumentCount() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('music')
      .get();

      musicCount = snapshot.size;
      update();
}

addlistMusic() async {
  musicList.clear();
  QuerySnapshot snapshot = await FirebaseFirestore.instance
                            .collection('music')
                            .get();
  for (var document in snapshot.docs){
   Music music = Music(
    image: document.get('image'), 
    mp3: document.get('mp3'), 
    name: document.get('name'), 
    singer: document.get('singer')
    );
    musicList.add(music.toString());
  }
}
}