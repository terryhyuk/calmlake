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
  List<String> documentIds = [];
  List<dynamic> fieldValues = [];

  // 음악 변환하는 함수
  firebaseMusicFunction(
      String musicname, String musicimage, String musictitle, doc) {
    firebaseMusic = musicname;
    selectImage = musicimage;
    selectMusic = musictitle;
    musicSelete = int.parse(doc.toString());
    update();
  }
  // firebase 문서의 갯수 출력
  getDocumentCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('music').get();

    musicCount = snapshot.size;
    update();
  }

  // 다음 노래나 이전 노래의 리스트를 firebase에서 가져오는 함수
  Future fetchDocumentFields(String musicSelect) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('music')
          .doc(musicSelect)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>?;
        // 모든 필드를 리스트로 변환
        fieldValues = data!.values.toList();
        fieldValues.sort((a, b) => a.length.compareTo(b.length));
        update();
      } else {
        print("문서가 존재하지 않습니다.");
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }

  // 다음 노래 출력
  Future nextMusicSelect() async {
    getDocumentCount();
    musicSelete == musicCount ? musicSelete = musicCount : musicSelete = musicSelete + 1;
    await fetchDocumentFields(musicSelete.toString());
    String checkmp3Value = fieldValues[2];
    String checkimageValue = fieldValues[3];
    checkmp3Value.contains('mp3') ? firebaseMusic = fieldValues[2].toString() : selectImage = fieldValues[2].toString();
    checkimageValue.contains('image') ? selectImage = fieldValues[3].toString() : firebaseMusic = fieldValues[3].toString();
    selectMusic = fieldValues[1].toString();
    checkaudioPlayer(firebaseMusic);
    stateCheck();
  }
  // 이전 노래 출력
    Future backMusicSelect() async {
    musicSelete == 1 ? musicSelete = 1 : musicSelete = musicSelete - 1;
    await fetchDocumentFields(musicSelete.toString());
    String checkmp3Value = fieldValues[2];
    String checkimageValue = fieldValues[3];
    checkmp3Value.contains('mp3') ? firebaseMusic = fieldValues[2].toString() : selectImage = fieldValues[2].toString();
    checkimageValue.contains('image') ? selectImage = fieldValues[3].toString() : firebaseMusic = fieldValues[3].toString();
    selectMusic = fieldValues[1].toString();
    checkaudioPlayer(firebaseMusic);
    stateCheck();
  }
}
