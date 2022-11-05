import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/models/menu_item.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:provider/provider.dart';

class MenuItems {
  static const dashboard = MenuItemModel('DashBoard', Icons.dashboard);
  static const product = MenuItemModel('Product', Icons.shopping_bag);
  static const banner = MenuItemModel('Banner', Icons.image);
  static const orders = MenuItemModel('Orders', Icons.list_alt);
  static const settings = MenuItemModel('Setting', Icons.settings);
  static const logout = MenuItemModel('Logout', Icons.exit_to_app);

  static const all = [
    // dashboard,
    product,
    banner,
    // orders,
    // settings,
    logout,
  ];
}

class MenuPage extends StatefulWidget {
  final MenuItemModel currentItem;
  final ValueChanged<MenuItemModel> onSelectedItem;

  MenuPage(this.currentItem, this.onSelectedItem);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final user = FirebaseAuth.instance.currentUser;

  var vendorData;

  Future<void> getVendorData() async {
    var result = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(user!.uid)
        .get();
    if (mounted) {
      setState(() {
        vendorData = result;
      });
    }
  }

  @override
  initState() {
    super.initState();
    getVendorData();
    // Future.delayed(Duration(milliseconds: 1));
    // var _provider = Provider.of<ProductProvider>(context,listen: false);
    // _provider.getShopName(vendorData!=null? vendorData.data()['shopName'] : '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // SizedBox(
            //   height: 15,
            // ),
            // CircleAvatar(
            //   radius: 60,
            //   backgroundImage: vendorData != null
            //       ? NetworkImage(vendorData.data()['image'])
            //       : null,
            // ),
            Container(
              height: 140,
              width: double.infinity,
              child: Image.network(
                vendorData != null
                    ? vendorData.data()['image']
                    : 'https://t4.ftcdn.net/jpg/04/70/29/97/360_F_470299797_UD0eoVMMSUbHCcNJCdv2t8B2g1GVqYgs.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                vendorData != null
                    ? vendorData.data()['shopName']
                    : 'Shop Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ...MenuItems.all.map(buildMenuItem).toList(),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(MenuItemModel item) {
    return ListTile(
      selected: widget.currentItem == item,
      selectedTileColor: Colors.indigo.shade50,
      minLeadingWidth: 20,
      title: Text(
        item.title,
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
      leading: Icon(
        item.icon,
        size: 28,
        color: Colors.black,
      ),
      onTap: () => widget.onSelectedItem(item),
    );
  }
}
