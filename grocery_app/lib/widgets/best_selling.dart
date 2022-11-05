import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../screens/product_detail_screen.dart';
import 'cart_counter.dart';

class BestSelling extends StatefulWidget {
  const BestSelling({Key? key}) : super(key: key);

  @override
  State<BestSelling> createState() => _BestSellingState();
}

class _BestSellingState extends State<BestSelling> {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder(
        future: store.products
            .where('sellerId', isEqualTo: store.selectedStoreId!)
            .where('published', isEqualTo: true)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //Error Handling conditions
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data!.docs;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.isNotEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.only(left: 15, top: 15, bottom: 5),
                    child: Text(
                      "Shop your daily necessary",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (data.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 15),
                    child: Text(
                      "Checkout large variety of products",
                      style: TextStyle(fontSize: 17, color: Colors.black38),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (ctx, index) {
                    String offer =
                        ((data[index]['originalPrice'] - data[index]['price']) /
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(int.parse(offer)  > 0)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    margin: const EdgeInsets.only(left: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      '$offer% OFF',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    height: 90,
                                    width: 120,
                                    margin: const EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(30)),
                                      child: Hero(
                                        tag: data[index]['productId'],
                                        child: Image.network(
                                          data[index]['prodImage'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data[index]['brand']),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      data[index]['productName'].length < 40? data[index]['productName'] : '${data[index]['productName'].toString().substring(0,40)}...',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${data[index]['price']}₹',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.green),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Text(
                                        '${data[index]['originalPrice']}₹',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        data[index]['weight'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('cart')
                                        .doc(user!.uid)
                                        .collection('products')
                                        .where('product.productId',
                                            isEqualTo: data[index]
                                                ['productId'])
                                        .snapshots(),
                                    builder: (BuildContext ctx,
                                        AsyncSnapshot snapShot) {
                                      if (snapShot.hasError) {
                                        return const Center(
                                          child: Text("Something went wrong"),
                                        );
                                      }
                                      if (snapShot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                            alignment: Alignment.center,
                                            child:
                                            const CircularProgressIndicator());
                                      }
                                      if (snapShot.data.docs.isEmpty) {
                                        return Align(
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                              child: const Text(
                                                'ADD',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
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
                              )
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return Container();
          }
        });
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
