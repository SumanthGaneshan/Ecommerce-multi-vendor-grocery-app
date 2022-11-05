import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  String selectedCategory = 'not Selected';
  String selectedSubCategory = 'not Selected';
  String categoryImage = '';
  String shopName = '';
  final user = FirebaseAuth.instance.currentUser;


  void selectCategory(mainCategory, catImage) {
    selectedCategory = mainCategory;
    categoryImage = catImage;
    notifyListeners();
  }

  void selectSubCategory(selected) {
    selectedSubCategory = selected;
    notifyListeners();
  }

  Future<void> getShopName()async{
    var result = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(user!.uid)
        .get();
    shopName = result.data()!['shopName'];
  }


  Future<void> saveProductToFirestore({
    productName,
    desc,
    price,
    ogPrice,
    collection,
    brand,
    itemCode,
    weight,
    tax,
    stockQ,
    lowStockQ,
    image
  }) async {
    await getShopName();
    var timeStamp = Timestamp.now().microsecondsSinceEpoch;
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    try{
      products.doc(timeStamp.toString()).set({
        'seller': {'shopName': shopName, 'sellerUid': user!.uid},
        'sellerId': user!.uid,
        'productName': productName,
        'productDescription': desc,
        'price': price,
        'originalPrice': ogPrice,
        'collection': collection,
        'brand': brand,
        'itemCode': itemCode,
        'prodImage': image,
        'category': {
          'categoryName': selectedCategory,
          'subCategoryName': selectedSubCategory,
          'categoryImage': categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQuantity': stockQ,
        'lowStockQuantity': lowStockQ,
        'published': false,
        'productId': timeStamp.toString(),
      });
    }catch(error){
      print(error);
    }
  }
}
