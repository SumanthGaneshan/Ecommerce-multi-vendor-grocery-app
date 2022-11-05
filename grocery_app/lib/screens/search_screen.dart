import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/screens/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = 'search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var productsDoc;
  List products = [];

  TextEditingController controller = TextEditingController();
  Future<void> getProducts() async {
    final snapShot =
        await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      productsDoc = snapShot;
      products = snapShot.docs;
    });
    print(productsDoc!.docs[0]['productName']);
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Search Products",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: products==null? Center(child: CircularProgressIndicator(),) : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 17,
              ),
              decoration: InputDecoration(
                hintText: 'Search for products',
                hintStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value){

                print(value);
                if(value.isEmpty){
                  products = productsDoc.docs;
                }
                searchProducts(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
            itemCount: products.length,
              itemBuilder: (ctx,index){
              return ListTile(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>ProductDetailScreen(products[index])));
                },
                title: Text(products[index]['productName']),
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade50,
                  backgroundImage: NetworkImage(products[index]['prodImage']),
                ),
              );
              },
          ),),
        ],
      ),
    );
  }

  void searchProducts(String query){
    final suggestions = products.where((prod){
      final prodTitle = prod['productName'].toLowerCase();
      final input = query.toLowerCase();
      return prodTitle.contains(input);
    }).toList();
    setState((){
      products = suggestions;
    });
  }
}
