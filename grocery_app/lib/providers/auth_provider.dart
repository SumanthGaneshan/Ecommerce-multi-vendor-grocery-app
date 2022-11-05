import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/screens/bottom_screen.dart';
import '../services/user_services.dart';

class AuthProvider with ChangeNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String smsOtp;
  late String verificationId;
  UserServices _userserivce = UserServices();


  Future<void> verifyNumber(BuildContext ctx, String number) async{

    final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async{
      await _auth.signInWithCredential(credential);
    };
    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) async{
      print(e.code);
    };
    final PhoneCodeSent codeSent = (String verificationId, int? resendToken) async{
      this.verificationId = verificationId;

    };

    try{
      await _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        timeout: Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }catch(error){

    }
  }
  Future<void> verifyOtp(String smsOtp,BuildContext ctx) async{
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsOtp);

    // Sign the user in (or link) with the credential
    await _auth.signInWithCredential(credential).then((user) async{
      QuerySnapshot result = await FirebaseFirestore.instance.collection('users').where('id',isEqualTo: user.user!.uid).get();
      // Map<String, dynamic> resultMap = result.data() as Map<String, dynamic>;
      if(result.size==0) {
        await _userserivce.createUser({
          'id': user.user!.uid,
          'phoneNumber': user.user!.phoneNumber,
        });
      }
      EasyLoading.dismiss();
      Navigator.of(ctx).pushNamedAndRemoveUntil(BottomScreen.routeName, (Route<dynamic> route) => false);

    }).catchError((error){
    });
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }

}