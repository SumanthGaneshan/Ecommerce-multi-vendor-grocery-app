import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor_app/providers/location_provider.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:grocery_vendor_app/screens/add_new_product.dart';
import 'package:grocery_vendor_app/screens/drawer_main_screen.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:grocery_vendor_app/screens/login_screen.dart';
import 'package:grocery_vendor_app/screens/sign_up_screen.dart';
import 'package:grocery_vendor_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, appSnapshot) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => LocationProvider()),
              ChangeNotifierProvider(create: (_) => ProductProvider()),
            ],
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                pageTransitionsTheme: const PageTransitionsTheme(builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                }),
              ),
              home: appSnapshot.connectionState != ConnectionState.done
                  ? SplashScreen()
                  : Builder(
                      builder: (ctx) {
                        final user = FirebaseAuth.instance.currentUser;
                        return user!=null? DrawerMainScreen() : SignUpScreen();
                      },
                    ),
              routes: {
                LoginScreen.routeName: (ctx) => LoginScreen(),
                SignUpScreen.routeName: (ctx) => SignUpScreen(),
                HomeScreen.routeName: (ctx) => HomeScreen(),
                AddNewProduct.routeName: (ctx) => AddNewProduct(),
                DrawerMainScreen.routeName: (ctx) => DrawerMainScreen(),

              },
              builder: EasyLoading.init(),
            ),
          );
        });
  }
}
