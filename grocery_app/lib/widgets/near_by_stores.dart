import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/store_provider.dart';
import '../screens/vendor_home_screen.dart';
import '../services/store_services.dart';

class NearByStore extends StatelessWidget {

  StoreServices stores = StoreServices();


  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context,listen: false);
    store.getUserLocationData();
    return FutureBuilder<QuerySnapshot>(
      future: stores.getNearByStores(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        //Data is output to the user
        if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data!.docs;
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
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
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        width: 130,
                        margin: EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            data[index]['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                                data[index]['shopName'].length < 20?  data[index]['shopName']! : "${data[index]['shopName'].toString().substring(0,20)}...",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              '${data[index]['address'].toString().substring(0,35)}...',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black54),
                            ),
                          ),
                          SizedBox(
                            height: 5,
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
