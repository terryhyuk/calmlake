import 'package:get/get.dart';

class Post extends GetxController {
  int? seq = 0;
  String user_id = '';
  DateTime date = DateTime.now();
  String image = "";
  String contents = "";
  String public = "";
  int favorite_seq = 0;
  String favorite_user_id = "";
  int favorite_post_seq = 0;
  String favorite = "";
  int hate_seq = 0;
  String hate_user_id = "";
  int hate_post_seq = 0;
  String hate = '';
  int comment_count = 0;

  Post({
    this.seq, //0
    required this.user_id, //1
    required this.date, //2
    required this.image, //3
    required this.contents, //4
    required this.public, //5
    required this.favorite_seq, //6
    required this.favorite_user_id, //7
    required this.favorite_post_seq, //8
    required this.favorite, //9
    required this.hate_seq, //10
    required this.hate_user_id, //11
    required this.hate_post_seq, //12
    required this.hate, //13
    required this.comment_count, //14
  });
}
