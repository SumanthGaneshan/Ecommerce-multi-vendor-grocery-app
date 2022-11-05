import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final user = FirebaseAuth.instance.currentUser;

  Future<double> getCartTotal() async {
    double subTotal = 0.0;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .get();

    snapshot.docs.forEach((doc) {
      subTotal = subTotal + (doc['product']['price'] * doc['quantity']);
    });
    print(subTotal);
    notifyListeners();
    return subTotal;
  }

  List? products;
  double? total;
  getProducts(prods, tot) {
    products = prods;
    total = tot;
    // notifyListeners();
  }
}
