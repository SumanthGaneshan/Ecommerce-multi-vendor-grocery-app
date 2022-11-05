import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/screens/auth/otp_screen.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'register-screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  String _userMobileNo = '';

  void _submit() async {
    EasyLoading.show(status: "Please wait...");
    final isValid = _formKey.currentState!.validate();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (isValid) {
      try {
        _formKey.currentState!.save();
        auth.verifyNumber(context, "+91$_userMobileNo").then((value) {
          print(_userMobileNo);
          EasyLoading.dismiss();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => OtpScreen(_userMobileNo)));
        });
      } catch (error) {
        throw error;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
          // size: 30,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Image.network(
                "https://img.freepik.com/premium-vector/secure-login-sign-up-concept-illustration-user-use-secure-login-password-protection-website-social-media-account-vector-flat-style_7737-2270.jpg?size=626&ext=jpg&ga=GA1.2.2080766150.1659539596"),
          ),
          Text(
            "Registration/Login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "An OTP will be sent to your mobile number for verification",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefix: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "+91",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        hintText: 'Enter Number',
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
                        _userMobileNo = value!;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  // if (_isLoading)
                  //   Align(
                  //     alignment: Alignment.center,
                  //     child: CircularProgressIndicator(),
                  //   ),
                  // if (!_isLoading)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: size.width * 0.9,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          'GET OTP',
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
                ],
              ))
        ]),
      ),
    );
  }
}
