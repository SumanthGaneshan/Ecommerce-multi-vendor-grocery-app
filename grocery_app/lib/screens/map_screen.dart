import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/providers/location_provider.dart';
import 'package:grocery_app/services/user_services.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  static const routeName = 'map-screen';
  final String? title;
  final String? address;

  MapScreen({this.title,this.address});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  TextEditingController title_controller = TextEditingController();
  TextEditingController address_controller = TextEditingController();

  void submitAddress(){
    print(address_controller.text);
    final user = FirebaseAuth.instance.currentUser;
    final locationData = Provider.of<LocationProvider>(context,listen: false);
    locationData.getLangLong(address_controller.text).then((latLong){
        UserServices userServices = UserServices();
        userServices.updateUser({
          'id': user!.uid,
          'phoneNumber': user.phoneNumber,
          'latitude': latLong[0],
          'longitude': latLong[1],
          'address': address_controller.text,
          'location_title': title_controller.text,
        });
        locationData.savePrefs(latLong[0], latLong[1], address_controller.text, title_controller.text);
        Navigator.of(context).pop(true);
    });
  }
  @override
  void initState(){
    super.initState();
    if(widget.title!=null && widget.address!=null){
      setState((){
        title_controller.text = widget.title!;
        address_controller.text = widget.address!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Your Address",style: TextStyle(color: Colors.black),),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                child: Image.asset('assets/location.png'),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Please enter your current address",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                child: TextField(
                  controller: title_controller,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(

                    hintText: 'Title',
                    hintStyle: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    fillColor: Color(0xFFEEEEEE),
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                child: TextField(
                  controller: address_controller,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Address',
                    hintStyle: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    fillColor: Color(0xFFEEEEEE),
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: submitAddress,
                    child: Text(
                      'Save Address',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      // primary: Color.fromARGB(255,224, 176, 255).withOpacity(0.8),
                      onPrimary: Colors.white,
                      // shadowColor: Colors.deepPurple,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(32.0)), ////// HERE
                    ),
                  ),
                ),
              ),
            ],
        ),
      )
    );
  }
}
