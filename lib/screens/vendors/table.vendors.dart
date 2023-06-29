import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marketdo_admin/screens/vendors/card.vendor.dart';
import 'package:marketdo_admin/screens/vendors/products.vendor.dart';
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
                          color: data['isOnline'] ? Colors.green : Colors.red,
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
              DataCell(Text('${data['mobile']}\n${data['email']}', softWrap: true)),
              DataCell(Text('${data['address']}\n(${data['landMark']})', softWrap: true)),
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
                            child: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => vendorsCollection.doc(data['vendorID']).update({'isApproved': true}).then((_) => Fluttertoast.showToast(msg: '${data['businessName']} ${data['isApproved'] == true ? 'unapproved!' : 'approved!'}', webBgColor: '${data['isApproved'] == true ? 'rgb(183, 28, 28)' : 'rgb(27, 94, 32)'} ', webPosition: 'center'))),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.teal)),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) =>
                                VendorDetailsCard(vendorID: data['vendorID'])),
                        child:
                            const Icon(Icons.visibility, color: Colors.white)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.blue.shade900)),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) =>
                                VendorProducts(vendorID: data['vendorID'])),
                        child: const Icon(Icons.store, color: Colors.white))
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
              columns: const [
                DataColumn(label: Text('LOGO')),
                DataColumn(label: Text('NAME')),
                DataColumn(label: Text('CONTACTS')),
                DataColumn(label: Text('ADDRESS')),
                DataColumn(label: Text('ACTIONS'))
              ],
              rows: rows);
        }
        return emptyWidget('NO RECORD FOUND');
      });
}