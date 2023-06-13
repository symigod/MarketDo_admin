import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/firebase.services.dart';

class VendorDetailsCard extends StatefulWidget {
  final String vendorID;
  const VendorDetailsCard({super.key, required this.vendorID});

  @override
  State<VendorDetailsCard> createState() => _VendorDetailsCardState();
}

class _VendorDetailsCardState extends State<VendorDetailsCard> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: vendorsCollection
          .where('vendorID', isEqualTo: widget.vendorID)
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
                                        '${vendor[index]['shopImage']}'),
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
                                    title: Text(vendor[index]['businessName']),
                                    subtitle: Text(vendor[index]['vendorID'])),
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
        return emptyWidget('VENDOR NOT FOUND');
      });
}
