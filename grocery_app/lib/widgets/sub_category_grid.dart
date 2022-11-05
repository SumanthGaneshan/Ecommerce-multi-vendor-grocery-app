import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/store_provider.dart';
import 'package:grocery_app/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

import 'cart_counter.dart';

class SubCategoryGrid extends StatefulWidget {
  const SubCategoryGrid({Key? key}) : super(key: key);

  @override
  State<SubCategoryGrid> createState() => _SubCategoryGridState();
}

class _SubCategoryGridState extends State<SubCategoryGrid> {
  @override
  Widget build(BuildContext context) {
    final _store = Provider.of<StoreProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    return Expanded(
      child: FutureBuilder<QuerySnapshot>(
        future: _store.subCatName == 'all'
            ? _store.products
        .where('published',isEqualTo: true)
                .where('category.categoryName',
                    isEqualTo: _store.selectedCatName)
                .get()
            : _store.products
            .where('published',isEqualTo: true)
            .where('category.categoryName',
                    isEqualTo: _store.selectedCatName)
                .where('category.subCategoryName', isEqualTo: _store.subCatName)
                .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data!.docs;
            return data.isEmpty
                ? Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      width: double.infinity,
                      child: Image.asset('assets/no-prod.png'),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      String offer = ((data[index]['originalPrice'] -
                                  data[index]['price']) /
                              data[index]['originalPrice'] *
                              100)
                          .toStringAsFixed(0);
                      return InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      ProductDetailScreen(data[index])))
                              .then((value) {
                            setState(() {});
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if(int.parse(offer)  > 0)
                                Container(
                                padding: EdgeInsets.all(4),
                                // margin: EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                ),
                                child: Text(
                                  '${offer}% OFF',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 80,
                                  width: 130,
                                  child: Hero(
                                    tag: data[index]['productId'],
                                    child: Image.network(
                                      data[index]['prodImage'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Text(data[index]['brand']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Text(
                                      data[index]['weight'],
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  data[index]['productName'].length < 30
                                      ? data[index]['productName']
                                      : '${data[index]['productName'].toString().substring(0, 30)}...',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                child: Row(
                                  children: [
                                    Text(
                                      '₹${data[index]['price'].toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '₹${data[index]['originalPrice']}',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('cart')
                                    .doc(user!.uid)
                                    .collection('products')
                                    .where('product.productId',
                                        isEqualTo: data[index]['productId'])
                                    .snapshots(),
                                builder:
                                    (BuildContext ctx, AsyncSnapshot snapShot) {
                                  if (snapShot.hasError) {
                                    return Center(
                                      child: Text("Something went wrong"),
                                    );
                                  }
                                  if (snapShot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Expanded(
                                      child: Container(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  print(snapShot.data.docs);
                                  if (snapShot.data.docs.isEmpty) {
                                    return Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            EasyLoading.show(
                                                status: 'Saving...');
                                            addToCart(data[index])
                                                .then((value) {
                                              EasyLoading.showSuccess(
                                                  'Added to Cart');
                                            }).catchError((error) {
                                              EasyLoading.showError(
                                                  'Something went wrong!!!');
                                              print(error);
                                            });
                                          },
                                          child: Text(
                                            'ADD',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                                fontSize: 17),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return CartCounter(
                                        data[index]['productId']);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    });
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> addToCart(document) async {
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
