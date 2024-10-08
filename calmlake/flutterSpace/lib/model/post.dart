import 'package:get/get.dart';

class Post extends GetxController {
  int? seq = 0;
  DateTime date = DateTime.now();
  String image = "";
  String contents = "";
  String userId = "";

  Post({
    this.seq,
    required this.date,
    required this.image,
    required this.contents,
    required this.userId,
  });
}
