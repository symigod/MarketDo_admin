import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/screens/vendors/orders.vendor.dart';
import 'package:marketdo_admin/screens/vendors/products.vendor.dart';
import 'package:marketdo_admin/widgets/dialogs.dart';
import 'package:marketdo_admin/widgets/snapshots.dart';
import 'package:marketdo_admin/firebase.services.dart';

class VendorsTable extends StatefulWidget {
  final bool? isApproved;
  const VendorsTable({this.isApproved, Key? key}) : super(key: key);

  @override
  State<VendorsTable> createState() => _VendorsTableState();
}

class _VendorsTableState extends State<VendorsTable> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: vendorsCollection
          .where('isApproved', isEqualTo: widget.isApproved)
          .snapshots(),
      builder: (context, vs) {
        if (vs.hasError) {
          return errorWidget(vs.error.toString());
        }
        if (vs.connectionState == ConnectionState.waiting) {
          return loadingWidget();
        }
        if (vs.data!.docs.isNotEmpty) {
          final List<DataRow> rows = vs.data!.docs.map((document) {
            final Map<String, dynamic> data = document.data();
            return DataRow(cells: [
              DataCell(Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: data['isOnline'] ? Colors.green : Colors.grey,
                          width: 2)),
                  child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                              imageUrl: data['logo'], fit: BoxFit.cover))))),
              DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data['businessName'], softWrap: true))),
              DataCell(
                  Text('${data['mobile']}\n${data['email']}', softWrap: true)),
              DataCell(Text('${data['address']}\n(${data['landMark']})',
                  softWrap: true)),
              DataCell(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    data['isApproved'] == true
                        ? ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.green.shade900)),
                            child: const Icon(Icons.check, color: Colors.white),
                            onPressed: () => vendorsCollection
                                .doc(data['vendorID'])
                                .update({'isApproved': false}).then((_) =>
                                    Fluttertoast.showToast(
                                        msg:
                                            '${data['businessName']} ${data['isApproved'] == true ? 'unapproved!' : 'approved!'}',
                                        timeInSecForIosWeb: 3,
                                        webBgColor:
                                            '${data['isApproved'] == true ? 'rgb(183, 28, 28)' : 'rgb(27, 94, 32)'} ',
                                        webPosition: 'center')))
                        : ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.red.shade900)),
                            child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.close, color: Colors.white)),
                            onPressed: () => vendorsCollection.doc(data['vendorID']).update({'isApproved': true}).then((_) => Fluttertoast.showToast(msg: '${data['businessName']} ${data['isApproved'] == true ? 'unapproved!' : 'approved!'}', webBgColor: '${data['isApproved'] == true ? 'rgb(183, 28, 28)' : 'rgb(27, 94, 32)'} ', webPosition: 'center'))),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.teal)),
                        onPressed: () =>
                            viewVendorDetails(context, data['vendorID']),
                        child:
                            const Icon(Icons.visibility, color: Colors.white)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.blue.shade900)),
                        onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                VendorProducts(vendorID: data['vendorID'])),
                        child: const Icon(Icons.store, color: Colors.white)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.orange)),
                        onPressed: () => showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                VendorOrders(vendorID: data['vendorID'])),
                        child:
                            const Icon(Icons.shopping_bag, color: Colors.white))
                  ]))
            ]);
          }).toList();
          return DataTable(
              border: TableBorder.all(width: 0.5),
              headingRowColor:
                  MaterialStateProperty.resolveWith((states) => Colors.green),
              headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold),
              columns: [
                dataColumn('LOGO'),
                dataColumn('NAME'),
                dataColumn('CONTACTS'),
                dataColumn('ADDRESS'),
                dataColumn('ACTIONS')
              ],
              rows: rows);
        }
        return emptyWidget('NO RECORD FOUND');
      });

  viewVendorDetails(context, String vendorID) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StreamBuilder(
          stream: vendorsCollection
              .where('vendorID', isEqualTo: vendorID)
              .snapshots(),
          builder: (context, vs) {
            if (vs.hasError) {
              return errorWidget(vs.error.toString());
            }
            if (vs.connectionState == ConnectionState.waiting) {
              return loadingWidget();
            }
            if (vs.data!.docs.isNotEmpty) {
              var vendor = vs.data!.docs[0];
              return AlertDialog(
                  scrollable: true,
                  titlePadding: EdgeInsets.zero,
                  title: Card(
                      color: Colors.green,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5))),
                      child: ListTile(
                          title: const Text('Vendor Details',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          trailing: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.close,
                                      color: Colors.white))))),
                  contentPadding: EdgeInsets.zero,
                  content: SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: Column(children: [
                        SizedBox(
                            height: 150,
                            child: DrawerHeader(
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(20),
                                          height: 150,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(3),
                                                      topRight:
                                                          Radius.circular(3)),
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      vendor['shopImage']),
                                                  fit: BoxFit.cover))),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                                height: 120,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: vendor['isOnline']
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        width: 3)),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 3)),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(130),
                                                        child:
                                                            CachedNetworkImage(
                                                                imageUrl:
                                                                    vendor[
                                                                        'logo'],
                                                                fit: BoxFit
                                                                    .cover))))
                                          ])
                                    ]))),
                        ListTile(
                            isThreeLine: true,
                            leading: const Icon(Icons.store),
                            title: Text(vendor['businessName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle:
                                Text('Vendor ID:\n${vendor['vendorID']}')),
                        ListTile(
                            leading: const Icon(Icons.perm_phone_msg),
                            title: Text(vendor['mobile']),
                            subtitle: Text(vendor['email'])),
                        ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(vendor['address']),
                            subtitle: Text(vendor['landMark'])),
                        ListTile(
                            leading: const Icon(Icons.date_range),
                            title: const Text('REGISTERED ON:'),
                            subtitle:
                                Text(dateTimeToString(vendor['registeredOn'])))
                      ])));
            }
            return emptyWidget('CUSTOMER NOT FOUND');
          }));
}
