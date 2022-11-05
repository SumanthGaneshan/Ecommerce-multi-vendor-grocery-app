import 'package:flutter/material.dart';
import 'package:grocery_app/screens/auth/register_screen.dart';

class LogoScreen extends StatelessWidget {
  static const routeName = 'logo-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            // height: MediaQuery.of(context).size.height * 0.6,
            // width: double.infinity,
            child: Image.asset(
                'assets/online_oasis.jpg'),
          ),
          Text(
            "Let's get started",
            style: TextStyle(
              fontSize: 28,
              color: Color(0xFF01002f),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Create a account or login to your account",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>RegisterScreen()));
              },
              child: Text(
                'Create Account/Login',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF5990FB),
                onPrimary: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)), ////// HERE
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Container(
          //   width: MediaQuery.of(context).size.width * 0.9,
          //   height: 50,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>RegisterScreen()));
          //     },
          //     child: Text(
          //       'Login',
          //       style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       primary: Colors.white,
          //       onPrimary: Color(0xFF5990FB),
          //       elevation: 10,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30.0)), ////// HERE
          //     ),
          //   ),
          // ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
