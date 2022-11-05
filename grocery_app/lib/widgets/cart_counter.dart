import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartCounter extends StatefulWidget {
  final String productId;
  CartCounter(this.productId);

  @override
  State<CartCounter> createState() => _CartCounterState();
}

class _CartCounterState extends State<CartCounter> {
  final user = FirebaseAuth.instance.currentUser;
  int? count;
  var data;

  Future<void> getCount() async {
    var snap = await FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('product.productId', isEqualTo: widget.productId)
        .get();
    setState(() {
      data = snap.docs;
      count = data[0]['quantity'];
    });
  }

  @override
  void initState() {
    super.initState();
    getCount();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                count = count! - 1;
                updateQuantity();
              });
            },
            child: Card(
              elevation: 3,
              child: Container(
                height: 35,
                width: 35,
                // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                alignment: Alignment.center,
                child: count == 1
                    ? Icon(Icons.delete,color: Colors.red,)
                    : Text(
                        "-",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
          Container(
            height: 30,
            width: 30,
            // margin: EdgeInsets.symmetric(horizontal: 3),
            // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            alignment: Alignment.center,
            child: Text(
              count == null ? '...' : count.toString(),
              style: TextStyle(fontSize: 18),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                count = count! + 1;
                updateQuantity();
              });
            },
            child: Card(
              elevation: 3,
              child: Container(
                height: 35,
                width: 35,
                alignment: Alignment.center,
                // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                child: Text(
                  "+",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateQuantity() async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('product.productId', isEqualTo: widget.productId)
        .get()
        .then((product) {
      if (count! < 1) {
        FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('products')
            .doc(product.docs[0].id)
            .delete();
        setState(() {
          count = 0;
        });
      } else {
        FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('products')
            .doc(product.docs[0].id)
            .update({
          'quantity': count,
        });
      }
    });
  }
}
