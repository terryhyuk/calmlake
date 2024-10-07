import 'dart:typed_data';

class Profile {
  String id;
  String pw;
  String email;
  String nickName;
  String? pwAnswer;
  Uint8List? image;

  Profile({
    required this.id,
    required this.pw,
    required this.email,
    required this.nickName,
    this.pwAnswer,
    this.image
  });
}