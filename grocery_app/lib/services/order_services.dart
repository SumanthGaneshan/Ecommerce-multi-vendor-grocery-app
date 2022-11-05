
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderServices{

  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  final user = FirebaseAuth.instance.currentUser;

  Future<void> saveOrder({required List products,total,cod,mobile,address,isPayed})async{
    var result = await orders.add(
        {
          'products': products,
          'total': total,
          'delivery fee': 40,
          'isCod': cod,
          'timestamp': DateTime.now().toString(),
          'userUid': user!.uid,
          'mobile': mobile,
          'address': address,
          'orderStatus': 'pending',
          'isPayed': isPayed,
        }
    );
  }
}