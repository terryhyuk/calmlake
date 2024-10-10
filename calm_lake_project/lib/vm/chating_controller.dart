import 'package:calm_lake_project/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/state_manager.dart';

class ChatingController extends GetxController{
  final messages = <Message>[].obs;
  final CollectionReference _messages = FirebaseFirestore.instance
                                        .collection('chat')
                                        .doc('grup')
                                        .collection('room1');

  // final CollectionReference _newchat = FirebaseFirestore.instance
  //                                       .collection('chat')
  //                                       .doc()
  //                                       .collection('newroom');

  @override
  void onInit() {
    super.onInit();
    _messages.orderBy('timestamp', descending: true).snapshots().listen((event) {
      messages.value = event.docs.map((doc)=> Message.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    },);
    // _newchat.orderBy('timestamp', descending: true).snapshots().listen((event) {
    //   messages.value = event.docs.map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    // },);
  }

  addMessage(String userID, String contents){
    _messages.add(
      {
      'userID': userID,
      'contents': contents,
      // 'nickname': nickname,
      'timestamp': Timestamp.now()
      }
    );
  }
}