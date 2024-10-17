import 'package:calm_lake_project/vm/friends_controller.dart';
import 'package:calm_lake_project/model/message.dart';
import 'package:calm_lake_project/vm/login_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatingController extends FriendsController {
  final messages = <Message>[].obs;
  final loginhandler = Get.put(LoginHandler());
  final chatRooms = <Map<String, dynamic>>[].obs; // 채팅방 목록을 Map으로 변경
  // ignore: constant_identifier_names
  static const List<String> defalult_rooms = ['직장인 채팅방', '맛집 공유','취미 공유','힐링 여행지 추천'];
  
  String getRoomDescription(String roomName) {
  switch (roomName) {
    case '직장인 채팅방':
      return '매일 일찍 퇴근하고 싶어요';
    case '맛집 공유':
      return '나만의 또간집! 맛집 추천해주세요!';
    case '취미 공유':
      return '건강한 취미는 필수! 취미 공유해요';
    case '힐링 여행지 추천':
      return '힐링을 위한 여행 여행 갈까요?';
    default:
      return ''; // 기본 채팅방이 아닌 경우 빈 문자열 반환
  }
}

ImageProvider getRoomImageProvider(String roomName) {
  switch (roomName) {
    case '직장인 채팅방':
      return const AssetImage('images/work.jpg');
    case '맛집 공유':
      return const AssetImage('images/eat.jpeg');
    case '취미 공유':
      return const AssetImage('images/1.jpg');
    case '힐링 여행지 추천':
      return const AssetImage('images/trip.jpg');
    default:
      return const AssetImage('images/default.jpg'); // 기본 이미지 에셋 경로
  }
}

TextStyle getRoomDescriptionStyle(String roomName) {
  switch (roomName) {
    case '직장인 채팅방':
      return const TextStyle(fontSize: 13, color: Color.fromARGB(255, 112, 162, 200), fontWeight: FontWeight.w700);
    case '맛집 공유':
      return const TextStyle(fontSize: 13, color: Color.fromARGB(255, 110, 170, 113), fontWeight: FontWeight.w700);
    case '취미 공유':
      return const TextStyle(fontSize: 13, color: Color.fromARGB(255, 244, 143, 85), fontWeight: FontWeight.w700);
    case '힐링 여행지 추천':
      return const TextStyle(fontSize: 13, color: Color.fromARGB(255, 167, 126, 174), fontWeight: FontWeight.w700);
    default:
      return const TextStyle(fontSize: 12, color: Colors.grey);
  }
} 

  String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat('MM/dd HH:mm').format(dateTime);
}


CollectionReference getMessagesRef(String roomId, bool isDefaultRoom) {
  if (isDefaultRoom) {
    // 기본 채팅방의 경우
    return FirebaseFirestore.instance
        .collection('chat')
        .doc('grup')
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages');
  } else {
    // 개인 채팅방의 경우
    return FirebaseFirestore.instance
        .collection('chat')
        .doc('users')
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages');
  }
}

@override
void onInit() {
  super.onInit();
  loadUserChatRooms();
  initializeDefaultRooms();
  
  // 기본 채팅방들의 메시지를 로드합니다.
  for (String roomId in defalult_rooms) {
    loadMessages(roomId, true);
  }
}

