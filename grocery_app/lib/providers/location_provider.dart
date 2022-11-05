import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  late double latitude;
  late double longitude;
  late bool permissionAllowed;

  Future<void> getCurrentPosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Location services are not enabled don't continue
    //   // accessing the position and request users of the
    //   // App to enable the location services.
    //   return Future.error('Location services are disabled.');
    // }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;
      permissionAllowed = true;
      notifyListeners();
    } else {
      print('permission not allowed');
    }
  }

  Future<List<double>> getLangLong(String address) async {
    List<Location> locations =
        await locationFromAddress(address);
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
