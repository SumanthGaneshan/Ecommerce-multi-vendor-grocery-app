import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../bottom_screen.dart';

class OtpScreen extends StatefulWidget {

  final String phoneNumber;
  OtpScreen(this.phoneNumber);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  int secondsRemaining = 60;
  bool enableResend = false;
  late Timer timer;
  String? otpCode;

  @override
  initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  void _resendCode() {
    Provider.of<AuthProvider>(context,listen: false).verifyNumber(context, "+91${widget.phoneNumber}").then((value) {
      setState((){
        secondsRemaining = 60;
        enableResend = false;
      });
    });
  }

  void verifyOtp(){
    EasyLoading.show(status: "Loading...");
    Provider.of<AuthProvider>(context,listen: false).verifyOtp(otpCode!,context).then((value){

    });
  }

  @override
  dispose(){
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "OTP Verification",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Enter 6 digit code number",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Verify +91${widget.phoneNumber}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          OTPTextField(
            length: 6,
            width: MediaQuery.of(context).size.width,
            fieldWidth: 55,
            style: TextStyle(
                fontSize: 19,
              color: Colors.black
            ),
            textFieldAlignment: MainAxisAlignment.spaceEvenly,
            fieldStyle: FieldStyle.box,
              onChanged: (String? pin) {
                if (pin?.length == 6) { }
              },
            onCompleted: (pin) {
              setState(()=>otpCode = pin);
            },
          ),
          SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 45,
              child: ElevatedButton(
                onPressed: verifyOtp,
                child: Text(
                  'Verify',
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 30),
          enableResend? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Didn't received code?",style: TextStyle(
                fontSize: 17
              ),),
              TextButton(
                child: Text('Resend Code',style: TextStyle(fontSize: 18),),
                onPressed: enableResend ? _resendCode : null,
              ),
            ],
          ) :
          Text(
            '$secondsRemaining sec',
            style: TextStyle(color: Colors.blue, fontSize: 20),
          ),
        ],
      ),
    );
  }

}
