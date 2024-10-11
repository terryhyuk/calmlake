class Addfriends {
  int? seq;
  String user_id;
  String accept;
  String add_id;
  String date;

  Addfriends({
    this.seq,
    required this.user_id,
    required this.accept,
    required this.add_id,
    required this.date,
  });
  Addfriends.fromMap(Map<String, dynamic> res)
      : seq = res['seq'],
        user_id = res['user_id'],
        accept = res['accept'],
        add_id = res['add_id'],
        date = res['date'];
}
