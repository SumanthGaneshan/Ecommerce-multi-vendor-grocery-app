import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/screens/product_detail_screen.dart';

class WishList extends StatelessWidget {
  static const routeName = 'wish-list';
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Your Wishlist",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('wishlists')
              .where('customerId', isEqualTo: user!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var data = snapshot.data!.docs;
            print(data);
            print('1');
            return data.isEmpty
                ? Center(
                    child: Text("No Products Added!!!",style: TextStyle(fontSize: 22,color: Colors.indigo,fontWeight: FontWeight.bold),),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (ctx, index) {
                      String offer = ((data[index]['product']['originalPrice'] -
                                  data[index]['product']['price']) /
                              data[index]['product']['originalPrice'] *
                              100)
                          .toStringAsFixed(0);
                      return InkWell(
                        onTap: () {
                          // Navigator.of(context)
                          //     .push(MaterialPageRoute(
                          //         builder: (ctx) =>
                          //             ProductDetailScreen(snapshot.data!.docs[0]['product'])))
                          //     .then((value) {
                          //   // setState(() {});
                          // });
                        },
                        child: Card(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        margin: const EdgeInsets.only(left: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          '$offer% OFF',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        height: 120,
                                        width: 150,
                                        margin: const EdgeInsets.all(10),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(30)),
                                          child: Image.network(
                                            data[index]['product']
                                                ['prodImage'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data[index]['product']['brand']),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          data[index]['product']['productName']
                                                      .length <
                                                  40
                                              ? data[index]['product']
                                                  ['productName']
                                              : '${data[index]['product']['productName'].toString().substring(0, 40)}...',
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
                                            '${data[index]['product']['price']}₹',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.green),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            '${data[index]['product']['originalPrice']}₹',
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            data[index]['product']['weight'],
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
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height: 30,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            EasyLoading.show(
                                                status: 'Deleting...');
                                            FirebaseFirestore.instance
                                                .collection('wishlists')
                                                .doc(snapshot
                                                    .data!.docs[index].id)
                                                .delete()
                                                .then((value) {
                                              EasyLoading.showSuccess(
                                                  'Deleted');
                                            });
                                          },
                                          icon: Icon(Icons.delete),
                                          label: Text(
                                            'Delete',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)), ////// HERE
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
          }),
    );
  }
}
