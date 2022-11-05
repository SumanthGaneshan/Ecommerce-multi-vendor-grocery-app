import 'package:flutter/material.dart';
import 'package:grocery_app/screens/auth/logo_screen.dart';
import 'package:grocery_app/screens/starter_screens/screen1.dart';
import 'package:grocery_app/screens/starter_screens/screen2.dart';
import 'package:grocery_app/screens/starter_screens/screen3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StarterScreen extends StatefulWidget {
  static const routeName = 'starter';

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> {
  PageController _controller = PageController();
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (pageNo) {
              setState(() {
                isLastPage = (pageNo == 2);
              });
            },
            children: [
              Screen1(),
              Screen2(),
              Screen3(),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: SlideEffect(
                      spacing: 8.0,
                      radius: 4.0,
                      dotWidth: 24.0,
                      dotHeight: 10.0,
                      // paintStyle:  PaintingStyle.stroke,
                      // strokeWidth:  1.5,
                      dotColor: Colors.grey,
                      activeDotColor: Colors.indigo),
                ),
                isLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(LogoScreen.routeName);
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: Duration(milliseconds: 250),
                              curve: Curves.easeIn);
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Container(
          //       width: MediaQuery.of(context).size.width * 0.9,
          //       height: 50,
          //       child: ElevatedButton(
          //         onPressed: () {},
          //         child: Text(
          //           'Register Now',
          //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          //         ),
          //         style: ElevatedButton.styleFrom(
          //           primary: Color(0xFFE4E7FF),
          //           onPrimary: Color(0xFF3E68FF),
          //           // shadowColor: Colors.deepPurple,
          //           elevation: 0,
          //           shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(5.0)), ////// HERE
          //         ),
          //       ),
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text("Already an User?",style: TextStyle(
          //           fontSize: 17
          //         ),),
          //         TextButton(
          //           child: Text("LOGIN",style: TextStyle(
          //               fontSize: 17,
          //             color: Color(0xFF3E68FF),
          //             fontWeight: FontWeight.bold
          //           ),),
          //           onPressed: () {},
          //         ),
          //       ],
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }
}
