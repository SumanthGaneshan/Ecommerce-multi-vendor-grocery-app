
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices{

  CollectionReference category = FirebaseFirestore.instance.collection('category');
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  CollectionReference vendorBanner = FirebaseFirestore.instance.collection('vendorBanner');



  Future<void> publishProduct({id}) async{
    return products.doc(id).update({
      'published': true
    });
  }

  Future<void> unPublishProduct({id}) async{
    return products.doc(id).update({
      'published': false
    });
  }

  Future<void> deleteProduct({id}) async{
    return products.doc(id).delete();
  }

  Future<void> saveBanner(url,id) async{
    await vendorBanner.add({
      'url': url,
      'sellerId': id
    });
  }

  Future<void> deleteBanner(id) async{
    await vendorBanner.doc(id).delete();
  }
}