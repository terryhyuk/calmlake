class Profile {
  String id;
  String pw;
  String email;
  String nickName;
  String? pwAnswer;
  String? image;

  Profile(
      {required this.id,
      required this.pw,
      required this.email,
      required this.nickName,
      this.pwAnswer,
      this.image});
}
