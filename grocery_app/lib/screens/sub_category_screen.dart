import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/providers/store_provider.dart';
import 'package:grocery_app/widgets/sub_category_grid.dart';
import 'package:provider/provider.dart';

class SubCategoryScreen extends StatefulWidget {
  static const routeName = 'sub-cat';
  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    final _store = Provider.of<StoreProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          _store.selectedCatName!,
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Column(children: [
        SizedBox(
          height: 70,
          child: FutureBuilder<QuerySnapshot>(
            future: _store.category
                .where('name', isEqualTo: _store.selectedCatName)
                .get(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                var data = snapshot.data!.docs;
                List<dynamic> subCatList = data[0]['subCat'];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          _store.getSubCategoryName('all');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey)),
                          alignment: Alignment.center,
                          child: Text(
                            'All',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.indigo.shade800),
                          ),
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: subCatList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            return InkWell(
                              onTap: () {
                                // setState(() {
                                //   subCatName = subCatList[index]['name'];
                                // });
                                _store.getSubCategoryName(
                                    subCatList[index]['name']);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey)),
                                alignment: Alignment.center,
                                child: Text(
                                  subCatList[index]['name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.indigo.shade800),
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                );
              }

              return const Text("loading");
            },
          ),
        ),
        const SubCategoryGrid(),
      ]),
    );
  }
}
