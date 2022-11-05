import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/store_provider.dart';
import 'package:grocery_app/screens/category_screen.dart';
import 'package:grocery_app/screens/map_screen.dart';
import 'package:grocery_app/screens/search_screen.dart';
import 'package:grocery_app/screens/sub_category_screen.dart';
import 'package:grocery_app/services/user_services.dart';
import 'package:grocery_app/widgets/image_slider.dart';
import 'package:grocery_app/widgets/near_by_stores.dart';
import 'package:grocery_app/widgets/top_picks.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? title;
  String? address;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  Future<void> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserServices _userServices = UserServices();
    DocumentSnapshot result = await _userServices.getUserById(user!.uid);
    Map<String, dynamic> data = result.data() as Map<String, dynamic>;

    if (mounted && data.containsKey('address')) {
      setState(() {
        title = result['location_title'];
        address = result['address'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _store = Provider.of<StoreProvider>(context, listen: false);
    final _cart = Provider.of<CartProvider>(context, listen: false);
    print(_cart.getCartTotal());
    final size = MediaQuery.of(context).size;
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(SearchScreen.routeName);
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.all(10),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Search for products...',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,color: Colors.black54),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () async {
                  // await locationData.getCurrentPosition();
                  // if(locationData.permissionAllowed == true){
                  // locationData.getCurrentPosition(context).then((value) {
                  if (address != null) {
                    buildBottomSheet(context);
                  } else {
                    final popResult = await Navigator.of(context)
                        .pushNamed(MapScreen.routeName);
                    if (popResult != null) {
                      getPrefs();
                      snackMessage();
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                            size: 25,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            title != null ? title! : 'Add Location',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      if (address != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                              address!.length < 40? address! : '${address!.substring(0, 40)}...',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const ImageSlider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Explore Categories",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(CategoryScreen.routeName);
                      },
                      child: Text(
                        "See More",
                        style: TextStyle(fontSize: 18, color: Colors.indigo),
                      )),
                ],
              ),
              Container(
                height: 150,
                child: FutureBuilder<QuerySnapshot>(
                  future: _store.category.get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    //Error Handling conditions
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }
                    //Data is output to the user
                    if (snapshot.connectionState == ConnectionState.done) {
                      var data = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: 7,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (ctx, index) {
                          return InkWell(
                            onTap: () {
                              _store.getSelectedCategory(
                                  data[index]['name'], data[index]['name']);
                              Navigator.of(context)
                                  .pushNamed(SubCategoryScreen.routeName)
                                  .then((value) {
                                _store.subCatName = 'all';
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.all(5),
                              width: 150,
                              child: Card(
                                color: Colors.indigo.shade50,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.indigo.shade50,
                                      backgroundImage:
                                          NetworkImage(data[index]['image']),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        data[index]['name'],
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return Text("loading");
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (address == null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 230,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image: NetworkImage(
                                  'https://miro.medium.com/max/800/1*ioO6gP78rLZ1Uk-T5v8Zgg.gif'),
                            )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 25),
                          child: Text(
                            "Set your location to locate top stores near you!!!",
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.indigo.shade900,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: size.width * 0.7,
                          height: 45,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final popResult = await Navigator.of(context)
                                  .pushNamed(MapScreen.routeName);
                              if (popResult != null) {
                                getPrefs();
                                snackMessage();
                              }
                            },
                            icon: Icon(
                              Icons.location_searching,
                              color: Colors.indigo.shade900,
                            ),
                            label: Text(
                              'Set Location',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                  color: Colors.indigo.shade900),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              side: BorderSide(
                                  width: 2, color: Colors.grey.shade200),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              if (address != null)
                const Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Top picks for you",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (address != null)
                Container(
                  height: 180,
                  child: TopPicks(),
                ),
              if (address != null) Divider(),
              if (address != null)
                const Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Text(
                    "All Nearby Stores",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (address != null)
                const Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    "Findout quality products near you",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              SizedBox(
                height: 5,
              ),
              if (address != null) NearByStore(),
            ],
          ),
        ));
  }

  Future buildBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Current Saved Address",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      title!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.indigo),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      address!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black54),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final popResult = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (ctx) => MapScreen(
                                        title: title,
                                        address: address,
                                      )));
                          if (popResult != null) {
                            getPrefs();
                            snackMessage();
                          }
                        },
                        child: Text(
                          'Edit',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  ScaffoldMessengerState snackMessage() {
    return ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Address Saved Successfully'),
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
        duration: Duration(seconds: 2),
      ));
  }
}
