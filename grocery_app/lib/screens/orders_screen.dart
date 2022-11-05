import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/widgets/cart_counter.dart';
import 'package:grocery_app/widgets/user_details.dart';

import 'bottom_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final user = FirebaseAuth.instance.currentUser;



  String address = '';
  String number = '';


  @override
  Widget build(BuildContext context) {
    number = user!.phoneNumber.toString();
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('products')
            .snapshots(),
        builder: (BuildContext ctx, AsyncSnapshot snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if(snapShot.data.size == 0){
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: double.infinity,
                  child: Image.asset('assets/empty-cart.png'),
                ),
                // SizedBox(
                //   height: 30,
                // ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.of(context).pushNamed(BottomScreen.routeName);
                      },
                      child: Text(
                        'Explore',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo,
                        onPrimary: Colors.white,
                        // shadowColor: Colors.deepPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(32.0)), ////// HERE
                      ),
                    ),
                  ),
                ),

              ],
            );
          }
          double subTotal = 0.0;
          double orgTotal = 0.0;
          var data = snapShot.data!.docs;
          data.forEach((doc) {
            subTotal = subTotal + (doc['product']['price'] * doc['quantity']);
            orgTotal =
                orgTotal + (doc['product']['originalPrice'] * doc['quantity']);
          });
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Review Cart",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.indigo.shade900,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(4.0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 90,
                                      margin: EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        child: Image.network(
                                          data[index]['product']['prodImage'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: 120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Text(
                                            data[index]['product']
                                                ['productName'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade800),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '${data[index]['product']['price']}₹',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.green),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                data[index]['product']
                                                    ['weight'],
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${data[index]['product']['originalPrice']}₹',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CartCounter(
                                        data[index]['product']['productId']),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pushNamed(UserDetails.routeName);
                        },
                        child: Text(
                          'Proceed to Bill details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.indigo,
                          onPrimary: Colors.white,
                          // shadowColor: Colors.deepPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(32.0)), ////// HERE
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
