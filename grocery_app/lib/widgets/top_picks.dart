import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app/providers/store_provider.dart';
import 'package:grocery_app/screens/vendor_home_screen.dart';
import 'package:grocery_app/services/store_services.dart';
import 'package:provider/provider.dart';

class TopPicks extends StatefulWidget {
  @override
  State<TopPicks> createState() => _TopPicksState();
}

class _TopPicksState extends State<TopPicks> {
  StoreServices stores = StoreServices();

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context,listen: false);
    store.getUserLocationData();
    return FutureBuilder<QuerySnapshot>(
      future: stores.getTopPickedStore(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //Error Handling conditions
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        //Data is output to the user
        if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              var distance = Geolocator.distanceBetween(store.userLat, store.userLong,
                  data[index]['latitude']!, data[index]['longitude']!);
              var distanceInKm = distance / 1000;
              if (distanceInKm < 10) {
                return InkWell(
                  onTap: (){
                    store.getSelectedStore(data[index]['shopName'], data[index]['uid'],data[index]['image'],data[index]['address'],data[index]['mobile']);
                    Navigator.of(context).pushNamed(VendorHomeScreen.routeName);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data[index]['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          data[index]['shopName'].length < 15?  data[index]['shopName']! : "${data[index]['shopName'].toString().substring(0,15)}...",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          '${distanceInKm.toStringAsFixed(2)}km',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                );
              }
              else{
                return Container();
              }
            },
          );
        }

        return Text("loading");
      },
    );
  }
}
