import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/firebase.services.dart';

class CustomerDetailsCard extends StatefulWidget {
  final String customerID;
  const CustomerDetailsCard({super.key, required this.customerID});

  @override
  State<CustomerDetailsCard> createState() => _CustomerDetailsCardState();
}

class _CustomerDetailsCardState extends State<CustomerDetailsCard> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: customersCollection
          .where('customerID', isEqualTo: widget.customerID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorWidget(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (snapshot.hasData) {
          final List<DocumentSnapshot> vendor = snapshot.data!.docs;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: vendor.length,
              itemBuilder: (context, index) => AlertDialog(
                      titlePadding: const EdgeInsets.all(5),
                      title: Stack(alignment: Alignment.center, children: [
                        Container(
                            padding: const EdgeInsets.all(20),
                            height: 200,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        '${vendor[index]['coverPhoto']}'),
                                    fit: BoxFit.cover))),
                        Container(
                            height: 175,
                            width: 175,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        '${vendor[index]['logo']}'),
                                    fit: BoxFit.cover)))
                      ]),
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                    leading: const Icon(Icons.store),
                                    title: Text(vendor[index]['name']),
                                    subtitle: Text(vendor[index]['customerID'])),
                                ListTile(
                                    leading: const Icon(Icons.perm_phone_msg),
                                    title: Text(vendor[index]['email']),
                                    subtitle: Text(vendor[index]['mobile'])),
                                ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(vendor[index]['address']),
                                    subtitle: Text(vendor[index]['landMark'])),
                                ListTile(
                                    leading: const Icon(Icons.date_range),
                                    title: const Text('REGISTERED ON:'),
                                    subtitle: Text(dateTimeToString(
                                        vendor[index]['registeredOn']))),
                              ])),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('Close')))
                      ]));
        }
        return emptyWidget('CUSTOMER NOT FOUND');
      });
}
