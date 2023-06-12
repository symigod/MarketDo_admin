import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketdo_admin/widgets/api_widgets.dart';

class VendorProducts extends StatefulWidget {
  final String vendorID;
  const VendorProducts({super.key, required this.vendorID});

  @override
  State<VendorProducts> createState() => _VendorProductsState();
}

class _VendorProductsState extends State<VendorProducts> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('vendorID', isEqualTo: widget.vendorID)
          .snapshots(),
      builder: (context, vps) {
        if (vps.hasError) {
          return errorWidget(vps.error.toString());
        }
        if (vps.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (vps.hasData) {
          final List<DocumentSnapshot> product = vps.data!.docs;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: product.length,
              itemBuilder: (context, index) => AlertDialog(
                      titlePadding: const EdgeInsets.all(5),
                      title: Container(
                          padding: const EdgeInsets.all(20),
                          height: 200,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                      '${product[index]['shopImage']}'),
                                  fit: BoxFit.cover))),
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                    leading: const Icon(Icons.store),
                                    title: Text(product[index]['businessName']),
                                    subtitle: Text(product[index]['vendorID'])),
                                ListTile(
                                    leading: const Icon(Icons.comment),
                                    title: Text(product[index]['email']),
                                    subtitle: Text(product[index]['mobile'])),
                                ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(product[index]['address']),
                                    subtitle: Text(product[index]['landMark'])),
                                ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(
                                        'TAX REGISTERED: ${product[index]['isTaxRegistered'] == true ? 'YES' : 'NO'}'),
                                    subtitle: Text(
                                        'PIN CODE: ${product[index]['pinCode']}')),
                                ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: const Text('REGISTERED ON:'),
                                    subtitle:
                                        Text('TIN: ${product[index]['tin']}')),
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
