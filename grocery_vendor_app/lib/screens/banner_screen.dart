import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';

import '../widgets/menu_widget.dart';
import '../widgets/user_image_picker.dart';

class BannerScreen extends StatefulWidget {
  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  File? _userImageFile;
  final user = FirebaseAuth.instance.currentUser;
  FirebaseServices _services = FirebaseServices();

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _submit(BuildContext ctx) async {
    EasyLoading.show(status: 'Saving...');
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
      var timeStamp = Timestamp.now().microsecondsSinceEpoch;

      final ref = FirebaseStorage.instance
          .ref()
          .child('banner_images')
          .child('${user!.uid}$timeStamp.jpg');

      await ref.putFile(_userImageFile!);
      final url = await ref.getDownloadURL();
      // add to firestore
      await _services.saveBanner(url, user!.uid);
      EasyLoading.dismiss();
      Navigator.of(ctx).pop();
    } catch (error) {
      EasyLoading.dismiss();
    }
  }

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
        centerTitle: true,
        title: Text(
          "Uploaded Banners",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                        child: Container(
                          height: size.height * 0.5,
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        'Add New Banner',
                                        style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: UserImagePicker(_pickedImage),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Container(
                                width: size.width * 0.6,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _submit(ctx);
                                  },
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    // primary: Color.fromARGB(255,224, 176, 255).withOpacity(0.8),
                                    onPrimary: Colors.white,
                                    // shadowColor: Colors.deepPurple,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5.0)), ////// HERE
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
            },
            icon: Icon(
              Icons.add,
              size: 28,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _services.vendorBanner
            .where('sellerId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (ctx, AsyncSnapshot snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            // physics: NeverScrollableScrollPhysics(), ///
            // shrinkWrap: true,
            itemCount: snapShot.data.docs.length,
            itemBuilder: (ctx, index) {
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 230,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            snapShot.data.docs[index]['url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 15,
                        child: CircleAvatar(
                          child: PopupMenuButton(
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: Text("Delete"),
                                  )),
                            ],
                            onSelected: (String value) {
                              if (value == 'delete') {
                                EasyLoading.show(status: 'Deleting...');
                                _services.deleteBanner(snapShot.data!.docs[index].id);
                                EasyLoading.dismiss();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider()
                ],
              );
            },
          );
        },
      ),
    );
  }
}
