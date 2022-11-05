import 'package:cloud_firestore/cloud_firestore.dart';

class StoreServices {


  getTopPickedStore() {
    return FirebaseFirestore.instance
        .collection('vendors')
        .where('accVerified', isEqualTo: true)
        .where('isTopPicked', isEqualTo: true)
        .get();
  }

  getNearByStores() {
    return FirebaseFirestore.instance
        .collection('vendors')
        .where('accVerified', isEqualTo: true)
        .get();
  }
}
