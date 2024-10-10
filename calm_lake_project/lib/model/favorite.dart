class Favorite {
  int? seq;
  String user_id;
  int post_seq;
  int favorite;

  Favorite(
      {this.seq,
      required this.user_id,
      required this.post_seq,
      required this.favorite});
}
