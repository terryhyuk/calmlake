import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String roomId;
  String roomName;
  String userID;
  String nickname;
  String contents;
  DateTime timestamp;

  Message({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.userID,
    required this.nickname,
    required this.contents,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      roomId: map['roomId']??'',
      roomName: map['roomName']?? '',
      userID: map['userID'] ?? '',
      nickname: map['nickname'] ?? '',
      contents: map['contents'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'roomId' : roomId,
      'roomName': roomName,
      'nickname': nickname,
      'contents': contents,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}