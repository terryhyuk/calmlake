import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_list2_app/model/music.dart';
import 'package:firebase_list2_app/vm/audioplayer_handler.dart';

class ListHandler extends AudioplayerHandler{
  String firebaseMusic = 'https://firebasestorage.googleapis.com/v0/b/calmlake-f513a.appspot.com/o/mp3%2FVivaldi_Spring.mp3?alt=media&token=2f669228-bb52-4e2d-b337-c4ed52316839';
  String selectMusic = 'Four_Session_Spring';
  String selectImage = 'https://firebasestorage.googleapis.com/v0/b/calmlake-f513a.appspot.com/o/image%2FVivaldi_Spring.jpg?alt=media&token=0013d406-df24-4b48-b146-4c5499a99ac4';
  int firendList = 0;
  int musicCount = 0;
  List<String> musicList = [];
  List<String> documentIds = ['nxlyH23Ya7L1kYHBqe8q'];

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

getDocId() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('music')
      .get();
      List<String> docID = querySnapshot.docs.map((doc) => doc.id).toList();
      // print(docID);
      documentIds.addAll(docID);
      // print(documentIds);

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
    musicList.add(music.name);
  }
}

Future<Map<String, dynamic>?> getDocumentFields(String docId) async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance.collection('music').doc(docId).get();
      if (document.exists) {
        return document.data() as Map<String, dynamic>?;
      } else {
        print("문서가 존재하지 않습니다.");
        return null;
      }
    } catch (e) {
      print("오류 발생: $e");
      return null;
    }
  }
}