import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/screens/add_new_product.dart';
import 'package:grocery_vendor_app/widgets/published_products.dart';
import 'package:grocery_vendor_app/widgets/unpublished_products.dart';

import '../widgets/menu_widget.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: MenuWidget(),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Products",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                  width: size.width * 0.4,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () async{
                      final popResult = await Navigator.of(context).pushNamed(AddNewProduct.routeName);
                      if (popResult != null) {
                        snackMessage(context);
                      }
                    },
                    icon: Icon(Icons.add),
                    label: Text(
                      'Add New',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      // primary: Color.fromARGB(255,224, 176, 255).withOpacity(0.8),
                      onPrimary: Colors.white,
                      // shadowColor: Colors.deepPurple,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)), ////// HERE
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  const TabBar(
                      unselectedLabelColor: Colors.black54,
                      labelColor: Colors.indigo,
                      labelStyle: TextStyle(fontSize: 18),
                      tabs: [
                        Tab(text: "PUBLISHED"),
                        Tab(text: "UN PUBLISHED"),
                      ]),
                  Expanded(
                    child: TabBarView(children: [
                      PublishedProducts(),
                      UnpublishedProducts(),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  ScaffoldMessengerState snackMessage(BuildContext context) {
    return ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Product Saved Successfully'),
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
        duration: Duration(seconds: 2),
      ));
  }
}
