
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_services.dart';

class StoreProvider with ChangeNotifier{

  CollectionReference vendorBanner = FirebaseFirestore.instance.collection('vendorBanner');
  CollectionReference category = FirebaseFirestore.instance.collection('category');
  CollectionReference products = FirebaseFirestore.instance.collection('products');



  final user = FirebaseAuth.instance.currentUser;
  UserServices userServices = UserServices();

  var userLat = 0.0;
  var userLong = 0.0;

  String? selectedStore;
  String? selectedStoreId;
  String? selectedStoreImage;
  String? selectedStoreAddress;
  String? selectedStoreNumber;



  getSelectedStore(String storeName,String storeId,String storeImage,String address,String number){
    selectedStore = storeName;
    selectedStoreId = storeId;
    selectedStoreImage = storeImage;
    selectedStoreAddress = address;
    selectedStoreNumber = number;
    notifyListeners();
  }

  // Category variables
  String? selectedCatId;
  String? selectedCatName;
  String subCatName = 'all';

  getSelectedCategory(String id,String name){
    selectedCatId = id;
    selectedCatName = name;
    notifyListeners();
  }

  getSubCategoryName(String subName){
    subCatName = subName;
    notifyListeners();
  }
  // get location
  Future<void> getUserLocationData() async{
    userServices.getUserById(user!.uid).then((value) {
      if (user != null) {
        Map<String, dynamic> data = value.data() as Map<String, dynamic>;
            userLat = data['latitude'];
            userLong = data['longitude'];
            notifyListeners();
        }
      }
    );
  }


}