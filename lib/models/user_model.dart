class UserModel extends Object {
  String email;
  String photoUrl;
  String? status;
  String userName;
  String uid;
  List<dynamic> rooms;

  UserModel(
      {required this.email,
      required this.userName,
      required this.uid,
      required this.photoUrl,
      this.status = "active",
      required this.rooms});

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'photoUrl': photoUrl,
      'status': status,
      'userName': userName,
      'uid': uid,
      "rooms": rooms
    };
  }
}