initializeDefaultRooms() async {
  String userId = loginhandler.box.read('userId');
  String nickname = loginhandler.box.read('nickname') ?? 'nickname';

  for (String roomId in defalult_rooms) {
    DocumentReference roomRef = FirebaseFirestore.instance
        .collection('chat')
        .doc('grup')
        .collection('rooms')
        .doc(roomId);

    DocumentSnapshot roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      await roomRef.set({
        'roomId': roomId,
        'roomName': '공용 채팅방 $roomId',
        'createdAt': Timestamp.now(),
        'participants': [userId],
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
      });

      await addMessage(roomId, 'system', 'System', roomDoc.get('lastMessageTime'), true);
    } else {
      // 이미 존재하는 경우, 사용자를 참가자 목록에 추가
      await roomRef.update({
        'participants': FieldValue.arrayUnion([userId]),
      });
    }

    // 사용자의 채팅방 목록에 추가
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chatRooms')
        .doc(roomId)
        .set({
      'roomId': roomId,
      'roomName': roomId,
      'joinedAt': Timestamp.now(),
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  loadUserChatRooms();
}

addFriendsToChatRoom(String roomId, List<String> friendIds) async {
  DocumentReference roomRef = FirebaseFirestore.instance
      .collection('chat')
      .doc('grup')
      .collection('rooms')
      .doc(roomId);
  
  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // 현재 채팅방 데이터 가져오기
      DocumentSnapshot roomSnapshot = await transaction.get(roomRef);
      
      if (!roomSnapshot.exists) {
        throw Exception('Chat room does not exist');
      }
      
      Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
      List<String> currentParticipants = List<String>.from(roomData['participants'] ?? []);
      
      // 새 친구들 추가 (중복 제거)
      Set<String> updatedParticipants = Set<String>.from(currentParticipants)..addAll(friendIds);
      
      // 채팅방 참가자 목록 업데이트
      transaction.update(roomRef, {'participants': updatedParticipants.toList()});
      
      // 각 친구의 chatRooms에 이 방 추가
      for (String friendId in friendIds) {
        if (!currentParticipants.contains(friendId)) {
          DocumentReference friendRef = FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .collection('chatRooms')
              .doc(roomId);
          transaction.set(friendRef, {
            'roomId': roomId,
            'roomName': roomData['roomName'],
            'joinedAt': Timestamp.now(),
          }, SetOptions(merge: true));
        }
      }
    });
    
    // 시스템 메시지 추가
    String addedFriends = friendIds.join(', ');
    await addMessage(roomId, 'system', 'System', '$addedFriends 님이 채팅방에 추가되었습니다.', true);
    
    // print('Friends added successfully');
  } catch (e) {
    // print('Error adding friends to chat room: $e');
  }
}

loadUserChatRooms() {
  String userId = loginhandler.box.read('userId');
  // print('Loading chat rooms for user: $userId');
  FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chatRooms')
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .listen((snapshot) {
    chatRooms.value = snapshot.docs.map((doc) {
      final data = doc.data();
      data['roomId'] = doc.id;
      return data;
    }).toList();
    // print('Loaded chat rooms: ${chatRooms.length}');
    chatRooms.refresh();
  }, onError: (error) {
    // print('Error loading chat rooms: $error');
  });
}

