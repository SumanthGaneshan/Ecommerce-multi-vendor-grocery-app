import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class OrderHistoryItem extends StatefulWidget {

  final QueryDocumentSnapshot<Object?> orderItem;
  OrderHistoryItem(this.orderItem);

  @override
  State<OrderHistoryItem> createState() => _OrderHistoryItemState();
}

class _OrderHistoryItemState extends State<OrderHistoryItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return  AnimatedContainer(
      duration: Duration(milliseconds: 150),
      height: _expanded? min(widget.orderItem['products'].length * 40.0 + 110, 300) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: (){
                setState(() {
                  _expanded = !_expanded;
                });
              },
              title: Text("Order Value - ₹${(widget.orderItem['total'] + 40).toStringAsFixed(2)}"),
              subtitle: Text(DateFormat("dd/MM/yyyy hh:mm").format(DateTime.parse(widget.orderItem['timestamp']))),
              trailing: IconButton(
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            if(_expanded)
            Expanded(
              // height: 300,
              child: ListView(
                children: widget.orderItem['products']
                    .map<Widget>((prod) => Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Text(
                        prod['product']['productName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${prod['quantity']}x ₹${prod['product']['price']}",
                        style:
                        TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                  ],
                ),
                    ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
