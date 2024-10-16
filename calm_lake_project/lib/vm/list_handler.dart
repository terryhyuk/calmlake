import 'package:calm_lake_project/model/music.dart';
import 'package:calm_lake_project/vm/audioplayer_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListHandler extends AudioplayerHandler {
  String firebaseMusic =
      'https://firebasestorage.googleapis.com/v0/b/calmlake-f513a.appspot.com/o/mp3%2FVivaldi_Spring.mp3?alt=media&token=2f669228-bb52-4e2d-b337-c4ed52316839';
  String selectMusic = 'Four_Session_Spring_01';
  String selectImage =
      'https://firebasestorage.googleapis.com/v0/b/calmlake-f513a.appspot.com/o/image%2FVivaldi_Spring.jpg?alt=media&token=0013d406-df24-4b48-b146-4c5499a99ac4';
  int firendList = 0;
  int musicCount = 0;
  int musicSelete = 1;
  String title1 = 'image';
  String title2 = 'mp3';
  String title3 = 'name';
  List<String> musicList = [];
  List<String> documentIds = [];
  List<String> mp3Values = [];
  List<dynamic> nameValues = [];
  List<dynamic> fieldValues = [];

  changeMusic(String musicName) {
    selectMusic = musicName;
    selectImage = musicName;
  }

  firebaseMusicFunction(
      String musicname, String musicimage, String musictitle) {
    firebaseMusic = musicname;
    selectImage = musicimage;
    selectMusic = musictitle;
    update();
  }

  getDocumentCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('music').get();

    musicCount = snapshot.size;
    update();
  }

  getDocId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('music').get();
    List<String> docID = querySnapshot.docs.map((doc) => doc.id).toList();
    // print(docID);
    documentIds.addAll(docID);
    // print(documentIds);

    update();
  }

  addlistMusic() async {
    musicList.clear();
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('music').get();
    for (var document in snapshot.docs) {
      Music music = Music(
          image: document.get('image'),
          mp3: document.get('mp3'),
          name: document.get('name'),
          singer: document.get('singer'));
      musicList.add(music.name);
    }
  }

  Future<Map<String, dynamic>?> getDocumentFields(String docId) async {
    try {
      DocumentSnapshot document =
          await FirebaseFirestore.instance.collection('music').doc(docId).get();
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

  Future fetchDocumentIds() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('music') // 컬렉션 이름
        .get();

    for (var doc in snapshot.docs) {
      documentIds.add(doc.id); // 각 문서의 ID를 추가
    }
    update();
  }

  Future fetchDocumentFields(String musicSelect) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('music')
          .doc(musicSelect)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>?;
        // 모든 필드를 리스트로 변환
        // fieldValues = data!['name'];
        // mp3Values = List<String>.from(fieldValues);
        fieldValues = data!.values.toList();
        fieldValues.sort((a, b) => a.length.compareTo(b.length));
        // print(fieldValues); // 가져온 필드 출력
        update();
      } else {
        print("문서가 존재하지 않습니다.");
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }

  Future nextMusicSelect() async {
    musicSelete = musicSelete + 1;
    await fetchDocumentFields(musicSelete.toString());
    String checkmp3Value = fieldValues[2];
    String checkimageValue = fieldValues[3];
    checkmp3Value.contains('mp3') ? firebaseMusic = fieldValues[2].toString() : selectImage = fieldValues[2].toString();
    checkimageValue.contains('image') ? selectImage = fieldValues[3].toString() : firebaseMusic = fieldValues[3].toString();
    selectMusic = fieldValues[1].toString();
    checkaudioPlayer(firebaseMusic);
    stateCheck();
  }

    Future backMusicSelect() async {
    musicSelete = musicSelete - 1;
    await fetchDocumentFields(musicSelete.toString());
    String checkmp3Value = fieldValues[2];
    String checkimageValue = fieldValues[3];
    checkmp3Value.contains('mp3') ? firebaseMusic = fieldValues[2].toString() : selectImage = fieldValues[3].toString();
    checkimageValue.contains('image') ? selectImage = fieldValues[3].toString() : firebaseMusic = fieldValues[3].toString();
    selectMusic = fieldValues[1].toString();
    checkaudioPlayer(firebaseMusic);
    stateCheck();
  }
}
