import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserServices {
  static Future<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      {bool getCurrentUser = false}) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Future.error("No existe un usuario logueado");
    }
    return getCurrentUser
        ? FirebaseFirestore.instance.collection("users").get()
        : FirebaseFirestore.instance
            .collection("users")
            .where("uid", isNotEqualTo: currentUser.uid)
            .get();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(
      String uid) {
    return FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  static Future<void> updateUserStatus(String uid, String status) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"status": status});
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      searchByEmailAddress(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: email)
          .where('email', isLessThanOrEqualTo: '$email\uf8ff')
          .get();
      return users.docs;
    } catch (e) {
      return [];
    }
  }
}
