import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/providers/store_provider.dart';
import 'package:grocery_app/screens/sub_category_screen.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = 'category';
  @override
  Widget build(BuildContext context) {
    final _store = Provider.of<StoreProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Shop by categories",
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.indigo.shade900,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _store.category.get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  //Error Handling conditions
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    var data = snapshot.data!.docs;
                    return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 10,
                          crossAxisSpacing: 7,
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: (){
                              _store.getSelectedCategory(data[index]['name'], data[index]['name']);
                              Navigator.of(context).pushNamed(SubCategoryScreen.routeName).then((value){
                                _store.subCatName = 'all';
                              });
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
