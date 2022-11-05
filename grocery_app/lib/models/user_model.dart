
import 'package:firebase_auth/firebase_auth.dart';

class UserModel{

  static const NUMBER = 'number';
  static const ID = 'id';

  final String? _number = FirebaseAuth.instance.currentUser!.phoneNumber;
  final String _id = FirebaseAuth.instance.currentUser!.uid;

  String get number => _number!;
  String get id => _id;

}