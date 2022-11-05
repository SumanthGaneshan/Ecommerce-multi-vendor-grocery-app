import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'cart_counter.dart';


class AddToCart extends StatelessWidget {

  final DocumentSnapshot document;
  AddToCart(this.document);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('cart').doc(user!.uid).collection('products').where('product.productId',isEqualTo: document['productId']).snapshots(),
      builder: (BuildContext ctx, AsyncSnapshot snapShot){
        if (snapShot.hasError) {
          return Center(
            child: Text("Something went wrong"),
          );
        }
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Expanded(
            child: Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator()),
          );
        }
        print(snapShot.data.docs);
        if(snapShot.data.docs.isEmpty){
          return Expanded(
            child: Container(
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  EasyLoading.show(status: 'Saving...');
                  addToCart().then((value) {
                    EasyLoading.showSuccess('Added to Cart');
                  }).catchError((error) {
                    EasyLoading.showError('Something went wrong!!!');
                    print(error);
                  });
                },
                icon: Icon(Icons.shopping_cart),
                label: Text(
                  'Add to Cart',
                  style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red.shade400,
                  onPrimary: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(30.0)), ////// HERE
                ),
              ),
            ),
          );
        }
        else{
          return Expanded(child: CartCounter(document['productId']));
        }
      },
    );

  }

  Future<void> addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference cart = FirebaseFirestore.instance.collection('cart');

    await cart.doc(user!.uid).set({
      'user': user.uid,
    });

    await cart.doc(user.uid).collection('products').add({
      'product': document.data() as Map<String, dynamic>,
      'quantity': 1,
    });
  }
}
