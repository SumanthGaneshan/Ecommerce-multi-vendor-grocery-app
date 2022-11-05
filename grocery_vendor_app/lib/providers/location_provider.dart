import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  late double latitude;
  late double longitude;
  late bool permissionAllowed;

  Future<List<double>> getLangLong(String address) async {
    List<Location> locations = await locationFromAddress(address);
    Location location = locations[0];
    // print(location.longitude.toString());
    // print(location.latitude.toString());
    return [location.latitude,location.longitude];

  }

  Future<void> getAddressFromLangLong(Position position) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    // print(placemarks);
    Placemark place = placemarks[0];
    final Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    print(Address);
  }

  Future<void> savePrefs(double lat,double long,String address,String add_title) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', lat);
    prefs.setDouble('longitude', long);
    prefs.setString('title', add_title);
    prefs.setString('address', address);
  }

}
