import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../widgets/user_image_picker.dart';
import 'drawer_main_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _businessName = '';
  String _number = '';
  String _userEmail = '';
  String _userPassword = '';
  String _address = '';
  var _isLoading = false;
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _submit() async {
    setState(() {
      _isLoading = true;
    });

    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    print('working');
    if (_userImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please pick an Image"),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      if (isValid) {
        _formKey.currentState!.save();
        final locationData =
            Provider.of<LocationProvider>(context, listen: false);
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        final ref = FirebaseStorage.instance
            .ref()
            .child('shop_images')
            .child('${userCredential.user!.uid}.jpg');

        await ref.putFile(_userImageFile!);
        final url = await ref.getDownloadURL();

        final latLong = await locationData.getLangLong(_address);

        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'shopName': _businessName,
          'mobile': _number,
          'email': _userEmail,
          'image': url,
          'address': _address,
          'latitude': latLong[0],
          'longitude': latLong[1],
          'shopOpen': true,
          'rating': 0.0,
          'totalRating': 0,
          'isTopPicked': false,
          'accVerified': true
        }).then((value){
          Navigator.of(context).pushReplacementNamed(DrawerMainScreen.routeName);
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 10,
            ),
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: UserImagePicker(_pickedImage),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your Business name';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.add_business),
                          hintText: 'Business Name',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _businessName = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length < 10) {
                            return 'Enter Valid Number';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.phone,
                            size: 25,
                          ),
                          hintText: 'Enter Mobile NUmber',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _number = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter valid email address. eg. abc@xvz.com';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Email (eg. abc@xyz.com)',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _userEmail = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'Password too short';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            size: 25,
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _userPassword = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter valid address';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Shop Address',
                          hintStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          fillColor: Color(0xFFEEEEEE),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          _address = value!;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (_isLoading)
                      Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    if (!_isLoading)
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: size.width * 0.9,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(
                              'SIGN UP',
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
                                      BorderRadius.circular(32.0)), ////// HERE
                            ),
                          ),
                        ),
                      ),
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already a user?",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          TextButton(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(LoginScreen.routeName);
                            },
                          ),
                        ],
                      ),
                  ],
                ))
          ]),
        ),
      ),
    );
  }
}
