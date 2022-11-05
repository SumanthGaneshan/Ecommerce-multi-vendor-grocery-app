import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/screens/order_confirmed.dart';
import 'package:grocery_app/services/order_services.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../services/user_services.dart';

class UserDetails extends StatefulWidget {
  static const routeName = 'user-detail';
  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  UserServices _userServices = UserServices();
  final user = FirebaseAuth.instance.currentUser;
  Razorpay? razorpay;
  late final CartProvider _cart;

  OrderServices _orderServices = OrderServices();

  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool canEdit = false;

  int selectedValue = 0;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, handlerPaymentError);
    razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _cart = Provider.of<CartProvider>(context, listen: false);
    }
  }

  void openCheckout(amount, mobile) {
    var options = {
      "key": "rzp_test_YxP3vhhtzHwCED",
      "amount": (amount * 100).toString(),
      "name": "Online Oasis",
      "description": "paying to Online Oasis",
      "prefill": {"contact": mobile.toString(), "email": ""},
      "external": {
        "wallets": ["paytm"]
      },
    };

    try {
      razorpay!.open(options);
    } catch (error) {}
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) {
    print('success');
    _orderServices
        .saveOrder(
            products: _cart.products!,
            total: _cart.total!,
            cod: false,
            mobile: phoneController.text,
            address: addressController.text,
            isPayed: true)
        .then((value) async {
      var collection = FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('products');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      EasyLoading.dismiss();
      Navigator.of(context).pushReplacementNamed(OrderConfirmed.routeName);
    });
  }

  void handlerPaymentError(PaymentFailureResponse response) {
    print('fail');
    EasyLoading.showError("Something went wrong!!!");
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    print('ext');
  }

  @override
  void dispose() {
    super.dispose();
    razorpay!.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('products')
            .get(),
        builder: (BuildContext context, AsyncSnapshot snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          double subTotal = 0.0;
          double orgTotal = 0.0;
          var data = snapShot.data!.docs;
          List products = [];
          data.forEach((doc) {
            subTotal = subTotal + (doc['product']['price'] * doc['quantity']);
            orgTotal =
                orgTotal + (doc['product']['originalPrice'] * doc['quantity']);
            // print(doc.data() as Map);
            products.add(doc.data() as Map);
          });
          _cart.getProducts(products, subTotal);
          // print(products);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              title: Text(
                "Bill Details",
                style: TextStyle(color: Colors.black),
              ),
              // elevation: 0,
            ),
            bottomSheet: Container(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Text("Sub Total"),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "₹${subTotal + 40}",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.indigo.shade700,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            EasyLoading.show(status: 'Loading...');
                            if (phoneController.text.isNotEmpty &&
                                addressController.text.isNotEmpty &&
                                selectedValue != 0) {
                              if (selectedValue == 1) {
                                _orderServices
                                    .saveOrder(
                                        products: products,
                                        total: subTotal,
                                        cod: true,
                                        mobile: phoneController.text,
                                        address: addressController.text,
                                        isPayed: false)
                                    .then((value) async {
                                  var collection = FirebaseFirestore.instance
                                      .collection('cart')
                                      .doc(user!.uid)
                                      .collection('products');
                                  var snapshots = await collection.get();
                                  for (var doc in snapshots.docs) {
                                    await doc.reference.delete();
                                  }
                                  EasyLoading.dismiss();
                                  Navigator.of(context).pushReplacementNamed(
                                      OrderConfirmed.routeName);
                                });
                              } else if (selectedValue == 2) {
                                openCheckout(subTotal + 40, user!.phoneNumber);
                              }
                            } else {
                              EasyLoading.showError('Please fill all details');
                            }
                          },
                          child: Text(
                            'Checkout',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.indigo,
                            onPrimary: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(5)), ////// HERE
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Total items: ${data.length}',
                      style: TextStyle(fontSize: 19),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data[index]['product']['productName'].length < 30? data[index]['product']['productName'] : '${data[index]['product']['productName'].toString().substring(0,30)}...',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800),
                                    ),
                                    Text(
                                      'x${data[index]['quantity']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Text(
                                  data[index]['product']['weight'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                Divider(),
                              ],
                            ),
                          );
                        }),
                  ),
                  Container(
                    // height: 150,
                    margin: EdgeInsets.all(9),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bill Details",
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Item Total",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.black),
                            ),
                            Text(
                              "₹$subTotal",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery Charges",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.black),
                            ),
                            Text(
                              "₹40",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.black),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.black),
                            ),
                            Text(
                              "₹${subTotal + 40}",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          color: Colors.indigo.shade50,
                          padding: EdgeInsets.all(5),
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Saving",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.indigo),
                              ),
                              Text(
                                "₹${orgTotal - subTotal}",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: _userServices.getUserById(user!.uid),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        var data = snapshot.data;
                        addressController.text = data!['address'];
                        phoneController.text =
                            user!.phoneNumber.toString().substring(3);
                        return Container(
                          // height: 150,
                          padding: EdgeInsets.all(14),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Your Details",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  // InkWell(
                                  //   onTap: () {
                                  //     print("hello");
                                  //     setState(() {
                                  //       canEdit = true;
                                  //     });
                                  //   },
                                  //   child: Text(
                                  //     "Edit",
                                  //     style: TextStyle(
                                  //         fontSize: 17,
                                  //         fontWeight: FontWeight.bold,
                                  //         color: Colors.green),
                                  //   ),
                                  // ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Mobile Number",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              TextField(
                                controller: phoneController,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefix: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      "+91",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  fillColor: Color(0xFFEEEEEE),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 0,
                              ),
                              Text(
                                "Deliver to this address",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: addressController,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  fillColor: Color(0xFFEEEEEE),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, top: 10),
                          child: Text(
                            "Select mode of payment",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800),
                          ),
                        ),
                        RadioListTile(
                            value: 1,
                            groupValue: selectedValue,
                            title: Text("Pay on Delivery"),
                            subtitle: Text("Pay after delivering the products"),
                            onChanged: (value) {
                              setState(() {
                                selectedValue = 1;
                              });
                            }),
                        RadioListTile(
                            value: 2,
                            groupValue: selectedValue,
                            title: Text("Online Payment"),
                            subtitle: Text("Pay with Upi,Card,etc"),
                            onChanged: (value) {
                              setState(() {
                                selectedValue = 2;
                              });
                            }),
                        SizedBox(
                          height: 60,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
