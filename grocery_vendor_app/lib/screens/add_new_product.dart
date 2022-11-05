import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/category_list.dart';
import '../widgets/user_image_picker.dart';

class AddNewProduct extends StatefulWidget {
  static const routeName = 'add-product';

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  final _formKey = GlobalKey<FormState>();

  String prodName = '';
  String prodDesc = '';
  double prodPrice = 0.0;
  double originalPrice = 0.0;
  String itemCode = '';
  String productWeight = '';
  double prodTax = 0.0;
  int stockQuantity = 0;

  List<String> _collections = [
    'Featured Products',
    'Best Selling',
    'Recently Added',
  ];

  String? dropDownValue;

  TextEditingController _catController = TextEditingController();
  TextEditingController _subController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _lowStockController = TextEditingController();

  File? _userImageFile;
  final user = FirebaseAuth.instance.currentUser;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  bool _visible = false;

  void _submit() async {

    EasyLoading.show(status: 'Saving...');
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_userImageFile == null) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please pick an Image"),
        ),
      );
      return;
    }
    try {
      if (isValid) {
        _formKey.currentState!.save();
        final _provider = Provider.of<ProductProvider>(context, listen: false);
        var timeStamp = Timestamp.now().microsecondsSinceEpoch;

        final ref = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${user!.uid}$timeStamp.png');

        await ref.putFile(_userImageFile!);
        final url = await ref.getDownloadURL();

        await _provider.saveProductToFirestore(
          productName: prodName,
          desc: prodDesc,
          price: prodPrice,
          ogPrice: originalPrice,
          collection: dropDownValue,
          brand: _brandController.text,
          itemCode: itemCode,
          weight: productWeight,
          tax: prodTax,
          stockQ: stockQuantity,
          lowStockQ: int.parse(_lowStockController.text),
          image: url,
        ).then((value) {
          EasyLoading.dismiss();
          Navigator.of(context).pop(true);
        });


        // setState((){
        //   _formKey.currentState!.reset();
        //   _catController.clear();
        //   _subController.clear();
        //   _brandController.clear();
        //   _lowStockController.clear();
        //   _userImageFile = null;
        //   dropDownValue = null;
        // });
      } else {
        EasyLoading.dismiss();

      }
    } catch (error) {
      print(error);
      EasyLoading.dismiss();

    }
  }

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<ProductProvider>(context, listen: false);

    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                color: Colors.indigo.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Product",
                      style: TextStyle(fontSize: 20),
                    ),
                    Container(
                      width: size.width * 0.4,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(Icons.save),
                        label: Text(
                          'Save',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          // primary: Color.fromARGB(255,224, 176, 255).withOpacity(0.8),
                          onPrimary: Colors.white,
                          // shadowColor: Colors.deepPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(5.0)), ////// HERE
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: UserImagePicker(_pickedImage),
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Product name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          prodName = value!;
                        },
                        decoration: InputDecoration(
                            hintText: 'Product Name',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Product Detail';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          prodDesc = value!;
                        },
                        decoration: InputDecoration(
                            hintText: 'Product Description',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Product price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          prodPrice = double.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Price',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Product original price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          originalPrice = double.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Original Price',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Collection',
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.black54,
                              ),
                            ),
                            DropdownButton(
                              hint: Text('Select Collection'),
                              value: dropDownValue,
                              icon: Icon(Icons.keyboard_arrow_down),
                              onChanged: (String? value) {
                                setState(() {
                                  dropDownValue = value;
                                });
                              },
                              items: _collections.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _brandController,
                        decoration: InputDecoration(
                            hintText: 'Brand',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter item code';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          itemCode = value!;
                        },
                        decoration: InputDecoration(
                            hintText: 'Item Code',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: _catController,
                              decoration: InputDecoration(
                                  hintText: 'Not Selected',
                                  labelStyle: TextStyle(color: Colors.black54),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  )),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return CategoryList();
                                  }).whenComplete(() {
                                setState(() {
                                  _catController.text =
                                      _provider.selectedCategory;
                                  _visible = true;
                                });
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: _visible,
                        child: Row(
                          children: [
                            Text(
                              'Sub Category',
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                controller: _subController,
                                decoration: InputDecoration(
                                    hintText: 'Not Selected',
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    )),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return SubCategory();
                                    }).whenComplete(() {
                                  setState(() {
                                    _subController.text =
                                        _provider.selectedSubCategory;
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter measurements';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          productWeight = value!;
                        },
                        decoration: InputDecoration(
                            hintText: 'Weight (eg: kg,gm,etc)',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Product tax';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          prodTax = double.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Tax %',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Stock Quantity';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          stockQuantity = int.parse(value!);
                        },
                        decoration: InputDecoration(
                            hintText: 'Enter Stock Quantity',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _lowStockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Inventory low stock quantity',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ));
  }
}
