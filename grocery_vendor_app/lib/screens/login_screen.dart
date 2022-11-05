
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_vendor_app/screens/drawer_main_screen.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:grocery_vendor_app/screens/sign_up_screen.dart';


class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _userPassword = '';
  var _isLoading = false;

  void _submit() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      try {
        _formKey.currentState!.save();
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        Navigator.of(context).pushReplacementNamed(DrawerMainScreen.routeName);
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        throw error;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                child: Image.asset('assets/images/login.png')
            ),
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          hintStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
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
                          prefixIcon: Icon(Icons.lock,size: 25,),
                          hintText: 'Password',
                          hintStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
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
                    SizedBox(
                      height: 15,
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
                              'LOGIN',
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
                            "Need an account?",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          TextButton(
                            child: Text(
                              "SIGN UP",
                              style: TextStyle(fontSize: 16, color: Colors.black,decoration: TextDecoration.underline),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(SignUpScreen.routeName);
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
