import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/menu_widget.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = 'home-screen';

  void signOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Dashboard'),
        leading: MenuWidget(),
      ),
      body: Column(
        children: [
          Text(user!.uid),
          Center(
            child: ElevatedButton(
              child: Text('singout'),
              onPressed: signOut,
            ),
          ),
        ],
      ),
    );
  }
}
