import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentalz_flutter/services/auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

// Property
  getAllProperties() async {
    var ref = _db.collection('properties');
    var snapshot = await ref.get();
    var data = snapshot.docs.map((s) => s.data());
    return data.toList();
  }

  getAllPropertiesByLike() async {
    var ref = _db
        .collection('properties')
        .orderBy('likeCount', descending: true)
        .limit(5);
    var snapshot = await ref.get();
    var data = snapshot.docs.map((s) => s.data());
    return data.toList();
  }

  getAllPropertiesId() async {
    var ref = _db.collection('properties');
    var snapshot = await ref.get();
    return snapshot;
  }

  getAllPropertiesIdByLike() async {
    var ref = _db
        .collection('properties')
        .orderBy('likeCount', descending: true)
        .limit(5);
    var snapshot = await ref.get();
    return snapshot;
  }

  getAllLikedProperties(String userId) async {
    var wishlistRef = _db
        .collection('users')
        .doc(userId)
        .collection('wishlists')
        .orderBy('createdAt', descending: true);
    var snapshot = await wishlistRef.get();
    var data = snapshot.docs.map((s) => s.data());
    return data.toList();
  }

  getAllPropertiesByUserId(String userId) async {
    var ref =
        _db.collection('properties').where('createdBy', isEqualTo: userId);
    var snapshot = await ref.get();
    var data = snapshot.docs.map((s) => s.data());
    return data.toList();
  }

  getAllPropertiesIdByUserId(String userId) async {
    var ref =
        _db.collection('properties').where('createdBy', isEqualTo: userId);
    var snapshot = await ref.get();
    return snapshot;
  }

  setNewProperty(Map<String, dynamic>? formData, User user) async {
    // Verify current user's uid
    var uid = AuthService().getUser?.uid;

    // Refs declaration
    var propertiesRef =
        await _db.collection('properties').add({...formData!, 'likeCount': 0});

    return propertiesRef;
  }

  getProperty(String hostId, dynamic propertyId) async {
    var ref = _db.collection('properties').doc(propertyId);
    var doc = await ref.get();
    var property = doc.data();
    return property;
  }

  searchProperty(String keyWords) async {
    var data;
    if (keyWords.toLowerCase() != "") {
      var searchResultsRef = await _db
          .collection('properties')
          .where('propertyName', isGreaterThanOrEqualTo: keyWords)
          // .where('propertyName',
          //     isLessThanOrEqualTo: keyWords +
          //         "\uf8ff") // https://stackoverflow.com/questions/46568142/google-firestore-query-on-substring-of-a-property-value-text-search
          .get();
      data = searchResultsRef.docs.map((s) => s.data());
    }

    return data?.toList();
  }

  getLatestProperties() async {
    var ref = _db
        .collection('properties')
        .orderBy('dateAdded', descending: true)
        .limit(3);
    var snapshot = await ref.get();
    var data = snapshot.docs.map((s) => s.data());
    return data.toList();
  }

  getLastestPropertiesId() async {
    var ref = _db
        .collection('properties')
        .orderBy('dateAdded', descending: true)
        .limit(3);
    var snapshot = await ref.get();
    return snapshot;
  }

  searchAllPropertiesId(String keyWords) async {
    var searchResultsRef;
    if (keyWords.toLowerCase() != "") {
      searchResultsRef = await _db
          .collection('properties')
          .where('propertyName', isGreaterThanOrEqualTo: keyWords)
          // .where('propertyName',
          //     isLessThanOrEqualTo: keyWords +
          //         "\uf8ff") // https://stackoverflow.com/questions/46568142/google-firestore-query-on-substring-of-a-property-value-text-search
          .get();
    }

    return searchResultsRef;
  }

  updateProperty(Map<String, dynamic>? editFormData, String userId,
      String propertyId) async {
    DocumentReference propertyDoc =
        _db.collection('properties').doc(propertyId);

    var property = await propertyDoc.update(editFormData!);

    return property;
  }

  removeProperty(String userId, String prototypeId) async {
    DocumentReference propertyDoc =
        _db.collection('properties').doc(prototypeId);

    return await propertyDoc.delete();
  }

// Comments
  setNewComment(Map<String, dynamic>? commentData, String ownerId,
      String propertyId) async {
    var commentsRef = await _db
        .collection('properties')
        .doc(propertyId)
        .collection('comments')
        .add(commentData!);
    return commentsRef;
  }

  getComments(String propertyId) async {
    var ref =
        _db.collection('properties').doc(propertyId).collection('comments');
    var snapshot = await ref.get();
    var comments = snapshot.docs.map((comment) => comment.data());
    return comments.toList();
  }

// Users
  getUserDataFromId(String userId) async {
    var ref = _db.doc("users/$userId");

    var doc = await ref.get();
    var userData = doc.data();
    return userData;
  }

  // Likes

  getPropertyLikesFromId(String propertyId) async {
    var likesRef = await _db
        .collection('properties')
        .doc(propertyId)
        .collection('likes')
        .get();
    var data = likesRef.docs.map((s) => s.data());
    return data.toList();
  }

  addLikeToProperty(String userId, String propertyId) async {
    var likesRef = await _db
        .collection('properties')
        .doc(propertyId)
        .collection('likes')
        .add({'uid': userId});

    var likeCount = await _db
        .collection('properties')
        .doc(propertyId)
        .update({'likeCount': FieldValue.increment(1)});

    var wishList = await _db
        .collection('users')
        .doc(userId)
        .collection('wishlists')
        .add({'propertyId': propertyId, 'createdAt': Timestamp.now()});
  }

  removeLikeFromProperty(String userId, String propertyId) async {
    var batch = _db.batch();
    var ref = await _db
        .collection('properties')
        .doc(propertyId)
        .collection('likes')
        .where('uid', isEqualTo: userId)
        .get();

    var likeId;

    var elements = ref.docs.forEach((element) {
      likeId = element.id;
    });

    var removeLike = await _db
        .collection('properties')
        .doc(propertyId)
        .collection('likes')
        .doc(likeId);

    batch.delete(removeLike);

    var likeCount = await _db.collection('properties').doc(propertyId);

    batch.update(likeCount, {'likeCount': FieldValue.increment(-1)});

    var wishListRef = await _db
        .collection('users')
        .doc(userId)
        .collection('wishlists')
        .where('propertyId', isEqualTo: propertyId)
        .get();

    var wishlistId;

    var lists = wishListRef.docs.forEach((element) {
      wishlistId = element.id;
    });

    var wishlistRef = await _db
        .collection('users')
        .doc(userId)
        .collection('wishlists')
        .doc(wishlistId);

    batch.delete(wishlistRef);

    await batch.commit();
  }

  checkUserLike(String userId, String propertyId) async {
    var ref = await _db
        .collection("properties")
        .doc(propertyId)
        .collection('likes')
        .where("uid", isEqualTo: userId)
        .get();

    var data = ref.docs.map((s) => s.data());

    return data;
  }
}
