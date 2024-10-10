class RequestedFriend {
  int? seq;
  String userId;
  String accept;
  String date;
  String addId;
  String nickname;

  RequestedFriend({
    this.seq,
    required this.userId,
    required this.accept,
    required this.date,
    required this.addId,
    required this.nickname,
  });

  RequestedFriend.fromMap(Map<String, dynamic> res)
      : seq = res['seq'],
        userId = res['user_id'],
        accept = res['accept'],
        date = res['date'],
        addId = res['add_id'],
        nickname = res['nickname'];
}
