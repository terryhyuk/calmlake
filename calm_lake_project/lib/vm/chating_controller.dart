import 'package:camlake_test_app/model/message.dart';
import 'package:camlake_test_app/vm/login_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatingController extends GetxController{
  final messages = <Message>[].obs;
  final chatRooms = <String>[].obs; // 채팅방 생성 리스트
  final loginhandler = Get.put(LoginHandler());
  
  final CollectionReference _messages = FirebaseFirestore.instance
                                        .collection('chat')
                                        .doc('grup')
                                        .collection('room1');

  @override
  void onInit() {
    super.onInit();
    _messages.orderBy('timestamp', descending: true).snapshots().listen((event) {
      messages.value = event.docs.map((doc)=> Message.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    },);
    loadUserChatRooms();
  }

loadUserChatRooms() {
    String userId = loginhandler.box.read('userId');
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chatRooms')
        .snapshots()
        .listen((snapshot) {
      chatRooms.value = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  createChatRoom(String roomName) async {
  String userId = loginhandler.box.read('userId');
  String nickname = loginhandler.box.read('nickname') ?? 'Anonymous';

  // Create a new document with an auto-generated ID
  DocumentReference roomRef = FirebaseFirestore.instance
      .collection('chat')
      .doc('grup')
      .collection('rooms')
      .doc();

  // 방생성
  await roomRef.set({
    'roomId': roomRef.id,
    'roomName': roomName,  // 방이름
    'createdAt': Timestamp.now(),
    'createdBy': userId,
    'participants': [userId],
  });

  // Add room to user's chat rooms
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chatRooms')
      .doc(roomRef.id)
      .set({
    'roomId': roomRef.id,
    'roomName': roomName,
    'joinedAt': Timestamp.now(),
  });

  // Add first message
  await roomRef.collection('messages').add({
    'roomId': roomRef.id,
    'roomName': roomName,
    'userID': userId,
    'nickname': nickname,
    'contents': '$nickname님이 채팅방을 생성했습니다.',
    'timestamp': Timestamp.now(),
  });
}
joinChatRoom(String roomId, String roomName) async {
    String userId = loginhandler.box.read('userId');
    String nickname = loginhandler.box.read('nickname') ?? 'Anonymous';

    // Add user to room participants
    await FirebaseFirestore.instance
        .collection('chat')
        .doc('grup')
        .collection('rooms')
        .doc(roomId)
        .update({
      'participants': FieldValue.arrayUnion([userId]),
    });

    // Add room to user's chat rooms
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chatRooms')
        .doc(roomId)
        .set({
      'joinedAt': Timestamp.now(),
      'roomName': roomName,
    });

    // Add join message
    await FirebaseFirestore.instance
        .collection('chat')
        .doc('grup')
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .add({
      'roomName': roomName,
      'userID': userId,
      'nickname': nickname,
      'contents': '$nickname님이 채팅방에 참여했습니다.',
      'timestamp': Timestamp.now(),
    });
  }

  addMessage(String userID, String contents){
    messages.clear();
    _messages.add(
      {
      // 'roomNane': roomNane,
      'userID': userID,
      'contents': contents,
      // 'nickname': nickname,
      'timestamp': Timestamp.now()
      }
    );
    print(messages);
  }
  
}