import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/screens/map_screen.dart';
import 'package:grocery_app/screens/order_history.dart';
import 'package:grocery_app/screens/orders_screen.dart';
import 'package:grocery_app/screens/starter_screens/starter_screen.dart';
import 'package:grocery_app/screens/wish_list.dart';
import 'package:grocery_app/services/user_services.dart';

class ProfileScreen extends StatelessWidget {
  UserServices _userServices = UserServices();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
        backgroundColor: Colors.indigo.shade50,
        body: FutureBuilder(
            future: _userServices.getUserById(user!.uid),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          "My Profile",
                          style: TextStyle(
                              fontSize: 27,
                              color: Colors.indigo.shade900,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        // height: 150,
                        margin: EdgeInsets.all(12),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mobile Number",
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              user.phoneNumber.toString(),
                              style:
                                  TextStyle(fontSize: 19, color: Colors.black),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Address Saved",
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                            Text(
                              data.containsKey('address')? data['address'] : "address not set",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (ctx) => MapScreen(
                                                  title: snapshot
                                                      .data!['location_title'],
                                                  address:
                                                      snapshot.data!['address'],
                                                )));
                                  },
                                  child: Text(
                                    'Change Address',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            onTap: (){
                              Navigator.of(context).pushNamed(OrderHistory.routeName);
                            },
                            leading: Icon(Icons.shopping_basket),
                            title: Text(
                              "My Orders",
                              style: TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            onTap: (){
                              Navigator.of(context).pushNamed(WishList.routeName);
                            },
                            leading: Icon(Icons.event_note_sharp),
                            title: Text(
                              "Wishlist",
                              style: TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>OrdersScreen()));
                            },
                            leading: Icon(Icons.shopping_cart),
                            title: Text(
                              "Cart",
                              style: TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            onTap: () {
                              showAlertDialog(context);
                            },
                            leading: Icon(Icons.exit_to_app),
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        Navigator.of(context).pop();
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed(StarterScreen.routeName);
      },
    );

    Widget noButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Do you want to Logout?"),
      actions: [
        noButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
