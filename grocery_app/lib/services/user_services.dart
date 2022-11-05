import 'package:cloud_firestore/cloud_firestore.dart';

class UserServices {
  String collection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(Map<String, dynamic> values) async {
    String id = values['id'];

    await _firestore.collection(collection).doc(id).set(values);
  }

  Future<void> updateUser(Map<String, dynamic> values) async {
    String id = values['id'];

    await _firestore.collection(collection).doc(id).update(values);
  }

  Future<DocumentSnapshot> getUserById(String id) async{
    var result = await _firestore.collection('users').doc(id).get();
    return result;
  }
}
