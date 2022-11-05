import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:grocery_vendor_app/screens/sign_up_screen.dart';

class LogoutDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sign Out"),
      content: Text("Do you want to Sign Out"),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            ZoomDrawer.of(context)!.open();
          },
        ),
        TextButton(
          child: Text("Yes"),
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacementNamed(SignUpScreen.routeName);
          },
        ),
      ],
    );
  }
}
