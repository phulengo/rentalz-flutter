import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get getUser => _auth.currentUser;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> googleSignIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication? googleAuth =
          await googleSignInAccount?.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(authCredential);
      User? user = result.user;

      // Update user data
      updateUserData(user);

      return user;
    } on FirebaseAuthException catch (error) {
      print(error.message);
      rethrow;
    }
  }

  updateUserData(User? user) async {
    DocumentReference reportRef = _db.collection('report').doc(user?.email);
    DocumentReference usersRef = _db.collection('users').doc(user?.uid);

    // Commit both docs together as a batch write.
    var batch = _db.batch();
    batch.set(reportRef, {'uid': user?.uid, 'lastActivity': DateTime.now()},
        SetOptions(merge: true));
    batch.set(
        usersRef,
        {
          'displayName': user?.displayName,
          'photoURL': user?.photoURL,
          'email': user?.email
        },
        SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
