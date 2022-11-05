import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/widgets/add_to_cart.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = 'detail-screen';
  final DocumentSnapshot document;
  ProductDetailScreen(this.document);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final size = MediaQuery.of(context).size;
    String offer = ((document['originalPrice'] - document['price']) /
            document['originalPrice'] *
            100)
        .toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          document['productName'],
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      bottomSheet: Container(
        // color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      EasyLoading.show(status: 'Saving...');
                      saveWishlist().then((value) {
                        EasyLoading.showSuccess('Saved to Wishlist');
                      }).catchError((error) {
                        EasyLoading.showError('Something went wrong!!!');
                        print(error);
                      });
                    },
                    child: Text(
                      'Add to wishlist',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey.shade300,
                      onPrimary: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)), ////// HERE
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              AddToCart(document),

            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: size.height * 0.37,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33),
                  bottomRight: Radius.circular(33),
                ),
                color: Colors.indigo.shade50, //Color(0xFFFECEFF1)
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Hero(
                  tag: document['productId'],
                  child: Image.network(
                    document['prodImage'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                document['brand'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      document['productName'],
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                document['weight'],
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Text(
                    "₹${document['price']}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.green),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text(
                    "₹${document['originalPrice']}",
                    style: TextStyle(
                        decoration: TextDecoration.lineThrough, fontSize: 20),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  if(int.parse(offer)  > 0)
                    Container(
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${offer}% OFF',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Product Description',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ExpandableText(
                document['productDescription'],
                expandText: 'View more',
                collapseText: 'View less',
                style: TextStyle(fontSize: 17, color: Colors.black54),
              ),
            ),
            Divider(),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Other Product Info',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Seller: ${document['seller']['shopName']}',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Category: ${document['category']['categoryName']}',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Collection: ${document['collection']}',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
            SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference wishlists =
        FirebaseFirestore.instance.collection('wishlists');

    await wishlists.add({
      'product': document.data() as Map<String, dynamic>,
      'customerId': user!.uid,
    });
  }
}
