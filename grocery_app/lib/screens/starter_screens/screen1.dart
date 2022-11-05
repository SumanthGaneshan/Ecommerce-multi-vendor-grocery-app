import 'package:flutter/material.dart';


class Screen1 extends StatelessWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          child: Image.asset('assets/grocery.gif'),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: const [
              Text(
                "Need Groceries now?",
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF01002f),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Select wide range of products from fresh fruits to delicious snacks",
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      ],
    );
  }
}
