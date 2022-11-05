import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:grocery_vendor_app/models/menu_item.dart';
import 'package:grocery_vendor_app/screens/home_screen.dart';
import 'package:grocery_vendor_app/screens/product_screen.dart';
import 'package:grocery_vendor_app/widgets/logout_dialog.dart';
import 'package:grocery_vendor_app/widgets/menu_page.dart';

import 'banner_screen.dart';

class DrawerMainScreen extends StatefulWidget {
  static const routeName = 'drawer-screen';

  @override
  State<DrawerMainScreen> createState() => _DrawerMainScreenState();
}

class _DrawerMainScreenState extends State<DrawerMainScreen> {

  MenuItemModel currentItem = MenuItems.product;

  Future<void> logOut()async{
    await FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade200,
      body: ZoomDrawer(
          borderRadius: 24.0,
          showShadow: false,
          angle: 0.0,
          slideWidth: MediaQuery.of(context).size.width * 0.65,
          menuScreen: Builder(
            builder: (context) {
              return MenuPage(
                  currentItem,
                  (item){
                    setState((){
                      currentItem = item;
                    });
                    ZoomDrawer.of(context)!.close();
                  }
              );
            }
          ), mainScreen: getScreen()!),
    );
  }
  Widget? getScreen(){
    switch(currentItem){
      case MenuItems.dashboard:
        return HomeScreen();
      case MenuItems.product:
        return ProductScreen();
      case MenuItems.banner:
        return BannerScreen();
      case MenuItems.logout:
        return LogoutDialog();
    }
    return null;
  }
}
