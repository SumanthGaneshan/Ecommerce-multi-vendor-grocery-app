import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/providers/product_provider.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    var _provider = Provider.of<ProductProvider>(context, listen: false);
    return Dialog(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black54,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: _services.category.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
              if (snapShot.hasError) {
                return Center(
                  child: Text('Something went wrong'),
                );
              }
              if (snapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Expanded(
                child: ListView(
                  children: snapShot.data!.docs.map(
                    (DocumentSnapshot document) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: document.data() != null
                              ? NetworkImage(document['image'])
                              : null,
                        ),
                        title: Text(document['name']),
                        onTap: () {
                          _provider.selectCategory(document['name'],document['image']);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ).toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class SubCategory extends StatelessWidget {
  const SubCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    var _provider = Provider.of<ProductProvider>(context, listen: false);

    return Dialog(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Select Sub Category',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black54,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: _services.category.doc(_provider.selectedCategory).get(),
            builder:
                (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapShot) {
              if (snapShot.hasError) {
                return Center(
                  child: Text('Something went wrong'),
                );
              }
              if (snapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              // var data = snapShot.data();
              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Main Category:',
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Container(
                          width: 160,
                          child: Text(
                            _provider.selectedCategory,
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          itemCount: snapShot.data!['subCat'].length,
                          itemBuilder: (ctx,index){
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade50,
                                child: Text('${index+1}'),
                              ),
                              title: Text(snapShot.data!['subCat'][index]['name']),
                              onTap: (){
                                  _provider.selectSubCategory(snapShot.data!['subCat'][index]['name']);
                                  Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

