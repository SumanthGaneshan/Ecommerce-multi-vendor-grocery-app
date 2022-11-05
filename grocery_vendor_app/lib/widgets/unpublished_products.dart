import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor_app/services/firebase_services.dart';

class UnpublishedProducts extends StatelessWidget {
  const UnpublishedProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      child: StreamBuilder(
        stream:
            _services.products.where('published', isEqualTo: false).where('sellerId',isEqualTo: user!.uid).snapshots(),
        builder: (ctx, AsyncSnapshot snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("Something went wrong"),
            );
          }
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            child: DataTable(
              showBottomBorder: true,
              dataRowHeight: 60,
              headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
              columns: [
                DataColumn(
                  label: Expanded(child: Text('Name')),
                ),
                DataColumn(
                  label: Text('Image'),
                ),
                DataColumn(
                  label: Text('Actions'),
                ),
              ],
              rows: _productDetails(snapShot.data),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _productDetails(QuerySnapshot snapshot) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      return DataRow(cells: [
        DataCell(Text(document['productName'].length < 15
            ? document['productName']
            : '${document['productName']}...'
            .substring(0, 15))),
        DataCell(Container(
          padding: EdgeInsets.all(5),
          child: Image.network(document['prodImage'],fit: BoxFit.cover,),
        )),
        DataCell(popUpButton(document)),
      ]);
    }).toList();

    return newList;
  }

  Widget popUpButton(data) {
    FirebaseServices _services = FirebaseServices();
    return PopupMenuButton(
      itemBuilder: (ctx) => [
        PopupMenuItem(
            value: 'publish',
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text("Publish"),
            )),
        PopupMenuItem(
            value: 'preview',
            child: ListTile(
              leading: Icon(Icons.remove_red_eye),
              title: Text("Preview"),
            )),
        PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text("Delete"),
            )),
      ],
      onSelected: (String value) {
        if(value=='publish'){
          _services.publishProduct(id: data['productId']);
        }
        if(value=='delete'){
          _services.deleteProduct(id: data['productId']);
        }
      },
    );
  }
}
