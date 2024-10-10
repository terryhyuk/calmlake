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
  /*
        p.seq, //0
        p.post_user_id, //1
        p.date, //2
        p.image, //3
        p.contents, //4
        p.public, //5
        p.post_nickname, //6
        f.seq AS favorite_seq, //7
        f.user_id AS favorite_user_id, //8
        f.post_seq AS favorite_post_seq, //9
        f.favorite,//10
        h.seq AS hate_seq,//11 
        h.user_id AS hate_user_id,//12 
        h.post_seq AS hate_post_seq, //13
        h.hate,//14
        count(c.seq) as comment_count //15
*/
}
