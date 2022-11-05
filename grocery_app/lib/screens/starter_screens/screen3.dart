import 'package:flutter/material.dart';

class Screen3 extends StatelessWidget {
  const Screen3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          child: Image.asset('assets/delivery.gif'),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: const [
              Text(
                "Super fast door step delivery",
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
                "Track your order and get your groceries delivered to your door step",
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