// 메시지 로드 함수도 기본 채팅방과 개인 채팅방에 맞게 수정
loadMessages(String roomId, bool isDefaultRoom) {
  getMessagesRef(roomId, isDefaultRoom)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .listen((event) {
    messages.value = event.docs
        .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
}

createOrGetChatRoom(String friendId, String friendName, bool isDefaultRoom, String userNickname) async {
  String userId = loginhandler.box.read('userId');
  String userNickname = loginhandler.box.read('nickname') ?? 'nickname';

  String roomId = userId.compareTo(friendId) < 0 ? '${userId}_$friendId' : '${friendId}_$userId';

  try {
    DocumentReference roomRef;
    if (isDefaultRoom) {
      // 기본 채팅방
      roomRef = FirebaseFirestore.instance
          .collection('chat')
          .doc('grup')
          .collection('rooms')
          .doc(roomId);
    } else {
      // 개인 채팅방
      roomRef = FirebaseFirestore.instance
          .collection('chat')
          .doc('users')
          .collection('chatRooms')
          .doc(roomId);
    }

    DocumentSnapshot roomDoc = await roomRef.get();

    final roomData = {
      'roomId': roomId,
      'roomName': isDefaultRoom ? '기본 채팅방 $roomId' : '$friendName와의 대화방',
      'createdAt': roomDoc.exists ? roomDoc.get('createdAt') : Timestamp.now(),
      'participants': [userId, friendId],
      'lastMessage': roomDoc.exists ? roomDoc.get('lastMessage') : '채팅방이 생성되었습니다.',
      'lastMessageTime': roomDoc.exists ? roomDoc.get('lastMessageTime') : Timestamp.now(),
    };

    // 채팅방 정보 업데이트 또는 생성
    await roomRef.set(roomData, SetOptions(merge: true));

    // 개인 채팅방인 경우에만 친구 목록에 방 추가
    if (!isDefaultRoom) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chatRooms')
          .doc(roomId)
          .set({
        'roomId': roomId,
        'roomName': '$friendName와의 대화방',
        'lastMessage': roomData['lastMessage'],
        'lastMessageTime': roomData['lastMessageTime'],
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('chatRooms')
          .doc(roomId)
          .set({
        'roomId': roomId,
        'roomName': '$userNickname와의 대화방',
        'lastMessage': roomData['lastMessage'],
        'lastMessageTime': roomData['lastMessageTime'],
      }, SetOptions(merge: true));
    }

    if (!roomDoc.exists) {
      // 새로운 채팅방인 경우에만 시스템 메시지 추가
      await addMessage(roomId, 'system', 'System', '채팅방이 생성되었습니다.', isDefaultRoom);
    }

    // 로컬 채팅방 목록 업데이트
    updateLocalChatRoomsList(
      roomId,
      isDefaultRoom ? '기본 채팅방 $roomId' : '$friendName와의 대화방',
      roomData['lastMessage'],
      roomData['lastMessageTime'],
    );

    // 채팅방 메시지 로드
    loadMessages(roomId, isDefaultRoom);

    return roomId;
  } catch (e) {
    // print('Error in createOrGetChatRoom: $e');
    return '';
  }
}



updateLocalChatRoomsList(String roomId, String roomName, String lastMessage, Timestamp lastMessageTime) {
  // 기존 방이 있는지 찾기
  final existingRoomIndex = chatRooms.indexWhere((room) => room['roomId'] == roomId);
  
  // 업데이트할 방 데이터
  final updatedRoom = {
    'roomId': roomId,
    'roomName': roomName,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime,
  };

  // 기존 방이 있으면 해당 방 정보 업데이트, 없으면 새로 추가
  if (existingRoomIndex != -1) {
    chatRooms[existingRoomIndex] = updatedRoom;
  } else {
    chatRooms.add(updatedRoom);
  }

  // 최신 메시지 순으로 정렬 (lastMessageTime이 Timestamp인 것을 보장)
  chatRooms.sort((a, b) {
    final timeA = a['lastMessageTime'] as Timestamp;
    final timeB = b['lastMessageTime'] as Timestamp;
    return timeB.compareTo(timeA);
  });
  // UI 갱신 트리거
  chatRooms.refresh();
}


  createChatRoom(String roomName, List<String> invitedFriends) async {
    String userId = loginhandler.box.read('userId');
    String nickname = loginhandler.box.read('nickname') ?? 'nickname';

    DocumentReference roomRef = FirebaseFirestore.instance
        .collection('chat')
        .doc('grup')
        .collection('rooms')
        .doc();

    List<String> participants = [userId, ...invitedFriends];

    final roomData = {
      'roomId': roomRef.id,
      'roomName': roomName,
      'createdAt': Timestamp.now(),
      'createdBy': userId,
      'participants': participants,
      'lastMessage': '$nickname님이 채팅방을 생성했습니다.',
      'lastMessageTime': Timestamp.now(),
    };

    await roomRef.set(roomData);

    // 참가자들의 chatRooms에 새 방 추가
    for (String participantId in participants) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(participantId)
          .collection('chatRooms')
          .doc(roomRef.id)
          .set(roomData);
    }

    // 첫 메시지 추가
    await addMessage(roomRef.id, userId, nickname, '$nickname님이 채팅방을 생성했습니다.',true);

    // 로컬 chatRooms 리스트 업데이트
    updateLocalChatRoomsList(roomRef.id, roomName, '$nickname님이 채팅방을 생성했습니다.', Timestamp.now());
  }

joinChatRoom(String roomId, String roomName, bool isDefaultRoom) async {
  String userId = loginhandler.box.read('userId');
  String nickname = loginhandler.box.read('nickname') ?? 'nickname';

  if (isDefaultRoom) {
    // 기본 채팅방의 경우
    await FirebaseFirestore.instance
        .collection('chat')
        .doc('grup')
        .collection('rooms')
        .doc(roomId)
        .update({
      'participants': FieldValue.arrayUnion([userId]),
    });
  }

  // 사용자의 채팅방 목록에 추가 (기본 채팅방과 개인 채팅방 모두)
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('chatRooms')
      .doc(roomId)
      .set({
    'joinedAt': Timestamp.now(),
    'roomName': roomName,
    'lastMessage': '$nickname님이 채팅방에 참여했습니다.',
    'lastMessageTime': Timestamp.now(),
  }, SetOptions(merge: true));

  // 참여 메시지 추가
  await addMessage(roomId, userId, nickname, '$nickname님이 채팅방에 참여했습니다.', isDefaultRoom);

  // 로컬 채팅방 목록 업데이트
  updateLocalChatRoomsList(
    roomId,
    roomName,
    '$nickname님이 채팅방에 참여했습니다.',
    Timestamp.now(),
  );
}

addMessage(String roomId, String userId, String nickname, String contents, bool isDefaultRoom) async {
  await getMessagesRef(roomId, isDefaultRoom).add({
    'roomId': roomId,
    'userID': userId,
    'nickname': nickname, // 닉네임 저장
    'contents': contents,
    'timestamp': Timestamp.now(),
  });

  // 채팅방의 마지막 메시지 정보 업데이트
  DocumentReference roomRef;
  if (isDefaultRoom) {
    roomRef = FirebaseFirestore.instance
        .collection('chat')
        .doc('grup')
        .collection('rooms')
        .doc(roomId);
  } else {
    roomRef = FirebaseFirestore.instance
        .collection('chat')
        .doc('users')
        .collection('chatRooms')
        .doc(roomId);
  }

  await roomRef.set({
    'lastMessage': contents,
    'lastMessageTime': Timestamp.now(),
  }, SetOptions(merge: true));

  // 사용자의 chatRooms 컬렉션 업데이트 (개인 채팅방의 경우에만)
  if (!isDefaultRoom) {
    String currentUserId = loginhandler.box.read('userId');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chatRooms')
        .doc(roomId)
        .set({
      'lastMessage': contents,
      'lastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}


deleteChatRoom(String roomId, bool isDefaultRoom) async {
  String userId = loginhandler.box.read('userId');

  try {
    // 사용자의 채팅방 목록에서 삭제
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chatRooms')
        .doc(roomId)
        .delete();

    if (!isDefaultRoom) {
      // 개인 채팅방인 경우, 채팅방 자체를 삭제
      await FirebaseFirestore.instance
          .collection('chat')
          .doc('users')
          .collection('chatRooms')
          .doc(roomId)
          .update({
        'participants': FieldValue.arrayRemove([userId])
      });
    } else {
      // 기본 채팅방인 경우, 참가자 목록에서 사용자 제거
      await FirebaseFirestore.instance
          .collection('chat')
          .doc('grup')
          .collection('rooms')
          .doc(roomId)
          // .delete();
          .update({
        'participants': FieldValue.arrayRemove([userId])
      });
    }

    // 로컬 채팅방 목록 업데이트
    chatRooms.removeWhere((room) => room['roomId'] == roomId);
    chatRooms.refresh();

    // print('Chat room deleted successfully');
  } catch (e) {
    // print('Error deleting chat room: $e');
  }
}


}
