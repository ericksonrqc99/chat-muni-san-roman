import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    return Future.error(e);
  }
}

Future<User?> registerWithEmailAndPassword(
    String userName, String email, String password) async {
  try {
    //create user in firebaseAuth
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user!.updateDisplayName(userName);

    //save user in firestore
    saveUserInFireStore(userName, email);

    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    return Future.error(e);
  }
}

Future<dynamic> saveUserInFireStore(String userName, String email) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String uid = FirebaseAuth.instance.currentUser!.uid;

    return await firestore.collection("users").doc(uid).set({
      "userName": userName,
      "email": email,
      "status": "active",
      "uid": uid,
      "rooms": [],
      "photoUrl": ""
    });
  } on Exception {
    return false;
  }
}

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    return userCredential.user;
  } on Exception {
    return null;
  }
}

Future<bool> logout() async {
  try {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    return true;
  } on Exception {
    return false;
  }
}
