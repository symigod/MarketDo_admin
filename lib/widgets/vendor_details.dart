import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/widgets/stream_widgets.dart';

class VendorDetailsCard extends StatefulWidget {
  final String vendorID;
  const VendorDetailsCard({super.key, required this.vendorID});

  @override
  State<VendorDetailsCard> createState() => _VendorDetailsCardState();
}

class _VendorDetailsCardState extends State<VendorDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('vendor')
            .where('vendorID', isEqualTo: widget.vendorID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return streamErrorWidget(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return streamLoadingWidget();
          }
          if (snapshot.hasData) {
            final List<DocumentSnapshot> vendor = snapshot.data!.docs;
            return ListView.builder(
                shrinkWrap: true,
                itemCount: vendor.length,
                itemBuilder: (context, index) {
                  return AlertDialog(
                      title: Text(vendor[index]['businessName']),
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Stack(alignment: Alignment.center, children: [
                                  Container(
                                      padding: const EdgeInsets.all(20),
                                      height: 125,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  '${vendor[index]['shopImage']}'),
                                              fit: BoxFit.cover))),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 3),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        '${vendor[index]['logo']}'),
                                                    fit: BoxFit.cover)))
                                      ])
                                ]),
                                const Divider(color: Colors.black12),
                                Text('CITY: ${vendor[index]['city']}'),
                                const Divider(color: Colors.black12),
                                Text('STATE: ${vendor[index]['state']}'),
                                const Divider(color: Colors.black12),
                                Text('COUNTRY: ${vendor[index]['country']}'),
                                const Divider(color: Colors.black12),
                                Text('EMAIL: ${vendor[index]['email']}'),
                                const Divider(color: Colors.black12),
                                Text('LANDMARK: ${vendor[index]['landMark']}'),
                                const Divider(color: Colors.black12),
                                Text('MOBILE: ${vendor[index]['mobile']}'),
                                const Divider(color: Colors.black12),
                                Text('PIN CODE: ${vendor[index]['pinCode']}'),
                                const Divider(color: Colors.black12),
                                Text(
                                    'TAX REGISTERED: ${vendor[index]['isTaxRegistered'] == true ? 'YES' : 'NO'}'),
                                const Divider(color: Colors.black12),
                                Text('TIN: ${vendor[index]['tin']}')
                              ]))),
                      actions: [
                        ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Close'),
                            ))
                      ]);
                });
          }
          return streamEmptyWidget('VENDOR NOT FOUND');
        });
  }
}
