import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/location_provider.dart';
import 'package:grocery_app/providers/store_provider.dart';
import 'package:grocery_app/screens/auth/logo_screen.dart';
import 'package:grocery_app/screens/auth/register_screen.dart';
import 'package:grocery_app/screens/bottom_screen.dart';
import 'package:grocery_app/screens/category_screen.dart';
import 'package:grocery_app/screens/home_screen.dart';
import 'package:grocery_app/screens/map_screen.dart';
import 'package:grocery_app/screens/order_confirmed.dart';
import 'package:grocery_app/screens/order_history.dart';
import 'package:grocery_app/screens/product_detail_screen.dart';
import 'package:grocery_app/screens/search_screen.dart';
import 'package:grocery_app/screens/splash_screen.dart';
import 'package:grocery_app/screens/starter_screens/starter_screen.dart';
import 'package:grocery_app/screens/sub_category_screen.dart';
import 'package:grocery_app/screens/vendor_home_screen.dart';
import 'package:grocery_app/screens/wish_list.dart';
import 'package:grocery_app/widgets/user_details.dart';
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
        future: _initialization,
        builder: (context, appSnapshot) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_)=>AuthProvider()),
              ChangeNotifierProvider(create: (_)=>LocationProvider()),
              ChangeNotifierProvider(create: (_)=>StoreProvider()),
              ChangeNotifierProvider(create: (_)=>CartProvider()),

            ],
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                pageTransitionsTheme: const PageTransitionsTheme(builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                }),
              ),
              routes: {
                LogoScreen.routeName: (ctx)=> LogoScreen(),
                RegisterScreen.routeName: (ctx) => RegisterScreen(),
                HomeScreen.routeName: (ctx)=> HomeScreen(),
                MapScreen.routeName: (ctx)=> MapScreen(),
                VendorHomeScreen.routeName: (ctx)=> VendorHomeScreen(),
                CategoryScreen.routeName: (ctx)=> CategoryScreen(),
                BottomScreen.routeName: (ctx)=> BottomScreen(),
                SubCategoryScreen.routeName: (ctx)=> SubCategoryScreen(),
                UserDetails.routeName: (ctx)=> UserDetails(),
                OrderConfirmed.routeName: (ctx)=> OrderConfirmed(),
                WishList.routeName: (ctx)=> WishList(),
                OrderHistory.routeName: (ctx)=> OrderHistory(),
                SearchScreen.routeName: (ctx)=> SearchScreen(),
                StarterScreen.routeName: (ctx)=> StarterScreen(),

              },
              builder: EasyLoading.init(),
              home: appSnapshot.connectionState != ConnectionState.done
                  ? SplashScreen()
              :Builder(
                builder: (ctx) {
                  final user = FirebaseAuth.instance.currentUser;
                  return user!=null? BottomScreen() : StarterScreen();
                },
              ),
            ),
          );
        });
  }
}
