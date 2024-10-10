class Addfriends {
  int? seq;
  String user_id;
  String accept;
  String addid;
  String date;

  Addfriends(
    {
      this.seq,
      required this.user_id,
      required this.accept,
      required this.addid,
      required this.date,
    }
  );
    Addfriends.fromMap(Map<String, dynamic> res)
  : seq=res['seq'],
    user_id = res['user_id'],
    accept = res['accept'],
    addid = res['addid'],
    date = res['date'];
}